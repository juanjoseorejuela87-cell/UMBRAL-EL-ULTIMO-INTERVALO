#!/usr/bin/env python3
"""
Envoltorio para TripoSR local en CPU (TAREA-017 / D-038).
Genera un archivo 3D GLB a partir de una imagen de referencia sin GPU y sin conexion externa.
Uso:
    python tools/triposr_generar.py <imagen> <salida.glb> [--resolucion 256] [--sin-quitar-fondo]
"""

import argparse
import os
import shutil
import subprocess
import sys
import time

def generar_modelo_triposr(
    ruta_imagen: str,
    ruta_salida_glb: str,
    resolucion: int = 256,
    sin_quitar_fondo: bool = False,
    hornear_textura: bool = False
) -> int:
    inicio = time.time()
    
    # 1. Localizar la instalacion de TripoSR
    raiz_repo = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    dir_triposr = os.path.join(raiz_repo, "ia", "triposr")
    dir_venv_python = os.path.join(dir_triposr, "venv", "Scripts", "python.exe")
    script_run = os.path.join(dir_triposr, "run.py")

    if not os.path.exists(dir_triposr) or not os.path.exists(dir_venv_python):
        print(f"ERROR: No se encontro el entorno de TripoSR en: {dir_triposr}")
        print("Para instalarlo por primera vez ejecuta:")
        print("  powershell -ExecutionPolicy Bypass -File tools/instalar_triposr.ps1")
        return 1

    if not os.path.exists(ruta_imagen):
        print(f"ERROR: La imagen de entrada no existe: {ruta_imagen}")
        return 1

    dir_temporal_salida = os.path.join(dir_triposr, "salida_temp")
    if os.path.exists(dir_temporal_salida):
        shutil.rmtree(dir_temporal_salida, ignore_errors=True)
    os.makedirs(dir_temporal_salida, exist_ok=True)

    print(f"=== Generando modelo 3D con TripoSR (CPU) ===", flush=True)
    print(f"Imagen de entrada: {ruta_imagen}", flush=True)
    print(f"Resolucion marching cubes: {resolucion}", flush=True)

    imagen_a_usar = os.path.abspath(ruta_imagen)
    script_preparar = os.path.join(raiz_repo, "tools", "triposr_preparar_imagen.py")

    if not sin_quitar_fondo and os.path.exists(script_preparar):
        print("Preparando imagen con modelo ligero u2netp...", flush=True)
        img_temp = os.path.join(dir_temporal_salida, "preparada.png")
        proc_prep = subprocess.run(
            [dir_venv_python, script_preparar, imagen_a_usar, img_temp],
            cwd=raiz_repo,
            text=True
        )
        if proc_prep.returncode == 0 and os.path.exists(img_temp):
            imagen_a_usar = img_temp
            sin_quitar_fondo = True

    comando = [
        dir_venv_python,
        script_run,
        imagen_a_usar,
        "--device", "cpu",
        "--mc-resolution", str(resolucion),
        "--output-dir", os.path.abspath(dir_temporal_salida),
        "--model-save-format", "glb"
    ]

    if sin_quitar_fondo:
        comando.append("--no-remove-bg")
    if hornear_textura:
        comando.append("--bake-texture")

    env = os.environ.copy()
    env["PYTHONUNBUFFERED"] = "1"

    proceso = subprocess.run(
        comando,
        cwd=dir_triposr,
        text=True,
        env=env
    )

    if proceso.returncode != 0:
        print(f"ERROR: TripoSR finalizo con codigo de error {proceso.returncode}")
        return proceso.returncode

    # Buscar el archivo .glb generado (usualmente en salida_temp/0/mesh.glb)
    glb_encontrado = None
    for raiz, _, archivos in os.walk(dir_temporal_salida):
        for arch in archivos:
            if arch.lower().endswith(".glb"):
                glb_encontrado = os.path.join(raiz, arch)
                break
        if glb_encontrado:
            break

    if not glb_encontrado or not os.path.exists(glb_encontrado):
        print("ERROR: No se encontro ningun archivo .glb en la salida generada.")
        return 1

    # Mover el archivo a la ruta final
    dir_salida = os.path.dirname(os.path.abspath(ruta_salida_glb))
    os.makedirs(dir_salida, exist_ok=True)
    shutil.copyfile(glb_encontrado, ruta_salida_glb)
    shutil.rmtree(dir_temporal_salida, ignore_errors=True)

    duracion = time.time() - inicio
    tam_kb = os.path.getsize(ruta_salida_glb) / 1024.0

    print(f"=== Modelo generado con exito ===")
    print(f"Destino: {ruta_salida_glb}")
    print(f"Tamano: {tam_kb:.1f} KB")
    print(f"Tiempo total empleado: {duracion:.2f} s")
    return 0

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Generador 3D con TripoSR en CPU")
    parser.add_argument("imagen", help="Ruta de la imagen de entrada")
    parser.add_argument("salida", help="Ruta del archivo GLB de salida")
    parser.add_argument("--resolucion", type=int, default=256, help="Resolucion de la malla (defecto: 256)")
    parser.add_argument("--sin-quitar-fondo", action="store_true", help="No eliminar el fondo de la imagen")
    parser.add_argument("--hornear-textura", action="store_true", help="Hornear atlas de textura UV")
    args = parser.parse_args()

    sys.exit(
        generar_modelo_triposr(
            ruta_imagen=args.imagen,
            ruta_salida_glb=args.salida,
            resolucion=args.resolucion,
            sin_quitar_fondo=args.sin_quitar_fondo,
            hornear_textura=args.hornear_textura
        )
    )
