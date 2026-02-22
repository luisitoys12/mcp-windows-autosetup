# 🤖 MCP Windows Auto Setup

**Instalador automático para convertir tu Windows Server en una PC controlable por IA en 5 minutos.**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-blue.svg)](https://docs.microsoft.com/en-us/powershell/)
[![Node.js](https://img.shields.io/badge/Node.js-20%2B-green.svg)](https://nodejs.org/)

## 🎯 ¿Qué hace este proyecto?

Este repositorio instala y configura automáticamente:

- ✅ **Claude Desktop** con servidores MCP
- ✅ **Gemini CLI** con los mismos servidores MCP
- ✅ **MCPControl** - Servidor MCP para control total de Windows (mouse, teclado, ventanas, archivos)

Una vez instalado, puedes pedirle a Claude o Gemini:
- "Abre el Bloc de notas y escribe 'Hola Mundo'"
- "Crea una carpeta C:\\proyectos\\test y un archivo README.md dentro"
- "Ejecuta este comando PowerShell: Get-Process | Sort-Object CPU -Descending | Select-Object -First 5"

## 🚀 Instalación Ultra Rápida

### Requisitos Previos

- Windows 10/11 o Windows Server 2016+
- PowerShell 5.1 o superior
- Permisos de administrador
- Conexión a Internet
- Git instalado (para clonar el repo)

### Instalación en 3 pasos

#### Paso 1: Clonar el repositorio

```powershell
git clone https://github.com/luisitoys12/mcp-windows-autosetup.git
cd mcp-windows-autosetup
```

#### Paso 2: Permitir ejecución de scripts

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
```

#### Paso 3: Ejecutar el instalador

```powershell
.\install.ps1
```

El script instalará automáticamente:
1. Node.js LTS (si no está instalado)
2. Claude Desktop
3. Gemini CLI
4. MCPControl (servidor MCP para Windows)
5. Configuraciones para ambos clientes

## 📋 Después de la instalación

### Probar con Claude Desktop

1. Abre **Claude Desktop** (se habrá instalado en tu menú de inicio)
2. Crea una conversación nueva
3. Prueba con: *"Usa MCP para abrir el Bloc de notas y escribir 'Hola desde Claude'"*

### Probar con Gemini CLI

1. Abre una nueva ventana de PowerShell
2. Ejecuta:
   ```powershell
   gcli auth  # Primero autentícate con tu cuenta de Google
   gcli chat
   ```
3. Escribe: *"Crea un archivo en C:\\temp\\test.txt con el texto 'Hola desde Gemini'"*

## 🛠️ Capacidades de Control de Windows

Con este setup, la IA puede:

### 🖱️ Control de Interfaz
- Mover el mouse
- Hacer clicks (izquierdo, derecho, doble)
- Escribir texto en cualquier aplicación
- Leer contenido de ventanas
- Capturar screenshots

### 📁 Gestión de Archivos
- Crear, leer, editar, eliminar archivos
- Crear y navegar carpetas
- Copiar y mover archivos
- Buscar archivos por nombre o contenido

### 💻 Ejecución de Comandos
- Ejecutar comandos PowerShell
- Ejecutar comandos CMD
- Abrir programas instalados
- Gestionar procesos

### 🔧 Automatización
- Instalar software vía winget/chocolatey
- Ejecutar scripts de build
- Interactuar con APIs
- Automatizar tareas repetitivas

## 📁 Estructura del Proyecto

```
mcp-windows-autosetup/
├── README.md                          # Este archivo
├── install.ps1                        # Script principal de instalación
├── scripts/
│   ├── install-nodejs.ps1             # Instala Node.js LTS
│   ├── install-claude-desktop.ps1     # Descarga e instala Claude Desktop
│   ├── install-gemini-cli.ps1         # Instala Gemini CLI vía npm
│   ├── install-mcpcontrol.ps1         # Clona y compila MCPControl
│   └── configure-mcp.ps1              # Configura ambos clientes
├── configs/
│   ├── claude_desktop_config.example.json   # Plantilla de config para Claude
│   └── gemini_settings.example.json         # Plantilla de config para Gemini
└── .gitignore
```

## 🎯 Ejemplos de Uso Real

### Ejemplo 1: Automatización de desarrollo

*"Crea una carpeta C:\\proyectos\\mi-app, dentro crea un package.json con nombre 'mi-app' y versión '1.0.0', y un archivo index.js con un console.log que diga 'Hola'"*

### Ejemplo 2: Gestión de archivos

*"Busca todos los archivos .log en C:\\logs que sean mayores a 100MB y muévelos a C:\\logs\\archivados"*

### Ejemplo 3: Monitoreo del sistema

*"Ejecuta Get-Process, ordénalos por uso de CPU descendente, muéstrame los top 10 y guarda el resultado en C:\\temp\\procesos.txt"*

## 🔧 Personalización

### Cambiar ubicación de MCPControl

Edita `scripts/install-mcpcontrol.ps1` y cambia el parámetro `$InstallDir`:

```powershell
param(
    [string]$InstallDir = "C:\\TuRutaPersonalizada\\MCPControl"
)
```

Luego actualiza `scripts/configure-mcp.ps1` con la misma ruta.

### Agregar más servidores MCP

1. Crea un nuevo script en `scripts/` para instalar tu servidor
2. Agrégalo al array de servidores en `scripts/configure-mcp.ps1`
3. Actualiza `install.ps1` para llamar tu script

## 🐛 Solución de Problemas

### Error: "No se puede ejecutar scripts"

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
```

### Claude Desktop no muestra las herramientas MCP

1. Cierra completamente Claude Desktop (incluyendo en la bandeja del sistema)
2. Abre `%APPDATA%\Claude\claude_desktop_config.json` y verifica que la configuración esté correcta
3. Reinicia Claude Desktop

### Gemini CLI no reconoce los comandos

1. Verifica que la instalación global funcionó: `npm list -g @google/gemini-cli`
2. Cierra y abre una nueva ventana de PowerShell
3. Ejecuta `gcli --version` para confirmar

### MCPControl no responde

1. Verifica que Node.js esté instalado: `node --version`
2. Navega a la carpeta de instalación (por defecto `C:\ProgramData\MCPControl`)
3. Ejecuta manualmente: `node dist/server.js`
4. Busca errores en la consola

## 🤝 Contribuciones

¡Las contribuciones son bienvenidas! Si tienes ideas para:

- Agregar más servidores MCP útiles
- Mejorar los scripts de instalación
- Documentar más casos de uso
- Corregir bugs

**Por favor abre un Pull Request o un Issue.**

## 📚 Recursos Adicionales

- [Documentación oficial de MCP](https://modelcontextprotocol.io/)
- [Claude Desktop](https://claude.ai/download)
- [Gemini CLI](https://geminicli.com/)
- [MCPControl en GitHub](https://github.com/claude-did-this/MCPControl)
- [Servidor MCP de GitHub](https://github.com/github/github-mcp-server)

## 📄 Licencia

MIT License - Úsalo libremente para cualquier propósito.

## 👤 Autor

**Luis Martinez Sandoval** - [EstacionKusMedias](https://estacionkusmedios.org)

---

⭐ **Si este proyecto te ayudó, dale una estrella en GitHub!**

🐛 **¿Encontraste un bug?** [Reporta un issue](https://github.com/luisitoys12/mcp-windows-autosetup/issues)

💡 **¿Tienes una idea?** [Abre una discusión](https://github.com/luisitoys12/mcp-windows-autosetup/discussions)