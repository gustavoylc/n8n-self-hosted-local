## | [English](README.en.md) | [Español](README.md) |

# Configuración Avanzada de n8n Autoalojado

Esta configuración utiliza Docker Compose para desplegar una instancia de n8n robusta y escalable, con funcionalidades de IA y herramientas adicionales para una gestión completa.

## Descripción General

Este stack de Docker Compose está diseñado para proporcionar una solución de autoalojado de n8n "con todo incluido". Incluye:

- **n8n en modo cola (`queue`)**: Para un alto rendimiento y escalabilidad, con un servicio principal y un trabajador.
- **Base de datos PostgreSQL**: Como base de datos persistente para n8n.
- **Redis**: Para la gestión de colas de n8n.
- **Nginx Proxy Manager**: Para gestionar fácilmente los proxies inversos y los certificados SSL.
- **Cloudflare Tunnel**: Para exponer de forma segura los servicios a Internet sin abrir puertos.
- **Ollama y Qdrant**: Para ejecutar modelos de lenguaje grandes (LLMs) localmente y dar soporte a las funcionalidades de IA de n8n.
- **Scripts de Importación/Exportación**: Para hacer copias de seguridad y restaurar flujos de trabajo y credenciales automáticamente.

## Estructura del Directorio

```
advanced/
├── docker-compose.yml     # El archivo principal de Docker Compose.
├── init-data.sh           # Script de inicialización para la base de datos.
├── n8n/
│   ├── backup/            # Directorio para las copias de seguridad.
│   │   ├── credentials/
│   │   └── workflows/
│   └── import/            # Directorio para importar datos.
│       ├── credentials/
│       └── workflows/
└── README.md              # Este archivo.
```

## Prerrequisitos

- Docker instalado.
- Una cuenta de Cloudflare y un token de túnel.

## Puesta en Marcha

1.  **Clonar el repositorio** (si aún no lo has hecho).

2.  **Navegar al directorio `advanced`**:

    ```bash
    cd advanced
    ```

3.  **Crear el archivo de entorno (`.env`)**:
    Crea un archivo llamado `.env` en este directorio y pega el siguiente contenido. Asegúrate de reemplazar los valores con tu propia configuración.

    ```dotenv
    # -----------------------------------------------------------------------------
    # General Settings
    # -----------------------------------------------------------------------------
    # Timezone for the services
    TZ=Europe/Berlin

    # The public URL of your n8n instance
    URL=n8n.example.com

    # -----------------------------------------------------------------------------
    # Cloudflare Tunnel
    #
    # 1. Create a tunnel in your Cloudflare dashboard.
    # 2. Get the token for it.
    # 3. Paste the token here.
    # -----------------------------------------------------------------------------
    CLOUDFLARED_TUNNEL_TOKEN=

    # -----------------------------------------------------------------------------
    # PostgreSQL Database
    #
    # Credentials for the PostgreSQL database.
    # The init-data.sh script will create a non-root user for n8n to use.
    # -----------------------------------------------------------------------------
    POSTGRES_USER=postgres
    POSTGRES_PASSWORD=postgres
    POSTGRES_DB=n8n
    POSTGRES_NON_ROOT_USER=n8n_user
    POSTGRES_NON_ROOT_PASSWORD=supersecretpassword

    # -----------------------------------------------------------------------------
    # n8n Specific Settings
    #
    # These are crucial for securing your n8n instance.
    # Generate strong, random secrets for these keys.
    # You can use 'openssl rand -hex 32' to generate them.
    # -----------------------------------------------------------------------------
    N8N_ENCRYPTION_KEY=
    N8N_USER_MANAGEMENT_JWT_SECRET=

    # -----------------------------------------------------------------------------
    # Import / Export on Startup
    #
    # Set these to 'true' to run the import/export services when you start the stack.
    # This is useful for initial setup or for creating backups.
    # It's recommended to set them back to 'false' after the initial run.
    # -----------------------------------------------------------------------------
    RUN_IMPORT_ON_STARTUP=false
    RUN_BACKUP_ON_STARTUP=false
    ```

    **Importante**: Necesitarás generar claves seguras para `N8N_ENCRYPTION_KEY` y `N8N_USER_MANAGEMENT_JWT_SECRET`. Puedes usar `openssl rand -hex 32` en tu terminal para generar cada una.

4.  **Iniciar los servicios**:
    ```bash
    docker-compose up -d
    ```

## Servicios

Aquí hay un desglose de cada servicio en `docker-compose.yml`:

