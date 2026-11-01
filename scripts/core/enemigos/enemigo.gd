class_name Enemigo
extends CharacterBody3D
## Enemigo genérico: reposo, persecución, ataques telegrafiados, reacciones
## según su peso, Ruptura y existencia en uno o ambos estados de la realidad.
## Los arquetipos (corpóreo, eco, bifásico) son escenas que configuran este
## script. Diseño: documentation/GAMEPLAY.md §2.7 y §3.5.

signal derrotado(enemigo: Enemigo)
signal ataque_telegrafiado(datos: DatosAtaque)
signal desgarrado(efecto: StringName)

enum Peso { LIGERO, MEDIO, PESADO }
enum Estado { REPOSO, PERSECUCION, ATAQUE, ATURDIDO, RUPTURA, MUERTO }
enum Etapa { PREPARACION, ACTIVO, RECUPERACION }

const GRUPO_DESGARRABLES: StringName = &"desgarrables"
const CAPA_CUERPO: int = 16
const COLOR_TELEGRAFIA: Color = Color(1.0, 0.45, 0.1)
const COLOR_GOLPE: Color = Color(1.0, 1.0, 1.0)
const COLOR_CRITICO: Color = Color(1.0, 0.9, 0.5)
const COLOR_RUPTURA: Color = Color(0.9, 0.6, 0.15)
const COLOR_EXPUESTO: Color = Color(0.5, 0.8, 1.0)

@export var existe_en: ElementoFase.Existencia = ElementoFase.Existencia.REALIDAD
@export var peso: Peso = Peso.MEDIO
## Si es false, el enemigo está presente (se le puede golpear) pero no actúa:
## enemigos dormidos de un nivel, escenas, pruebas.
@export var ia_activa: bool = true

@export_group("Movimiento")
@export var velocidad: float = 2.5
@export var rango_deteccion: float = 9.0
@export var rango_perdida: float = 14.0
@export var rango_ataque: float = 1.6
@export var gravedad: float = 30.0

@export_group("Ataque")
@export var ataques: Array[DatosAtaque] = []
@export var pausa_entre_ataques: float = 0.9
## Frenada durante el ataque (unidades/s²).
@export var friccion_ataque: float = 25.0

@export_group("Reacciones")
@export var aturdimiento_golpe: float = 0.35
@export var aturdimiento_parry: float = 0.8
@export var aturdimiento_desgarro: float = 0.6
## Fracción de la postura máxima que suma un parry de Nereth.
@export_range(0.0, 1.0) var postura_por_parry: float = 0.45
@export var postura_por_desgarro: float = 25.0
@export var duracion_expuesto: float = 3.0
@export var multiplicador_expuesto: float = 1.5

@export_group("Estados de la realidad")
@export var multiplicador_dano_realidad: float = 1.0
@export var multiplicador_postura_realidad: float = 1.0
@export var multiplicador_dano_desfase: float = 1.0
@export var multiplicador_postura_desfase: float = 1.0
## Postura que recibe al golpear sus Hilos desde el estado en que no existe.
@export var multiplicador_hilos: float = 1.0

var estado: Estado = Estado.REPOSO
var etapa: Etapa = Etapa.PREPARACION
var mirando: float = -1.0
var objetivo: Nereth
var ataque_actual: DatosAtaque
var expuesto_restante: float = 0.0

var _tiempo: float = 0.0
var _pausa: float = 0.0
var _aturdido_restante: float = 0.0
var _indice_ataque: int = 0
var _golpeados: Array[CajaDano] = []
var _posicion_inicial: Vector3
var _plano_z: float = 0.0
var _material: StandardMaterial3D
var _tween_destello: Tween
var _amenaza_registrada: bool = false
var _fase: GestorFase = GestorFase.global()

@onready var vida: ComponenteVida = $Vida
@onready var postura: ComponentePostura = $Postura
@onready var _caja_dano: CajaDano = $CajaDano
@onready var _caja_golpe: Area3D = $CajaGolpe
@onready var _forma_golpe: CollisionShape3D = $CajaGolpe/FormaGolpe
@onready var _visual: Node3D = $Visual
@onready var _cuerpo: MeshInstance3D = $Visual/Cuerpo


