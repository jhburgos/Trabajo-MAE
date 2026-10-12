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

Tienes dos formas de vincular tus proyectos.

### Método 1: Clonar un repositorio desde GitHub a RStudio (Recomendado para empezar)
1. En GitHub, crea un nuevo repositorio.
2. En la página de tu nuevo repositorio, haz clic en el botón verde **Code** y copia la URL (termina en `.git`).
3. Abre RStudio y ve a **File** > **New Project...**
4. Selecciona **Version Control** > **Git**.
5. Pega la URL en *Repository URL*. RStudio rellenará automáticamente el nombre de la carpeta.
6. Elige dónde guardar el proyecto en tu computadora y haz clic en **Create Project**.

> **Nota:** La primera vez que hagas Push/Pull, RStudio te pedirá credenciales. Tu usuario es tu nombre de usuario de GitHub y la contraseña es el Token que generaste en el paso anterior.

### Método 2: Usar el paquete `usethis` para proyectos existentes
Si ya tienes un proyecto en RStudio y quieres subirlo a GitHub, abre la consola de R y ejecuta:

```R
# Instala los paquetes si no los tienes
install.packages(c("usethis", "gitcreds"))

library(usethis)

# Inicia Git en tu proyecto local
use_git() 

# Configura tu token de GitHub (pega el token cuando la consola te lo pida)
gitcreds::gitcreds_set()

# Sube el proyecto a GitHub
use_github()
```

---

## 5. El Flujo de Trabajo Diario en RStudio

Una vez que tu proyecto está conectado, aparecerá una nueva pestaña llamada **Git** en el panel superior derecho de RStudio (donde está el Environment). Sigue este orden cada vez que trabajes:

1. **Pull (Flecha azul hacia abajo):** Haz clic siempre aquí al iniciar tu sesión de trabajo para asegurarte de tener la última versión del código.
2. **Stage (Casillas de verificación):** En la pestaña Git, marca las casillas bajo la columna *Status* correspondientes a los archivos que modificaste y deseas guardar.
3. **Commit:** Haz clic en el botón **Commit**. Se abrirá una ventana nueva. Escribe un resumen de tus cambios en la caja *Commit message* y haz clic en el botón *Commit*.
4. **Push (Flecha verde hacia arriba):** Haz clic en *Push* para subir permanentemente tus cambios locales al repositorio remoto en GitHub.
