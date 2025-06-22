# n8n Self-Hosted Local

Este repositorio proporciona configuraciones de Docker Compose para alojar [n8n](https://n8n.io/) localmente con exposición segura a internet.

## ¿Qué es n8n?

n8n es una herramienta gratuita y de código abierto para automatización de flujos de trabajo que te permite conectar diferentes servicios y APIs para automatizar tareas repetitivas, procesamiento de datos y flujos de trabajo empresariales.

## Configuraciones Disponibles

Este repositorio contiene dos configuraciones diferentes de Docker Compose para satisfacer diferentes necesidades:

### 📁 Configuración Básica (`/basic`)

Una configuración simple y liviana perfecta para:

- Comenzar con n8n
- Proyectos personales
- Automatización a pequeña escala

**Incluye:**

- Herramienta de automatización de flujos de trabajo n8n
- Nginx Proxy Manager para SSL y proxy inverso
- Cloudflare Tunnel para exposición segura a internet

### 📁 Configuración Avanzada (`/advanced`)

Una configuración completa y lista para producción diseñada para:

- Alto rendimiento y escalabilidad
- Flujos de trabajo con inteligencia artificial
- Uso profesional y empresarial

**Incluye:**

- n8n en modo cola (servicio principal + worker)
- Base de datos PostgreSQL para persistencia
- Redis para gestión de colas
- Nginx Proxy Manager para SSL y proxy inverso
- Cloudflare Tunnel para exposición segura a internet
- Ollama para integración local de IA/LLM
- Base de datos vectorial Qdrant para funciones de IA
- Herramientas automatizadas de importación/exportación para respaldos

## Comenzar

1. Elige la configuración que mejor se adapte a tus necesidades (básica o avanzada)
2. Navega a la carpeta respectiva
3. Sigue las instrucciones detalladas en el archivo README de cada carpeta

## Requisitos Previos

- [Docker](https://docs.docker.com/get-docker/) instalado
- Cuenta de [Cloudflare](https://www.cloudflare.com/) con un dominio registrado

## Características de Seguridad

Ambas configuraciones incluyen:

- **Certificados SSL** gestionados automáticamente
- **Cloudflare Tunnel** para exposición segura sin abrir puertos
- Configuración de **proxy inverso** para mayor seguridad

## Soporte

Para instrucciones detalladas de configuración, solución de problemas y opciones de configuración, consulta los archivos README en cada carpeta respectiva:

- [Documentación Configuración Básica](./basic/README.md)
- [Documentación Configuración Avanzada](./advanced/README.md)

## Licencia

Este proyecto está licenciado bajo la Licencia MIT - consulta el archivo [LICENSE](LICENSE) para más detalles.
