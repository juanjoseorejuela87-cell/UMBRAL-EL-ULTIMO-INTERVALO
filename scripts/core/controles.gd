class_name ConfigControles
extends Node
## Registra las acciones de entrada del juego (teclado y mando).
## Se carga como autoload "Controles"; las acciones se definen en código para
## mantenerlas legibles y facilitar la reasignación futura.

const ZONA_MUERTA: float = 0.25

## Acción -> lista de eventos. Enteros = teclas (keycode físico);
## "boton:N" = botón de mando; "eje:N:signo" = eje de mando;
## "raton:N" = botón de ratón.
const ACCIONES: Dictionary = {
	&"mover_izquierda": [KEY_A, KEY_LEFT, "eje:0:-1", "boton:13"],
	&"mover_derecha": [KEY_D, KEY_RIGHT, "eje:0:1", "boton:14"],
	&"mover_arriba": [KEY_W, KEY_UP, "eje:1:-1", "boton:11"],
	&"mover_abajo": [KEY_S, KEY_DOWN, "eje:1:1", "boton:12"],
	&"saltar": [KEY_SPACE, "boton:0"],
	&"esquivar": [KEY_SHIFT, KEY_L, "boton:1"],
	&"interactuar": [KEY_E, "boton:3"],
	&"atacar_ligero": [KEY_J, "raton:1", "boton:2"],
	&"atacar_pesado": [KEY_K, "raton:2", "boton:10"],
	&"desfase": [KEY_Q, KEY_I, "boton:9"],
}


func _init() -> void:
	registrar()


static func registrar() -> void:
	for accion: StringName in ACCIONES:
		if InputMap.has_action(accion):
			continue
		InputMap.add_action(accion, ZONA_MUERTA)
		for definicion: Variant in ACCIONES[accion]:
			InputMap.action_add_event(accion, _crear_evento(definicion))


static func _crear_evento(definicion: Variant) -> InputEvent:
	if definicion is int:
		var tecla := InputEventKey.new()
		tecla.physical_keycode = definicion as Key
		return tecla
	var partes: PackedStringArray = (definicion as String).split(":")
	if partes[0] == "raton":
		var raton := InputEventMouseButton.new()
		raton.button_index = int(partes[1]) as MouseButton
		return raton
	if partes[0] == "boton":
		var boton := InputEventJoypadButton.new()
		boton.button_index = int(partes[1]) as JoyButton
		return boton
	var eje := InputEventJoypadMotion.new()
	eje.axis = int(partes[1]) as JoyAxis
	eje.axis_value = float(partes[2])
	return eje
