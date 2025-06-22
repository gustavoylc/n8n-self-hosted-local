# Advanced Self-Hosted n8n Setup

This setup uses Docker Compose to deploy a robust and scalable n8n instance, with AI features and additional tools for complete management.

## Overview

This Docker Compose stack is designed to provide an "all-inclusive" self-hosted n8n solution. It includes:

- **n8n in queue mode**: For high performance and scalability, with a main service and a worker.
- **PostgreSQL Database**: As a persistent database for n8n.
- **Redis**: For n8n's queue management.
- **Nginx Proxy Manager**: To easily manage reverse proxies and SSL certificates.
- **Cloudflare Tunnel**: To securely expose services to the internet without opening ports.
- **Ollama and Qdrant**: To run large language models (LLMs) locally and support n8n's AI features.
- **Import/Export Scripts**: To automatically back up and restore workflows and credentials.

## Directory Structure

```
advanced/
├── docker-compose.yml     # The main Docker Compose file.
├── init-data.sh           # Database initialization script.
├── import-loop.sh         # Advanced import script with error handling.
├── n8n/
│   ├── backup/            # Directory for backups.
│   │   ├── credentials/
│   │   └── workflows/
│   └── import/            # Directory for importing data.
│       ├── credentials/
│       └── workflows/
└── README.md              # This file.
```

## Prerequisites

- Docker installed.
- A Cloudflare account and tunnel token.

## Getting Started

For a detailed video tutorial on how to set up this advanced project, you can watch our guide on YouTube:
[![Advanced Setup Tutorial](https://img.youtube.com/vi/74AkNRf1MQQ/0.jpg)](https://youtu.be/74AkNRf1MQQ)

1.  **Clone the repository** (if you haven't already).

2.  **Navigate to the `advanced` directory**:

    ```bash
    cd advanced
    ```

3.  **Create the environment file (`.env`)**:
    Create a file named `.env` in this directory and paste the following content. Make sure to replace the values with your own settings.

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

    **Important**: You will need to generate secure keys for `N8N_ENCRYPTION_KEY` and `N8N_USER_MANAGEMENT_JWT_SECRET`. You can use `openssl rand -hex 32` in your terminal to generate each one.

4.  **Start the services**:
    ```bash
    docker-compose up -d
    ```

## Services

Here is a breakdown of each service in `docker-compose.yml`:

- `nginx-proxy-manager`: UI for reverse proxy management. Accessible at `http://<your_ip>:81`.
- `cloudflared`: Creates a secure tunnel to the Cloudflare network.
- `postgres`: The PostgreSQL database for n8n.
- `redis`: In-memory store used by n8n for queue management.
- `qdrant`: Vector search engine for n8n's AI features.
- `ollama`: Allows running LLMs locally.
- `init-ollama`: A one-time service that downloads an LLM model (default `llama3.2`) on startup.
- `n8n`: The main n8n application service.
- `n8n-worker`: A worker that processes workflow executions.
- `n8n-import`: Service to import credentials and workflows on startup.
- `n8n-export`: Service to export credentials and workflows on startup.

## Configuration

Environment variables are managed in the `.env` file. The most important are:

- `URL`: The public domain name for your n8n instance (e.g., `n8n.example.com`).
- `TZ`: Your timezone (e.g., `America/New_York`).
- `CLOUDFLARED_TUNNEL_TOKEN`: Your Cloudflare tunnel token.
- `POSTGRES_*`: Credentials for the PostgreSQL database.
- `N8N_ENCRYPTION_KEY`: Encryption key for n8n credentials.
- `N8N_USER_MANAGEMENT_JWT_SECRET`: JWT secret for user management.
- `RUN_IMPORT_ON_STARTUP`: Set to `true` to import data from the `n8n/import` directory on startup.
- `RUN_BACKUP_ON_STARTUP`: Set to `true` to back up data to the `n8n/backup` directory on startup.

## Usage

### Accessing Services

- **n8n**: `https://<URL>`
- **Nginx Proxy Manager**: `http://<server_ip>:81`

### Import and Export

- **Import**: Place your credential (`.json`) and workflow (`.json`) files in the `n8n/import/credentials` and `n8n/import/workflows` directories, respectively. Set `RUN_IMPORT_ON_STARTUP=true` in your `.env` file and restart the services.
- **Export/Backup**: Set `RUN_BACKUP_ON_STARTUP=true` in your `.env` file. On startup, data will be exported to `n8n/backup`.

#### Import Error Handling

The default command for the `n8n-import` service is basic. If you have many workflows and need more robust error handling, you can use the provided `import-loop.sh` script. This script attempts to import workflows one by one. If a workflow fails (due to invalid JSON or an import error), it is moved to the `n8n/import/workflows/with_error` directory, and the process continues with the next file.

To use it, modify the `n8n-import` service in your `docker-compose.yml` file:

```yaml
# ... (inside n8n-import service)
volumes:
  - ./n8n/import:/import
  - n8n_storage:/home/node/.n8n
  - ./import-loop.sh:/scripts/import-loop.sh:ro # Uncomment this line
# ...
# command:
#   - "-c"
#   - |
#     if [ "${RUN_IMPORT_ON_STARTUP:-false}" = "true" ]; then
#       ...
#     fi
command: ["/scripts/import-loop.sh"] # Replace the old command with this
# ...
```

### Local AI with Ollama

The `ollama` service allows you to use large language models without relying on external APIs. The `init-ollama` service will download `llama3.2` by default. You can change the model in the `docker-compose.yml`.

To use Ollama with your hardware, you may need to adjust the `ollama` service configuration in `docker-compose.yml`:

- **For CPU**:
  Ensure the `image` is `ollama/ollama:latest` and that there are no `deploy` or `devices` sections for GPU in the service definition.

- **For NVIDIA GPU**:
  Uncomment or add the `deploy` section to the `ollama` service. Your GPU drivers must be installed on the host machine.

  ```yaml
  # ... (inside ollama service)
  image: ollama/ollama:latest
  deploy:
    resources:
      reservations:
        devices:
          - driver: nvidia
            count: all
            capabilities: [gpu]
  ```

- **For AMD GPU (on Linux)**:
  Change the `image` to `ollama/ollama:rocm` and uncomment or add the `devices` section.
  ```yaml
  # ... (inside ollama service)
  image: ollama/ollama:rocm
  devices:
    - "/dev/kfd"
    - "/dev/dri"
  ```
