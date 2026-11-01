class_name MenuPausa
extends CanvasLayer
## Menú de pausa del juego con lista legible de controles y ajustes de sonido.
## Se abre y cierra con Esc o con el botón Start del mando.
## Al pausar, detiene el árbol del juego (get_tree().paused = true).

const ACCION_PAUSA: StringName = &"pausa"
const ESCENA_TITULO: String = "res://scenes/ui/titulo/titulo.tscn"

const NOMBRES_ACCIONES: Dictionary = {
	&"mover_izquierda": "Mover a la izquierda",
	&"mover_derecha": "Mover a la derecha",
	&"mover_arriba": "Mover arriba",
	&"mover_abajo": "Mover abajo",
	&"saltar": "Saltar",
	&"esquivar": "Esquivar",
	&"interactuar": "Interactuar",
	&"atacar_ligero": "Ataque ligero",
	&"atacar_pesado": "Ataque pesado",
	&"desfase": "Desfase",
	&"coser": "Coser",
	&"guardia": "Guardia",
}

const DESCRIPCIONES_CALIDAD: Array[String] = [
	"Para equipos modestos y gráficas integradas.",
	"Equilibrio entre aspecto y rendimiento.",
	"Sombras e iluminación de calidad. Requiere una gráfica dedicada.",
	"Iluminación global y niebla volumétrica. Para equipos potentes.",
]

var _abierto: bool = false
var _ultimo_frame_accion: int = -1
var _foco_inicial_dado: bool = false
var _preajuste_pendiente: int = -1

@onready var panel_raiz: Control = %PanelRaiz
@onready var menu_opciones: VBoxContainer = %MenuOpciones
@onready var panel_controles: VBoxContainer = %PanelControles
@onready var panel_sonido: VBoxContainer = %PanelSonido
@onready var panel_graficos: VBoxContainer = %PanelGraficos

@onready var boton_reanudar: Button = %Reanudar
@onready var boton_controles: Button = %Controles
@onready var boton_sonido: Button = %Sonido
@onready var boton_graficos: Button = %Graficos
@onready var boton_volver_titulo: Button = %VolverTitulo
@onready var boton_volver_menu: Button = %VolverMenu
@onready var boton_volver_sonido: Button = %VolverSonido
@onready var boton_volver_graficos: Button = %VolverGraficos

@onready var deslizador_musica: HSlider = %DeslizadorMusica
@onready var deslizador_efectos: HSlider = %DeslizadorEfectos
@onready var deslizador_ambiente: HSlider = %DeslizadorAmbiente

@onready var selector_calidad: OptionButton = %SelectorCalidad
@onready var texto_descripcion_calidad: Label = %TextoDescripcionCalidad
@onready var panel_confirmacion_reinicio: VBoxContainer = %PanelConfirmacionReinicio
@onready var texto_aviso_reinicio: Label = %TextoAvisoReinicio
@onready var boton_reiniciar: Button = %BotonReiniciar
@onready var boton_cancelar_reinicio: Button = %BotonCancelarReinicio

