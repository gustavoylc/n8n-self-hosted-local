# n8n Self-Hosted Local with Cloudflare Tunnel

This project provides a basic setup to self-host [n8n](https://n8n.io/) locally and expose it to the internet securely using [Cloudflare Tunnel](https://www.cloudflare.com/products/tunnel/) and [Nginx Proxy Manager](https://nginxproxymanager.com/).

## Features

- **n8n:** Free and source-available workflow automation tool.
- **Nginx Proxy Manager:** Easy-to-use interface for managing proxy hosts and SSL certificates.
- **Cloudflare Tunnel:** Securely expose your local server to the internet without opening public inbound ports.

## Prerequisites

Before you begin, ensure you have the following installed:

- [Docker](https://docs.docker.com/get-docker/)
- [Docker Compose](https://docs.docker.com/compose/install/)

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

1.  **Configure Cloudflare SSL:**

    - In your Cloudflare dashboard, select your domain.
    - Go to **SSL/TLS** > **Origin Server**.
    - Click **Create Certificate**.
    - Keep the default settings and click **Create**.
    - Copy the **Origin Certificate** and **Private Key**. You will need them in the next steps.
    - After creating the certificate, go to the **Overview** tab of SSL/TLS and set the encryption mode to **Full (Strict)**.

2.  **Configure Nginx Proxy Manager:**

    - Open your browser and navigate to `http://localhost:81`.
    - Default Admin User:
      - Email: `admin@example.com`
      - Password: `changeme`
    - You will be prompted to change your login details upon first login.
    - Go to the **SSL Certificates** tab and click **Add SSL Certificate** > **Custom**.
    - Paste the **Origin Certificate** from Cloudflare into the `Certificate Key` field.
    - Paste the **Private Key** from Cloudflare into the `Private Key` field.
    - Save the certificate.
    - Add a new proxy host:
      - **Domain Name:** The `URL` you set in your `.env` file (e.g., `n8n.yourdomain.com`).
      - **Scheme:** `http`
      - **Forward Hostname / IP:** `n8n` (the name of the n8n service in `docker-compose.yml`).
      - **Forward Port:** `5678` (the default n8n port).
      - Enable `Websockets Support`.
    - Go to the `SSL` tab, select your custom Cloudflare certificate from the dropdown.

3.  **Access n8n:**
    Once Nginx Proxy Manager and your Cloudflare Tunnel are configured, you can access your n8n instance at the `URL` you defined (e.g., `https://n8n.yourdomain.com`).

## Contributing

Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
