class_name HudJuego
extends CanvasLayer
## HUD de juego de Nereth: medallón de Resonancia (arco de 270° con pulso
## etéreo y gema del Desfase), vida carmesí con barra rezagada ámbar (Tween
## TRANS_CUBIC + EASE_OUT de 0,6 s), estamina jade que parpadea al agotarse,
## viales de Esencia con contador y pantalla de muerte.

const COLOR_VIDA_DANO: Color = Color(1.0, 0.85, 0.8)
const COLOR_CURACION: Color = Color(1.0, 0.82, 0.4)
const COLOR_ALERTA_ESTAMINA: Color = Color(1.0, 0.32, 0.22)
## La estamina deja de parpadear al recuperar esta fracción.
const UMBRAL_FIN_ALERTA: float = 0.35

@export var objetivo: Nereth

@onready var _barra_vida: BarraOrnamental = $Raiz/Bloque/BarraVida
@onready var _barra_estamina: BarraOrnamental = $Raiz/Bloque/BarraEstamina
@onready var _medallon: ColorRect = $Raiz/Bloque/Medallon
@onready var _fila_esencias: HBoxContainer = $Raiz/Bloque/FilaEsencias
@onready var _contador: Label = $Raiz/Bloque/FilaEsencias/CartelaContador/Contador
@onready var _pantalla_muerte: PantallaMuerte = $PantallaMuerte

var _material_medallon: ShaderMaterial
var _tween_resonancia: Tween
var _tween_regimen: Tween
var _tween_fase: Tween
var _tween_aviso: Tween
var _tween_esencias: Tween
var _iconos_esencias: Array[Panel] = []

var fila_esencias: HBoxContainer:
	get: return _fila_esencias
var iconos_esencias: Array[Panel]:
	get: return _iconos_esencias


func _ready() -> void:
	_material_medallon = _medallon.material as ShaderMaterial
	_inicializar_iconos_esencias()
	if not objetivo:
		return
	if not objetivo.is_node_ready():
		await objetivo.ready
	_conectar_senales()
	_inicializar_valores()


func _inicializar_iconos_esencias() -> void:
	_iconos_esencias.clear()
	for hijo: Node in _fila_esencias.get_children():
		if hijo is IconoVial:
			_iconos_esencias.append(hijo as Panel)


func _conectar_senales() -> void:
	if objetivo.vida:
		objetivo.vida.cambiada.connect(_al_cambiar_vida)
	if objetivo.resistencia:
		objetivo.resistencia.cambiada.connect(_al_cambiar_resistencia)
		objetivo.resistencia.agotada.connect(_al_agotar_resistencia)
	if objetivo.resonancia:
		objetivo.resonancia.cambiada.connect(_al_cambiar_resonancia)
		objetivo.resonancia.regimen_cambiado.connect(_al_cambiar_regimen)
	if objetivo.fase:
		objetivo.fase.cambio_bloqueado.connect(_al_bloquear_cambio)
		objetivo.fase.rechazo.connect(_al_rechazo)
		objetivo.fase.desfase_preciso.connect(_al_desfase_preciso)
	if objetivo.esencias:
		objetivo.esencias.cargas_cambiadas.connect(_al_cambiar_esencias)
		objetivo.esencias.curacion_iniciada.connect(_al_iniciar_curacion)
		objetivo.esencias.curacion_interrumpida.connect(_al_interrumpir_curacion)
		objetivo.esencias.curacion_completada.connect(_al_completar_curacion)
	objetivo.derrotado.connect(_al_derrotar_nereth)
	var gestor: GestorFase = GestorFase.global()
	if gestor:
		gestor.cambiada.connect(_al_cambiar_fase)


