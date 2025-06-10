# n8n Self-Hosted Local

This project provides a basic setup to self-host [n8n](https://n8n.io/) locally and expose it to the internet securely using [Cloudflare Tunnel](https://www.cloudflare.com/products/tunnel/) and [Nginx Proxy Manager](https://nginxproxymanager.com/).

## Features

- **n8n:** Free and source-available workflow automation tool.
- **Nginx Proxy Manager:** Easy-to-use interface for managing proxy hosts and SSL certificates.
- **Cloudflare Tunnel:** Securely expose your local server to the internet without opening public inbound ports.

## Prerequisites

Before you begin, ensure you have the following installed:

- [Docker](https://docs.docker.com/get-docker/)

You will also need a [Cloudflare](https://www.cloudflare.com/) account and a registered domain.

## Setup

1.  **Clone the repository:**

    ```bash
    git clone https://github.com/your-username/n8n-self-hosted-local.git
    cd n8n-self-hosted-local
    ```

2.  **Create a `.env` file:**
    Navigate to the `basic` directory and create a `.env` file from the `docker-compose.yml` environment variables.

    ```bash
    cd basic
    ```

    Your `.env` file should look like this:

    ```env
    # .env
    TZ=Your/Timezone # e.g., Europe/Madrid
    URL=n8n.yourdomain.com
    CLOUDFLARED_TUNNEL_TOKEN=your_cloudflare_tunnel_token
    ```

    - `TZ`: Your local timezone (e.g., `America/New_York`, `Europe/London`).
    - `URL`: The public URL you want to use for your n8n instance. This should be a domain or subdomain you have configured in Cloudflare.
    - `CLOUDFLARED_TUNNEL_TOKEN`: Your Cloudflare Tunnel token. Follow the [Cloudflare Tunnel documentation](https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/install-and-setup/tunnel-guide/) to create a tunnel and get your token.

3.  **Start the services:**
    From the `basic` directory, run the following command to start all the services:
    ```bash
    docker-compose up -d
    ```

## Usage

For a detailed video tutorial on how to set up this project, you can watch our guide on YouTube:
[![Tutorial Setup](https://img.youtube.com/vi/GJid000lZsY/0.jpg)](https://youtu.be/GJid000lZsY)

1.  **Configure Cloudflare:**
2.  **Configure Nginx Proxy Manager:**    
    - Default Admin User:
      - Email: `admin@example.com`
      - Password: `changeme`    
3.  **Access n8n:**
    Once Nginx Proxy Manager and your Cloudflare Tunnel are configured, you can access your n8n instance at the `URL` you defined (e.g., `https://n8n.yourdomain.com`).

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
