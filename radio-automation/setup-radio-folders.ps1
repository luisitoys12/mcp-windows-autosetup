#Requires -RunAsAdministrator

<#
.SYNOPSIS
    Crea estructura de carpetas para automatizacion de radio
.DESCRIPTION
    Crea todas las carpetas necesarias para ZaraRadio:
    - Music/musica (canciones por genero)
    - Music/Spots (cunas comerciales, IDs de estacion, promos)
    - Music/Programa Gob (capsulas y avisos oficiales)
.EXAMPLE
    .\setup-radio-folders.ps1
#>

$baseDir = "C:\Users\Administrator\Music"

Write-Host ""
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "  Configuracion de Radio Automation" -ForegroundColor Cyan
Write-Host "  EstacionKusMedias Radio Setup" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Creando estructura de carpetas en: $baseDir" -ForegroundColor Yellow
Write-Host ""

try {
    # Crear carpeta base si no existe
    if (-not (Test-Path $baseDir)) {
        New-Item -ItemType Directory -Path $baseDir -Force | Out-Null
    }

    # === MUSICA ===
    Write-Host "[1/3] Creando carpetas de MUSICA..." -ForegroundColor Green
    
    $musicaDir = "$baseDir\musica"
    $generos = @(
        "Pop",
        "Rock",
        "Regional Mexicano",
        "Baladas",
        "Electronica",
        "Hip Hop",
        "Indie",
        "Clasicos",
        "Novedades"
    )
    
    foreach ($genero in $generos) {
        $path = "$musicaDir\$genero"
        if (-not (Test-Path $path)) {
            New-Item -ItemType Directory -Path $path -Force | Out-Null
            Write-Host "      [OK] Creado: $genero" -ForegroundColor Gray
        }
    }
    
    # README para musica
    $musicaReadme = @"
INSTRUCCIONES - CARPETA MUSICA
================================

Coloca tus archivos de musica (MP3, WAV, etc) en las subcarpetas por genero.

Formato recomendado de archivos:
- Artista - Titulo.mp3
- Bitrate: 128-320 kbps
- Formato: MP3 o WAV

Ejemplos:
- Pop/Dua Lipa - Levitating.mp3
- Rock/Imagine Dragons - Believer.mp3
- Regional Mexicano/Banda MS - El Color de Tus Ojos.mp3

ZaraRadio escanea automaticamente estas carpetas.

Tips:
- Usa ID3 tags correctos (artista, titulo, album)
- Normaliza el volumen con MP3Gain
- Evita silencios al inicio/final de las canciones
"@
    
    $musicaReadme | Out-File -FilePath "$musicaDir\README.txt" -Encoding UTF8

    # === SPOTS ===
    Write-Host "[2/3] Creando carpetas de SPOTS (publicidad)..." -ForegroundColor Green
    
    $spotsDir = "$baseDir\Spots"
    $tiposSpots = @(
        "IDs Estacion",
        "Cunas Comerciales",
        "Promos Internas",
        "Jingles",
        "Efectos"
    )
    
    foreach ($tipo in $tiposSpots) {
        $path = "$spotsDir\$tipo"
        if (-not (Test-Path $path)) {
            New-Item -ItemType Directory -Path $path -Force | Out-Null
            Write-Host "      [OK] Creado: $tipo" -ForegroundColor Gray
        }
    }
    
    # README para spots
    $spotsReadme = @"
INSTRUCCIONES - CARPETA SPOTS
================================

Aqui van todos los elementos de produccion de la radio:

1. IDs Estacion:
   - RunaRadio IDs ("Escuchas RunaRadio...")
   - RadioAventuraMX IDs
   - Duracion: 5-15 segundos
   - Se insertan cada 3-5 canciones

2. Cunas Comerciales:
   - Anuncios de patrocinadores
   - Spots publicitarios vendidos
   - Duracion: 20-60 segundos

3. Promos Internas:
   - Promociones de programas
   - Redes sociales ("Siguenos en...")
   - Eventos especiales

4. Jingles:
   - Cortinillas musicales
   - Transiciones
   - Duracion: 3-10 segundos

5. Efectos:
   - Efectos de sonido especiales
   - Sweepers

Formato recomendado:
- MP3 320kbps o WAV
- Volumen normalizado (-14 LUFS)
- Nombre descriptivo: ID_RunaRadio_01.mp3
"@
    
    $spotsReadme | Out-File -FilePath "$spotsDir\README.txt" -Encoding UTF8

    # === PROGRAMA GOB ===
    Write-Host "[3/3] Creando carpetas de PROGRAMA GOB..." -ForegroundColor Green
    
    $gobDir = "$baseDir\Programa Gob"
    $tiposGob = @(
        "Capsulas Informativas",
        "Avisos Oficiales",
        "Mensajes Salud",
        "Campanas Sociales"
    )
    
    foreach ($tipo in $tiposGob) {
        $path = "$gobDir\$tipo"
        if (-not (Test-Path $path)) {
            New-Item -ItemType Directory -Path $path -Force | Out-Null
            Write-Host "      [OK] Creado: $tipo" -ForegroundColor Gray
        }
    }
    
    # README para gobierno
    $gobReadme = @"
INSTRUCCIONES - PROGRAMA GOB
================================

Contenido institucional y de utilidad publica:

1. Capsulas Informativas:
   - Informacion de gobierno
   - Tips y consejos
   - Duracion: 30-90 segundos

2. Avisos Oficiales:
   - Comunicados oficiales
   - Alertas importantes
   - Transmision obligatoria

3. Mensajes Salud:
   - Campanas de salud publica
   - Prevencion
   - Covid, vacunacion, etc

4. Campanas Sociales:
   - Igualdad de genero
   - No violencia
   - Medio ambiente

NOTA IMPORTANTE:
- Algunos contenidos pueden ser de transmision obligatoria
- Verifica requisitos legales de tu region
- Mantener registro de reproduccion para reportes

Rotacion sugerida:
- 1 capsula cada hora
- Avisos oficiales segun indicaciones
"@
    
    $gobReadme | Out-File -FilePath "$gobDir\README.txt" -Encoding UTF8

    # Resumen
    Write-Host ""
    Write-Host "=========================================" -ForegroundColor Green
    Write-Host "  [OK] Estructura creada exitosamente!" -ForegroundColor Green
    Write-Host "=========================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Carpetas creadas en: $baseDir" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Estructura:" -ForegroundColor Yellow
    Write-Host "  musica/" -ForegroundColor White
    foreach ($g in $generos) {
        Write-Host "    - $g/" -ForegroundColor Gray
    }
    Write-Host ""
    Write-Host "  Spots/" -ForegroundColor White
    foreach ($s in $tiposSpots) {
        Write-Host "    - $s/" -ForegroundColor Gray
    }
    Write-Host ""
    Write-Host "  Programa Gob/" -ForegroundColor White
    foreach ($p in $tiposGob) {
        Write-Host "    - $p/" -ForegroundColor Gray
    }
    Write-Host ""
    Write-Host "Proximos pasos:" -ForegroundColor Cyan
    Write-Host "  1. Sube tus archivos de musica a las carpetas correspondientes" -ForegroundColor White
    Write-Host "  2. Crea o sube tus IDs de estacion (RunaRadio, RadioAventuraMX)" -ForegroundColor White
    Write-Host "  3. Agrega spots publicitarios y contenido de gobierno" -ForegroundColor White
    Write-Host "  4. Ejecuta: .\install-zararadio.ps1" -ForegroundColor White
    Write-Host "  5. Configura la playlist en ZaraRadio" -ForegroundColor White
    Write-Host ""
    Write-Host "Lee los archivos README.txt en cada carpeta para mas info." -ForegroundColor Gray
    Write-Host ""

} catch {
    Write-Host ""
    Write-Host "[X] Error al crear estructura:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host ""
    exit 1
}