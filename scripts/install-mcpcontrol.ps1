<#
.SYNOPSIS
    Instala MCPControl (servidor MCP para Windows)
.DESCRIPTION
    Instala MCPControl globalmente vía npm.
    MCPControl permite a Claude y Gemini controlar Windows (mouse, teclado, ventanas, etc.)
    Requiere Python 3.6+ para compilar módulos nativos.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

Write-Host "Instalando MCPControl..." -ForegroundColor Cyan

# Verificar que npm esté disponible
if (-not (Get-Command npm -ErrorAction SilentlyContinue)) {
    throw "Error: npm no está disponible. Asegúrate de que Node.js esté instalado correctamente."
}

# Función para verificar Python
function Test-PythonInstalled {
    try {
        $pythonVersion = python --version 2>&1
        if ($pythonVersion -match "Python (\d+\.\d+)" -and [version]$matches[1] -ge [version]"3.6") {
            return $true
        }
    } catch {
        return $false
    }
    return $false
}

# Verificar/instalar Python
if (-not (Test-PythonInstalled)) {
    Write-Host "  Python no encontrado. MCPControl necesita Python 3.6+ para compilar módulos nativos..." -ForegroundColor Yellow
    
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        Write-Host "  Instalando Python 3.11 con winget..." -ForegroundColor Green
        try {
            winget install -e --id Python.Python.3.11 --silent --accept-source-agreements --accept-package-agreements
            
            # Actualizar PATH para esta sesión
            $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
            
            # Esperar a que Python esté disponible
            Start-Sleep -Seconds 5
            $maxRetries = 5
            $retries = 0
            
            while (-not (Test-PythonInstalled) -and $retries -lt $maxRetries) {
                Write-Host "  Esperando a que Python esté disponible... ($retries/$maxRetries)" -ForegroundColor Gray
                Start-Sleep -Seconds 2
                $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
                $retries++
            }
            
            if (Test-PythonInstalled) {
                $pythonPath = (Get-Command python).Source
                Write-Host "  ✅ Python instalado: $pythonPath" -ForegroundColor Green
                
                # Configurar variables de entorno para npm/node-gyp
                $env:PYTHON = $pythonPath
                [System.Environment]::SetEnvironmentVariable("PYTHON", $pythonPath, "User")
            } else {
                throw "Python no responde después de instalación"
            }
        } catch {
            Write-Host "  ⚠️ No se pudo instalar Python automáticamente" -ForegroundColor Yellow
            Write-Host ""
            Write-Host "  Para instalar MCPControl necesitas:" -ForegroundColor Yellow
            Write-Host "  1. Instalar Python 3.11 desde: https://www.python.org/downloads/" -ForegroundColor White
            Write-Host "  2. Marcar 'Add Python to PATH' durante instalación" -ForegroundColor White
            Write-Host "  3. Reiniciar PowerShell y ejecutar: npm install -g mcp-control" -ForegroundColor White
            Write-Host ""
            Write-Host "  Saltando MCPControl por ahora..." -ForegroundColor Gray
            return
        }
    } else {
        Write-Host "  ⚠️ winget no disponible y Python no instalado" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "  Instala Python 3.11 manualmente desde: https://www.python.org/downloads/" -ForegroundColor White
        Write-Host "  Luego ejecuta: npm install -g mcp-control" -ForegroundColor White
        Write-Host ""
        Write-Host "  Saltando MCPControl por ahora..." -ForegroundColor Gray
        return
    }
}

try {
    Write-Host "  Instalando mcp-control globalmente (esto puede tomar 2-3 minutos)..." -ForegroundColor Green
    
    # Instalar usando npm directamente (sin Start-Process que causa problemas)
    $output = npm install -g mcp-control 2>&1 | Out-String
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "  ⚠️ Instalación con warnings, verificando..." -ForegroundColor Yellow
    }
    
    # Verificar instalación
    Start-Sleep -Seconds 2
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
    
    $mcpVersion = $null
    try {
        $mcpVersion = & mcp-control --version 2>&1
    } catch {
        $mcpVersion = $null
    }
    
    if ($mcpVersion -and $mcpVersion -notmatch "error") {
        Write-Host "  ✅ MCPControl instalado correctamente" -ForegroundColor Green
        Write-Host "  Versión: $mcpVersion" -ForegroundColor Gray
        Write-Host ""
        Write-Host "  Para usar MCPControl:" -ForegroundColor Yellow
        Write-Host "  - Modo local (stdio): configurar en claude_desktop_config.json" -ForegroundColor White
        Write-Host "  - Modo red (SSE): ejecutar 'mcp-control --sse' y usar http://localhost:3232/mcp" -ForegroundColor White
    } else {
        Write-Host "  ⚠️ MCPControl se instaló pero no responde correctamente" -ForegroundColor Yellow
        Write-Host "  Esto puede ser normal. Verifica con: mcp-control --version" -ForegroundColor Gray
    }
    
} catch {
    Write-Host "  ❌ Error al instalar MCPControl" -ForegroundColor Red
    Write-Host "  Detalles: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
    Write-Host "  Puedes intentar manualmente:" -ForegroundColor Yellow
    Write-Host "  npm install -g mcp-control" -ForegroundColor White
    Write-Host ""
    Write-Host "  Si el error es sobre Python/node-gyp:" -ForegroundColor Yellow
    Write-Host "  1. Verifica Python: python --version" -ForegroundColor White
    Write-Host "  2. Asegúrate de tener Visual Studio Build Tools" -ForegroundColor White
    Write-Host "  3. Prueba: npm install -g windows-build-tools" -ForegroundColor White
    Write-Host ""
    Write-Host "  Documentación: https://github.com/claude-did-this/MCPControl" -ForegroundColor Gray
    
    # No lanzar error para que el instalador continúe
    Write-Host "  Continuando con la instalación..." -ForegroundColor Gray
}