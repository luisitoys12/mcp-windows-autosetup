<#
.SYNOPSIS
    Instala Node.js LTS en Windows
.DESCRIPTION
    Descarga e instala la última versión LTS de Node.js usando winget.
    Si winget no está disponible, descarga el instalador MSI directamente.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

Write-Host "Instalando Node.js LTS..." -ForegroundColor Cyan

# Intentar instalar con winget primero
if (Get-Command winget -ErrorAction SilentlyContinue) {
    Write-Host "  Usando winget para instalar Node.js..." -ForegroundColor Green
    $useDirectDownload = $false
    try {
        winget install -e --id OpenJS.NodeJS.LTS --silent --accept-source-agreements --accept-package-agreements
        Write-Host "  Node.js instalado correctamente vía winget" -ForegroundColor Green
    } catch {
        Write-Host "  Advertencia: winget falló, intentando descarga directa..." -ForegroundColor Yellow
        $useDirectDownload = $true
    }
} else {
    Write-Host "  winget no disponible, usando descarga directa..." -ForegroundColor Yellow
    $useDirectDownload = $true
}

# Fallback: descarga directa desde nodejs.org
if ($useDirectDownload) {
    $nodejsVersion = "20.11.0"
    $url = "https://nodejs.org/dist/v$nodejsVersion/node-v$nodejsVersion-x64.msi"
    $output = "$env:TEMP\nodejs-installer.msi"
    
    Write-Host "  Descargando Node.js v$nodejsVersion desde nodejs.org..." -ForegroundColor Green
    Invoke-WebRequest -Uri $url -OutFile $output -UseBasicParsing
    
    Write-Host "  Instalando Node.js..." -ForegroundColor Green
    Start-Process msiexec.exe -ArgumentList "/i `"$output`" /quiet /norestart" -Wait
    
    # Limpiar
    Remove-Item $output -Force
}

# Actualizar PATH para esta sesión
$env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")

# Verificar instalación
Start-Sleep -Seconds 2
$nodeVersion = node --version 2>$null
$npmVersion = npm --version 2>$null

if ($nodeVersion -and $npmVersion) {
    Write-Host "  ✅ Node.js $nodeVersion instalado correctamente" -ForegroundColor Green
    Write-Host "  ✅ npm $npmVersion instalado correctamente" -ForegroundColor Green
} else {
    throw "Error: Node.js no se instaló correctamente. Reinicia PowerShell e intenta de nuevo."
}