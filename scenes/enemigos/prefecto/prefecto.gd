class_name Prefecto
extends Enemigo
## El Prefecto de las Puertas, primer jefe (documentation/GAMEPLAY.md §10).
## Fase 1 — Custodia: barrido, estocada y golpe de llave.
## Fase 2 — Puertas cruzadas: viaja entre puertas; solo el Desfase revela por
##   cuál saldrá; coser la puerta por la que entró lo atrapa en Ruptura. Invoca ecos.
## Fase 3 — Umbral abierto: bifásico (blindado en la Realidad), parte del suelo
##   solo existe en el Desfase y usa el Cierre de todas las puertas, del que solo
##   protege una puerta cosida (o una esquiva a tiempo).

signal fase_cambiada(fase: int)
signal atrapado
signal derrotado_definitivamente

const EVENTO_DERROTA: StringName = &"prefecto_derrotado"
const ESCENA_ECO: PackedScene = preload("res://scenes/enemigos/eco_rezagado/eco_rezagado.tscn")

@export_group("Prefecto")
@export var puertas: Array[CSGBox3D] = []
@export var ataques_fase_1: Array[DatosAtaque] = []
@export var ataques_fase_2: Array[DatosAtaque] = []
@export var ataques_fase_3: Array[DatosAtaque] = []
## Ataque al salir de una puerta en la fase 2.
@export var ataque_salida: DatosAtaque
@export var ataque_cierre: DatosAtaque
@export_range(0.0, 1.0) var umbral_fase_2: float = 0.65
@export_range(0.0, 1.0) var umbral_fase_3: float = 0.30
@export var duracion_travesia: float = 1.4
@export var ataques_entre_travesias: int = 2
@export var ecos_fase_2: int = 2
@export var intervalo_cierre: float = 12.0
## Distancia horizontal a una puerta cosida que protege del Cierre.
@export var radio_refugio: float = 1.6
## Suelos que en la fase 3 pasan a existir solo en el Desfase.
@export var suelos_fase_3: Array[CSGBox3D] = []
## Se abre (desaparece) al derrotar al Prefecto.
@export var puerta_salida: Node3D

var fase_actual: int = 1
var en_travesia: bool = false
var puerta_entrada: CSGBox3D
var puerta_destino: CSGBox3D

var _tiempo_travesia: float = 0.0
var _ataques_desde_travesia: int = 0
var _tiempo_cierre: float = 0.0
var _ecos: Array[Enemigo] = []
var _marca_salida: MeshInstance3D
var _derrotado: bool = false
var _altura_suelo: float = 0.0
var _multiplicadores_originales: Array[float] = []


func _ready() -> void:
	super._ready()
	ataques = ataques_fase_1
	_multiplicadores_originales = [multiplicador_dano_realidad, multiplicador_postura_realidad,
			multiplicador_dano_desfase, multiplicador_postura_desfase]
	vida.cambiada.connect(_al_cambiar_vida)
	_crear_marca_salida()
	_fase.cambiada.connect(_actualizar_marca.unbind(1))
	if GestorPartida.global().evento_ocurrido(EVENTO_DERROTA):
		_derrotado = true
		estado = Estado.MUERTO
		visible = false
		collision_layer = 0
		_caja_dano.activa = false
		_abrir_salida()


func puede_desgarrarse() -> bool:
	return not en_travesia and super.puede_desgarrarse()


func _physics_process(delta: float) -> void:
	if _derrotado or estado == Estado.MUERTO:
		return
	if en_travesia:
		_tiempo_travesia += delta
		if _tiempo_travesia >= duracion_travesia:
			_emerger()
		return
	if fase_actual == 3 and ia_activa and estado == Estado.PERSECUCION:
		_tiempo_cierre += delta
		if _tiempo_cierre >= intervalo_cierre:
			iniciar_cierre()
	super._physics_process(delta)


## Cierre de todas las puertas: golpe a toda la sala tras una larga telegrafía.
func iniciar_cierre() -> void:
	_tiempo_cierre = 0.0
	_iniciar_ataque_con(ataque_cierre)


func _al_terminar_ataque() -> void:
	if fase_actual < 2 or ataque_actual == ataque_cierre:
		return
	_ataques_desde_travesia += 1
	if _ataques_desde_travesia >= ataques_entre_travesias:
		_iniciar_travesia()


func _puede_golpear(caja: CajaDano) -> bool:
	if ataque_actual != ataque_cierre:
		return true
	return not _esta_refugiado(caja.global_position)


func _esta_refugiado(posicion: Vector3) -> bool:
	for puerta: CSGBox3D in puertas:
		if _puerta_cosida(puerta) and absf(puerta.global_position.x - posicion.x) <= radio_refugio:
			return true
	return false


# --- Puertas cruzadas ---

func _iniciar_travesia() -> void:
	if puertas.size() < 2:
		return
	puerta_entrada = _puerta_mas_cercana(global_position.x, null)
	puerta_destino = _elegir_salida()
	en_travesia = true
	_tiempo_travesia = 0.0
	_altura_suelo = global_position.y
	_caja_golpe.monitoring = false
	_caja_dano.activa = false
	collision_layer = 0
	visible = false
	_actualizar_marca()


## Sale por la puerta más cercana a la espalda de Nereth.
func _elegir_salida() -> CSGBox3D:
	var x_objetivo: float = global_position.x
	if objetivo:
		x_objetivo = objetivo.global_position.x - objetivo.mirando * 2.5
	return _puerta_mas_cercana(x_objetivo, puerta_entrada)


