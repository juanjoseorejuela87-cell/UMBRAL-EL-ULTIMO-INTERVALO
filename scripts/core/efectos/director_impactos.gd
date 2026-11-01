class_name DirectorImpactos
extends Node
## Sensación de impacto (autoload "Impactos"): parada de impacto (hitstop),
## temblor de cámara y efecto visual en el punto del golpe.
## La parada de impacto se desactiva sin pantalla (pruebas headless) para no
## alterar los tiempos de juego.

const ESCENA_EFECTO: String = "res://scenes/efectos/impacto/impacto.tscn"

## Duración de la parada (segundos reales) y temblor (intensidad, duración) por tipo.
@export var parada_golpe: float = 0.045
@export var parada_critico: float = 0.11
@export var parada_parry: float = 0.13
@export var parada_herida: float = 0.07
@export var escala_tiempo_parada: float = 0.05
@export var temblor_golpe: Vector2 = Vector2(0.06, 0.12)
@export var temblor_critico: Vector2 = Vector2(0.22, 0.25)
@export var temblor_parry: Vector2 = Vector2(0.14, 0.18)
@export var temblor_herida: Vector2 = Vector2(0.18, 0.22)
## Permite desactivar la parada (accesibilidad o pruebas).
@export var parada_activa: bool = true

var _camara: CamaraLateral
var _parada_restante: float = 0.0
var _escena_efecto: PackedScene

static var _instancia: DirectorImpactos


func _init() -> void:
	_instancia = self


## Acceso sin depender del nombre del autoload (ver GestorFase.global()).
static func global() -> DirectorImpactos:
	return _instancia


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	if DisplayServer.get_name() == "headless":
		parada_activa = false
	if ResourceLoader.exists(ESCENA_EFECTO):
		_escena_efecto = load(ESCENA_EFECTO) as PackedScene


func registrar_camara(camara: CamaraLateral) -> void:
	_camara = camara


func en_parada() -> bool:
	return _parada_restante > 0.0


## Nereth conecta un golpe (Golpe de Umbral si info.critico).
func golpe(info: InfoGolpe, posicion: Vector3) -> void:
	if info.critico:
		_impacto(&"critico", posicion, parada_critico, temblor_critico)
	else:
		_impacto(&"golpe", posicion, parada_golpe, temblor_golpe)


func parry(posicion: Vector3) -> void:
	_impacto(&"parry", posicion, parada_parry, temblor_parry)


func herida(posicion: Vector3) -> void:
	_impacto(&"herida", posicion, parada_herida, temblor_herida)


func sacudir(intensidad: float, duracion: float) -> void:
	if is_instance_valid(_camara):
		_camara.temblar(intensidad, duracion)


func _impacto(tipo: StringName, posicion: Vector3, parada: float, temblor: Vector2) -> void:
	_parar(parada)
	sacudir(temblor.x, temblor.y)
	_crear_efecto(tipo, posicion)


func _parar(duracion: float) -> void:
	if not parada_activa or duracion <= 0.0:
		return
	_parada_restante = maxf(_parada_restante, duracion)
	Engine.time_scale = escala_tiempo_parada


func _process(delta: float) -> void:
	if _parada_restante <= 0.0:
		return
	# delta ya viene escalado: se recupera el tiempo real transcurrido.
	_parada_restante -= delta / maxf(Engine.time_scale, 0.0001)
	if _parada_restante <= 0.0:
		_parada_restante = 0.0
		Engine.time_scale = 1.0


func _crear_efecto(tipo: StringName, posicion: Vector3) -> void:
	if _escena_efecto == null:
		return
	var efecto: Node3D = _escena_efecto.instantiate() as Node3D
	if efecto == null:
		return
	var contenedor: Node = get_tree().current_scene if get_tree().current_scene else get_tree().root
	contenedor.add_child(efecto)
	efecto.global_position = posicion
	if efecto.has_method(&"configurar"):
		efecto.call(&"configurar", tipo)
