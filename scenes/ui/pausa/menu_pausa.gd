class_name MenuPausa
extends CanvasLayer
## Menú de pausa del juego con lista legible de controles y ajustes de sonido y gráficos.
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
	&"curar": "Curar (Esencia)",
}

var _abierto: bool = false
var _ultimo_frame_accion: int = -1
var _foco_inicial_dado: bool = false

@onready var panel_raiz: Control = %PanelRaiz
@onready var menu_opciones: VBoxContainer = %MenuOpciones
@onready var panel_controles: VBoxContainer = %PanelControles
@onready var panel_ajustes: PanelAjustes = %PanelAjustes

@onready var boton_reanudar: Button = %Reanudar
@onready var boton_controles: Button = %Controles
@onready var boton_sonido: Button = %Sonido
@onready var boton_graficos: Button = %Graficos
@onready var boton_volver_titulo: Button = %VolverTitulo
@onready var boton_volver_menu: Button = %VolverMenu

@onready var texto_controles: Label = %TextoControles

# Delegaciones a panel_ajustes para compatibilidad y pruebas
var panel_sonido: VBoxContainer:
	get: return panel_ajustes.panel_sonido if panel_ajustes != null else null
var panel_graficos: VBoxContainer:
	get: return panel_ajustes.panel_graficos if panel_ajustes != null else null
var deslizador_musica: HSlider:
	get: return panel_ajustes.deslizador_musica if panel_ajustes != null else null
var deslizador_efectos: HSlider:
	get: return panel_ajustes.deslizador_efectos if panel_ajustes != null else null
var deslizador_ambiente: HSlider:
	get: return panel_ajustes.deslizador_ambiente if panel_ajustes != null else null
var selector_calidad: OptionButton:
	get: return panel_ajustes.selector_calidad if panel_ajustes != null else null
var texto_descripcion_calidad: Label:
	get: return panel_ajustes.texto_descripcion_calidad if panel_ajustes != null else null
var panel_confirmacion_reinicio: VBoxContainer:
	get: return panel_ajustes.panel_confirmacion_reinicio if panel_ajustes != null else null
var texto_aviso_reinicio: Label:
	get: return panel_ajustes.texto_aviso_reinicio if panel_ajustes != null else null
var boton_reiniciar: Button:
	get: return panel_ajustes.boton_reiniciar if panel_ajustes != null else null
var boton_cancelar_reinicio: Button:
	get: return panel_ajustes.boton_cancelar_reinicio if panel_ajustes != null else null
var boton_volver_sonido: Button:
	get: return panel_ajustes.boton_volver_sonido if panel_ajustes != null else null
var boton_volver_graficos: Button:
	get: return panel_ajustes.boton_volver_graficos if panel_ajustes != null else null


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

	panel_ajustes.volver_pulsado.connect(mostrar_menu_principal)

	# Sonidos de interfaz para botones
	for btn: Button in [
		boton_reanudar,
		boton_controles,
		boton_sonido,
		boton_graficos,
		boton_volver_titulo,
		boton_volver_menu,
	]:
		_conectar_sonidos_boton(btn)

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
	panel_ajustes.visible = false
	panel_ajustes.ocultar_todo()
	_foco_inicial_dado = false
	boton_reanudar.grab_focus.call_deferred()
	_activar_sonido_foco_tras_frame()


func mostrar_controles() -> void:
	menu_opciones.visible = false
	panel_controles.visible = true
	panel_ajustes.visible = false
	panel_ajustes.ocultar_todo()
	_foco_inicial_dado = false
	boton_volver_menu.grab_focus.call_deferred()
	_activar_sonido_foco_tras_frame()


func mostrar_sonido() -> void:
	menu_opciones.visible = false
	panel_controles.visible = false
	panel_ajustes.mostrar_sonido()


func mostrar_graficos() -> void:
	menu_opciones.visible = false
	panel_controles.visible = false
	panel_ajustes.mostrar_graficos()


func seleccionar_preajuste(p: ConfiguracionGrafica.Preajuste) -> void:
	panel_ajustes.seleccionar_preajuste(p)


func cancelar_reinicio() -> void:
	panel_ajustes.cancelar_reinicio()


func confirmar_reinicio() -> void:
	panel_ajustes.confirmar_reinicio()


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
