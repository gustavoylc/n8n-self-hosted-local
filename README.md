# n8n Self-Hosted Local

This repository provides Docker Compose configurations to self-host [n8n](https://n8n.io/) workflow automation tool locally with secure internet exposure.

## What is n8n?

n8n is a free and source-available workflow automation tool that allows you to connect different services and APIs to automate repetitive tasks, data processing, and business workflows.

## Available Setups

This repository contains two different Docker Compose configurations to suit different needs:

### 📁 Basic Setup (`/basic`)

A simple and lightweight setup perfect for:

- Getting started with n8n
- Personal projects
- Small-scale automation

**Includes:**

- n8n workflow automation tool
- Nginx Proxy Manager for SSL and reverse proxy
- Cloudflare Tunnel for secure internet exposure

### 📁 Advanced Setup (`/advanced`)

A comprehensive and production-ready setup designed for:

- High performance and scalability
- AI-powered workflows
- Professional and enterprise use

**Includes:**

- n8n in queue mode (main service + worker)
- PostgreSQL database for persistence
- Redis for queue management
- Nginx Proxy Manager for SSL and reverse proxy
- Cloudflare Tunnel for secure internet exposure
- Ollama for local AI/LLM integration
- Qdrant vector database for AI features
- Automated import/export tools for backups

## Getting Started

1. Choose the setup that best fits your needs (basic or advanced)
2. Navigate to the respective folder
3. Follow the detailed instructions in each folder's README file

## Prerequisites

- [Docker](https://docs.docker.com/get-docker/) installed
- [Cloudflare](https://www.cloudflare.com/) account with a registered domain

## Security Features

Both setups include:

- **SSL certificates** managed automatically
- **Cloudflare Tunnel** for secure exposure without opening ports
- **Reverse proxy** configuration for enhanced security

## Support

For detailed setup instructions, troubleshooting, and configuration options, please refer to the README files in each respective folder:

- [Basic Setup Documentation](./basic/README.md)
- [Advanced Setup Documentation](./advanced/README.md)

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
