class_name GestorFase
extends Node
## Estado global de la realidad (autoload "Fase"): Realidad o Desfase.
## Lo cambia Nereth (FaseNereth) y lo escuchan los elementos del mundo
## (ElementoFase). Diseño: documentation/GAMEPLAY.md §3.

signal cambiada(estado: Estado)

enum Estado { REALIDAD, DESFASE }

## Bits de capa de física de la geometría (ver [layer_names] en project.godot).
const CAPA_COMUN: int = 1
const CAPA_REALIDAD: int = 2
const CAPA_DESFASE: int = 4

var estado: Estado = Estado.REALIDAD

static var _instancia: GestorFase


func _init() -> void:
	_instancia = self


## Acceso al gestor sin depender del nombre del autoload (que no existe como
## identificador al ejecutar scripts con -s, p. ej. en las pruebas).
static func global() -> GestorFase:
	return _instancia


func en_desfase() -> bool:
	return estado == Estado.DESFASE


func cambiar(nuevo: Estado) -> void:
	if nuevo == estado:
		return
	estado = nuevo
	cambiada.emit(estado)


static func capa_de(estado_fase: Estado) -> int:
	return CAPA_DESFASE if estado_fase == Estado.DESFASE else CAPA_REALIDAD


static func opuesto(estado_fase: Estado) -> Estado:
	return Estado.REALIDAD if estado_fase == Estado.DESFASE else Estado.DESFASE