func _ready() -> void:
	add_to_group(GestorPartida.GRUPO_REINICIO)
	add_to_group(GRUPO_DESGARRABLES)
	_posicion_inicial = global_position
	_plano_z = global_position.z
	collision_layer = CAPA_CUERPO
	collision_mask = GestorFase.CAPA_COMUN | (GestorFase.CAPA_DESFASE \
			if existe_en == ElementoFase.Existencia.DESFASE else GestorFase.CAPA_REALIDAD)
	_forma_golpe.shape = _forma_golpe.shape.duplicate()
	_caja_golpe.monitoring = false
	var original: Material = _cuerpo.get_active_material(0)
	_material = (original as StandardMaterial3D).duplicate()
	# Las figuras hechas de varias piezas comparten el material del Cuerpo:
	# todas reciben la copia, así el destello y la telegrafía afectan a la figura entera.
	for nodo: Node in $Visual.find_children("*", "MeshInstance3D", true, false):
		var pieza: MeshInstance3D = nodo as MeshInstance3D
		for i: int in pieza.get_surface_override_material_count():
			if pieza.get_active_material(i) == original:
				pieza.set_surface_override_material(i, _material)
	_caja_dano.golpe_recibido.connect(_al_recibir_golpe)
	vida.agotada.connect(_morir)
	postura.rota.connect(_al_romper_postura)
	postura.recuperada.connect(_al_recuperar_postura)
	_fase.cambiada.connect(_actualizar_presencia.unbind(1))
	_actualizar_presencia()


## True si el enemigo existe en el estado actual de la realidad.
func existe_ahora() -> bool:
	match existe_en:
		ElementoFase.Existencia.REALIDAD:
			return not _fase.en_desfase()
		ElementoFase.Existencia.DESFASE:
			return _fase.en_desfase()
		_:
			return true


## El Desgarro actúa sobre los Hilos, que solo se ven desde el Desfase.
func puede_desgarrarse() -> bool:
	return estado != Estado.MUERTO and _fase.en_desfase()


func tiempo_en_etapa() -> float:
	return _tiempo


func _physics_process(delta: float) -> void:
	if estado == Estado.MUERTO:
		return
	if objetivo == null:
		objetivo = get_tree().get_first_node_in_group(Nereth.GRUPO) as Nereth
	if expuesto_restante > 0.0:
		expuesto_restante -= delta
		if expuesto_restante <= 0.0:
			_actualizar_color()
	if not is_on_floor():
		velocity.y -= gravedad * delta
	if not ia_activa:
		_frenar(delta)
		move_and_slide()
		return
	match estado:
		Estado.REPOSO:
			_procesar_reposo(delta)
		Estado.PERSECUCION:
			_procesar_persecucion(delta)
		Estado.ATAQUE:
			_procesar_ataque(delta)
		Estado.ATURDIDO:
			_frenar(delta)
			_aturdido_restante -= delta
			if _aturdido_restante <= 0.0:
				estado = Estado.PERSECUCION
		Estado.RUPTURA:
			_frenar(delta)
	velocity.z = 0.0
	move_and_slide()
	global_position.z = _plano_z
	_visual.scale.x = mirando


func _procesar_reposo(delta: float) -> void:
	_frenar(delta)
	if _distancia_objetivo() <= rango_deteccion:
		_entrar_en_alerta()


func _procesar_persecucion(delta: float) -> void:
	var distancia: float = _distancia_objetivo()
	if distancia > rango_perdida:
		estado = Estado.REPOSO
		_registrar_amenaza(false)
		return
	var dx: float = objetivo.global_position.x - global_position.x
	if not is_zero_approx(dx):
		mirando = signf(dx)
	_pausa -= delta
	if absf(dx) > rango_ataque:
		velocity.x = mirando * velocidad
	else:
		_frenar(delta)
		if _pausa <= 0.0 and not ataques.is_empty():
			_iniciar_ataque()


func _procesar_ataque(delta: float) -> void:
	_frenar(delta)
	_tiempo += delta
	match etapa:
		Etapa.PREPARACION:
			if _tiempo >= ataque_actual.preparacion:
				_activar_caja()
				etapa = Etapa.ACTIVO
				_tiempo = 0.0
		Etapa.ACTIVO:
			_detectar_golpes()
			if _tiempo >= ataque_actual.activo:
				_caja_golpe.monitoring = false
				etapa = Etapa.RECUPERACION
				_tiempo = 0.0
				_actualizar_color()
		Etapa.RECUPERACION:
			if _tiempo >= ataque_actual.recuperacion:
				estado = Estado.PERSECUCION
				_pausa = pausa_entre_ataques
				_al_terminar_ataque()


