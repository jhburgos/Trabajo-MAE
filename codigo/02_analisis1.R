library(dplyr)
library(ggplot2)
library(stargazer)

# --- Carpeta del proyecto -------------------------------------------------------
# Fija como directorio de trabajo la carpeta Trabajo-MAE para que las rutas funcionen.
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

output <- "output"

# --- 1. Cargar la base limpia -------------------------------------------------
# Lee el archivo que se generó en el script 01_limpieza_una_linea.R
paso3 <- readRDS(file.path(output, "lic_2025-12_una_linea.rds"))

# --- 2. Limpieza de casos pendientes (Bitácora) -------------------------------
# Excluir los casos absurdos en pesos y las licitaciones en UF dudosas[cite: 4, 5]
casos_excluir <- c("4044-43-LE25", "620304-8-LE25", "2180-24-LP25", "591-41-LR25")
paso4 <- paso3 %>% filter(!CodigoExterno %in% casos_excluir)

# --- 3. Creación de Variables Clave -------------------------------------------
paso4 <- paso4 %>%
  mutate(
    # Razón original
    razon_original = MontoLineaAdjudica / MontoEstimado,
    
    # Corrección del problema del IVA (Razón exacta de 0.84 = 1/1.19)
    MontoAdjudicado_Ajustado = if_else(round(razon_original, 2) == 0.84, 
                                       MontoLineaAdjudica * 1.19, 
                                       MontoLineaAdjudica),
    razon_ajustada = MontoAdjudicado_Ajustado / MontoEstimado,
    
    # Variable dependiente Y
    Y_log_razon = log(razon_ajustada),
    
    # Variables independientes (N oferentes)
    log_N = log(NumeroOferentes),
    N_dummies = case_when(
      NumeroOferentes == 1 ~ "1",
      NumeroOferentes == 2 ~ "2",
      NumeroOferentes == 3 ~ "3",
      NumeroOferentes == 4 ~ "4",
      NumeroOferentes >= 5 ~ "5_o_mas"
    ),
    N_dummies = factor(N_dummies, levels = c("1", "2", "3", "4", "5_o_mas"))
  ) %>%
  # Identificar y filtrar contratos de suministro (razones cercanas a 0) y valores extremos
  filter(razon_ajustada > 0.01 & razon_ajustada < 5)

# --- 4. Estadísticas Descriptivas ---------------------------------------------
# Gráfico: Relación entre N y log(razón adjudicado/estimado)
grafico_descriptivo <- ggplot(paso4, aes(x = factor(NumeroOferentes), y = Y_log_razon)) +
  geom_boxplot(fill = "#F05032") + 
  labs(x = "Número de Oferentes", y = "Log(Monto Adjudicado / Estimado)",
       title = "Distribución de la Razón de Adjudicación por N° de Oferentes") +
  theme_minimal()
ggsave(file.path(output, "grafico_oferentes_vs_razon.pdf"), grafico_descriptivo)

# --- 5. Primera Estimación MCO ------------------------------------------------
# Regresión con interacción entre log_N y VisibilidadMonto, controlando por TipoLicitacion
modelo_mco <- lm(Y_log_razon ~ log_N * VisibilidadMonto + factor(TipoLicitacion), data = paso4)

# Exportar resultados de la regresión a formato LaTeX (.tex)
stargazer(modelo_mco, type = "latex", 
          title = "Resultados Primera Estimación MCO",
          out = file.path(output, "tabla_mco.tex"))
