class_name Nereth
extends CharacterBody3D
## Controlador de Nereth sobre el plano lateral (X/Y): movimiento, esquiva y
## estado de acción (ataques). Diseño: documentation/GAMEPLAY.md §1–2.

signal salto_iniciado
signal aterrizado
signal esquiva_iniciada
signal esquiva_terminada

enum Estado { SUELO, AIRE, ESQUIVA, ACCION }

@export_group("Desplazamiento")
@export var velocidad_maxima: float = 6.0
@export var tiempo_aceleracion: float = 0.08
@export var tiempo_frenada: float = 0.06
@export_range(0.0, 1.0) var control_aereo: float = 0.75

@export_group("Salto")
@export var altura_salto: float = 3.0
@export var tiempo_hasta_cima: float = 0.38
@export var multiplicador_caida: float = 1.6
@export_range(0.0, 1.0) var corte_salto: float = 0.45
@export var velocidad_caida_maxima: float = 18.0
@export var tiempo_coyote: float = 0.1
@export var tiempo_buffer_salto: float = 0.12

@export_group("Esquiva")
@export var distancia_esquiva: float = 3.2
@export var duracion_esquiva: float = 0.25
@export var inicio_invulnerable: float = 0.04
@export var fin_invulnerable: float = 0.19
@export var enfriamiento_esquiva: float = 0.15
@export var coste_resistencia_esquiva: float = 18.0
## Durante un ataque, una esquiva pulsada antes de la ventana de cancelación
## se guarda este tiempo y sale en cuanto la ventana se abre.
@export var tiempo_buffer_esquiva: float = 0.15

@export_group("Acción")
## Frenada horizontal durante los ataques (unidades/s²).
@export var friccion_accion: float = 30.0

var estado: Estado = Estado.AIRE
## 1.0 = derecha, -1.0 = izquierda.
var mirando: float = 1.0
var invulnerable: bool = false:
	set(valor):
		invulnerable = valor
		if _caja_dano:
			_caja_dano.activa = not valor

var _gravedad_subida: float = 0.0
var _velocidad_salto: float = 0.0
var _plano_z: float = 0.0
var _temporizador_coyote: float = 0.0
var _temporizador_buffer: float = 0.0
var _tiempo_esquiva: float = 0.0
var _enfriamiento: float = 0.0
var _esquiva_aerea_disponible: bool = true
var _buffer_esquiva: float = 0.0

@onready var vida: ComponenteVida = $Vida
@onready var resistencia: ComponenteResistencia = $Resistencia
@onready var combate: CombateNereth = $Combate
@onready var _visual: Node3D = $Visual
@onready var _caja_dano: CajaDano = $CajaDano


func _ready() -> void:
	_plano_z = global_position.z
	_recalcular_salto()


## Deriva gravedad y velocidad inicial a partir de altura y tiempo hasta la cima.
func _recalcular_salto() -> void:
	_gravedad_subida = 2.0 * altura_salto / (tiempo_hasta_cima * tiempo_hasta_cima)
	_velocidad_salto = 2.0 * altura_salto / tiempo_hasta_cima


func _physics_process(delta: float) -> void:
	_actualizar_temporizadores(delta)
	combate.procesar(delta)
	match estado:
		Estado.ESQUIVA:
			_procesar_esquiva(delta)
		Estado.ACCION:
			_procesar_accion(delta)
		_:
			_procesar_movimiento(delta)
	velocity.z = 0.0
	move_and_slide()
	global_position.z = _plano_z
	_actualizar_estado_suelo()
	_visual.scale.x = mirando


## Pasa al estado de acción (lo llama CombateNereth al empezar un ataque).
## direccion: entrada horizontal para girarse antes de atacar.
func comenzar_accion(direccion: float, impulso: float) -> void:
	if not is_zero_approx(direccion):
		mirando = signf(direccion)
	estado = Estado.ACCION
	if is_on_floor():
		velocity.x = impulso * mirando


func terminar_accion() -> void:
	if estado == Estado.ACCION:
		estado = Estado.SUELO if is_on_floor() else Estado.AIRE


func _actualizar_temporizadores(delta: float) -> void:
	_temporizador_coyote = maxf(_temporizador_coyote - delta, 0.0)
	_temporizador_buffer = maxf(_temporizador_buffer - delta, 0.0)
	_enfriamiento = maxf(_enfriamiento - delta, 0.0)
	_buffer_esquiva = maxf(_buffer_esquiva - delta, 0.0)


