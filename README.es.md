# n8n Self-Hosted Local

## Descripción General

Este repositorio proporciona configuraciones de Docker Compose para alojar [n8n](https://n8n.io/) localmente con exposición segura a internet. n8n es una herramienta gratuita y de código abierto para automatización de flujos de trabajo que te permite conectar diferentes servicios y APIs para automatizar tareas repetitivas, procesamiento de datos y flujos de trabajo empresariales.

**Tres configuraciones disponibles:**

- **Configuración Básica**: Instalación simple para uso personal con componentes esenciales
- **Configuración Avanzada**: Instalación con funciones de IA, persistencia de base de datos y herramientas de respaldo
- **Configuración Avanzada con Evolution API**: Configuración avanzada mejorada con Evolution API v2.2.3 para integración con WhatsApp

## Estructura del Directorio

```
n8n-self-hosted-local/
├── basic/                           # Configuración simple para uso personal
│   └── docker-compose.yml          # Configuración simple de Docker Compose
├── advanced/                        # Configuración avanzada con funciones de IA
│   ├── docker-compose.yml          # Configuración avanzada de Docker Compose
│   ├── init-data.sh                # Script de inicialización de base de datos
│   ├── import-loop.sh              # Script avanzado de importación con manejo de errores
│   └── n8n/                        # Directorios de datos de n8n
│       ├── backup/                 # Directorio para respaldos
│       │   ├── credentials/        # Almacenamiento de respaldos de credenciales
│       │   └── workflows/          # Almacenamiento de respaldos de flujos de trabajo
│       └── import/                 # Directorio para importar datos
│           ├── credentials/        # Importar credenciales desde aquí
│           └── workflows/          # Importar flujos de trabajo desde aquí
├── advanced-with-evolution-api-v2.2.3/ # Configuración avanzada con Evolution API
│   ├── docker-compose.yml          # Docker Compose avanzado con Evolution API
│   ├── init-data.sh                # Script de inicialización de base de datos
│   └── import-loop.sh              # Script avanzado de importación con manejo de errores
├── .gitignore                       # Archivo Git ignore
├── LICENSE                          # Licencia MIT
├── README.md                       # Documentación en inglés
└── README.es.md                    # Este archivo (Español)
```

### Componentes de Configuración Básica:

- Herramienta de automatización de flujos de trabajo n8n
- Nginx Proxy Manager para SSL y proxy inverso
- Cloudflare Tunnel para exposición segura a internet

### Componentes de Configuración Avanzada:

- n8n en modo cola (servicio principal + worker)
- Base de datos PostgreSQL para persistencia
- Redis para gestión de colas
- Nginx Proxy Manager para SSL y proxy inverso
- Cloudflare Tunnel para exposición segura a internet
- Ollama para integración local de IA/LLM
- Base de datos vectorial Qdrant para funciones de IA
- Herramientas automatizadas de importación/exportación para respaldos

## Prerrequisitos

- [Docker](https://docs.docker.com/get-docker/) instalado
- Cuenta de [Cloudflare](https://www.cloudflare.com/) con un dominio registrado

## Puesta en Marcha

**Elige tu configuración y mira el tutorial en video correspondiente:**

### Configuración Básica

**Para instalación simple y uso personal:**

[![Tutorial Configuración Básica](https://img.youtube.com/vi/GJid000lZsY/maxresdefault.jpg)](https://youtu.be/GJid000lZsY "Tutorial Configuración Básica n8n")

**Navega a:** carpeta `/basic`

### Configuración Avanzada

**Para instalación con funciones de IA:**

[![Tutorial Configuración Avanzada](https://img.youtube.com/vi/FyXjwv_oZuc/maxresdefault.jpg)](https://youtu.be/FyXjwv_oZuc "Tutorial Configuración Avanzada n8n")

**Navega a:** carpeta `/advanced`

### Configuración Avanzada con Evolution API

**Para instalación con funciones de IA e integración con WhatsApp vía Evolution API v2.2.3:**

[![Tutorial Configuración Avanzada con Evolution API](https://img.youtube.com/vi/xKtVkRx3-5I/maxresdefault.jpg)](https://youtu.be/xKtVkRx3-5I "Tutorial Configuración Avanzada n8n con Evolution API")

**Navega a:** carpeta `/advanced-with-evolution-api-v2.2.3`

_Esta configuración incluye todas las funciones avanzadas más Evolution API v2.2.3 para automatización de WhatsApp y capacidades de mensajería._