- `nginx-proxy-manager`: Interfaz de usuario para la gestión de proxy inverso. Accesible en `http://<tu_ip>:81`.
- `cloudflared`: Crea un túnel seguro a la red de Cloudflare.
- `postgres`: La base de datos de PostgreSQL para n8n.
- `redis`: Almacén en memoria utilizado por n8n para la gestión de colas.
- `qdrant`: Motor de búsqueda de vectores para las funciones de IA de n8n.
- `ollama`: Permite ejecutar LLMs localmente.
- `init-ollama`: Un servicio de un solo uso que descarga un modelo de LLM (por defecto `llama3.2`) al iniciar.
- `n8n`: El servicio principal de la aplicación n8n.
- `n8n-worker`: Un trabajador que procesa las ejecuciones de los flujos de trabajo.
- `n8n-import`: Servicio para importar credenciales y flujos de trabajo al iniciar.
- `n8n-export`: Servicio para exportar credenciales y flujos de trabajo al iniciar.

## Configuración

Las variables de entorno se gestionan en el archivo `.env`. Las más importantes son:

- `URL`: El nombre de dominio público para tu instancia de n8n (ej. `n8n.example.com`).
- `TZ`: Tu zona horaria (ej. `America/Mexico_City`).
- `CLOUDFLARED_TUNNEL_TOKEN`: Tu token de túnel de Cloudflare.
- `POSTGRES_*`: Credenciales para la base de datos PostgreSQL.
- `N8N_ENCRYPTION_KEY`: Clave de cifrado para las credenciales de n8n.
- `N8N_USER_MANAGEMENT_JWT_SECRET`: Secreto JWT para la gestión de usuarios.
- `RUN_IMPORT_ON_STARTUP`: Ponlo en `true` para importar datos desde el directorio `n8n/import` al iniciar.
- `RUN_BACKUP_ON_STARTUP`: Ponlo en `true` para hacer una copia de seguridad de los datos en el directorio `n8n/backup` al iniciar.

## Uso

### Acceder a los servicios

- **n8n**: `https://<URL>`
- **Nginx Proxy Manager**: `http://<IP_del_servidor>:81`

### Importación y Exportación

- **Importar**: Coloca tus archivos de credenciales (`.json`) y flujos de trabajo (`.json`) en los directorios `n8n/import/credentials` y `n8n/import/workflows` respectivamente. Establece `RUN_IMPORT_ON_STARTUP=true` en tu `.env` y reinicia los servicios.
- **Exportar/Backup**: Establece `RUN_BACKUP_ON_STARTUP=true` en tu `.env`. Al iniciar, los datos se exportarán a `n8n/backup`.

#### Manejo de Errores de Importación

El comando por defecto para el servicio `n8n-import` es básico. Si tienes muchos flujos de trabajo y necesitas un manejo de errores más robusto, puedes usar el script `import-loop.sh` proporcionado. Este script intenta importar los flujos de trabajo uno por uno. Si un flujo de trabajo falla (debido a un JSON inválido o un error de importación), se mueve al directorio `n8n/import/workflows/with_error`, y el proceso continúa con el siguiente archivo.

Para usarlo, modifica el servicio `n8n-import` en tu archivo `docker-compose.yml`:

```yaml
# ... (dentro del servicio n8n-import)
volumes:
  - ./n8n/import:/import
  - n8n_storage:/home/node/.n8n
  - ./import-loop.sh:/scripts/import-loop.sh:ro # Descomenta esta línea
# ...
# command:
#   - "-c"
#   - |
#     if [ "${RUN_IMPORT_ON_STARTUP:-false}" = "true" ]; then
#       ...
#     fi
command: ["/scripts/import-loop.sh"] # Reemplaza el comando anterior con esto
# ...
```

### IA Local con Ollama

El servicio `ollama` te permite usar modelos de lenguaje grandes sin depender de APIs externas. El servicio `init-ollama` descargará `llama3.2` por defecto. Puedes cambiar el modelo en el `docker-compose.yml`.

Para usar Ollama con tu hardware, puede que necesites ajustar la configuración del servicio `ollama` en `docker-compose.yml`:

- **Para CPU**:
  Asegúrate de que la `image` sea `ollama/ollama:latest` y de que no haya secciones `deploy` o `devices` para GPU en la definición del servicio.

- **Para GPU NVIDIA**:
  Descomenta o añade la sección `deploy` al servicio `ollama`. Debes tener los drivers de tu GPU instalados en la máquina anfitriona.

  ```yaml
  # ... (dentro del servicio ollama)
  image: ollama/ollama:latest
  deploy:
    resources:
      reservations:
        devices:
          - driver: nvidia
            count: all
            capabilities: [gpu]
  ```

- **Para GPU AMD (en Linux)**:
  Cambia la `image` a `ollama/ollama:rocm` y descomenta o añade la sección `devices`.
  ```yaml
  # ... (dentro del servicio ollama)
  image: ollama/ollama:rocm
  devices:
    - "/dev/kfd"
    - "/dev/dri"
  ```