func _iniciar_ataque() -> void:
	_iniciar_ataque_con(_elegir_ataque())


## Punto de extensión: qué ataque usar (por defecto, en orden cíclico).
func _elegir_ataque() -> DatosAtaque:
	var datos: DatosAtaque = ataques[_indice_ataque % ataques.size()]
	_indice_ataque += 1
	return datos


## Punto de extensión: se llama al acabar la recuperación de un ataque.
func _al_terminar_ataque() -> void:
	pass


## Punto de extensión: permite anular un golpe concreto (refugios, etc.).
func _puede_golpear(_caja: CajaDano) -> bool:
	return true


func _iniciar_ataque_con(datos: DatosAtaque) -> void:
	ataque_actual = datos
	estado = Estado.ATAQUE
	etapa = Etapa.PREPARACION
	_tiempo = 0.0
	_material.emission_enabled = true
	_material.emission = COLOR_TELEGRAFIA
	_material.emission_energy_multiplier = 1.2
	ataque_telegrafiado.emit(ataque_actual)


func _activar_caja() -> void:
	_golpeados.clear()
	(_forma_golpe.shape as BoxShape3D).size = ataque_actual.tamano_caja
	var desplazamiento: Vector3 = ataque_actual.desplazamiento_caja
	_caja_golpe.position = Vector3(desplazamiento.x * mirando, desplazamiento.y, 0.0)
	_caja_golpe.monitoring = true
	velocity.x = ataque_actual.impulso * mirando


func _detectar_golpes() -> void:
	# Un enemigo no puede golpear a quien está en el otro estado de la realidad.
	if not existe_ahora():
		return
	for area: Area3D in _caja_golpe.get_overlapping_areas():
		var caja: CajaDano = area as CajaDano
		if caja == null or caja in _golpeados:
			continue
		_golpeados.append(caja)
		if not _puede_golpear(caja):
			continue
		var info := InfoGolpe.new()
		info.dano = ataque_actual.dano
		info.dano_postura = ataque_actual.dano_postura
		info.tipo = ataque_actual.tipo_dano
		info.fuerza = ataque_actual.fuerza
		info.parable = ataque_actual.parable
		info.bloqueable = ataque_actual.bloqueable
		info.direccion = mirando
		info.origen = self
		info.nombre_ataque = ataque_actual.nombre
		caja.recibir_golpe(info)


func _al_recibir_golpe(info: InfoGolpe) -> void:
	if estado == Estado.MUERTO:
		return
	var dano: float = info.dano
	var dano_postura: float = info.dano_postura
	if not existe_ahora():
		# Golpe a los Hilos desde el otro estado: solo postura.
		dano = 0.0
		dano_postura *= multiplicador_hilos
	elif _fase.en_desfase():
		dano *= multiplicador_dano_desfase
		dano_postura *= multiplicador_postura_desfase
	else:
		dano *= multiplicador_dano_realidad
		dano_postura *= multiplicador_postura_realidad
	if expuesto_restante > 0.0:
		dano *= multiplicador_expuesto
	if postura.en_ruptura and dano > 0.0:
		info.critico = true
		dano *= info.multiplicador_critico
		postura.terminar_ruptura()
	else:
		postura.acumular(dano_postura)
	info.dano_aplicado = dano
	if dano > 0.0:
		vida.recibir_dano(dano)
	if estado == Estado.MUERTO:
		return
	_destellar(info.critico)
	if estado == Estado.REPOSO:
		_entrar_en_alerta()
	if estado != Estado.RUPTURA and _es_interrumpido(info):
		aturdir(aturdimiento_golpe)


func _es_interrumpido(info: InfoGolpe) -> bool:
	match peso:
		Peso.LIGERO:
			return true
		Peso.MEDIO:
			return info.fuerza == InfoGolpe.Fuerza.PESADA
		_:
			return false


