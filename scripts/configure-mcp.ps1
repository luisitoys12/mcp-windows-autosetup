<#
.SYNOPSIS
    Configura Claude Desktop y Gemini CLI con servidores MCP
.DESCRIPTION
    Escribe los archivos de configuración para ambos clientes,
    conectándolos con MCPControl para control de Windows.
#>

param(
    [string]$McpServerPath = "C:\ProgramData\MCPControl\dist\server.js"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

Write-Host "Configurando clientes MCP..." -ForegroundColor Cyan

# Verificar que el servidor MCP exista
if (-not (Test-Path $McpServerPath)) {
    # Intentar ubicación alternativa sin /dist
    $altPath = "C:\ProgramData\MCPControl\src\index.js"
    if (Test-Path $altPath) {
        $McpServerPath = $altPath
    } else {
        Write-Host "  ⚠️  Advertencia: MCPControl no encontrado en $McpServerPath" -ForegroundColor Yellow
        Write-Host "  La configuración se guardará pero puede no funcionar hasta que MCPControl esté instalado" -ForegroundColor Yellow
    }
}

# 1) Configurar Claude Desktop
Write-Host "  Configurando Claude Desktop..." -ForegroundColor Green
$claudeConfigPath = Join-Path $env:APPDATA "Claude\claude_desktop_config.json"

$claudeConfig = @{
    mcpServers = @{
        mcpcontrol = @{
            command   = "node"
            args      = @($McpServerPath)
            transport = "stdio"
        }
    }
} | ConvertTo-Json -Depth 10

New-Item -ItemType Directory -Force -Path (Split-Path $claudeConfigPath) | Out-Null
Set-Content -Path $claudeConfigPath -Value $claudeConfig -Encoding UTF8

Write-Host "  ✅ Configuración escrita en: $claudeConfigPath" -ForegroundColor Green

# 2) Configurar Gemini CLI
Write-Host "  Configurando Gemini CLI..." -ForegroundColor Green
$geminiConfigPath = Join-Path $env:USERPROFILE ".gemini\settings.json"

$geminiConfig = @{
    mcpServers = @{
        mcpcontrol = @{
            command   = "node"
            args      = @($McpServerPath)
            transport = "stdio"
        }
    }
} | ConvertTo-Json -Depth 10

New-Item -ItemType Directory -Force -Path (Split-Path $geminiConfigPath) | Out-Null
Set-Content -Path $geminiConfigPath -Value $geminiConfig -Encoding UTF8

Write-Host "  ✅ Configuración escrita en: $geminiConfigPath" -ForegroundColor Green

Write-Host ""
Write-Host "Configuración MCP completada para ambos clientes" -ForegroundColor Green