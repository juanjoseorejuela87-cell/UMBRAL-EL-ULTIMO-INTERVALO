# Script de comprobación y sincronización automática de UMBRAL
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "   UMBRAL: Monitor Automático del Repo   " -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan

# 1. Comprobar Git
Write-Host "`n[1/3] Sincronizando con GitHub..." -ForegroundColor Yellow
& "D:\Git\cmd\git.exe" pull --rebase

# 2. Comprobar tareas pendientes
Write-Host "`n[2/3] Revisando tareas en documentation/tareas/..." -ForegroundColor Yellow
$tareas = Get-ChildItem -Path "documentation\tareas\TAREA-*.md"
foreach ($t in $tareas) {
    $contenido = Get-Content $t.FullName -Raw
    $estado = "DESCONOCIDO"
    if ($contenido -match "- \*\*Estado:\*\* ([^\r\n]+)") {
        $estado = $matches[1]
    }
    $color = "Gray"
    if ($estado -match "ABIERTO") { $color = "Red" }
    elseif ($estado -match "ENTREGADO") { $color = "Yellow" }
    elseif ($estado -match "ACEPTADO") { $color = "Green" }
    
    Write-Host "  - $($t.Name): $estado" -ForegroundColor $color
}

# 3. Correr pruebas headless de Godot
Write-Host "`n[3/3] Ejecutando pruebas automáticas de Godot..." -ForegroundColor Yellow
& "D:\Godot_v4.7.2-stable_win64_console.exe" --headless --path D:\UMBRAL -s res://tests/test_movimiento.gd

Write-Host "`n=========================================" -ForegroundColor Cyan
Write-Host "   Comprobación finalizada con éxito     " -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
