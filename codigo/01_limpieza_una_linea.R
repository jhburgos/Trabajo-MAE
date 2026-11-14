library(dplyr)

# --- Carpeta del proyecto -------------------------------------------------------
# Fija como directorio de trabajo la carpeta Trabajo-MAE (la que contiene
# codigo/), para que las rutas a input/ y output/ funcionen aunque no se abra el .Rproj.
ruta_source <- unlist(lapply(sys.frames(), function(f) f$ofile))
ruta_script <- if (length(ruta_source) > 0) {
  tail(ruta_source, 1)                                           # con source()
} else if (requireNamespace("rstudioapi", quietly = TRUE) &&
           rstudioapi::isAvailable()) {
  rstudioapi::getSourceEditorContext()$path                      # desde RStudio
} else {
  sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE)) # Rscript
}
if (length(ruta_script) == 1 && nzchar(ruta_script)) {
  setwd(dirname(dirname(normalizePath(ruta_script))))
}

# --- Carpetas de datos ----------------------------------------------------------
input  <- "input"    # datos originales (no se modifican)
output <- "output"   # todo lo que genera el código
archivo_zip <- "2025-12.zip"       # zip dentro de input/
archivo_csv <- "lic_2025-12.csv"   # nombre del CSV dentro del zip
dir.create(output, showWarnings = FALSE)
stopifnot(file.exists(file.path(input, archivo_zip)))

# --- Lectura -------------------------------------------------------------------
# Cada fila es una oferta de un proveedor a una línea (Codigoitem) de una
# licitación (CodigoExterno). El CSV viene separado por ";" y en latin1.
lic <- read.csv(
  unz(file.path(input, archivo_zip), archivo_csv),
  sep = ";", quote = "\"", dec = ".", check.names = FALSE,
  stringsAsFactors = FALSE, na.strings = c("NA", "")
)
lic <- lic %>% mutate(across(where(is.character),
                             ~ iconv(.x, from = "latin1", to = "UTF-8")))

# Montos y cantidades vienen como texto con coma decimal ("1,04e+08"): a número
montos <- c("MontoEstimado", "Cantidad", "Monto Estimado Adjudicado",
            "Cantidad Ofertada", "MontoUnitarioOferta", "Valor Total Ofertado",
            "CantidadAdjudicada", "MontoLineaAdjudica")
lic <- lic %>% mutate(across(all_of(montos), ~ as.numeric(gsub(",", ".", .x))))

# --- Número de líneas por licitación ------------------------------------------
lic <- lic %>%
  group_by(CodigoExterno) %>%
  mutate(n_lineas = n_distinct(Codigoitem)) %>%
  ungroup()

# --- Filtros -------------------------------------------------------------------
paso0 <- lic
paso1 <- paso0 %>% filter(n_lineas == 1)          # una sola línea
paso2 <- paso1 %>% filter(Estado == "Adjudicada") # adjudicadas
paso3 <- paso2 # todas las monedas se convierten a pesos

# --- Dólares, euros, Unidad de Fomento y Unidad Tributaria Mensual a pesos -------
# Valores al 30 de diciembre de 2025: dólar observado 911,18 pesos, euro 1,175
# dólares, Unidad de Fomento 39.727,96 pesos y Unidad Tributaria Mensual 69.542
# pesos. En las licitaciones en estas monedas, el monto estimado y las ofertas
# vienen en esa misma moneda (en UTM las ofertas dicen "Moneda revisar", pero
# los montos están en UTM; solo una oferta no seleccionada de 624-29-L125
# viene en pesos).
tipo_cambio_usd <- 911.18
tipo_cambio_eur <- 1.175 * tipo_cambio_usd   # pesos por euro
valor_uf        <- 39727.96                  # pesos por Unidad de Fomento
valor_utm       <- 69542                     # pesos por Unidad Tributaria Mensual
montos_pesos <- c("MontoEstimado", "Monto Estimado Adjudicado",
                  "MontoUnitarioOferta", "Valor Total Ofertado",
                  "MontoLineaAdjudica")

# Tabla ANTES de convertir (cada monto en su moneda original)
columnas_ver <- c("CodigoExterno", "Nombre", "CodigoMoneda", "Moneda de la Oferta",
                  "Oferta seleccionada", montos_pesos)
antes <- paso3[columnas_ver]
if (interactive()) View(antes, "Montos ANTES de convertir")

paso3 <- paso3 %>%
  mutate(moneda_original = CodigoMoneda,
         across(all_of(montos_pesos),
                ~ case_when(moneda_original == "USD" ~ .x * tipo_cambio_usd,
                            moneda_original == "EUR" ~ .x * tipo_cambio_eur,
                            moneda_original == "CLF" ~ .x * valor_uf,
                            moneda_original == "UTM" ~ .x * valor_utm,
                            TRUE ~ .x)),
         CodigoMoneda = "CLP")

# Licitaciones en otra moneda cuyo monto estimado (columna BI del Excel) ya
# viene en pesos: se deja sin convertir. Las ofertas y el monto adjudicado
# (columna DD) sí se convierten. Agregar aquí los códigos que se confirmen.
estimado_ya_en_pesos <- c("2295-156-LP25",   # fila 60940 del Excel
                          "218-42-LE25",     # fila 92374 del Excel
                          "4042-16-LE25")    # fila 58323 del Excel
paso3 <- paso3 %>%
  left_join(paso2 %>% distinct(CodigoExterno, MontoEstimado_original = MontoEstimado),
            by = "CodigoExterno") %>%
  mutate(MontoEstimado = if_else(CodigoExterno %in% estimado_ya_en_pesos,
                                 MontoEstimado_original, MontoEstimado)) %>%
  select(-MontoEstimado_original)

# Tabla DESPUÉS de convertir (todo en pesos)
despues <- paso3[c(columnas_ver, "moneda_original")]
if (interactive()) View(despues, "Montos DESPUÉS de convertir")

n_lic <- function(d) n_distinct(d$CodigoExterno)
resumen <- data.frame(
  paso = c("Base completa diciembre 2025",
           "Una sola línea",
           "Una sola línea y adjudicada",
           "Una sola línea, adjudicada, montos convertidos a pesos"),
  licitaciones = c(n_lic(paso0), n_lic(paso1), n_lic(paso2), n_lic(paso3)),
  filas        = c(nrow(paso0), nrow(paso1), nrow(paso2), nrow(paso3))
)
resumen$quedan_fuera <- c(NA, -diff(resumen$licitaciones))
print(resumen)

# Licitaciones de una sola línea que quedan fuera, por estado y por moneda
print(paso1 %>% distinct(CodigoExterno, Estado) %>% count(Estado))
print(paso2 %>% distinct(CodigoExterno, CodigoMoneda) %>% count(CodigoMoneda))

# --- Guardar -------------------------------------------------------------------
saveRDS(paso3, file.path(output, "lic_2025-12_una_linea.rds"))
write.csv2(paso3, file.path(output, "lic_2025-12_una_linea.csv"),
           row.names = FALSE, fileEncoding = "UTF-8")
write.csv2(resumen, file.path(output, "resumen_filtros.csv"),
           row.names = FALSE, fileEncoding = "UTF-8")
