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
    Write-Host "  Saltando instalación (ya existe)" -ForegroundColor Gray
    return
}

try {
    Write-Host "  Descargando Claude Desktop..." -ForegroundColor Green
    Invoke-WebRequest -Uri $url -OutFile $output -UseBasicParsing
    
    Write-Host "  Instalando Claude Desktop (esto puede tomar 2-3 minutos en VPS)..." -ForegroundColor Green
    
    # Iniciar proceso con mejor control
    $process = Start-Process -FilePath $output -ArgumentList "/S" -NoNewWindow -PassThru
    
    # Esperar hasta 5 minutos (300 segundos)
    $timeout = 300
    $waited = 0
    $checkInterval = 5
    
    while (-not $process.HasExited -and $waited -lt $timeout) {
        Start-Sleep -Seconds $checkInterval
        $waited += $checkInterval
        
        if ($waited % 30 -eq 0) {
            Write-Host "  Aún instalando... ($waited segundos)" -ForegroundColor Gray
        }
    }
    
    # Si se pasó del timeout, matar el proceso
    if (-not $process.HasExited) {
        Write-Host "  ⚠️ Timeout alcanzado, deteniendo instalador..." -ForegroundColor Yellow
        $process.Kill()
        $process.WaitForExit()
    }
    
    # Limpiar
    Remove-Item $output -Force -ErrorAction SilentlyContinue
    
    # Verificar si realmente se instaló
    Start-Sleep -Seconds 2
    if (Test-Path $claudePath) {
        Write-Host "  ✅ Claude Desktop instalado correctamente" -ForegroundColor Green
        Write-Host "  Ubicación: $claudePath" -ForegroundColor Gray
    } else {
        Write-Host "  ⚠️ El instalador terminó pero Claude no se detecta" -ForegroundColor Yellow
        Write-Host "  Esto es normal en algunos VPS. Claude funcionará cuando configures MCP." -ForegroundColor Yellow
    }
    
} catch {
    Write-Host "  ❌ Error al instalar Claude Desktop" -ForegroundColor Red
    Write-Host "  Detalles: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
    Write-Host "  Si estás en VPS sin GUI, puedes:" -ForegroundColor Yellow
    Write-Host "  1. Saltar Claude con: .\install.ps1 -SkipClaude" -ForegroundColor White
    Write-Host "  2. Instalar manualmente en tu PC local desde: https://claude.ai/download" -ForegroundColor White
    throw
}