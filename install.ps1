#Requires -RunAsAdministrator

<#
.SYNOPSIS
    Instalador automático de Claude Desktop + Gemini CLI + MCP Servers para Windows
.DESCRIPTION
    Descarga, instala y configura todo lo necesario para que Claude y Gemini
    puedan controlar tu PC Windows desde el primer momento.
.NOTES
    Versión: 1.0.0
    Autor: Luis Martinez Sandoval - EstacionKusMedias
    Requiere: PowerShell 5.1+ y permisos de administrador
.EXAMPLE
    .\install.ps1
    Ejecuta la instalación completa
.EXAMPLE
    .\install.ps1 -SkipClaude
    Instala todo excepto Claude Desktop
#>

[CmdletBinding()]
param(
    [switch]$SkipClaude,
    [switch]$SkipGemini,
    [switch]$SkipMCPServers
)

Set-ExecutionPolicy Bypass -Scope Process -Force
$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

# Banner
Write-Host ""
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "  MCP Windows AI Control Installer v1.0" -ForegroundColor Cyan
Write-Host "  Por Luis Martinez - EstacionKusMedias" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

try {
    # Verificar que estamos en la carpeta correcta
    if (-not (Test-Path ".\scripts")) {
        throw "Error: Debes ejecutar este script desde la carpeta raíz del repositorio donde existe la carpeta 'scripts'"
    }

    # 1. Instalar Node.js si no existe
    Write-Host "[1/5] Verificando Node.js..." -ForegroundColor Yellow
    if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
        Write-Host "      Instalando Node.js LTS..." -ForegroundColor Green
        & ".\scripts\install-nodejs.ps1"
    } else {
        $nodeVersion = node --version
        Write-Host "      Node.js ya instalado: $nodeVersion" -ForegroundColor Green
    }

    # 2. Instalar Claude Desktop
    if (-not $SkipClaude) {
        Write-Host "[2/5] Instalando Claude Desktop..." -ForegroundColor Yellow
        & ".\scripts\install-claude-desktop.ps1"
    } else {
        Write-Host "[2/5] Saltando Claude Desktop (parámetro -SkipClaude)" -ForegroundColor Gray
    }

    # 3. Instalar Gemini CLI
    if (-not $SkipGemini) {
        Write-Host "[3/5] Instalando Gemini CLI..." -ForegroundColor Yellow
        & ".\scripts\install-gemini-cli.ps1"
    } else {
        Write-Host "[3/5] Saltando Gemini CLI (parámetro -SkipGemini)" -ForegroundColor Gray
    }

    # 4. Instalar MCPControl
    if (-not $SkipMCPServers) {
        Write-Host "[4/5] Instalando MCPControl (servidor MCP)..." -ForegroundColor Yellow
        & ".\scripts\install-mcpcontrol.ps1"
    } else {
        Write-Host "[4/5] Saltando MCP Servers (parámetro -SkipMCPServers)" -ForegroundColor Gray
    }

    # 5. Configurar clientes (Claude Desktop + Gemini CLI)
    Write-Host "[5/5] Aplicando configuraciones MCP..." -ForegroundColor Yellow
    & ".\scripts\configure-mcp.ps1"

    # Éxito
    Write-Host ""
    Write-Host "=========================================" -ForegroundColor Green
    Write-Host "  ✅ Instalación completada con éxito!" -ForegroundColor Green
    Write-Host "=========================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Próximos pasos:" -ForegroundColor Cyan
    Write-Host "  1. Reinicia Claude Desktop (si estaba abierto)" -ForegroundColor White
    Write-Host "  2. Abre una nueva ventana de PowerShell" -ForegroundColor White
    Write-Host "  3. Ejecuta 'gcli auth' para autenticar Gemini CLI" -ForegroundColor White
    Write-Host "  4. Ejecuta 'gcli chat' para iniciar chat con Gemini" -ForegroundColor White
    Write-Host ""
    Write-Host "Prueba de ejemplo:" -ForegroundColor Yellow
    Write-Host "  'Abre el Bloc de notas y escribe Hola Mundo'" -ForegroundColor White
    Write-Host ""
    Write-Host "Documentación completa: https://github.com/luisitoys12/mcp-windows-autosetup" -ForegroundColor Cyan
    Write-Host ""

} catch {
    Write-Host ""
    Write-Host "❌ Error durante la instalación:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host ""
    Write-Host "Por favor reporta este error en:" -ForegroundColor Yellow
    Write-Host "https://github.com/luisitoys12/mcp-windows-autosetup/issues" -ForegroundColor Yellow
    Write-Host ""
    exit 1
}