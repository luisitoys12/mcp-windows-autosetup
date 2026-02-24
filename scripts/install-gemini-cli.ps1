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
    Write-Host "  (Ignorando warnings de deprecación conocidos)" -ForegroundColor Gray
    
    # Instalar con flags para ignorar deprecation warnings
    $npmOutput = npm install -g @google/gemini-cli --force --loglevel=error 2>&1
    
    # Si hay error crítico, intentar con --legacy-peer-deps
    if ($LASTEXITCODE -ne 0) {
        Write-Host "  Reintentando con --legacy-peer-deps..." -ForegroundColor Yellow
        $npmOutput = npm install -g @google/gemini-cli --legacy-peer-deps --force --loglevel=error 2>&1
    }
    
    # Verificar instalación
    Start-Sleep -Seconds 2
    $gcliVersion = gcli --version 2>$null
    
    if ($gcliVersion) {
        Write-Host "  ✅ Gemini CLI instalado correctamente" -ForegroundColor Green
        Write-Host "  Versión: $gcliVersion" -ForegroundColor Gray
        Write-Host ""
        Write-Host "  Próximo paso: Ejecuta 'gcli auth' para autenticarte" -ForegroundColor Yellow
    } else {
        throw "Gemini CLI no responde después de la instalación"
    }
    
} catch {
    Write-Host "  ❌ Error al instalar Gemini CLI" -ForegroundColor Red
    Write-Host "  Detalles: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
    Write-Host "  Problema conocido: @google/gemini-cli tiene dependencias deprecadas" -ForegroundColor Yellow
    Write-Host "  Issue de GitHub: https://github.com/google-gemini/gemini-cli/issues/19962" -ForegroundColor Gray
    Write-Host ""
    Write-Host "  Opciones:" -ForegroundColor Cyan
    Write-Host "  1. Saltar Gemini CLI: .\install.ps1 -SkipGemini" -ForegroundColor White
    Write-Host "  2. Instalar manualmente: npm install -g @google/gemini-cli --force" -ForegroundColor White
    Write-Host "  3. Usar Node.js v18 (LTS anterior) en lugar de v24" -ForegroundColor White
    Write-Host ""
    Write-Host "  Puedes continuar sin Gemini CLI, los MCP servers se instalarán igual." -ForegroundColor Yellow
    
    # No lanzar error para que el instalador continúe
    Write-Host "  Continuando con la instalación..." -ForegroundColor Gray
}