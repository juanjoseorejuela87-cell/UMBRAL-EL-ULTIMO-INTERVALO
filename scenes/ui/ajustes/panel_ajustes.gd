class_name PanelAjustes
extends VBoxContainer
## Panel reutilizable de ajustes de Sonido y Gráficos.
## Se utiliza en el menú de pausa y en la pantalla de título.

signal volver_pulsado

const DESCRIPCIONES_CALIDAD: Array[String] = [
	"Para equipos modestos y gráficas integradas.",
	"Equilibrio entre aspecto y rendimiento.",
	"Sombras e iluminación de calidad. Requiere una gráfica dedicada.",
	"Iluminación global y niebla volumétrica. Para equipos potentes.",
]

var _foco_inicial_dado: bool = false
var _preajuste_pendiente: int = -1

@onready var panel_sonido: VBoxContainer = %PanelSonido
@onready var panel_graficos: VBoxContainer = %PanelGraficos

@onready var deslizador_musica: HSlider = %DeslizadorMusica
@onready var deslizador_efectos: HSlider = %DeslizadorEfectos
@onready var deslizador_ambiente: HSlider = %DeslizadorAmbiente

@onready var selector_calidad: OptionButton = %SelectorCalidad
@onready var texto_descripcion_calidad: Label = %TextoDescripcionCalidad
@onready var panel_confirmacion_reinicio: VBoxContainer = %PanelConfirmacionReinicio
@onready var texto_aviso_reinicio: Label = %TextoAvisoReinicio
@onready var boton_reiniciar: Button = %BotonReiniciar
@onready var boton_cancelar_reinicio: Button = %BotonCancelarReinicio

@onready var boton_volver_sonido: Button = %VolverSonido
@onready var boton_volver_graficos: Button = %VolverGraficos


func _ready() -> void:
	# Conexión de botones de volver
	boton_volver_sonido.pressed.connect(_al_volver)
	boton_volver_graficos.pressed.connect(_al_volver)

	boton_reiniciar.pressed.connect(confirmar_reinicio)
	boton_cancelar_reinicio.pressed.connect(cancelar_reinicio)

	# Sonidos de interfaz para botones
	for btn: Button in [
		boton_volver_sonido,
		boton_volver_graficos,
		boton_reiniciar,
		boton_cancelar_reinicio,
		selector_calidad,
	]:
		_conectar_sonidos_boton(btn)

	# Sonidos y eventos de los deslizadores
	for sld: HSlider in [deslizador_musica, deslizador_efectos, deslizador_ambiente]:
		_conectar_sonidos_deslizador(sld)

	deslizador_musica.value_changed.connect(func(v: float) -> void:
		if GestorSonido.global() != null:
			GestorSonido.global().fijar_volumen(GestorSonido.BUS_MUSICA, v)
	)
	deslizador_efectos.value_changed.connect(func(v: float) -> void:
		if GestorSonido.global() != null:
			GestorSonido.global().fijar_volumen(GestorSonido.BUS_EFECTOS, v)
	)
	deslizador_ambiente.value_changed.connect(func(v: float) -> void:
		if GestorSonido.global() != null:
			GestorSonido.global().fijar_volumen(GestorSonido.BUS_AMBIENTE, v)
	)

	_poblar_selector_graficos()
	selector_calidad.item_selected.connect(_al_seleccionar_calidad)

	var popup: PopupMenu = selector_calidad.get_popup()
	if popup != null:
		popup.id_focused.connect(func(id: int) -> void:
			if GestorSonido.global() != null:
				GestorSonido.global().reproducir(&"ui_mover")
			_actualizar_descripcion_calidad(id)
		)
		popup.popup_hide.connect(func() -> void:
			if is_instance_valid(selector_calidad):
				_actualizar_descripcion_calidad(selector_calidad.selected)
		)

	var graficos: ConfiguracionGrafica = ConfiguracionGrafica.global()
	if graficos != null:
		graficos.calidad_cambiada.connect(func(_p: ConfiguracionGrafica.Preajuste) -> void:
			_actualizar_selector_graficos()
		)


func _al_volver() -> void:
	ocultar_todo()
	volver_pulsado.emit()


func ocultar_todo() -> void:
	if is_instance_valid(panel_sonido):
		panel_sonido.visible = false
	if is_instance_valid(panel_graficos):
		panel_graficos.visible = false
	if is_instance_valid(panel_confirmacion_reinicio):
		panel_confirmacion_reinicio.visible = false
	_preajuste_pendiente = -1


func mostrar_sonido() -> void:
	visible = true
	if is_instance_valid(panel_graficos):
		panel_graficos.visible = false
	if is_instance_valid(panel_sonido):
		panel_sonido.visible = true
	actualizar_deslizadores_sonido()
	_foco_inicial_dado = false
	deslizador_musica.grab_focus.call_deferred()
	_activar_sonido_foco_tras_frame()


func mostrar_graficos() -> void:
	visible = true
	_preajuste_pendiente = -1
	if is_instance_valid(panel_confirmacion_reinicio):
		panel_confirmacion_reinicio.visible = false
	if is_instance_valid(panel_sonido):
		panel_sonido.visible = false
	if is_instance_valid(panel_graficos):
		panel_graficos.visible = true
	actualizar_selector_graficos()
	_foco_inicial_dado = false
	selector_calidad.grab_focus.call_deferred()
	_activar_sonido_foco_tras_frame()


