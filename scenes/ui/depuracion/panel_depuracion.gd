class_name PanelDepuracion
extends CanvasLayer
## Panel de depuración para inspeccionar en tiempo real el movimiento y estado de Nereth.

const ACCION_ALTERNAR: StringName = &"depuracion_alternar"

@export var objetivo: Nereth

@onready var _etiqueta: Label = $Margen/PanelFondo/EtiquetaInformacion


func _ready() -> void:
	_asegurar_accion_entrada()
	visible = OS.is_debug_build()


func _asegurar_accion_entrada() -> void:
	if not InputMap.has_action(ACCION_ALTERNAR):
		InputMap.add_action(ACCION_ALTERNAR)
		var evento: InputEventKey = InputEventKey.new()
		evento.physical_keycode = KEY_F3
		InputMap.action_add_event(ACCION_ALTERNAR, evento)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(ACCION_ALTERNAR):
		visible = not visible


func _process(_delta: float) -> void:
	if not visible or not is_instance_valid(objetivo):
		return
	_actualizar_informacion()


func _actualizar_informacion() -> void:
	var texto_estado: String = _obtener_nombre_estado(objetivo.estado)
	var fps: int = Engine.get_frames_per_second()
	var en_suelo_str: String = "Sí" if objetivo.is_on_floor() else "No"
	var invulnerable_str: String = "Sí" if objetivo.invulnerable else "No"
	var mirando_str: String = "Derecha (1.0)" if objetivo.mirando > 0.0 else "Izquierda (-1.0)"

	_etiqueta.text = (
		"FPS: %d\n" % fps +
		"Estado: %s\n" % texto_estado +
		"Velocidad X: %.2f\n" % objetivo.velocity.x +
		"Velocidad Y: %.2f\n" % objetivo.velocity.y +
		"En suelo: %s\n" % en_suelo_str +
		"Invulnerable: %s\n" % invulnerable_str +
		"Mirando: %s" % mirando_str
	)


func _obtener_nombre_estado(estado_val: Nereth.Estado) -> String:
	return Nereth.Estado.keys()[estado_val]
