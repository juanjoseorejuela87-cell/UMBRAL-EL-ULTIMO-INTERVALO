#!/usr/bin/env python3
"""
Generador 3D usando el motor TRELLIS de Microsoft a través de Hugging Face.
Produce modelos .glb de alta calidad con simplificación de malla (≤ 15 000 triángulos)
y texturas 1K PBR optimizadas para la Intel UHD 610.

Uso:
    python tools/generar_trellis.py [--imagen RUTA] [--salida RUTA]
"""

import argparse
import os
import shutil
import socket
import sys

_orig_getaddrinfo = socket.getaddrinfo
def patched_getaddrinfo(host, port, *args, **kwargs):
    if "hf.space" in host:
        return _orig_getaddrinfo("23.21.54.33", port, *args, **kwargs)
    return _orig_getaddrinfo(host, port, *args, **kwargs)
socket.getaddrinfo = patched_getaddrinfo

from gradio_client import Client, handle_file


def leer_token() -> str:
    token = os.environ.get("HF_TOKEN", "")
    ruta_env = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", ".env")
    if not token and os.path.exists(ruta_env):
        with open(ruta_env, encoding="utf-8") as archivo:
            for linea in archivo:
                if linea.strip().startswith("HF_TOKEN="):
                    token = linea.split("=", 1)[1].strip()
    return token


def generar_trellis(ruta_imagen: str, ruta_salida_glb: str) -> None:
    if not os.path.exists(ruta_imagen):
        sys.exit(f"Error: No existe la imagen de entrada: {ruta_imagen}")

    token = leer_token()
    headers = {"Authorization": f"Bearer {token}"} if token else {}

    print("[1/5] Conectando con Microsoft TRELLIS (Hugging Face)...")
    cliente = Client("trellis-community/TRELLIS", token=token or None, headers=headers)

    print("[2/5] Iniciando sesión (/start_session)...")
    cliente.predict(api_name="/start_session")

    print(f"[3/5] Preprocesando imagen para aislar fondo ({ruta_imagen})...")
    pre_img = cliente.predict(handle_file(ruta_imagen), api_name="/preprocess_image")

    print("[4/5] Enviando a GPU para generación de malla 3D y texturas PBR...")
    job = cliente.submit(
        image=handle_file(pre_img),
        multiimages=[],
        seed=42,
        ss_guidance_strength=7.5,
        ss_sampling_steps=12,
        slat_guidance_strength=3.0,
        slat_sampling_steps=12,
        multiimage_algo="stochastic",
        mesh_simplify=0.95,
        texture_size=1024,
        api_name="/generate_and_extract_glb"
    )

    video_res, litmodel_res, download_glb = job.result(timeout=600)
    print(f"[5/5] Descargado modelo 3D GLB en: {download_glb}")

    os.makedirs(os.path.dirname(os.path.abspath(ruta_salida_glb)), exist_ok=True)
    shutil.copy(download_glb, ruta_salida_glb)
    print(f"Éxito: Modelo 3D guardado correctamente en: {ruta_salida_glb}")
    print(f"Tamaño del archivo: {os.path.getsize(ruta_salida_glb)} bytes")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Generador TRELLIS para UMBRAL")
    parser.add_argument("--imagen", default="assets/modelos/nereth/fuente/nereth_sin_fondo.png")
    parser.add_argument("--salida", default="assets/modelos/nereth/nereth_trellis.glb")
    args = parser.parse_args()

    generar_trellis(args.imagen, args.salida)
