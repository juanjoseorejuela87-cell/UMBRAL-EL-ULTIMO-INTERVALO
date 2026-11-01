class_name CombateNereth
extends Node
## Ataques de Nereth: cadena ligera, pesado cargable y ataque aéreo.
## Nereth llama a procesar() cada frame de física antes de moverse.
## Diseño: documentation/GAMEPLAY.md §2.

signal ataque_iniciado(datos: DatosAtaque)
signal golpe_conectado(info: InfoGolpe, objetivo: CajaDano)
signal ataque_terminado

enum Etapa { NINGUNA, CARGA, PREPARACION, ACTIVO, RECUPERACION }

@export var arma: DatosArma
@export var tiempo_buffer_ataque: float = 0.25
@export var multiplicador_golpe_umbral: float = 2.5

var etapa: Etapa =Etapa.NINGUNA
var ataque_actual: DatosAtaque
## Posición en la cadena ligera del ataque actual (0 = primero).
var indice_cadena: int = -1

var _tiempo_etapa: float = 0.0
var _carga: float = 0.0
var _multiplicador: float = 1.0
var _buffer_ligero: float = 0.0
var _buffer_pesado: float = 0.0
var _golpeados: Array[CajaDano] = []

@onready var _nereth: Nereth = get_parent() as Nereth
@onready var _caja_golpe: Area3D = %CajaGolpe
@onready var _forma_golpe: CollisionShape3D = %FormaGolpe


func _ready() -> void:
	_forma_golpe.shape = _forma_golpe.shape.duplicate()
	_caja_golpe.monitoring = false


func atacando() -> bool:
	return etapa != Etapa.NINGUNA


## True cuando la recuperación ya permite cancelar con esquiva.
func puede_cancelar() -> bool:
	return etapa == Etapa.CARGA \
			or (etapa == Etapa.RECUPERACION and _tiempo_etapa >= ataque_actual.inicio_cancelacion)


## Corta el ataque en curso (esquiva, golpe recibido...).
func interrumpir() -> void:
	if atacando():
		_terminar(false)


func procesar(delta: float) -> void:
	_buffer_ligero = maxf(_buffer_ligero - delta, 0.0)
	_buffer_pesado = maxf(_buffer_pesado - delta, 0.0)
	if Input.is_action_just_pressed(&"atacar_ligero"):
		_buffer_ligero = tiempo_buffer_ataque
	if Input.is_action_just_pressed(&"atacar_pesado"):
		_buffer_pesado = tiempo_buffer_ataque

	_tiempo_etapa += delta
	match etapa:
		Etapa.NINGUNA:
			if _nereth.estado == Nereth.Estado.SUELO or _nereth.estado == Nereth.Estado.AIRE:
				_intentar_iniciar(-1)
		Etapa.CARGA:
			_carga += delta
			if not Input.is_action_pressed(&"atacar_pesado") or _carga >= ataque_actual.carga_maxima:
				var proporcion: float = clampf(_carga / ataque_actual.carga_maxima, 0.0, 1.0)
				_multiplicador = lerpf(1.0, ataque_actual.multiplicador_carga, proporcion)
				_cambiar_etapa(Etapa.PREPARACION)
		Etapa.PREPARACION:
			if _tiempo_etapa >= ataque_actual.preparacion:
				_activar_caja()
				_cambiar_etapa(Etapa.ACTIVO)
		Etapa.ACTIVO:
			_detectar_golpes()
			if _tiempo_etapa >= ataque_actual.activo:
				_caja_golpe.monitoring = false
				_cambiar_etapa(Etapa.RECUPERACION)
		Etapa.RECUPERACION:
			var encadenable: bool = ataque_actual != arma.aereo
			if encadenable and _tiempo_etapa >= ataque_actual.inicio_cancelacion \
					and _intentar_iniciar(indice_cadena):
				return
			if _tiempo_etapa >= ataque_actual.recuperacion:
				_terminar(true)


## Empieza el ataque que corresponda al buffer. indice_previo = posición en la
## cadena ligera del ataque que se está encadenando (-1 si no hay).
func _intentar_iniciar(indice_previo: int) -> bool:
	if not arma:
		return false
	var datos: DatosAtaque = null
	var indice: int = -1
	if _buffer_ligero > 0.0:
		if not _nereth.is_on_floor():
			if indice_previo == -1:
				datos = arma.aereo
		elif indice_previo + 1 < arma.ligeros.size():
			indice = indice_previo + 1
			datos = arma.ligeros[indice]
	elif _buffer_pesado > 0.0 and _nereth.is_on_floor():
		datos = arma.pesado
	if datos == null or not _nereth.resistencia.consumir(datos.coste_resistencia):
		return false

	_buffer_ligero = 0.0
	_buffer_pesado = 0.0
	_caja_golpe.monitoring = false
	ataque_actual = datos
	indice_cadena = indice
	_carga = 0.0
	_multiplicador = 1.0
	var direccion: float = Input.get_axis(&"mover_izquierda", &"mover_derecha")
	_nereth.comenzar_accion(direccion, datos.impulso)
	_cambiar_etapa(Etapa.CARGA if datos.carga_maxima > 0.0 else Etapa.PREPARACION)
	ataque_iniciado.emit(datos)
	return true


func _activar_caja() -> void:
	_golpeados.clear()
	(_forma_golpe.shape as BoxShape3D).size = ataque_actual.tamano_caja
	var desplazamiento: Vector3 = ataque_actual.desplazamiento_caja
	_caja_golpe.position = Vector3(desplazamiento.x * _nereth.mirando, desplazamiento.y, 0.0)
	_caja_golpe.monitoring = true


func _detectar_golpes() -> void:
	for area: Area3D in _caja_golpe.get_overlapping_areas():
		var caja: CajaDano = area as CajaDano
		if caja == null or caja in _golpeados:
			continue
		_golpeados.append(caja)
		var info := InfoGolpe.new()
		info.dano = ataque_actual.dano * _multiplicador
		info.dano_postura = ataque_actual.dano_postura * _multiplicador
		info.tipo = ataque_actual.tipo_dano
		info.fuerza = ataque_actual.fuerza
		info.direccion = _nereth.mirando
		info.origen = _nereth
		info.nombre_ataque = ataque_actual.nombre
		info.multiplicador_critico = multiplicador_golpe_umbral
		if caja.recibir_golpe(info):
			golpe_conectado.emit(info, caja)


func _cambiar_etapa(nueva: Etapa) -> void:
	etapa = nueva
	_tiempo_etapa = 0.0


func _terminar(devolver_control: bool) -> void:
	_caja_golpe.monitoring = false
	etapa = Etapa.NINGUNA
	ataque_actual = null
	indice_cadena = -1
	if devolver_control:
		_nereth.terminar_accion()
	ataque_terminado.emit()
