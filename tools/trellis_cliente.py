#!/usr/bin/env python3
"""Genera un modelo 3D con TRELLIS.2 (Microsoft, licencia MIT) a partir de una imagen,
usando la API pública de su demo en Hugging Face (microsoft/TRELLIS.2).

Solo usa la biblioteca estándar de Python. Si hay una clave de Hugging Face en la
variable de entorno HF_TOKEN o en el archivo .env (HF_TOKEN=...), se usa para tener
más cuota de GPU; sin ella funciona con la cuota anónima.

Uso:
    python tools/trellis_cliente.py <imagen.png> <salida.glb> [--semilla N] [--caras N] [--textura N]
"""

import argparse
import json
import os
import random
import string
import sys
import time
import urllib.error
import urllib.request
import uuid

SERVIDOR = "https://microsoft-trellis-2.hf.space"
PREFIJO = SERVIDOR + "/gradio_api"


def leer_token() -> str:
    token = os.environ.get("HF_TOKEN", "")
    ruta_env = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", ".env")
    if not token and os.path.exists(ruta_env):
        with open(ruta_env, encoding="utf-8") as archivo:
            for linea in archivo:
                if linea.strip().startswith("HF_TOKEN="):
                    token = linea.split("=", 1)[1].strip()
    return token


TOKEN = leer_token()


def cabeceras(extra: dict | None = None) -> dict:
    h = {"User-Agent": "umbral-trellis-cliente/1.0"}
    if TOKEN:
        h["Authorization"] = "Bearer " + TOKEN
    if extra:
        h.update(extra)
    return h


def abrir(peticion: urllib.request.Request, timeout: int):
    """urlopen con reintentos: la resolución DNS de este equipo falla a ratos."""
    for intento in range(8):
        try:
            return urllib.request.urlopen(peticion, timeout=timeout)
        except urllib.error.URLError as error:
            if isinstance(error, urllib.error.HTTPError) or intento == 7:
                raise
            time.sleep(2 + intento * 2)


def subir(ruta: str) -> str:
    limite = "----umbral" + uuid.uuid4().hex
    with open(ruta, "rb") as archivo:
        datos = archivo.read()
    nombre = os.path.basename(ruta)
    cuerpo = (f"--{limite}\r\nContent-Disposition: form-data; name=\"files\"; filename=\"{nombre}\"\r\n"
              f"Content-Type: image/png\r\n\r\n").encode() + datos + f"\r\n--{limite}--\r\n".encode()
    peticion = urllib.request.Request(PREFIJO + "/upload", data=cuerpo, method="POST",
                                      headers=cabeceras({"Content-Type": "multipart/form-data; boundary=" + limite}))
    with abrir(peticion, timeout=120) as respuesta:
        return json.loads(respuesta.read())[0]


# Índices internos de la demo (dependencias de /config): la sesión de Gradio
# guarda el estado entre «generar» y «extraer GLB», así que se usa la cola.
FN_START_SESSION = 2
FN_PREPROCESS = 4
FN_IMAGE_TO_3D = 7
FN_EXTRACT_GLB = 9


def llamar(fn_index: int, datos: list, sesion: str, disparador: int | None = None, espera_max: int = 1500) -> list:
    """Encola una función en la cola de Gradio y espera su resultado."""
    cuerpo = json.dumps({"data": datos, "event_data": None, "fn_index": fn_index,
                         "trigger_id": disparador, "session_hash": sesion}).encode()
    peticion = urllib.request.Request(PREFIJO + "/queue/join", data=cuerpo, method="POST",
                                      headers=cabeceras({"Content-Type": "application/json"}))
    with abrir(peticion, timeout=120) as respuesta:
        evento = json.loads(respuesta.read())["event_id"]
    peticion = urllib.request.Request(f"{PREFIJO}/queue/data?session_hash={sesion}", headers=cabeceras())
    inicio = time.time()
    with abrir(peticion, timeout=espera_max) as respuesta:
        for linea_bytes in respuesta:
            linea = linea_bytes.decode("utf-8", "replace").strip()
            if not linea.startswith("data:"):
                continue
            mensaje = json.loads(linea[5:].strip())
            if mensaje.get("event_id") not in (None, evento):
                continue
            tipo = mensaje.get("msg")
            if tipo == "estimation" and mensaje.get("rank") is not None:
                print(f"    en cola: puesto {mensaje.get('rank')}", flush=True)
            elif tipo == "process_completed":
                if not mensaje.get("success", False):
                    raise RuntimeError(f"función {fn_index}: error en la demo: {mensaje.get('output')}")
                return mensaje["output"]["data"]
            if time.time() - inicio > espera_max:
                break
    raise RuntimeError(f"función {fn_index}: sin respuesta completa")


def archivo(info: dict) -> dict:
    return {"path": info["path"], "meta": {"_type": "gradio.FileData"}}


def descargar(info: dict, destino: str) -> None:
    url = info.get("url") or f"{PREFIJO}/file={info['path']}"
    peticion = urllib.request.Request(url, headers=cabeceras())
    with abrir(peticion, timeout=300) as respuesta, open(destino, "wb") as salida:
        salida.write(respuesta.read())


def main() -> None:
    parser = argparse.ArgumentParser(description="Imagen → modelo 3D con TRELLIS.2")
    parser.add_argument("imagen")
    parser.add_argument("salida")
    parser.add_argument("--semilla", type=int, default=1)
    parser.add_argument("--caras", type=int, default=60000, help="objetivo de simplificación de la demo")
    parser.add_argument("--textura", type=int, default=2048)
    args = parser.parse_args()

    sesion = "".join(random.choices(string.ascii_lowercase + string.digits, k=11))
    print("[1/5] Subiendo imagen…", flush=True)
    ruta = subir(args.imagen)
    print("[2/5] Abriendo sesión…", flush=True)
    llamar(FN_START_SESSION, [], sesion, disparador=0)
    print("[3/5] Preparando imagen (quitar fondo)…", flush=True)
    imagen = llamar(FN_PREPROCESS, [archivo({"path": ruta})], sesion, disparador=4)[0]
    print("[4/5] Generando el modelo 3D (puede tardar minutos)…", flush=True)
    llamar(FN_IMAGE_TO_3D, [archivo(imagen), args.semilla, "1024",
                            7.5, 0.7, 12, 5.0, 7.5, 0.5, 12, 3.0, 1.0, 0.0, 12, 3.0], sesion)
    print("[5/5] Extrayendo el GLB…", flush=True)
    resultado = llamar(FN_EXTRACT_GLB, [None, args.caras, args.textura], sesion)
    glb = resultado[1] if len(resultado) > 1 and resultado[1] else resultado[0]
    os.makedirs(os.path.dirname(os.path.abspath(args.salida)), exist_ok=True)
    descargar(glb, args.salida)
    print("LISTO:", args.salida, os.path.getsize(args.salida), "bytes", flush=True)


if __name__ == "__main__":
    try:
        main()
    except urllib.error.HTTPError as error:
        print("ERROR HTTP", error.code, error.read()[:500].decode("utf-8", "replace"))
        sys.exit(1)
    except Exception as error:  # noqa: BLE001 — informe legible para quien lo ejecute
        print("ERROR:", error)
        sys.exit(1)