func _puerta_mas_cercana(x: float, excluida: CSGBox3D) -> CSGBox3D:
	var mejor: CSGBox3D = null
	for puerta: CSGBox3D in puertas:
		if puerta == excluida:
			continue
		if mejor == null or absf(puerta.global_position.x - x) < absf(mejor.global_position.x - x):
			mejor = puerta
	return mejor


func _emerger() -> void:
	var quedo_atrapado: bool = _puerta_cosida(puerta_entrada)
	var puerta: CSGBox3D = puerta_entrada if quedo_atrapado else puerta_destino
	en_travesia = false
	global_position = Vector3(puerta.global_position.x, _altura_suelo, _plano_z)
	velocity = Vector3.ZERO
	visible = true
	collision_layer = CAPA_CUERPO
	_ataques_desde_travesia = 0
	_actualizar_presencia()
	_actualizar_marca()
	if objetivo:
		mirando = signf(objetivo.global_position.x - global_position.x)
		if is_zero_approx(mirando):
			mirando = 1.0
	if quedo_atrapado:
		estado = Estado.PERSECUCION
		postura.acumular(postura.maximo)
		atrapado.emit()
	else:
		_iniciar_ataque_con(ataque_salida)


func _puerta_cosida(puerta: CSGBox3D) -> bool:
	if puerta == null:
		return false
	var cosible: ElementoCosible = puerta.get_node_or_null("Cosible") as ElementoCosible
	return cosible != null and cosible.esta_cosido()


func _crear_marca_salida() -> void:
	var malla := SphereMesh.new()
	malla.radius = 0.3
	malla.height = 0.8
	malla.radial_segments = 4
	malla.rings = 2
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = Color(1.0, 0.55, 0.2)
	_marca_salida = MeshInstance3D.new()
	_marca_salida.mesh = malla
	_marca_salida.material_override = material
	_marca_salida.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_marca_salida.top_level = true
	_marca_salida.visible = false
	add_child(_marca_salida)


## La puerta de salida solo se revela desde el Desfase.
func _actualizar_marca() -> void:
	if _marca_salida == null:
		return
	_marca_salida.visible = en_travesia and puerta_destino != null and _fase.en_desfase()
	if puerta_destino:
		_marca_salida.global_position = puerta_destino.global_position + Vector3(0.0, 2.2, 0.6)


# --- Fases ---

func _al_cambiar_vida(actual: float, maximo: float) -> void:
	if _derrotado or actual <= 0.0:
		return
	var proporcion: float = actual / maximo
	if fase_actual == 1 and proporcion <= umbral_fase_2:
		_entrar_fase(2)
	if fase_actual == 2 and proporcion <= umbral_fase_3:
		_entrar_fase(3)


func _entrar_fase(nueva: int) -> void:
	fase_actual = nueva
	match nueva:
		2:
			ataques = ataques_fase_2
			_invocar_ecos()
		3:
			ataques = ataques_fase_3
			multiplicador_dano_realidad = 0.25
			multiplicador_postura_realidad = 1.0
			multiplicador_dano_desfase = 1.3
			multiplicador_postura_desfase = 0.8
			_cambiar_suelos(ElementoFase.Existencia.DESFASE)
			_tiempo_cierre = intervalo_cierre * 0.5
	_indice_ataque = 0
	fase_cambiada.emit(nueva)


func _invocar_ecos() -> void:
	for i: int in ecos_fase_2:
		if puertas.is_empty():
			return
		var puerta: CSGBox3D = puertas[i % puertas.size()]
		var eco: Enemigo = ESCENA_ECO.instantiate() as Enemigo
		get_parent().add_child(eco)
		eco.global_position = Vector3(puerta.global_position.x, global_position.y, _plano_z)
		_ecos.append(eco)


func _limpiar_ecos() -> void:
	for eco: Enemigo in _ecos:
		if is_instance_valid(eco):
			eco.queue_free()
	_ecos.clear()


func _cambiar_suelos(existencia: ElementoFase.Existencia) -> void:
	for suelo: CSGBox3D in suelos_fase_3:
		for hijo: Node in suelo.get_children():
			if hijo is ElementoFase:
				(hijo as ElementoFase).cambiar_existencia(existencia)


func _abrir_salida() -> void:
	if puerta_salida == null:
		return
	puerta_salida.visible = false
	if "use_collision" in puerta_salida:
		puerta_salida.set("use_collision", false)
	if puerta_salida is CollisionObject3D:
		(puerta_salida as CollisionObject3D).collision_layer = 0


func _morir() -> void:
	super._morir()
	_derrotado = true
	en_travesia = false
	_actualizar_marca()
	_limpiar_ecos()
	_cambiar_suelos(ElementoFase.Existencia.AMBOS)
	_abrir_salida()
	GestorPartida.global().registrar_evento(EVENTO_DERROTA)
	derrotado_definitivamente.emit()


## Tras una derrota de Nereth, el combate empieza de cero (salvo si ya cayó).
func reiniciar() -> void:
	if _derrotado:
		return
	_limpiar_ecos()
	en_travesia = false
	fase_actual = 1
	ataques = ataques_fase_1
	_indice_ataque = 0
	_ataques_desde_travesia = 0
	_tiempo_cierre = 0.0
	multiplicador_dano_realidad = _multiplicadores_originales[0]
	multiplicador_postura_realidad = _multiplicadores_originales[1]
	multiplicador_dano_desfase = _multiplicadores_originales[2]
	multiplicador_postura_desfase = _multiplicadores_originales[3]
	_cambiar_suelos(ElementoFase.Existencia.AMBOS)
	super.reiniciar()
	_actualizar_marca()
