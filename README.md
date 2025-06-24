# n8n Self-Hosted Local

## General Description

This repository provides Docker Compose configurations to self-host [n8n](https://n8n.io/) workflow automation tool locally with secure internet exposure. n8n is a free and source-available workflow automation tool that allows you to connect different services and APIs to automate repetitive tasks, data processing, and business workflows.

**Two configurations available:**

- **Basic Setup**: Simple installation for personal use with essential components
- **Advanced Setup**: Installation with AI features, database persistence, and backup tools

## Directory Structure

```
n8n-self-hosted-local/
├── basic/                    # Simple setup for personal use
│   └── docker-compose.yml   # Simple Docker Compose configuration
├── advanced/                 # Advanced setup with AI features
│   ├── docker-compose.yml   # Advanced Docker Compose configuration
│   ├── init-data.sh         # Database initialization script
│   ├── import-loop.sh       # Advanced import script with error handling
│   └── n8n/                 # n8n data directories
│       ├── backup/          # Directory for backups
│       │   ├── credentials/ # Backup credentials storage
│       │   └── workflows/   # Backup workflows storage
│       └── import/          # Directory for importing data
│           ├── credentials/ # Import credentials from here
│           └── workflows/   # Import workflows from here
├── .gitignore               # Git ignore file
├── LICENSE                  # MIT License
├── README.md               # This file (English)
└── README.es.md            # Spanish documentation
```

### Basic Setup Components:

- n8n workflow automation tool
- Nginx Proxy Manager for SSL and reverse proxy
- Cloudflare Tunnel for secure internet exposure

### Advanced Setup Components:

- n8n in queue mode (main service + worker)
- PostgreSQL database for persistence
- Redis for queue management
- Nginx Proxy Manager for SSL and reverse proxy
- Cloudflare Tunnel for secure internet exposure
- Ollama for local AI/LLM integration
- Qdrant vector database for AI features
- Automated import/export tools for backups

## Prerequisites

- [Docker](https://docs.docker.com/get-docker/) installed
- [Cloudflare](https://www.cloudflare.com/) account with a registered domain

## Getting Started

**Choose your setup and watch the corresponding video tutorial:**

### Basic Setup

**For simple installation and personal use:**

[![Basic Setup Tutorial](https://img.youtube.com/vi/GJid000lZsY/maxresdefault.jpg)](https://youtu.be/GJid000lZsY "n8n Basic Setup Tutorial")

**Navigate to:** `/basic` folder

### Advanced Setup

**For installation with AI features:**

[![Advanced Setup Tutorial](https://img.youtube.com/vi/FyXjwv_oZuc/maxresdefault.jpg)](https://youtu.be/FyXjwv_oZuc "n8n Advanced Setup Tutorial")

**Navigate to:** `/advanced` folder
