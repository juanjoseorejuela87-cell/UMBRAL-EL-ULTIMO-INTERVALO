extends SceneTree
## Prueba automática del ambiente sonoro de las salas, sonidos de interfaz y volúmenes (TAREA-009).
## Uso: Godot_console.exe --headless --path D:\UMBRAL -s res://tests/test_sonido_ui.gd
## Código de salida = número de comprobaciones fallidas.

const BARRIO: String = "res://scenes/niveles/elyndor/barrio_desprendido.tscn"
const SALON: String = "res://scenes/niveles/elyndor/salon_prefecto.tscn"
const TITULO: String = "res://scenes/ui/titulo/titulo.tscn"
const FIN: String = "res://scenes/ui/fin_demo/fin_demo.tscn"
const PAUSA: String = "res://scenes/ui/pausa/menu_pausa.tscn"

var _sonido: GestorSonido
var _fallos: int = 0


func _initialize() -> void:
	ConfigControles.registrar()
	_sonido = GestorSonido.global()
	_ejecutar.call_deferred()


func _ejecutar() -> void:
	await _esperar(3)

	# 1. El Barrio fija el ambiente «elyndor»
	var escena_barrio: PackedScene = load(BARRIO) as PackedScene
	_comprobar(escena_barrio != null, "la escena del Barrio existe")
	var nodo_barrio: Node = escena_barrio.instantiate()
	root.add_child(nodo_barrio)
	await _esperar(3)
	_comprobar(_sonido.ambiente_actual() == &"elyndor", "el Barrio Desprendido activa el ambiente «elyndor»")
	nodo_barrio.queue_free()
	await _esperar(3)

	# 2. El Salón fija el ambiente «prefecto»
	var escena_salon: PackedScene = load(SALON) as PackedScene
	_comprobar(escena_salon != null, "la escena del Salón existe")
	var nodo_salon: Node = escena_salon.instantiate()
	root.add_child(nodo_salon)
	await _esperar(3)
	_comprobar(_sonido.ambiente_actual() == &"prefecto", "el Salón del Prefecto activa el ambiente «prefecto»")
	nodo_salon.queue_free()
	await _esperar(3)

	# 3. La pantalla de título detiene el ambiente (&"")
	var escena_titulo: PackedScene = load(TITULO) as PackedScene
	_comprobar(escena_titulo != null, "la pantalla de título existe")
	var nodo_titulo: Node = escena_titulo.instantiate()
	root.add_child(nodo_titulo)
	await _esperar(3)
	_comprobar(_sonido.ambiente_actual() == &"", "la pantalla de título detiene el ambiente")
	nodo_titulo.queue_free()
	await _esperar(3)

	# 4. El fin de la demo también detiene el ambiente
	_sonido.ambiente(&"elyndor")
	var escena_fin: PackedScene = load(FIN) as PackedScene
	var nodo_fin: Node = escena_fin.instantiate()
	root.add_child(nodo_fin)
	await _esperar(3)
	_comprobar(_sonido.ambiente_actual() == &"", "la pantalla de fin de la demo detiene el ambiente")
	nodo_fin.queue_free()
	await _esperar(3)

	# 5. Volúmenes en el menú de pausa: mover un deslizador cambia el volumen del bus
	var escena_pausa: PackedScene = load(PAUSA) as PackedScene
	var menu: MenuPausa = escena_pausa.instantiate() as MenuPausa
	root.add_child(menu)
	menu.abrir()
	menu.mostrar_sonido()
	await _esperar(3)

	_comprobar(menu.panel_sonido.visible, "la sección de sonido es visible en el menú de pausa")

	# Probar cambio en deslizador de música
	menu.deslizador_musica.value = 0.65
	await _esperar(2)
	var db_m: float = AudioServer.get_bus_volume_db(AudioServer.get_bus_index(GestorSonido.BUS_MUSICA))
	_comprobar(absf(db_m - linear_to_db(0.65)) < 0.02, "el deslizador de música ajusta el bus Música (db = %.2f)" % db_m)

	# Probar cambio en deslizador de efectos
	menu.deslizador_efectos.value = 0.40
	await _esperar(2)
	var db_e: float = AudioServer.get_bus_volume_db(AudioServer.get_bus_index(GestorSonido.BUS_EFECTOS))
	_comprobar(absf(db_e - linear_to_db(0.40)) < 0.02, "el deslizador de efectos ajusta el bus Efectos (db = %.2f)" % db_e)

	# Probar cambio en deslizador de ambiente
	menu.deslizador_ambiente.value = 0.25
	await _esperar(2)
	var db_a: float = AudioServer.get_bus_volume_db(AudioServer.get_bus_index(GestorSonido.BUS_AMBIENTE))
	_comprobar(absf(db_a - linear_to_db(0.25)) < 0.02, "el deslizador de ambiente ajusta el bus Ambiente (db = %.2f)" % db_a)

	# Probar que al volver a abrir la sección muestra los volúmenes actuales
	menu.mostrar_menu_principal()
	await _esperar(2)
	_sonido.fijar_volumen(GestorSonido.BUS_EFECTOS, 0.85)
	menu.mostrar_sonido()
	await _esperar(2)
	_comprobar(absf(menu.deslizador_efectos.value - 0.85) < 0.02, "los deslizadores leen el volumen actual del bus al abrir la sección")

	# Restaurar volúmenes
	_sonido.fijar_volumen(GestorSonido.BUS_MUSICA, 1.0)
	_sonido.fijar_volumen(GestorSonido.BUS_EFECTOS, 1.0)
	_sonido.fijar_volumen(GestorSonido.BUS_AMBIENTE, 1.0)
	menu.cerrar()
	menu.queue_free()

	print("RESULTADO: %s (%d fallos)" % ["OK" if _fallos == 0 else "FALLO", _fallos])
	quit(_fallos)


func _esperar(frames: int) -> void:
	for i: int in frames:
		await process_frame


func _comprobar(condicion: bool, descripcion: String) -> void:
	print(("  [OK]    " if condicion else "  [FALLO] ") + descripcion)
	if not condicion:
		_fallos += 1
