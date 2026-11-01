class_name EfectoImpacto
extends Node3D
## Efecto visual de impacto para golpes, críticos, parries, heridas y Desfase.
## Emite una explosión de chispas ligera con CPUParticles3D y se libera automáticamente.

const TIPOS_VALIDOS: Array[StringName] = [
	&"golpe",
	&"critico",
	&"parry",
	&"herida",
	&"desfase",
]

@export var tipo_impacto: StringName = &"golpe"

var _configurado: bool = false
var _terminado: bool = false

@onready var chispas: CPUParticles3D = $Chispas
@onready var luz: OmniLight3D = $DestelloLuz


func _ready() -> void:
	if not _configurado:
		configurar.call_deferred(tipo_impacto)


func configurar(tipo: StringName) -> void:
	if _configurado and tipo == tipo_impacto:
		return
	_configurado = true
	tipo_impacto = tipo

	if chispas == null:
		chispas = get_node_or_null("Chispas") as CPUParticles3D
	if luz == null:
		luz = get_node_or_null("DestelloLuz") as OmniLight3D

	_aplicar_tipo(tipo)

	if is_instance_valid(chispas):
		chispas.restart()
		chispas.emitting = true
		if not chispas.finished.is_connected(_al_terminar):
			chispas.finished.connect(_al_terminar)

	var duracion_maxima: float = (chispas.lifetime + 0.15) if is_instance_valid(chispas) else 0.4
	get_tree().create_timer(duracion_maxima).timeout.connect(_al_terminar)


func _aplicar_tipo(tipo: StringName) -> void:
	if not is_instance_valid(chispas):
		return

	match tipo:
		&"critico":
			chispas.amount = 24
			chispas.lifetime = 0.35
			chispas.color = Color(1.0, 0.82, 0.25, 1.0)
			chispas.initial_velocity_min = 4.0
			chispas.initial_velocity_max = 6.5
			chispas.gravity = Vector3(0.0, -9.8, 0.0)
			chispas.scale_amount_min = 1.3
			chispas.scale_amount_max = 1.8
			_encender_destello(Color(1.0, 0.85, 0.4, 1.0), 2.2, 3.5, 0.1)

		&"parry":
			chispas.amount = 20
			chispas.lifetime = 0.28
			chispas.color = Color(0.7, 0.88, 1.0, 1.0)
			chispas.initial_velocity_min = 3.5
			chispas.initial_velocity_max = 5.5
			chispas.gravity = Vector3(0.0, -2.5, 0.0)
			chispas.scale_amount_min = 1.0
			chispas.scale_amount_max = 1.5
			_encender_destello(Color(0.6, 0.85, 1.0, 1.0), 1.6, 2.5, 0.08)

		&"herida":
			chispas.amount = 10
			chispas.lifetime = 0.25
			chispas.color = Color(0.92, 0.18, 0.18, 1.0)
			chispas.initial_velocity_min = 2.0
			chispas.initial_velocity_max = 4.0
			chispas.gravity = Vector3(0.0, -9.0, 0.0)
			chispas.scale_amount_min = 0.8
			chispas.scale_amount_max = 1.2
			if is_instance_valid(luz):
				luz.visible = false

		&"desfase":
			chispas.amount = 18
			chispas.lifetime = 0.45
			chispas.color = Color(0.35, 0.65, 1.0, 0.9)
			chispas.initial_velocity_min = 1.0
			chispas.initial_velocity_max = 2.2
			chispas.gravity = Vector3(0.0, 0.5, 0.0)
			chispas.scale_amount_min = 0.9
			chispas.scale_amount_max = 1.4
			if is_instance_valid(luz):
				luz.visible = false

		_: # &"golpe"
			chispas.amount = 10
			chispas.lifetime = 0.25
			chispas.color = Color(1.0, 1.0, 1.0, 1.0)
			chispas.initial_velocity_min = 2.5
			chispas.initial_velocity_max = 4.5
			chispas.gravity = Vector3(0.0, -8.0, 0.0)
			chispas.scale_amount_min = 0.8
			chispas.scale_amount_max = 1.2
			if is_instance_valid(luz):
				luz.visible = false


func _encender_destello(color_luz: Color, energia: float, rango: float, duracion_apagado: float) -> void:
	if not is_instance_valid(luz):
		return
	luz.light_color = color_luz
	luz.light_energy = energia
	luz.omni_range = rango
	luz.visible = true
	var tween: Tween = create_tween()
	if tween != null:
		tween.tween_property(luz, "light_energy", 0.0, duracion_apagado)
		tween.tween_callback(func() -> void:
			if is_instance_valid(luz):
				luz.visible = false
		)


func _al_terminar() -> void:
	if _terminado:
		return
	_terminado = true
	queue_free()