func actualizar_deslizadores_sonido() -> void:
	var sonido: GestorSonido = GestorSonido.global()
	if sonido != null:
		if is_instance_valid(deslizador_musica):
			deslizador_musica.set_value_no_signal(sonido.volumen(GestorSonido.BUS_MUSICA))
		if is_instance_valid(deslizador_efectos):
			deslizador_efectos.set_value_no_signal(sonido.volumen(GestorSonido.BUS_EFECTOS))
		if is_instance_valid(deslizador_ambiente):
			deslizador_ambiente.set_value_no_signal(sonido.volumen(GestorSonido.BUS_AMBIENTE))
	else:
		var idx_m: int = AudioServer.get_bus_index(GestorSonido.BUS_MUSICA)
		if idx_m >= 0 and is_instance_valid(deslizador_musica):
			deslizador_musica.set_value_no_signal(db_to_linear(AudioServer.get_bus_volume_db(idx_m)))

		var idx_e: int = AudioServer.get_bus_index(GestorSonido.BUS_EFECTOS)
		if idx_e >= 0 and is_instance_valid(deslizador_efectos):
			deslizador_efectos.set_value_no_signal(db_to_linear(AudioServer.get_bus_volume_db(idx_e)))

		var idx_a: int = AudioServer.get_bus_index(GestorSonido.BUS_AMBIENTE)
		if idx_a >= 0 and is_instance_valid(deslizador_ambiente):
			deslizador_ambiente.set_value_no_signal(db_to_linear(AudioServer.get_bus_volume_db(idx_a)))


func _poblar_selector_graficos() -> void:
	if not is_instance_valid(selector_calidad):
		return
	selector_calidad.clear()
	for i: int in ConfiguracionGrafica.NOMBRES.size():
		selector_calidad.add_item(ConfiguracionGrafica.NOMBRES[i], i)


func actualizar_selector_graficos() -> void:
	_actualizar_selector_graficos()


func _actualizar_selector_graficos() -> void:
	var graficos: ConfiguracionGrafica = ConfiguracionGrafica.global()
	if graficos != null and is_instance_valid(selector_calidad):
		var actual: int = graficos.preajuste as int
		selector_calidad.selected = actual
		_actualizar_descripcion_calidad(actual)


func _actualizar_descripcion_calidad(idx: int) -> void:
	if is_instance_valid(texto_descripcion_calidad) and idx >= 0 and idx < DESCRIPCIONES_CALIDAD.size():
		texto_descripcion_calidad.text = DESCRIPCIONES_CALIDAD[idx]


func _al_seleccionar_calidad(idx: int) -> void:
	seleccionar_preajuste(idx as ConfiguracionGrafica.Preajuste)


func seleccionar_preajuste(p: ConfiguracionGrafica.Preajuste) -> void:
	var graficos: ConfiguracionGrafica = ConfiguracionGrafica.global()
	if graficos == null:
		return
	if is_instance_valid(selector_calidad):
		selector_calidad.selected = p as int
	_actualizar_descripcion_calidad(p as int)

	if graficos.requiere_reinicio(p):
		_preajuste_pendiente = p as int
		if is_instance_valid(panel_confirmacion_reinicio):
			panel_confirmacion_reinicio.visible = true
			_foco_inicial_dado = false
			boton_cancelar_reinicio.grab_focus.call_deferred()
			_activar_sonido_foco_tras_frame()
	else:
		_preajuste_pendiente = -1
		if is_instance_valid(panel_confirmacion_reinicio):
			panel_confirmacion_reinicio.visible = false
		graficos.cambiar(p)


func cancelar_reinicio() -> void:
	_preajuste_pendiente = -1
	if is_instance_valid(panel_confirmacion_reinicio):
		panel_confirmacion_reinicio.visible = false
	_actualizar_selector_graficos()
	if is_instance_valid(selector_calidad):
		_foco_inicial_dado = false
		selector_calidad.grab_focus.call_deferred()
		_activar_sonido_foco_tras_frame()


func confirmar_reinicio() -> void:
	if _preajuste_pendiente < 0:
		return
	var p: ConfiguracionGrafica.Preajuste = _preajuste_pendiente as ConfiguracionGrafica.Preajuste
	_preajuste_pendiente = -1
	if is_instance_valid(panel_confirmacion_reinicio):
		panel_confirmacion_reinicio.visible = false
	var graficos: ConfiguracionGrafica = ConfiguracionGrafica.global()
	if graficos != null:
		graficos.cambiar(p)
	_actualizar_selector_graficos()
	if is_instance_valid(selector_calidad):
		_foco_inicial_dado = false
		selector_calidad.grab_focus.call_deferred()
		_activar_sonido_foco_tras_frame()


func _conectar_sonidos_boton(boton: Button) -> void:
	boton.focus_entered.connect(func() -> void:
		if not _foco_inicial_dado:
			return
		if GestorSonido.global() != null:
			GestorSonido.global().reproducir(&"ui_mover")
	)
	boton.pressed.connect(func() -> void:
		if GestorSonido.global() != null:
			GestorSonido.global().reproducir(&"ui_aceptar")
	)


func _conectar_sonidos_deslizador(sld: HSlider) -> void:
	sld.focus_entered.connect(func() -> void:
		if not _foco_inicial_dado:
			return
		if GestorSonido.global() != null:
			GestorSonido.global().reproducir(&"ui_mover")
	)


func _activar_sonido_foco_tras_frame() -> void:
	await get_tree().process_frame
	_foco_inicial_dado = true
