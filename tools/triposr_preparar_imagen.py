"""Quita el fondo de una imagen con un modelo ligero (u2netp de rembg) y la deja
lista para TripoSR: figura centrada sobre gris medio.

El modelo por defecto de rembg pide más de 800 MB de memoria de una vez y falla
en este PC; u2netp ocupa unos pocos MB y es rápido en CPU.

Se ejecuta con el Python de la instalación local de TripoSR:
    ia\\triposr\\venv\\Scripts\\python.exe tools/triposr_preparar_imagen.py <entrada> <salida.png>
y después:
    python tools/triposr_generar.py <salida.png> <modelo.glb> --sin-quitar-fondo
"""

import sys

import numpy as np
import rembg
from PIL import Image


def main() -> None:
    entrada, salida = sys.argv[1], sys.argv[2]
    sesion = rembg.new_session("u2netp")
    imagen = rembg.remove(Image.open(entrada).convert("RGB"), session=sesion)  # RGBA
    # Recortar a la figura y centrarla ocupando el 85 % del lienzo cuadrado
    alfa = np.array(imagen)[:, :, 3]
    filas = np.where(alfa.max(axis=1) > 10)[0]
    columnas = np.where(alfa.max(axis=0) > 10)[0]
    figura = imagen.crop((columnas[0], filas[0], columnas[-1] + 1, filas[-1] + 1))
    lado = int(max(figura.size) / 0.85)
    lienzo = Image.new("RGBA", (lado, lado), (0, 0, 0, 0))
    lienzo.paste(figura, ((lado - figura.width) // 2, (lado - figura.height) // 2))
    # TripoSR espera la figura sobre gris medio
    gris = Image.new("RGBA", lienzo.size, (127, 127, 127, 255))
    Image.alpha_composite(gris, lienzo).convert("RGB").resize((512, 512), Image.LANCZOS).save(salida)
    print("PREPARADA:", salida)


if __name__ == "__main__":
    main()
