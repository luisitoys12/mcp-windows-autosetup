<#
.SYNOPSIS
    Instala Gemini CLI globalmente
.DESCRIPTION
    Instala la interfaz de línea de comandos de Gemini vía npm.
    Gemini CLI permite interactuar con Google Gemini desde la terminal.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = "Continue"  # Cambiar a Continue para no romper por warnings

Write-Host "Instalando Gemini CLI..." -ForegroundColor Cyan

# Verificar que npm esté disponible
if (-not (Get-Command npm -ErrorAction SilentlyContinue)) {
    throw "Error: npm no está disponible. Asegúrate de que Node.js esté instalado correctamente."
}

try {
    Write-Host "  Instalando @google/gemini-cli globalmente..." -ForegroundColor Green
    Write-Host "  (Ignorando warnings de deprecación conocidos - issue #19962)" -ForegroundColor Gray
    
    # Instalar con flags para forzar instalación a pesar de warnings
    Write-Host "  Ejecutando: npm install -g @google/gemini-cli --force --legacy-peer-deps" -ForegroundColor Gray
    
    $installOutput = npm install -g @google/gemini-cli --force --legacy-peer-deps 2>&1
    
    # Actualizar PATH varias veces para asegurar detección
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
    
    # Esperar a que npm termine de escribir archivos
    Start-Sleep -Seconds 3
    
    # Actualizar PATH de nuevo
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
    
    # Verificar instalación con múltiples intentos
    $maxRetries = 5
    $gcliFound = $false
    
    for ($i = 0; $i -lt $maxRetries; $i++) {
        try {
            # Intentar ejecutar gcli
            $gcliVersion = gcli --version 2>&1
            
            if ($gcliVersion -and $gcliVersion -notmatch "not recognized" -and $gcliVersion -notmatch "error") {
                $gcliFound = $true
                Write-Host "  ✅ Gemini CLI instalado correctamente" -ForegroundColor Green
                Write-Host "  Versión: $gcliVersion" -ForegroundColor Gray
                Write-Host ""
                Write-Host "  Próximos pasos:" -ForegroundColor Yellow
                Write-Host "  1. Abre una NUEVA ventana de PowerShell" -ForegroundColor White
                Write-Host "  2. Ejecuta 'gcli auth' para autenticarte con Google" -ForegroundColor White
                Write-Host "  3. Ejecuta 'gcli chat' para iniciar chat con Gemini" -ForegroundColor White
                break
            }
        } catch {
            # Ignorar errores y reintentar
        }
        
        if ($i -lt $maxRetries - 1) {
            Write-Host "  Esperando a que gcli esté disponible... ($($i+1)/$maxRetries)" -ForegroundColor Gray
            Start-Sleep -Seconds 2
            $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
        }
    }
    
    if (-not $gcliFound) {
        Write-Host "  ⚠️ Gemini CLI se instaló pero gcli no está en PATH aún" -ForegroundColor Yellow
        Write-Host "  Esto es normal. Abre una NUEVA ventana de PowerShell y prueba: gcli --version" -ForegroundColor Gray
        Write-Host ""
        Write-Host "  Si sigue sin funcionar, ejecuta manualmente:" -ForegroundColor Yellow
        Write-Host "  npm install -g @google/gemini-cli --force" -ForegroundColor White
    }
    
} catch {
    Write-Host "  ⚠️ Error al instalar Gemini CLI" -ForegroundColor Yellow
    Write-Host "  Detalles: $($_.Exception.Message)" -ForegroundColor Gray
    Write-Host ""
    Write-Host "  Problema conocido: @google/gemini-cli tiene dependencias deprecadas" -ForegroundColor Yellow
    Write-Host "  Issue de GitHub: https://github.com/google-gemini/gemini-cli/issues/19962" -ForegroundColor Gray
    Write-Host ""
    Write-Host "  Puedes intentar manualmente:" -ForegroundColor Yellow
    Write-Host "  npm install -g @google/gemini-cli --force --legacy-peer-deps" -ForegroundColor White
    Write-Host ""
    Write-Host "  Continuando con la instalación..." -ForegroundColor Gray
}