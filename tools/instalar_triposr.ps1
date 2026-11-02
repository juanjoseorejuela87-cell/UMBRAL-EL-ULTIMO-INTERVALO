# tools/instalar_triposr.ps1
# Instalacion automatizada e idempotente de TripoSR local en CPU para UMBRAL (TAREA-017)
# Requiere Python 3.12 y Git instalados en el sistema.

$ErrorActionPreference = "Stop"

$RaizRepo = Split-Path -Parent $PSScriptRoot
$CarpetaIA = Join-Path $RaizRepo "ia"
$CarpetaTripo = Join-Path $CarpetaIA "triposr"
$VenvDir = Join-Path $CarpetaTripo "venv"
$PythonVenv = Join-Path $VenvDir "Scripts\python.exe"
$PipVenv = Join-Path $VenvDir "Scripts\pip.exe"

Write-Host "=== [1/5] Preparando carpeta de IA y aislamiento para Godot ===" -ForegroundColor Cyan
if (-not (Test-Path $CarpetaIA)) {
    New-Item -ItemType Directory -Path $CarpetaIA -Force | Out-Null
}
$Gdignore = Join-Path $CarpetaIA ".gdignore"
if (-not (Test-Path $Gdignore)) {
    New-Item -ItemType File -Path $Gdignore -Force | Out-Null
    Write-Host "Creado archivo .gdignore para aislar la carpeta de Godot." -ForegroundColor Green
}

Write-Host "=== [2/5] Repositorio oficial de TripoSR ===" -ForegroundColor Cyan
if (-not (Test-Path $CarpetaTripo)) {
    Write-Host "Clonando VAST-AI-Research/TripoSR..." -ForegroundColor Yellow
    & "D:\Git\cmd\git.exe" clone https://github.com/VAST-AI-Research/TripoSR.git $CarpetaTripo
} else {
    Write-Host "TripoSR ya esta presente en: $CarpetaTripo" -ForegroundColor Green
}

Write-Host "=== [3/5] Entorno virtual de Python ===" -ForegroundColor Cyan
if (-not (Test-Path $PythonVenv)) {
    Write-Host "Creando entorno virtual en $VenvDir..." -ForegroundColor Yellow
    python -m venv $VenvDir
} else {
    Write-Host "Entorno virtual ya existente." -ForegroundColor Green
}

Write-Host "=== [4/5] Instalando PyTorch CPU y dependencias base ===" -ForegroundColor Cyan
& $PipVenv install --upgrade pip
& $PipVenv install torch torchvision --index-url https://download.pytorch.org/whl/cpu

# Dependencias necesarias para TripoSR sin torchmcubes (usando PyMCubes o scikit-image)
Write-Host "Instalando dependencias de TripoSR..." -ForegroundColor Yellow
& $PipVenv install omegaconf==2.3.0 Pillow einops==0.7.0 "transformers<4.45,>=4.40" trimesh "rembg[cpu]" onnxruntime huggingface-hub "imageio[ffmpeg]" xatlas moderngl PyMCubes scikit-image

