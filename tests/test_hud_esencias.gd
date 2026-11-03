extends SceneTree
## Prueba automática del HUD de Esencias y controles de pausa (TAREA-024).
## Comprueba:
## 1. El HUD muestra 3 iconos llenos al empezar.
## 2. Tras gastar una Esencia muestra 2.
## 3. Tras nereth.restaurar() vuelve a 3.
## 4. La lista de controles de la pausa incluye «Curar».
## Uso: Godot_console.exe --headless --path D:\UMBRAL -s res://tests/test_hud_esencias.gd
## Código de salida = número de comprobaciones fallidas.

const SALA: String = "res://scenes/niveles/pruebas/sala_combate.tscn"
const ESCENA_PAUSA: String = "res://scenes/ui/pausa/menu_pausa.tscn"

var _fallos: int = 0


func _initialize() -> void:
	ConfigControles.registrar()
	_ejecutar.call_deferred()


func _ejecutar() -> void:
	var sala: Node = (load(SALA) as PackedScene).instantiate()
	root.add_child(sala)

	var nereth: Nereth = null
	var hud: HudJuego = null

	for nodo in sala.find_children("*", "", true, false):
		if nodo is Nereth:
			nereth = nodo as Nereth
		elif nodo is HudJuego:
			hud = nodo as HudJuego

	for i: int in 300:
		if nereth and nereth.is_on_floor():
			break
		await physics_frame
	await _esperar(5)

	_comprobar(hud != null, "HudJuego encontrado en la sala")
	_comprobar(nereth != null, "Nereth encontrado en la sala")

	if hud and nereth:
		# 1. Estado inicial
		_comprobar(hud.obtener_cargas_esencias() == 3, "el HUD muestra 3 iconos llenos al empezar")
		_comprobar(hud.obtener_iconos_esencias().size() == 3, "la fila de Esencias contiene 3 iconos")

		# 2. Gastar una Esencia con la vida por debajo del máximo
		nereth.vida.establecer(30.0)
		var gasto_ok: bool = nereth.esencias.intentar_curar()
		_comprobar(gasto_ok, "intentar_curar() consume una carga")
		await _esperar(3)
		_comprobar(hud.obtener_cargas_esencias() == 2, "tras gastar una Esencia el HUD muestra 2 iconos llenos")

		# 3. Restaurar en Ancla o reaparición
		nereth.restaurar()
		await _esperar(3)
		_comprobar(hud.obtener_cargas_esencias() == 3, "tras nereth.restaurar() vuelve a mostrar 3 iconos llenos")

	# 4. Lista de controles de la pausa incluye «Curar»
	var escena_pausa: PackedScene = load(ESCENA_PAUSA) as PackedScene
	var menu: MenuPausa = escena_pausa.instantiate() as MenuPausa
	root.add_child(menu)
	var texto_controles: String = menu.obtener_texto_controles()
	_comprobar(texto_controles.contains("Curar"), "la lista de controles de la pausa incluye «Curar»")
	_comprobar(MenuPausa.NOMBRES_ACCIONES.has(&"curar"), "NOMBRES_ACCIONES contiene la clave &\"curar\"")

	print("RESULTADO: %s (%d fallos)" % ["OK" if _fallos == 0 else "FALLO", _fallos])
	quit(_fallos)


func _esperar(frames: int) -> void:
	for i: int in frames:
		await physics_frame


func _comprobar(condicion: bool, descripcion: String) -> void:
	print(("  [OK]    " if condicion else "  [FALLO] ") + descripcion)
	if not condicion:
		_fallos += 1
