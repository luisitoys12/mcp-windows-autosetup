<#
.SYNOPSIS
    Instala Gemini CLI globalmente
.DESCRIPTION
    Instala la interfaz de línea de comandos de Gemini vía npm.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

Write-Host "Instalando Gemini CLI..." -ForegroundColor Cyan

# Verificar que npm esté disponible
if (-not (Get-Command npm -ErrorAction SilentlyContinue)) {
    throw "Error: npm no está disponible. Asegúrate de que Node.js esté instalado correctamente."
}

try {
    Write-Host "  Instalando @google/gemini-cli globalmente..." -ForegroundColor Green
    npm install -g @google/gemini-cli 2>&1 | Out-Null
    
    # Verificar instalación
    Start-Sleep -Seconds 2
    $gcliVersion = gcli --version 2>$null
    
    if ($gcliVersion) {
        Write-Host "  ✅ Gemini CLI $gcliVersion instalado correctamente" -ForegroundColor Green
        Write-Host ""
        Write-Host "  Próximo paso: Ejecuta 'gcli auth' para autenticarte" -ForegroundColor Yellow
    } else {
        throw "Gemini CLI no responde después de la instalación"
    }
    
} catch {
    Write-Host "  ❌ Error al instalar Gemini CLI" -ForegroundColor Red
    Write-Host "  Intenta manualmente: npm install -g @google/gemini-cli" -ForegroundColor Yellow
    throw
}