Write-Host "=== [5/5] Aplicando parche de isosuperficie compatible con CPU (PyMCubes / skimage) ===" -ForegroundColor Cyan
$IsosurfaceFile = Join-Path $CarpetaTripo "tsr\models\isosurface.py"
if (Test-Path $IsosurfaceFile) {
    $Contenido = Get-Content $IsosurfaceFile -Raw
    if (-not $Contenido.Contains("# PATCH_UMBRAL_CPU")) {
        $Parche = @"
# PATCH_UMBRAL_CPU: reemplazo de torchmcubes por PyMCubes / skimage para ejecucion en CPU sin compilador C++
from typing import Callable, Optional, Tuple
import numpy as np
import torch
import torch.nn as nn

try:
    import mcubes
    def _marching_cubes_cpu(level: torch.Tensor, thresh: float = 0.0):
        arr = level.detach().cpu().numpy()
        verts, faces = mcubes.marching_cubes(arr, thresh)
        return torch.from_numpy(verts.copy()).float(), torch.from_numpy(faces.copy()).long()
except ImportError:
    from skimage.measure import marching_cubes as _skimage_mc
    def _marching_cubes_cpu(level: torch.Tensor, thresh: float = 0.0):
        arr = level.detach().cpu().numpy()
        verts, faces, _, _ = _skimage_mc(arr, thresh)
        return torch.from_numpy(verts.copy()).float(), torch.from_numpy(faces.copy()).long()

class IsosurfaceHelper(nn.Module):
    points_range: Tuple[float, float] = (0, 1)

    @property
    def grid_vertices(self) -> torch.FloatTensor:
        raise NotImplementedError

class MarchingCubeHelper(IsosurfaceHelper):
    def __init__(self, resolution: int) -> None:
        super().__init__()
        self.resolution = resolution
        self.mc_func: Callable = _marching_cubes_cpu
        self._grid_vertices: Optional[torch.FloatTensor] = None

    @property
    def grid_vertices(self) -> torch.FloatTensor:
        if self._grid_vertices is None:
            x, y, z = (
                torch.linspace(*self.points_range, self.resolution),
                torch.linspace(*self.points_range, self.resolution),
                torch.linspace(*self.points_range, self.resolution),
            )
            x, y, z = torch.meshgrid(x, y, z, indexing="ij")
            verts = torch.cat(
                [x.reshape(-1, 1), y.reshape(-1, 1), z.reshape(-1, 1)], dim=-1
            ).reshape(-1, 3)
            self._grid_vertices = verts
        return self._grid_vertices

    def forward(
        self,
        level: torch.FloatTensor,
    ) -> Tuple[torch.FloatTensor, torch.LongTensor]:
        level = -level.view(self.resolution, self.resolution, self.resolution)
        v_pos, t_pos_idx = self.mc_func(level, 0.0)
        v_pos = v_pos[..., [2, 1, 0]]
        v_pos = v_pos / (self.resolution - 1.0)
        return v_pos.to(level.device), t_pos_idx.to(level.device)
"@
        Set-Content -Path $IsosurfaceFile -Value $Parche -Encoding UTF8
        Write-Host "Parche de extraccion isosuperficie aplicado con exito." -ForegroundColor Green
    } else {
        Write-Host "El parche de isosuperficie ya estaba aplicado." -ForegroundColor Green
    }
}

$SystemFile = Join-Path $CarpetaTripo "tsr\system.py"
if (Test-Path $SystemFile) {
    $ContenidoSys = Get-Content $SystemFile -Raw
    if ($ContenidoSys.Contains('ckpt = torch.load(weight_path, map_location="cpu")') -and -not $ContenidoSys.Contains('mmap=True')) {
        $ContenidoSys = $ContenidoSys.Replace('ckpt = torch.load(weight_path, map_location="cpu")', "try:`n            ckpt = torch.load(weight_path, map_location=`"cpu`", mmap=True)`n        except Exception:`n            ckpt = torch.load(weight_path, map_location=`"cpu`")")
        Set-Content -Path $SystemFile -Value $ContenidoSys -Encoding UTF8
        Write-Host "Parche de carga ligera mmap aplicado en tsr/system.py." -ForegroundColor Green
    }
}

$RunFile = Join-Path $CarpetaTripo "run.py"
if (Test-Path $RunFile) {
    $ContenidoRun = Get-Content $RunFile -Raw
    if ($ContenidoRun.Contains('out_mesh_path = os.path.join(output_dir, str(i), f"mesh.{args.model_save_format}")') -and -not $ContenidoRun.Contains('os.makedirs(os.path.dirname(out_mesh_path), exist_ok=True)')) {
        $ContenidoRun = $ContenidoRun.Replace('out_mesh_path = os.path.join(output_dir, str(i), f"mesh.{args.model_save_format}")', 'out_mesh_path = os.path.join(output_dir, str(i), f"mesh.{args.model_save_format}")`n    os.makedirs(os.path.dirname(out_mesh_path), exist_ok=True)')
        Set-Content -Path $RunFile -Value $ContenidoRun -Encoding UTF8
        Write-Host "Parche de creacion de directorio en run.py aplicado." -ForegroundColor Green
    }
}

Write-Host "=== TripoSR instalado y configurado correctamente para CPU ===" -ForegroundColor Green
