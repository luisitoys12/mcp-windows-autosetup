#Requires -RunAsAdministrator

<#
.SYNOPSIS
    Fix/Instala Windows-MCP para Claude Desktop
.DESCRIPTION
    Script dedicado para instalar o reparar la instalación de Windows-MCP.
    Requiere que Node.js y Claude Desktop ya estén instalados.
.NOTES
    Versión: 1.0.1
    Autor: Luis Martinez - EstacionKusMedias
    Requiere: PowerShell 5.1+ y permisos de administrador
.EXAMPLE
    .\fix-windows-mcp.ps1
    Ejecuta la reparación/instalación completa de Windows-MCP
#>

Set-ExecutionPolicy Bypass -Scope Process -Force
$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

# Banner
Write-Host ""
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "  Windows-MCP Fix/Installer v1.0.1" -ForegroundColor Cyan
Write-Host "  Por Luis Martinez - EstacionKusMedias" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

try {
    # Verificar Node.js
    Write-Host "[1/4] Verificando Node.js..." -ForegroundColor Yellow
    if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
        throw "Error: Node.js no esta instalado. Instalalo primero desde: https://nodejs.org"
    }
    $nodeVersion = node --version
    Write-Host "      [OK] Node.js instalado: $nodeVersion" -ForegroundColor Green

    # Verificar/Instalar Python 3.13+
    Write-Host "[2/4] Verificando Python 3.13+..." -ForegroundColor Yellow
    
    function Test-Python313 {
        try {
            $pythonVersion = python --version 2>&1
            if ($pythonVersion -match "Python (\d+\.\d+)" -and [version]$matches[1] -ge [version]"3.13") {
                return $true
            }
        } catch {
            return $false
        }
        return $false
    }
    
    if (-not (Test-Python313)) {
        Write-Host "      Python 3.13+ no encontrado, instalando..." -ForegroundColor Yellow
        
        if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
            throw "Error: winget no disponible. Instala Python 3.13 manualmente desde https://www.python.org/downloads/"
        }
        
        # Desinstalar versiones antiguas
        Write-Host "      Eliminando versiones antiguas de Python..." -ForegroundColor Gray
        winget uninstall Python.Python.3.11 --silent 2>$null
        winget uninstall Python.Python.3.12 --silent 2>$null
        
        # Instalar Python 3.13
        Write-Host "      Instalando Python 3.13..." -ForegroundColor Green
        winget install -e --id Python.Python.3.13 --silent --accept-source-agreements --accept-package-agreements
        
        # Actualizar PATH
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
        
        # Esperar y verificar
        Start-Sleep -Seconds 5
        $maxRetries = 10
        $retries = 0
        
        while (-not (Test-Python313) -and $retries -lt $maxRetries) {
            Write-Host "      Esperando a que Python este disponible... ($retries/$maxRetries)" -ForegroundColor Gray
            Start-Sleep -Seconds 2
            $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
            $retries++
        }
        
        if (-not (Test-Python313)) {
            throw "Python 3.13 no se instalo correctamente. Instalalo manualmente y ejecuta este script de nuevo."
        }
    }
    
    $pythonVersion = python --version
    $pythonPath = (Get-Command python).Source
    Write-Host "      [OK] Python instalado: $pythonVersion" -ForegroundColor Green
    Write-Host "      Ubicacion: $pythonPath" -ForegroundColor Gray
    
    # Configurar variable de entorno PYTHON
    Write-Host "      Configurando variable de entorno PYTHON..." -ForegroundColor Gray
    $env:PYTHON = $pythonPath
    [System.Environment]::SetEnvironmentVariable("PYTHON", $pythonPath, "User")
    [System.Environment]::SetEnvironmentVariable("PYTHON", $pythonPath, "Machine")

    # Instalar mcp-control
    Write-Host "[3/4] Instalando mcp-control..." -ForegroundColor Yellow
    Write-Host "      (Esto puede tomar 2-3 minutos, compilando modulos nativos...)" -ForegroundColor Gray
    
    # Desinstalar version anterior si existe
    npm uninstall -g mcp-control 2>$null
    
    # Instalar mcp-control
    $output = npm install -g mcp-control 2>&1
    
    # Actualizar PATH
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
    
    # Verificar instalacion
    Start-Sleep -Seconds 3
    
    try {
        $mcpVersion = & mcp-control --version 2>&1
        if ($mcpVersion -and $mcpVersion -notmatch "error" -and $mcpVersion -notmatch "not recognized") {
            Write-Host "      [OK] mcp-control instalado: $mcpVersion" -ForegroundColor Green
        } else {
            Write-Host "      [!] mcp-control instalado pero no responde correctamente" -ForegroundColor Yellow
            Write-Host "      Ubicacion: $env:APPDATA\npm\mcp-control.cmd" -ForegroundColor Gray
        }
    } catch {
        Write-Host "      [!] mcp-control instalado pero no responde aun" -ForegroundColor Yellow
    }

    # Verificar Claude Desktop
    Write-Host "[4/4] Verificando Claude Desktop..." -ForegroundColor Yellow
    
    $claudePath = "$env:LOCALAPPDATA\Programs\Claude\Claude.exe"
    $claudeConfigPath = "$env:APPDATA\Claude\claude_desktop_config.json"
    
    if (Test-Path $claudePath) {
        Write-Host "      [OK] Claude Desktop encontrado" -ForegroundColor Green
        Write-Host "      Ubicacion: $claudePath" -ForegroundColor Gray
    } else {
        Write-Host "      [!] Claude Desktop no encontrado" -ForegroundColor Yellow
        Write-Host "      Instalalo desde: https://claude.ai/download" -ForegroundColor Yellow
    }
    
    if (Test-Path $claudeConfigPath) {
        Write-Host "      [OK] Configuracion MCP encontrada" -ForegroundColor Green
    } else {
        Write-Host "      [i] Configuracion MCP no encontrada (se creara automaticamente)" -ForegroundColor Cyan
    }

    # Exito
    Write-Host ""
    Write-Host "=========================================" -ForegroundColor Green
    Write-Host "  [OK] Windows-MCP configurado con exito!" -ForegroundColor Green
    Write-Host "=========================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Proximos pasos:" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "1. CIERRA Claude Desktop completamente" -ForegroundColor White
    Write-Host "   (Click derecho en el icono del taskbar -> Exit)" -ForegroundColor Gray
    Write-Host ""
    Write-Host "2. Vuelve a abrir Claude Desktop" -ForegroundColor White
    Write-Host ""
    Write-Host "3. En Claude Desktop:" -ForegroundColor White
    Write-Host "   - Haz clic en el menu (3 lineas arriba a la izquierda)" -ForegroundColor Gray
    Write-Host "   - Busca 'Windows-MCP' en extensiones" -ForegroundColor Gray
    Write-Host "   - Haz clic en 'Install'" -ForegroundColor Gray
    Write-Host ""
    Write-Host "4. Prueba con:" -ForegroundColor White
    Write-Host "   'Abre el Bloc de notas y escribe Hola Mundo'" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Configuracion:" -ForegroundColor Cyan
    Write-Host "  Python: $pythonVersion en $pythonPath" -ForegroundColor Gray
    Write-Host "  Node.js: $nodeVersion" -ForegroundColor Gray
    Write-Host "  mcp-control: Instalado globalmente" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Si Windows-MCP sigue sin funcionar:" -ForegroundColor Yellow
    Write-Host "  1. Verifica: python --version (debe ser 3.13+)" -ForegroundColor White
    Write-Host "  2. Verifica: mcp-control --version" -ForegroundColor White
    Write-Host "  3. Reporta en: https://github.com/luisitoys12/mcp-windows-autosetup/issues" -ForegroundColor White
    Write-Host ""

} catch {
    Write-Host ""
    Write-Host "[X] Error durante la instalacion:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host ""
    Write-Host "Por favor reporta este error en:" -ForegroundColor Yellow
    Write-Host "https://github.com/luisitoys12/mcp-windows-autosetup/issues" -ForegroundColor Yellow
    Write-Host ""
    exit 1
}