@onready var texto_controles: Label = %TextoControles


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	asegurar_accion_pausa()
	_generar_lista_controles()

	# Conexiones de botones principales
	boton_reanudar.pressed.connect(cerrar)
	boton_controles.pressed.connect(mostrar_controles)
	boton_sonido.pressed.connect(mostrar_sonido)
	boton_graficos.pressed.connect(mostrar_graficos)
	boton_volver_titulo.pressed.connect(volver_al_titulo)
	boton_volver_menu.pressed.connect(mostrar_menu_principal)
	boton_volver_sonido.pressed.connect(mostrar_menu_principal)
	boton_volver_graficos.pressed.connect(mostrar_menu_principal)

	boton_reiniciar.pressed.connect(confirmar_reinicio)
	boton_cancelar_reinicio.pressed.connect(cancelar_reinicio)

	# Sonidos de interfaz para botones
	for btn: Button in [
		boton_reanudar,
		boton_controles,
		boton_sonido,
		boton_graficos,
		boton_volver_titulo,
		boton_volver_menu,
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

	visible = false
	panel_raiz.visible = false


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


static func asegurar_accion_pausa() -> void:
	if not InputMap.has_action(ACCION_PAUSA):
		InputMap.add_action(ACCION_PAUSA)
		var tecla := InputEventKey.new()
		tecla.physical_keycode = KEY_ESCAPE
		InputMap.action_add_event(ACCION_PAUSA, tecla)
		var boton := InputEventJoypadButton.new()
		boton.button_index = JOY_BUTTON_START
		InputMap.action_add_event(ACCION_PAUSA, boton)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(ACCION_PAUSA):
		alternar()
		get_viewport().set_input_as_handled()


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed(ACCION_PAUSA):
		alternar()


func alternar() -> void:
	var f: int = Engine.get_process_frames()
	if f == _ultimo_frame_accion:
		return
	_ultimo_frame_accion = f
	if _abierto:
		cerrar()
	else:
		abrir()


func abrir() -> void:
	_abierto = true
	visible = true
	panel_raiz.visible = true
	mostrar_menu_principal()
	get_tree().paused = true


func cerrar() -> void:
	_abierto = false
	visible = false
	panel_raiz.visible = false
	get_tree().paused = false


func esta_abierto() -> bool:
	return _abierto


func mostrar_menu_principal() -> void:
	menu_opciones.visible = true
	panel_controles.visible = false
	panel_sonido.visible = false
	panel_graficos.visible = false
	_foco_inicial_dado = false
	boton_reanudar.grab_focus.call_deferred()
	_activar_sonido_foco_tras_frame()


func mostrar_controles() -> void:
	menu_opciones.visible = false
	panel_controles.visible = true
	panel_sonido.visible = false
	panel_graficos.visible = false
	_foco_inicial_dado = false
	boton_volver_menu.grab_focus.call_deferred()
	_activar_sonido_foco_tras_frame()


func mostrar_sonido() -> void:
	_actualizar_deslizadores_sonido()
	menu_opciones.visible = false
	panel_controles.visible = false
	panel_sonido.visible = true
	panel_graficos.visible = false
	_foco_inicial_dado = false
	deslizador_musica.grab_focus.call_deferred()
	_activar_sonido_foco_tras_frame()


func mostrar_graficos() -> void:
	_preajuste_pendiente = -1
	if is_instance_valid(panel_confirmacion_reinicio):
		panel_confirmacion_reinicio.visible = false
	_actualizar_selector_graficos()
	menu_opciones.visible = false
	panel_controles.visible = false
	panel_sonido.visible = false
	panel_graficos.visible = true
	_foco_inicial_dado = false
	selector_calidad.grab_focus.call_deferred()
	_activar_sonido_foco_tras_frame()


func _poblar_selector_graficos() -> void:
	if not is_instance_valid(selector_calidad):
		return
	selector_calidad.clear()
	for i: int in ConfiguracionGrafica.NOMBRES.size():
		selector_calidad.add_item(ConfiguracionGrafica.NOMBRES[i], i)


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


func _actualizar_deslizadores_sonido() -> void:
	var idx_m: int = AudioServer.get_bus_index(GestorSonido.BUS_MUSICA)
	if idx_m >= 0 and is_instance_valid(deslizador_musica):
		deslizador_musica.set_value_no_signal(db_to_linear(AudioServer.get_bus_volume_db(idx_m)))

	var idx_e: int = AudioServer.get_bus_index(GestorSonido.BUS_EFECTOS)
	if idx_e >= 0 and is_instance_valid(deslizador_efectos):
		deslizador_efectos.set_value_no_signal(db_to_linear(AudioServer.get_bus_volume_db(idx_e)))

	var idx_a: int = AudioServer.get_bus_index(GestorSonido.BUS_AMBIENTE)
	if idx_a >= 0 and is_instance_valid(deslizador_ambiente):
		deslizador_ambiente.set_value_no_signal(db_to_linear(AudioServer.get_bus_volume_db(idx_a)))


func volver_al_titulo() -> void:
	cerrar()
	GestorSalas.global().ir_a_entrada(ESCENA_TITULO, &"")


func obtener_texto_controles() -> String:
	if texto_controles == null:
		return _construir_texto_controles()
	return texto_controles.text


func _generar_lista_controles() -> void:
	var texto: String = _construir_texto_controles()
	if texto_controles != null:
		texto_controles.text = texto


func _construir_texto_controles() -> String:
	var lineas: PackedStringArray = []
	for accion: StringName in ConfigControles.ACCIONES:
		var nombre: String = NOMBRES_ACCIONES.get(accion, str(accion).capitalize())
		var entradas: Array = ConfigControles.ACCIONES[accion]
		var teclas: PackedStringArray = []
		var mandos: PackedStringArray = []
		for entrada: Variant in entradas:
			var info: Dictionary = _describir_entrada(entrada)
			if info["tipo"] == "teclado":
				teclas.append(info["texto"])
			else:
				mandos.append(info["texto"])
		var texto_teclado: String = ", ".join(teclas) if not teclas.is_empty() else "-"
		var texto_mando: String = ", ".join(mandos) if not mandos.is_empty() else "-"
		lineas.append("%s:\n  Teclado: %s\n  Mando: %s" % [nombre, texto_teclado, texto_mando])
	return "\n\n".join(lineas)


static func _describir_entrada(def: Variant) -> Dictionary:
	if def is int:
		return {"tipo": "teclado", "texto": _nombre_tecla(def as int)}
	var s: String = str(def)
	var partes: PackedStringArray = s.split(":")
	match partes[0]:
		"raton":
			var btn: int = int(partes[1])
			var txt: String = "Clic Izq" if btn == 1 else ("Clic Der" if btn == 2 else "Ratón %d" % btn)
			return {"tipo": "teclado", "texto": txt}
		"boton":
			var idx: int = int(partes[1])
			var txt: String = ""
			match idx:
				0: txt = "A"
				1: txt = "B"
				2: txt = "X"
				3: txt = "Y"
				9: txt = "LB"
				10: txt = "RB"
				11: txt = "D-Pad Arriba"
				12: txt = "D-Pad Abajo"
				13: txt = "D-Pad Izq"
				14: txt = "D-Pad Der"
				6: txt = "Start"
				_: txt = "Botón %d" % idx
			return {"tipo": "mando", "texto": txt}
		"eje":
			var eje_idx: int = int(partes[1])
			var signo: int = int(partes[2])
			var txt: String = ""
			match eje_idx:
				0: txt = "Stick Izq (Der)" if signo > 0 else "Stick Izq (Izq)"
				1: txt = "Stick Izq (Abajo)" if signo > 0 else "Stick Izq (Arriba)"
				4: txt = "LT (Gatillo Izq)"
				5: txt = "RT (Gatillo Der)"
				_: txt = "Eje %d" % eje_idx
			return {"tipo": "mando", "texto": txt}
	return {"tipo": "teclado", "texto": s}


static func _nombre_tecla(key: int) -> String:
	match key:
		KEY_LEFT: return "Flecha Izq"
		KEY_RIGHT: return "Flecha Der"
		KEY_UP: return "Flecha Arriba"
		KEY_DOWN: return "Flecha Abajo"
		KEY_SPACE: return "Espacio"
		KEY_SHIFT: return "Shift"
		KEY_ESCAPE: return "Esc"
		_: return OS.get_keycode_string(key)
