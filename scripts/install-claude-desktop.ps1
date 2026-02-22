<#
.SYNOPSIS
    Instala Claude Desktop en Windows
.DESCRIPTION
    Descarga e instala la última versión de Claude Desktop desde los servidores de Anthropic.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

Write-Host "Instalando Claude Desktop..." -ForegroundColor Cyan

# URL de descarga de Claude Desktop para Windows
$url = "https://storage.googleapis.com/osprey-downloads-c02f6a0d-347c-492b-a752-3e0651722e97/nest-win-x64/Claude-Setup-x64.exe"
$output = "$env:TEMP\ClaudeSetup.exe"

# Verificar si ya está instalado
$claudePath = "$env:LOCALAPPDATA\Programs\Claude\Claude.exe"
if (Test-Path $claudePath) {
    Write-Host "  Claude Desktop ya está instalado" -ForegroundColor Yellow
    Write-Host "  Ubicación: $claudePath" -ForegroundColor Gray
    
    $response = Read-Host "  ¿Deseas reinstalar? (s/N)"
    if ($response -ne 's' -and $response -ne 'S') {
        Write-Host "  Saltando instalación de Claude Desktop" -ForegroundColor Gray
        return
    }
}

try {
    Write-Host "  Descargando Claude Desktop..." -ForegroundColor Green
    Invoke-WebRequest -Uri $url -OutFile $output -UseBasicParsing
    
    Write-Host "  Instalando Claude Desktop (esto puede tomar un minuto)..." -ForegroundColor Green
    Start-Process -FilePath $output -ArgumentList "/S" -Wait
    
    # Limpiar
    Remove-Item $output -Force -ErrorAction SilentlyContinue
    
    Write-Host "  ✅ Claude Desktop instalado correctamente" -ForegroundColor Green
    Write-Host "  Ubicación: $claudePath" -ForegroundColor Gray
    
} catch {
    Write-Host "  ❌ Error al instalar Claude Desktop" -ForegroundColor Red
    Write-Host "  Puedes instalarlo manualmente desde: https://claude.ai/download" -ForegroundColor Yellow
    throw
}