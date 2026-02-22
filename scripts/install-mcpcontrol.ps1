<#
.SYNOPSIS
    Instala MCPControl (servidor MCP para Windows)
.DESCRIPTION
    Clona el repositorio de MCPControl y lo compila.
    MCPControl permite a Claude y Gemini controlar Windows (mouse, teclado, ventanas, etc.)
#>

param(
    [string]$InstallDir = "$env:ProgramData\MCPControl"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

Write-Host "Instalando MCPControl en $InstallDir..." -ForegroundColor Cyan

# Verificar que git esté disponible
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host "  ❌ Error: Git no está instalado" -ForegroundColor Red
    Write-Host "  Instálalo desde: https://git-scm.com/download/win" -ForegroundColor Yellow
    throw "Git no disponible"
}

# Verificar que npm esté disponible
if (-not (Get-Command npm -ErrorAction SilentlyContinue)) {
    throw "Error: npm no está disponible. Asegúrate de que Node.js esté instalado correctamente."
}

try {
    # Crear directorio si no existe
    if (-not (Test-Path $InstallDir)) {
        New-Item -ItemType Directory -Path $InstallDir -Force | Out-Null
        Write-Host "  Directorio creado: $InstallDir" -ForegroundColor Green
    }

    Set-Location $InstallDir

    # Clonar o actualizar repositorio
    if (-not (Test-Path ".git")) {
        Write-Host "  Clonando MCPControl desde GitHub..." -ForegroundColor Green
        git clone https://github.com/claude-did-this/MCPControl.git . 2>&1 | Out-Null
    } else {
        Write-Host "  MCPControl ya existe, actualizando..." -ForegroundColor Yellow
        git pull 2>&1 | Out-Null
    }

    # Instalar dependencias
    Write-Host "  Instalando dependencias de Node.js..." -ForegroundColor Green
    npm install 2>&1 | Out-Null

    # Compilar (si hay build script)
    if (Test-Path "package.json") {
        $packageJson = Get-Content "package.json" | ConvertFrom-Json
        if ($packageJson.scripts.build) {
            Write-Host "  Compilando MCPControl..." -ForegroundColor Green
            npm run build 2>&1 | Out-Null
        }
    }

    Write-Host "  ✅ MCPControl instalado correctamente" -ForegroundColor Green
    Write-Host "  Ubicación: $InstallDir" -ForegroundColor Gray
    
} catch {
    Write-Host "  ❌ Error al instalar MCPControl" -ForegroundColor Red
    throw
} finally {
    # Volver al directorio original
    Pop-Location -ErrorAction SilentlyContinue
}