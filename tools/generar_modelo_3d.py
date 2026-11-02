#!/usr/bin/env python3
"""
Herramienta para generar modelos 3D a partir de una imagen de referencia usando InstantMesh en Hugging Face.
Uso:
    python tools/generar_modelo_3d.py --imagen scenes/jugador/modelos/nereth_ref.png --salida scenes/jugador/modelos/nereth.glb
"""

import argparse
import os
import shutil
import sys
from gradio_client import Client, handle_file


def generar_3d(ruta_imagen: str, ruta_salida_glb: str) -> None:
    if not os.path.exists(ruta_imagen):
        print(f"Error: No existe la imagen de entrada: {ruta_imagen}")
        sys.exit(1)

    print(f"[1/4] Conectando con InstantMesh en Hugging Face...")
    cliente = Client("TencentARC/InstantMesh")

    print(f"[2/4] Preprocesando imagen ({ruta_imagen})...")
    resultado_prep = cliente.predict(
        input_image=handle_file(ruta_imagen),
        do_remove_background=True,
        api_name="/preprocess"
    )
    img_procesada = resultado_prep if isinstance(resultado_prep, str) else resultado_prep.get("path")
    print(f"  Imagen lista: {img_procesada}")

    print(f"[3/4] Generando vistas múltiples (Multi-View Diffusion)...")
    cliente.predict(
        input_image=handle_file(img_procesada),
        sample_steps=75,
        sample_seed=42,
        api_name="/generate_mvs"
    )

    print(f"[4/4] Reconstruyendo malla 3D y texturas (.glb)...")
    res_obj, res_glb = cliente.predict(api_name="/make3d")
    print(f"  Modelo generado en: {res_glb}")

    os.makedirs(os.path.dirname(os.path.abspath(ruta_salida_glb)), exist_ok=True)
    shutil.copy(res_glb, ruta_salida_glb)
    print(f"Exito: Modelo 3D guardado correctamente en: {ruta_salida_glb}")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Generador Image-to-3D para UMBRAL")
    parser.add_argument("--imagen", default="scenes/jugador/modelos/nereth_ref.png", help="Ruta de la imagen de entrada")
    parser.add_argument("--salida", default="scenes/jugador/modelos/nereth.glb", help="Ruta del archivo .glb resultante")
    args = parser.parse_args()

    generar_3d(args.imagen, args.salida)
