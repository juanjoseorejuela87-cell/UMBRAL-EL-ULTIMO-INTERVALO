# Exporta la demo de UMBRAL como ejecutable de Windows en builds\windows\.
# Requiere las plantillas de exportación de Godot 4.7.2 instaladas
# (Editor > Gestionar plantillas de exportación > Descargar e instalar).
# Uso: powershell -ExecutionPolicy Bypass -File tools\exportar.ps1

$ErrorActionPreference = "Stop"
$godot = "D:\Godot_v4.7.2-stable_win64_console.exe"
$raiz = Split-Path -Parent $PSScriptRoot
$plantillas = Join-Path $env:APPDATA "Godot\export_templates\4.7.2.stable"
$salida = Join-Path $raiz "builds\windows\UMBRAL.exe"

if (-not (Test-Path (Join-Path $plantillas "windows_release_x86_64.exe"))) {
    Write-Host "Faltan las plantillas de exportacion de Godot 4.7.2 en $plantillas" -ForegroundColor Red
    Write-Host "Instalalas desde el editor: Editor > Gestionar plantillas de exportacion > Descargar e instalar." -ForegroundColor Yellow
    exit 1
}

New-Item -ItemType Directory -Force (Split-Path $salida) | Out-Null
& $godot --headless --path $raiz --export-release "Windows Desktop" $salida
if ($LASTEXITCODE -ne 0 -or -not (Test-Path $salida)) {
    Write-Host "La exportacion ha fallado (codigo $LASTEXITCODE)." -ForegroundColor Red
    exit 1
}
$tamano = [math]::Round((Get-Item $salida).Length / 1MB, 1)
Write-Host "Exportado: $salida ($tamano MB)" -ForegroundColor Green
