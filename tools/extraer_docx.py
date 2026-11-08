#!/usr/bin/env python3
"""Extrae el 100 % del texto (párrafos y tablas, en orden) de todos los .docx de
documentation/ a documentation/_extraido/<nombre>.txt. Solo biblioteca estándar.

Uso: python tools/extraer_docx.py
"""

import pathlib
import sys
import zipfile
import xml.etree.ElementTree as ET

W = "{http://schemas.openxmlformats.org/wordprocessingml/2006/main}"
RAIZ = pathlib.Path(__file__).resolve().parent.parent
ORIGEN = RAIZ / "documentation"
DESTINO = ORIGEN / "_extraido"


def texto_parrafo(p: ET.Element) -> str:
	partes: list[str] = []
	for nodo in p.iter():
		if nodo.tag == W + "t" and nodo.text:
			partes.append(nodo.text)
		elif nodo.tag == W + "tab":
			partes.append("\t")
		elif nodo.tag in (W + "br", W + "cr"):
			partes.append("\n")
	return "".join(partes)


def estilo(p: ET.Element) -> str:
	ppr = p.find(W + "pPr")
	if ppr is not None:
		ps = ppr.find(W + "pStyle")
		if ps is not None:
			return ps.get(W + "val", "")
	return ""


def recorrer(cuerpo: ET.Element, salida: list[str]) -> None:
	for hijo in cuerpo:
		if hijo.tag == W + "p":
			t = texto_parrafo(hijo)
			e = estilo(hijo).lower()
			if e.startswith("heading") or e.startswith("ttulo") or e.startswith("titulo"):
				nivel = "".join(c for c in e if c.isdigit()) or "1"
				t = "#" * int(nivel) + " " + t
			salida.append(t)
		elif hijo.tag == W + "tbl":
			for fila in hijo.iter(W + "tr"):
				celdas = []
				for celda in fila.iter(W + "tc"):
					celdas.append(" ".join(texto_parrafo(p) for p in celda.iter(W + "p")).strip())
				salida.append("| " + " | ".join(celdas) + " |")
			salida.append("")
		elif hijo.tag == W + "sdt":
			contenido = hijo.find(W + "sdtContent")
			if contenido is not None:
				recorrer(contenido, salida)


def extraer(ruta: pathlib.Path) -> str:
	with zipfile.ZipFile(ruta) as z:
		raiz = ET.fromstring(z.read("word/document.xml"))
	salida: list[str] = []
	recorrer(raiz.find(W + "body"), salida)
	return "\n".join(salida)


def main() -> int:
	DESTINO.mkdir(exist_ok=True)
	total = 0
	for ruta in sorted(ORIGEN.rglob("*.docx")):
		if DESTINO in ruta.parents:
			continue
		try:
			texto = extraer(ruta)
		except Exception as error:  # noqa: BLE001
			print(f"ERROR {ruta.name}: {error}", file=sys.stderr)
			continue
		(DESTINO / (ruta.stem + ".txt")).write_text(texto, encoding="utf-8")
		total += 1
		print(f"{len(texto):>8} caracteres  {ruta.relative_to(ORIGEN)}")
	print(f"{total} documentos extraídos en {DESTINO}")
	return 0


if __name__ == "__main__":
	sys.exit(main())
