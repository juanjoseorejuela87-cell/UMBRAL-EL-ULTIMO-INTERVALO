#!/usr/bin/env python3
"""Genera una imagen con un modelo de imagen de Gemini (p. ej. «Nano Banana»).

Pensado para referencias de personajes y enemigos que luego se convierten en 3D
con TripoSR (tools/triposr_generar.py). Misma clave y mismas precauciones que
tools/gemini_texto.py (clave en cabecera; en el plan gratuito Google puede usar
las entradas y salidas para mejorar sus productos).

Uso:
    python tools/gemini_imagen.py "<descripción>" <salida.png> [--modelo NOMBRE]
"""

import argparse
import base64
import json
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from gemini_texto import peticion  # noqa: E402


def main() -> None:
    parser = argparse.ArgumentParser(description="Imagen con Gemini")
    parser.add_argument("descripcion")
    parser.add_argument("salida")
    parser.add_argument("--modelo", default="gemini-2.5-flash-image")
    args = parser.parse_args()
    cuerpo = {"contents": [{"role": "user", "parts": [{"text": args.descripcion}]}],
              "generationConfig": {"responseModalities": ["IMAGE", "TEXT"]}}
    respuesta = peticion(f"/models/{args.modelo}:generateContent", cuerpo)
    for candidato in respuesta.get("candidates", []):
        for parte in candidato.get("content", {}).get("parts", []):
            datos = parte.get("inlineData") or parte.get("inline_data")
            if datos and datos.get("data"):
                os.makedirs(os.path.dirname(os.path.abspath(args.salida)), exist_ok=True)
                with open(args.salida, "wb") as archivo:
                    archivo.write(base64.b64decode(datos["data"]))
                print("LISTO:", args.salida)
                return
    sys.exit("ERROR: la respuesta no trae imagen: " + json.dumps(respuesta)[:500])


if __name__ == "__main__":
    main()
