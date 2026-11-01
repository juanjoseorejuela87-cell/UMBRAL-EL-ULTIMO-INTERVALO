extends SceneTree
## Prueba automática del menú de pausa y la pantalla de controles.
## Uso: Godot_console.exe --headless --path D:\UMBRAL -s res://tests/test_pausa.gd
## Código de salida = número de comprobaciones fallidas.

const ESCENA_PAUSA: String = "res://scenes/ui/pausa/menu_pausa.tscn"
const BARRIO: String = "res://scenes/niveles/elyndor/barrio_desprendido.tscn"
const SALON: String = "res://scenes/niveles/elyndor/salon_prefecto.tscn"

var _fallos: int = 0
var _menu: MenuPausa


func _initialize() -> void:
	ConfigControles.registrar()
	MenuPausa.asegurar_accion_pausa()
	var escena: PackedScene = load(ESCENA_PAUSA) as PackedScene
	_menu = escena.instantiate() as MenuPausa
	root.add_child(_menu)
	_ejecutar.call_deferred()


func _ejecutar() -> void:
	await _esperar(3)

	# 1. Estado inicial
	_comprobar(not paused, "el juego arranca sin pausa")
	_comprobar(not _menu.esta_abierto() and not _menu.visible, "el menú de pausa arranca oculto")

	# 2. Abrir simulando la acción pausa
	Input.action_press(MenuPausa.ACCION_PAUSA)
	await _esperar(2)
	Input.action_release(MenuPausa.ACCION_PAUSA)
	await _esperar(2)
	_comprobar(paused, "abrir pausa el árbol (simulando acción)")
	_comprobar(_menu.esta_abierto() and _menu.visible, "el menú se muestra al pausar")

	# 3. Cerrar simulando la acción pausa
	Input.action_press(MenuPausa.ACCION_PAUSA)
	await _esperar(2)
	Input.action_release(MenuPausa.ACCION_PAUSA)
	await _esperar(2)
	_comprobar(not paused, "cerrar simulando la acción reanuda el árbol")
	_comprobar(not _menu.esta_abierto() and not _menu.visible, "el menú se oculta al reanudar")

	# 4. Abrir y cerrar mediante métodos directos
	_menu.abrir()
	await _esperar(2)
	_comprobar(paused, "método abrir() pausa el árbol")
	_menu.cerrar()
	await _esperar(2)
	_comprobar(not paused, "método cerrar() reanuda el árbol")

	# 5. Lista de controles generada desde ConfigControles.ACCIONES
	var texto_controles: String = _menu.obtener_texto_controles()
	_comprobar(texto_controles.contains("Desfase"), "la lista de controles contiene «Desfase»")
	_comprobar(texto_controles.contains("Coser"), "la lista de controles contiene «Coser»")
	_comprobar(texto_controles.contains("Guardia"), "la lista de controles contiene «Guardia»")

	# 6. Navegación a la vista de controles
	_menu.abrir()
	await _esperar(2)
	_menu.mostrar_controles()
	await _esperar(2)
	_comprobar(_menu.panel_controles.visible and not _menu.menu_opciones.visible, "mostrar_controles() abre el panel de controles")
	_menu.mostrar_menu_principal()
	await _esperar(2)
	_comprobar(_menu.menu_opciones.visible and not _menu.panel_controles.visible, "mostrar_menu_principal() vuelve a las opciones")

	# 7. Volver al título quita la pausa
	_menu.volver_al_titulo()
	await _esperar(2)
	_comprobar(not paused, "«Volver al título» quita la pausa")

	# 8. Presencia en las escenas de Elyndor
	_comprobar(_comprobar_instancia_en_escena(BARRIO), "Barrio Desprendido tiene una instancia de MenuPausa")
	_comprobar(_comprobar_instancia_en_escena(SALON), "Salón del Prefecto tiene una instancia de MenuPausa")

	print("RESULTADO: %s (%d fallos)" % ["OK" if _fallos == 0 else "FALLO", _fallos])
	quit(_fallos)


func _comprobar_instancia_en_escena(ruta_escena: String) -> bool:
	var escena: PackedScene = load(ruta_escena) as PackedScene
	if escena == null:
		return false
	var estado: SceneState = escena.get_state()
	for i: int in estado.get_node_count():
		var tipo: String = estado.get_node_type(i)
		var nombre: String = str(estado.get_node_name(i))
		if nombre == "MenuPausa" or tipo == "MenuPausa":
			return true
		var inst: PackedScene = estado.get_node_instance(i)
		if inst != null and inst.resource_path == ESCENA_PAUSA:
			return true
	return false


func _esperar(frames: int) -> void:
	for i: int in frames:
		await process_frame


func _comprobar(condicion: bool, descripcion: String) -> void:
	print(("  [OK]    " if condicion else "  [FALLO] ") + descripcion)
	if not condicion:
		_fallos += 1
