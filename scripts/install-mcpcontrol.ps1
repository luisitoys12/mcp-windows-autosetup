<#
.SYNOPSIS
    Instala MCPControl (servidor MCP para Windows)
.DESCRIPTION
    Instala MCPControl globalmente vía npm.
    MCPControl permite a Claude y Gemini controlar Windows (mouse, teclado, ventanas, etc.)
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

Write-Host "Instalando MCPControl..." -ForegroundColor Cyan

# Verificar que npm esté disponible
if (-not (Get-Command npm -ErrorAction SilentlyContinue)) {
    throw "Error: npm no está disponible. Asegúrate de que Node.js esté instalado correctamente."
}

try {
    Write-Host "  Instalando mcp-control globalmente..." -ForegroundColor Green
    
    # Instalar desde npm (es un paquete publicado)
    npm install -g mcp-control --loglevel=error 2>&1 | Out-Null
    
    if ($LASTEXITCODE -ne 0) {
        throw "npm install falló con código $LASTEXITCODE"
    }
    
    # Verificar instalación
    Start-Sleep -Seconds 2
    $mcpVersion = mcp-control --version 2>$null
    
    if ($mcpVersion) {
        Write-Host "  ✅ MCPControl instalado correctamente" -ForegroundColor Green
        Write-Host "  Versión: $mcpVersion" -ForegroundColor Gray
        Write-Host ""
        Write-Host "  Para usar MCPControl:" -ForegroundColor Yellow
        Write-Host "  - Modo local (stdio): configurar en claude_desktop_config.json" -ForegroundColor White
        Write-Host "  - Modo red (SSE): ejecutar 'mcp-control --sse' y usar http://localhost:3232/mcp" -ForegroundColor White
    } else {
        throw "MCPControl no responde después de la instalación"
    }
    
} catch {
    Write-Host "  ❌ Error al instalar MCPControl" -ForegroundColor Red
    Write-Host "  Detalles: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
    Write-Host "  Puedes intentar manualmente:" -ForegroundColor Yellow
    Write-Host "  npm install -g mcp-control" -ForegroundColor White
    Write-Host ""
    Write-Host "  Documentación: https://github.com/claude-did-this/MCPControl" -ForegroundColor Gray
    throw
}