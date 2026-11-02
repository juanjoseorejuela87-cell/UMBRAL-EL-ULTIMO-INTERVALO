#!/usr/bin/env python3
"""Genera texto con la API de Gemini (Google) para el proyecto.

La clave se lee de GEMINI_API_KEY (variable de entorno o archivo .env, que Git
ignora) y se envía en la cabecera `x-goog-api-key`, nunca en la URL.
Solo usa la biblioteca estándar de Python.

Uso:
    python tools/gemini_texto.py --modelos                      # lista los modelos disponibles
    python tools/gemini_texto.py <prompt.md> <salida.md> [--modelo NOMBRE] [--contexto archivo ...]

El prompt y los archivos de contexto se concatenan (contexto primero).
Nota: en el plan gratuito Google puede usar las entradas y salidas para mejorar
sus productos; no enviar información privada.
"""

import argparse
import json
import os
import sys
import time
import urllib.error
import urllib.request

API = "https://generativelanguage.googleapis.com/v1beta"
RAIZ = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))


def clave() -> str:
    valor = os.environ.get("GEMINI_API_KEY", "")
    ruta = os.path.join(RAIZ, ".env")
    if not valor and os.path.exists(ruta):
        with open(ruta, encoding="utf-8") as archivo:
            for linea in archivo:
                if linea.strip().startswith("GEMINI_API_KEY="):
                    valor = linea.split("=", 1)[1].strip().strip('"')
    if not valor:
        sys.exit("ERROR: falta GEMINI_API_KEY en .env o en el entorno.")
    return valor


def peticion(ruta: str, cuerpo: dict | None = None) -> dict:
    datos = json.dumps(cuerpo).encode() if cuerpo is not None else None
    req = urllib.request.Request(API + ruta, data=datos, method="POST" if datos else "GET",
                                 headers={"x-goog-api-key": clave(), "Content-Type": "application/json"})
    for intento in range(6):
        try:
            with urllib.request.urlopen(req, timeout=300) as respuesta:
                return json.loads(respuesta.read())
        except urllib.error.HTTPError as error:
            # 429/5xx: cuota o saturación momentánea → reintentar con espera
            if error.code in (429, 500, 503) and intento < 5:
                time.sleep(10 * (intento + 1))
                continue
            sys.exit(f"ERROR HTTP {error.code}: {error.read()[:600].decode('utf-8', 'replace')}")
        except urllib.error.URLError:
            if intento < 5:
                time.sleep(3 + intento * 2)
                continue
            raise
    sys.exit("ERROR: sin respuesta")


def listar() -> None:
    for m in peticion("/models?pageSize=200").get("models", []):
        if "generateContent" in m.get("supportedGenerationMethods", []):
            print(m["name"].removeprefix("models/"), "-", m.get("displayName", ""))


def generar(texto: str, modelo: str, temperatura: float) -> str:
    cuerpo = {"contents": [{"role": "user", "parts": [{"text": texto}]}],
              "generationConfig": {"temperature": temperatura}}
    respuesta = peticion(f"/models/{modelo}:generateContent", cuerpo)
    candidatos = respuesta.get("candidates", [])
    if not candidatos:
        sys.exit("ERROR: respuesta vacía: " + json.dumps(respuesta)[:600])
    return "".join(p.get("text", "") for p in candidatos[0]["content"]["parts"])


def main() -> None:
    parser = argparse.ArgumentParser(description="Texto con Gemini")
    parser.add_argument("prompt", nargs="?")
    parser.add_argument("salida", nargs="?")
    parser.add_argument("--modelos", action="store_true")
    parser.add_argument("--modelo", default="gemini-2.5-pro")
    parser.add_argument("--temperatura", type=float, default=0.9)
    parser.add_argument("--contexto", nargs="*", default=[])
    args = parser.parse_args()
    if args.modelos:
        listar()
        return
    partes = []
    for ruta in args.contexto:
        with open(ruta, encoding="utf-8") as archivo:
            partes.append(f"=== {os.path.basename(ruta)} ===\n{archivo.read()}")
    with open(args.prompt, encoding="utf-8") as archivo:
        partes.append(archivo.read())
    resultado = generar("\n\n".join(partes), args.modelo, args.temperatura)
    os.makedirs(os.path.dirname(os.path.abspath(args.salida)), exist_ok=True)
    with open(args.salida, "w", encoding="utf-8", newline="\n") as archivo:
        archivo.write(resultado)
    print("LISTO:", args.salida, len(resultado), "caracteres")


if __name__ == "__main__":
    main()
