# Comprobacion del repositorio UMBRAL: sincroniza, muestra el estado de los
# encargos y ejecuta todas las pruebas automaticas de Godot.
# Uso: powershell -ExecutionPolicy Bypass -File tools\comprobar.ps1
# Idea original: Antigravity (auto.ps1). Codigo de salida = pruebas fallidas.

$ErrorActionPreference = "Stop"
$git = "D:\Git\cmd\git.exe"
$godot = "D:\Godot_v4.7.2-stable_win64_console.exe"
$raiz = Split-Path -Parent $PSScriptRoot
Set-Location $raiz

function Titulo([string]$texto) {
    Write-Host "`n$texto" -ForegroundColor Yellow
}

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "   UMBRAL: comprobacion del repositorio  " -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan

# 1. Sincronizar sin reescribir historial (AGENTS.md)
Titulo "[1/3] Sincronizando con GitHub..."
$cambiosLocales = & $git status --porcelain
if ($cambiosLocales) {
    Write-Host "  Hay cambios sin commit; se omite la sincronizacion." -ForegroundColor DarkYellow
} else {
    & $git pull --ff-only
    if ($LASTEXITCODE -ne 0) {
        Write-Host "  La historia local y la remota han divergido. Revisalo a mano." -ForegroundColor Red
    }
}

# 2. Estado de los encargos
Titulo "[2/3] Encargos en documentation/tareas/..."
$tareas = Get-ChildItem -Path (Join-Path $raiz "documentation\tareas") -Filter "TAREA-*.md"
foreach ($t in $tareas) {
    $contenido = Get-Content $t.FullName -Raw -Encoding UTF8
    $estado = "DESCONOCIDO"
    if ($contenido -match "- \*\*Estado:\*\* ([^\r\n]+)") {
        $estado = $matches[1].Trim()
    }
    $color = switch -Regex ($estado) {
        "ABIERTO" { "Red" }
        "ENTREGADO" { "Yellow" }
        "CAMBIOS" { "Magenta" }
        "ACEPTADO" { "Green" }
        default { "Gray" }
    }
    Write-Host "  - $($t.Name): $estado" -ForegroundColor $color
}

# 3. Pruebas automaticas (todas las de tests/)
Titulo "[3/3] Pruebas automaticas de Godot..."
$fallidas = 0
$pruebas = Get-ChildItem -Path (Join-Path $raiz "tests") -Filter "test_*.gd"
$limiteSegundos = 120
foreach ($p in $pruebas) {
    Write-Host "  > $($p.Name)"
    # Un error de compilacion deja la prueba colgada sin llamar a quit():
    # se limita el tiempo y se cuenta como fallo.
    $salida = Join-Path $env:TEMP "umbral_$($p.BaseName).log"
    $proceso = Start-Process -FilePath $godot -ArgumentList "--headless", "--path", $raiz, "-s", "res://tests/$($p.Name)" `
        -NoNewWindow -PassThru -RedirectStandardOutput $salida -RedirectStandardError "$salida.err"
    $null = $proceso.Handle  # sin esto PowerShell no conserva ExitCode
    $terminado = $proceso.WaitForExit($limiteSegundos * 1000)
    Get-Content $salida -Encoding UTF8 | Select-Object -Skip 2 | ForEach-Object { Write-Host $_ }
    Get-Content "$salida.err" -Encoding UTF8 | Where-Object { $_ -match "ERROR" } | ForEach-Object { Write-Host "  $_" -ForegroundColor Red }
    if (-not $terminado) {
        $proceso.Kill()
        $fallidas++
        Write-Host "  FALLO: $($p.Name) no termino en $limiteSegundos s (error de compilacion?)" -ForegroundColor Red
    } elseif ($proceso.ExitCode -ne 0) {
        $fallidas++
        Write-Host "  FALLO: $($p.Name) (codigo $($proceso.ExitCode))" -ForegroundColor Red
    }
}

Write-Host "`n=========================================" -ForegroundColor Cyan
if ($fallidas -eq 0) {
    Write-Host "   Todo correcto ($($pruebas.Count) pruebas)" -ForegroundColor Green
} else {
    Write-Host "   $fallidas de $($pruebas.Count) pruebas fallidas" -ForegroundColor Red
}
Write-Host "=========================================" -ForegroundColor Cyan
exit $fallidas