func _procesar_movimiento(delta: float) -> void:
	var direccion: float = Input.get_axis(&"mover_izquierda", &"mover_derecha")
	if not is_zero_approx(direccion):
		mirando = signf(direccion)

	_aplicar_desplazamiento(direccion, delta)
	_aplicar_gravedad(delta)
	_procesar_salto()

	if Input.is_action_just_pressed(&"esquivar"):
		_intentar_esquivar(direccion)


func _procesar_accion(delta: float) -> void:
	if is_on_floor():
		velocity.x = move_toward(velocity.x, 0.0, friccion_accion * delta)
	_aplicar_gravedad(delta)
	if Input.is_action_just_pressed(&"esquivar"):
		_buffer_esquiva = tiempo_buffer_esquiva
	if _buffer_esquiva > 0.0 and combate.puede_cancelar() and _puede_esquivar():
		_buffer_esquiva = 0.0
		combate.interrumpir()
		_intentar_esquivar(Input.get_axis(&"mover_izquierda", &"mover_derecha"))


func _aplicar_desplazamiento(direccion: float, delta: float) -> void:
	var objetivo: float = direccion * velocidad_maxima
	var frenando: bool = is_zero_approx(direccion) \
			or (not is_zero_approx(velocity.x) and signf(direccion) != signf(velocity.x))
	var tasa: float = velocidad_maxima / (tiempo_frenada if frenando else tiempo_aceleracion)
	if not is_on_floor():
		tasa *= control_aereo
	velocity.x = move_toward(velocity.x, objetivo, tasa * delta)


func _aplicar_gravedad(delta: float) -> void:
	if is_on_floor():
		return
	var gravedad: float = _gravedad_subida
	if velocity.y < 0.0:
		gravedad *= multiplicador_caida
	velocity.y = maxf(velocity.y - gravedad * delta, -velocidad_caida_maxima)


func _procesar_salto() -> void:
	if Input.is_action_just_pressed(&"saltar"):
		_temporizador_buffer = tiempo_buffer_salto
	if _temporizador_buffer > 0.0 and _temporizador_coyote > 0.0:
		velocity.y = _velocidad_salto
		_temporizador_buffer = 0.0
		_temporizador_coyote = 0.0
		estado = Estado.AIRE
		salto_iniciado.emit()
	elif Input.is_action_just_released(&"saltar") and velocity.y > 0.0:
		velocity.y *= corte_salto


func _puede_esquivar() -> bool:
	return _enfriamiento <= 0.0 and (is_on_floor() or _esquiva_aerea_disponible) \
			and resistencia.puede_actuar()


func _intentar_esquivar(direccion: float) -> void:
	if not _puede_esquivar():
		return
	resistencia.consumir(coste_resistencia_esquiva)
	var sentido: float = signf(direccion) if not is_zero_approx(direccion) else mirando
	mirando = sentido
	if not is_on_floor():
		_esquiva_aerea_disponible = false
	estado = Estado.ESQUIVA
	_tiempo_esquiva = 0.0
	velocity = Vector3(sentido * distancia_esquiva / duracion_esquiva, 0.0, 0.0)
	esquiva_iniciada.emit()


func _procesar_esquiva(delta: float) -> void:
	_tiempo_esquiva += delta
	invulnerable = _tiempo_esquiva >= inicio_invulnerable and _tiempo_esquiva < fin_invulnerable
	velocity.y = 0.0
	if _tiempo_esquiva >= duracion_esquiva:
		_terminar_esquiva()


func _terminar_esquiva() -> void:
	invulnerable = false
	velocity.x = clampf(velocity.x, -velocidad_maxima, velocidad_maxima)
	_enfriamiento = enfriamiento_esquiva
	estado = Estado.SUELO if is_on_floor() else Estado.AIRE
	esquiva_terminada.emit()


func _actualizar_estado_suelo() -> void:
	if is_on_floor():
		_temporizador_coyote = tiempo_coyote
		_esquiva_aerea_disponible = true
		if estado == Estado.AIRE:
			estado = Estado.SUELO
			aterrizado.emit()
	elif estado == Estado.SUELO:
		estado = Estado.AIRE