## Interrumpe lo que esté haciendo y queda aturdido un tiempo.
func aturdir(duracion: float) -> void:
	if estado == Estado.MUERTO or estado == Estado.RUPTURA:
		return
	_caja_golpe.monitoring = false
	estado = Estado.ATURDIDO
	_aturdido_restante = duracion
	_actualizar_color()


## Lo llama Nereth al desviar uno de sus golpes.
func recibir_parry() -> void:
	postura.acumular(postura.maximo * postura_por_parry)
	aturdir(aturdimiento_parry)


## Desgarro (Costura en combate): corta un ataque en curso o, si no ataca,
## expone sus puntos débiles durante un tiempo.
func desgarrar() -> StringName:
	var efecto: StringName
	if estado == Estado.ATAQUE and etapa != Etapa.RECUPERACION:
		postura.acumular(postura_por_desgarro)
		aturdir(aturdimiento_desgarro)
		efecto = &"cortar"
	else:
		expuesto_restante = duracion_expuesto
		_actualizar_color()
		efecto = &"exponer"
	desgarrado.emit(efecto)
	return efecto


## Vuelve a su estado inicial (descanso en un Ancla, reaparición de Nereth).
func reiniciar() -> void:
	global_position = _posicion_inicial
	velocity = Vector3.ZERO
	vida.restaurar()
	if postura.en_ruptura or postura.actual > 0.0:
		postura.terminar_ruptura()
	estado = Estado.REPOSO
	expuesto_restante = 0.0
	_pausa = 0.0
	_caja_golpe.monitoring = false
	collision_layer = CAPA_CUERPO
	visible = true
	_registrar_amenaza(false)
	_actualizar_presencia()
	_actualizar_color()


func _morir() -> void:
	estado = Estado.MUERTO
	_caja_golpe.monitoring = false
	_caja_dano.activa = false
	collision_layer = 0
	visible = false
	_registrar_amenaza(false)
	derrotado.emit(self)


func _al_romper_postura() -> void:
	if estado == Estado.MUERTO:
		return
	_caja_golpe.monitoring = false
	estado = Estado.RUPTURA
	_actualizar_color()


func _al_recuperar_postura() -> void:
	if estado == Estado.RUPTURA:
		estado = Estado.PERSECUCION
		_pausa = pausa_entre_ataques
	_actualizar_color()


func _entrar_en_alerta() -> void:
	estado = Estado.PERSECUCION
	_registrar_amenaza(true)


## Un enemigo en alerta pone la Resonancia de Nereth en régimen de Amenaza.
func _registrar_amenaza(activa: bool) -> void:
	if activa == _amenaza_registrada or objetivo == null:
		return
	_amenaza_registrada = activa
	if activa:
		objetivo.resonancia.registrar_amenaza(self)
	else:
		objetivo.resonancia.retirar_amenaza(self)


## Caja de daño: activa salvo para un eco visto desde la Realidad (no tiene
## presencia ni Hilos allí).
func _actualizar_presencia() -> void:
	if estado == Estado.MUERTO:
		return
	_caja_dano.activa = existe_ahora() or _fase.en_desfase()


func _distancia_objetivo() -> float:
	if objetivo == null:
		return INF
	return global_position.distance_to(objetivo.global_position)


func _frenar(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0.0, friccion_ataque * delta)


func _destellar(critico: bool) -> void:
	if _tween_destello:
		_tween_destello.kill()
	_material.emission_enabled = true
	_material.emission = COLOR_CRITICO if critico else COLOR_GOLPE
	_material.emission_energy_multiplier = 2.0 if critico else 1.0
	_tween_destello = create_tween()
	_tween_destello.tween_property(_material, "emission_energy_multiplier", 0.0, 0.15)
	_tween_destello.tween_callback(_actualizar_color)


func _actualizar_color() -> void:
	if estado == Estado.RUPTURA:
		_material.emission_enabled = true
		_material.emission = COLOR_RUPTURA
		_material.emission_energy_multiplier = 0.8
	elif estado == Estado.ATAQUE and etapa == Etapa.PREPARACION:
		_material.emission_enabled = true
		_material.emission = COLOR_TELEGRAFIA
		_material.emission_energy_multiplier = 1.2
	elif expuesto_restante > 0.0:
		_material.emission_enabled = true
		_material.emission = COLOR_EXPUESTO
		_material.emission_energy_multiplier = 0.7
	else:
		_material.emission_enabled = false
