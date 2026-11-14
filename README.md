# Guía Básica: Uso de GitHub y Conexión con RStudio

Este repositorio contiene una guía rápida para entender los conceptos básicos de GitHub y cómo integrar tus repositorios directamente con RStudio para el control de versiones en tus proyectos de análisis de datos.

## 1. Conceptos Básicos de GitHub

GitHub es una plataforma de alojamiento de código en la nube que utiliza el sistema de control de versiones Git. Te permite mantener un historial de tus archivos y colaborar con otros.

### Términos Clave
* **Repositorio (Repo):** El directorio o carpeta principal donde se almacena tu proyecto y su historial de cambios.
* **Commit:** Un registro de los cambios realizados en los archivos. Funciona como un "punto de guardado" acompañado de un mensaje descriptivo.
* **Push:** Enviar tus *commits* locales al repositorio remoto en GitHub.
* **Pull:** Traer los cambios más recientes del repositorio remoto en GitHub a tu computadora local.
* **Branch (Rama):** Una línea de desarrollo paralela donde puedes hacer pruebas o cambios sin alterar la versión principal del proyecto (la rama `main`).

---

## 2. Requisitos Previos

Antes de conectar RStudio con GitHub, asegúrate de tener instalados y configurados los siguientes elementos:

1. Una cuenta activa en [GitHub](https://github.com/).
2. [Git](https://git-scm.com/downloads) instalado en tu computadora.
3. [R y RStudio](https://posit.co/download/rstudio-desktop/) instalados.

---

## 3. Configuración de Git y Generación de Token

GitHub requiere un Token de Acceso Personal (PAT, por sus siglas en inglés) en lugar de una contraseña estándar para conectar aplicaciones externas como RStudio.

### Paso 1: Configurar tu identidad en Git
Abre la pestaña **Terminal** (junto a la consola) en RStudio y ejecuta estos comandos con tus datos:

```bash
git config --global user.name "Tu Nombre"
git config --global user.email "tu_correo@ejemplo.com"
```

### Paso 2: Crear el Token en GitHub
1. Inicia sesión en GitHub y ve a **Settings** (Configuración de tu perfil).
2. En el menú lateral izquierdo, baja hasta el final y haz clic en **Developer settings**.
3. Selecciona **Personal access tokens** > **Tokens (classic)**.
4. Haz clic en **Generate new token (classic)**.
5. Asigna un nombre (ej. `RStudio`), define un tiempo de expiración (ej. 90 días) y **marca la casilla `repo`** para dar permisos sobre tus repositorios.
6. Haz clic en generar y **copia el token inmediatamente** (no volverá a mostrarse).

---

## 4. Conectar GitHub a RStudio

### Metodo para el trabajo.
Vallan a arriba a la derecha en "new proyect" y apretan version control, en ese lugar le van a pedir la url del archivo es decir del github https://github.com/jhburgos/Trabajo-MAE, y listo ya estarian anclado al github, 

### Ahora para subir los codigos y etc
Tienen que apretar el codigo en files les va a aparecer todo los archivos del trabajo, apretan el codigo a modificar y en el codigo pueden editarlo y desp subirlos con ctrl+s (guardado) y desp apretan en la parte de environment les va a aparecer el git apretan ahi, 
van a commit ahi en la caja de commit message dejan algo como cambio o utilizar el anterior, apretan commit denuevo que estara debajo posteriormente pull y desp push pa subirlo

> **Nota:** La primera vez que hagas Push/Pull, RStudio te pedirá credenciales. Tu usuario es tu nombre de usuario de GitHub y la contraseña es el Token que generaste en el paso anterior.



---

## 5. El Flujo de Trabajo Diario en RStudio

Una vez que tu proyecto está conectado, aparecerá una nueva pestaña llamada **Git** en el panel superior derecho de RStudio (donde está el Environment). Sigue este orden cada vez que trabajes:

1. **Pull (Flecha azul hacia abajo):** Haz clic siempre aquí al iniciar tu sesión de trabajo para asegurarte de tener la última versión del código.
2. **Stage (Casillas de verificación):** En la pestaña Git, marca las casillas bajo la columna *Status* correspondientes a los archivos que modificaste y deseas guardar.
3. **Commit:** Haz clic en el botón **Commit**. Se abrirá una ventana nueva. Escribe un resumen de tus cambios en la caja *Commit message* y haz clic en el botón *Commit*.
4. **Push (Flecha verde hacia arriba):** Haz clic en *Push* para subir permanentemente tus cambios locales al repositorio remoto en GitHub.

---

## 6. Cómo usar el código del trabajo en RStudio

### Estructura de carpetas

```
Trabajo-MAE/
├── Trabajo-MAE.Rproj               <- abrir este archivo en RStudio
├── input/                          <- ENTRADA: datos originales (no se modifican)
│   └── 2025-12.zip                    (contiene lic_2025-12.csv, ChileCompra diciembre 2025)
├── codigo/
│   └── 01_limpieza_una_linea.R     <- script de limpieza
└── output/                         <- SALIDA: todo lo que genera el código
    ├── lic_2025-12_una_linea.rds      (base limpia, se genera al correr el código)
    ├── lic_2025-12_una_linea.csv      (base limpia en CSV, se genera al correr el código)
    ├── resumen_filtros.csv            (cuántas licitaciones quedan en cada filtro)
    └── bitacora.pdf / bitacora.tex    (registro de todo lo que se le ha hecho a la base)
```

Las bases limpias (`.rds` y `.csv` de `output/`) **no se suben a GitHub** porque pesan mucho: cada uno las genera en su computador corriendo el código.

### Pasos para correr el código

1. **Traer la última versión:** en la pestaña *Git* de RStudio, apretar **Pull**.
2. **Instalar los paquetes necesarios** (solo la primera vez), en la consola:
   ```r
   install.packages(c("dplyr", "rstudioapi"))
   ```
3. **Abrir el proyecto:** *File > Open Project...* y elegir `Trabajo-MAE.Rproj`.
4. **Abrir el script:** en el panel *Files*, entrar a `codigo/` y abrir `01_limpieza_una_linea.R`.
5. **Correrlo:** apretar **Source** (arriba a la derecha del script) o `Ctrl + Shift + S`. Toma cerca de un minuto.
6. **Revisar:**
   - En la consola aparece la tabla de filtros (cuántas licitaciones quedan en cada paso).
   - Se abren dos tablas en RStudio: *Montos ANTES de convertir* y *Montos DESPUÉS de convertir* a pesos.
   - En `output/` quedan la base limpia y el resumen de filtros.
7. **Usar la base limpia** en otro script:
   ```r
   lic <- readRDS("output/lic_2025-12_una_linea.rds")
   ```

El script fija solo la carpeta del proyecto, así que funciona aunque se abra sin el `.Rproj`.

### Cómo cambiar las carpetas o el archivo de entrada

Al inicio del script, en la sección **Carpetas de datos**, están todas las rutas:

```r
input  <- "input"    # datos originales (no se modifican)
output <- "output"   # todo lo que genera el código
archivo_zip <- "2025-12.zip"       # zip dentro de input/
archivo_csv <- "lic_2025-12.csv"   # nombre del CSV dentro del zip
```

- **Otra base (por ejemplo, otro mes):** descargarla de [Datos Abiertos ChileCompra](https://datos-abiertos.chilecompra.cl/descargas/ordenes-y-licitaciones), dejar el `.zip` en `input/` y cambiar `archivo_zip` y `archivo_csv` por sus nombres.
- **Otras carpetas:** cambiar `input` u `output` por la ruta deseada (relativa a la carpeta del proyecto). La carpeta de salida se crea sola si no existe.

### Qué hace el código

1. Lee el CSV desde el zip y arregla tildes y montos (vienen como texto con coma decimal).
2. Deja solo las licitaciones de **una sola línea** y **adjudicadas**.
3. Convierte todos los montos a **pesos** con valores al 30 de diciembre de 2025: dólar 911,18; euro 1,175 dólares; Unidad de Fomento 39.727,96; Unidad Tributaria Mensual 69.542. La columna `moneda_original` indica la moneda en que venía cada licitación.
4. Corrige licitaciones cuyo monto estimado ya venía en pesos (lista `estimado_ya_en_pesos`).
5. Guarda la base limpia y el resumen en `output/`.

Todo cambio a la base queda registrado en `output/bitacora.pdf`, incluidos los casos raros que hay que consultar con el profesor.