func _inicializar_valores() -> void:
	if objetivo.vida:
		_barra_vida.fijar(objetivo.vida.actual, objetivo.vida.maximo, false)
	if objetivo.resistencia:
		_barra_estamina.fijar(objetivo.resistencia.actual, objetivo.resistencia.maximo, false)
	if objetivo.resonancia:
		var r: ComponenteResonancia = objetivo.resonancia
		_param(&"valor", r.actual / maxf(r.maximo, 0.001))
		_param(&"limite", r.limite_recuperacion_amenaza)
		_param(&"amenaza", 1.0 if r.amenaza() else 0.0)
	if objetivo.esencias:
		_actualizar_iconos_esencia(objetivo.esencias.cargas, objetivo.esencias.cargas_maximas)
	var gestor: GestorFase = GestorFase.global()
	if gestor:
		_param(&"desfase", 1.0 if gestor.estado == GestorFase.Estado.DESFASE else 0.0)


func _param(nombre: StringName, valor: Variant) -> void:
	if _material_medallon:
		_material_medallon.set_shader_parameter(nombre, valor)


func _leer_param(nombre: StringName) -> float:
	if _material_medallon:
		var v: Variant = _material_medallon.get_shader_parameter(nombre)
		if v != null:
			return float(v)
	return 0.0


# --- Vida -------------------------------------------------------------------

func _al_cambiar_vida(actual: float, maximo: float) -> void:
	var hubo_dano: bool = actual < _barra_vida.valor
	var hubo_curacion: bool = actual > _barra_vida.valor
	_barra_vida.fijar(actual, maximo, true)
	if hubo_dano:
		_barra_vida.destello(COLOR_VIDA_DANO, 0.25)
	elif hubo_curacion:
		_barra_vida.destello(COLOR_CURACION, 0.5)


# --- Estamina ---------------------------------------------------------------

func _al_cambiar_resistencia(actual: float, maximo: float) -> void:
	_barra_estamina.fijar(actual, maximo, true)
	if _barra_estamina.en_alerta() and actual >= maximo * UMBRAL_FIN_ALERTA:
		_barra_estamina.alerta(false)


func _al_agotar_resistencia() -> void:
	_barra_estamina.alerta(true, COLOR_ALERTA_ESTAMINA)


# --- Resonancia -------------------------------------------------------------

func _al_cambiar_resonancia(actual: float, maximo: float) -> void:
	var destino: float = actual / maxf(maximo, 0.001)
	if _tween_resonancia and _tween_resonancia.is_valid():
		_tween_resonancia.kill()
	_tween_resonancia = create_tween()
	_tween_resonancia.tween_method(_fijar_valor_resonancia, _leer_param(&"valor"), destino, 0.12) \
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)


func _fijar_valor_resonancia(v: float) -> void:
	_param(&"valor", v)


func _fijar_amenaza(v: float) -> void:
	_param(&"amenaza", v)


func _fijar_desfase(v: float) -> void:
	_param(&"desfase", v)


func _fijar_destello(v: float) -> void:
	_param(&"destello", v)


func _al_cambiar_regimen(en_amenaza: bool) -> void:
	if objetivo and objetivo.resonancia:
		_param(&"limite", objetivo.resonancia.limite_recuperacion_amenaza)
	if _tween_regimen and _tween_regimen.is_valid():
		_tween_regimen.kill()
	_tween_regimen = create_tween()
	_tween_regimen.tween_method(_fijar_amenaza, _leer_param(&"amenaza"), 1.0 if en_amenaza else 0.0, 0.4) \
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)


func _al_cambiar_fase(estado: GestorFase.Estado) -> void:
	var activo: bool = estado == GestorFase.Estado.DESFASE
	if _tween_fase and _tween_fase.is_valid():
		_tween_fase.kill()
	_tween_fase = create_tween()
	_tween_fase.tween_method(_fijar_desfase, _leer_param(&"desfase"), 1.0 if activo else 0.0, 0.3) \
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	# Latido del medallón al cruzar de estado.
	_tween_fase.parallel().tween_property(_medallon, "scale", Vector2(1.12, 1.12), 0.08)
	_tween_fase.tween_property(_medallon, "scale", Vector2.ONE, 0.25).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)


func _al_bloquear_cambio() -> void:
	_aviso_medallon(Color(0.95, 0.35, 0.2), true)


func _al_rechazo() -> void:
	_aviso_medallon(Color(1.0, 0.12, 0.1), true)


func _al_desfase_preciso() -> void:
	_aviso_medallon(Color(0.75, 0.88, 1.0), false)


func _aviso_medallon(color: Color, con_temblor: bool) -> void:
	if _tween_aviso and _tween_aviso.is_valid():
		_tween_aviso.kill()
	_param(&"color_destello", color)
	_tween_aviso = create_tween()
	_tween_aviso.tween_method(_fijar_destello, 0.9, 0.0, 0.45).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	if con_temblor:
		var x0: float = 18.0
		_tween_aviso.parallel().tween_property(_medallon, "position:x", x0 + 4.0, 0.05)
		_tween_aviso.tween_property(_medallon, "position:x", x0 - 3.0, 0.05)
		_tween_aviso.tween_property(_medallon, "position:x", x0 + 2.0, 0.05)
		_tween_aviso.tween_property(_medallon, "position:x", x0, 0.05)


# --- Esencias ---------------------------------------------------------------

func _al_cambiar_esencias(cargas: int, maximo: int) -> void:
	_actualizar_iconos_esencia(cargas, maximo)


func _actualizar_iconos_esencia(cargas: int, maximo: int) -> void:
	while _iconos_esencias.size() < maximo:
		var nuevo: IconoVial = IconoVial.new()
		_fila_esencias.add_child(nuevo)
		_fila_esencias.move_child(nuevo, _iconos_esencias.size())
		_iconos_esencias.append(nuevo)
	while _iconos_esencias.size() > maximo:
		var sobrante: Panel = _iconos_esencias.pop_back()
		if is_instance_valid(sobrante):
			sobrante.queue_free()
	for i: int in range(_iconos_esencias.size()):
		(_iconos_esencias[i] as IconoVial).lleno = i < cargas
	_contador.text = str(cargas)
	_contador.modulate = Color.WHITE if cargas > 0 else Color(0.6, 0.45, 0.4)


func _al_iniciar_curacion() -> void:
	# Destella el último vial vaciado (el primero vacío por la derecha de los llenos).
	for icono: Panel in _iconos_esencias:
		if not (icono as IconoVial).lleno:
			var t: Tween = create_tween()
			icono.modulate = Color(2.0, 1.7, 1.1)
			t.tween_property(icono, "modulate", Color.WHITE, 0.4).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
			break


func _al_completar_curacion(_cantidad: float) -> void:
	_barra_vida.destello(COLOR_CURACION, 0.6)


func _al_interrumpir_curacion() -> void:
	if _tween_esencias and _tween_esencias.is_valid():
		_tween_esencias.kill()
	_tween_esencias = create_tween()
	_fila_esencias.modulate = Color(1.0, 0.35, 0.35)
	_tween_esencias.tween_property(_fila_esencias, "modulate", Color.WHITE, 0.35).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	var x0: float = 132.0
	_tween_esencias.parallel().tween_property(_fila_esencias, "position:x", x0 + 3.0, 0.05)
	_tween_esencias.tween_property(_fila_esencias, "position:x", x0 - 3.0, 0.05)
	_tween_esencias.tween_property(_fila_esencias, "position:x", x0, 0.05)


# --- Muerte -----------------------------------------------------------------

func _al_derrotar_nereth() -> void:
	_pantalla_muerte.mostrar()


# --- API pública (pruebas) --------------------------------------------------

func obtener_cargas_esencias() -> int:
	var total: int = 0
	for icono: Panel in _iconos_esencias:
		if is_instance_valid(icono) and icono.get_meta(&"lleno", false):
			total += 1
	return total


func obtener_iconos_esencias() -> Array[Panel]:
	return _iconos_esencias.duplicate()


func barra_vida() -> BarraOrnamental:
	return _barra_vida


func barra_estamina() -> BarraOrnamental:
	return _barra_estamina


func pantalla_muerte() -> PantallaMuerte:
	return _pantalla_muerte
