extends SceneTree
## Prueba automática del flujo de la demo: título, Fragmento del Prefecto,
## salida al fin de la demo y vuelta al título con continuar / nueva partida.
## Uso: Godot_console.exe --headless --path D:\UMBRAL -s res://tests/test_demo.gd
## Código de salida = número de comprobaciones fallidas.

const TITULO: String = "res://scenes/ui/titulo/titulo.tscn"
const BARRIO: String = "res://scenes/niveles/elyndor/barrio_desprendido.tscn"
const CAMARA: String = "res://scenes/niveles/elyndor/camara_despertar.tscn"
const SALON: String = "res://scenes/niveles/elyndor/salon_prefecto.tscn"
const FIN: String = "res://scenes/ui/fin_demo/fin_demo.tscn"

var _partida: GestorPartida
var _fallos: int = 0


func _initialize() -> void:
	ConfigControles.registrar()
	_partida = GestorPartida.global()
	_partida.ruta_guardado = "user://prueba_demo.json"
	_partida.nueva_partida()
	GestorSalas.global().duracion_fundido = 0.0
	_ejecutar.call_deferred()


func _ejecutar() -> void:
	# --- Título sin partida ---
	change_scene_to_file(TITULO)
	await _llegar_a(TITULO)
	var titulo: PantallaTitulo = current_scene as PantallaTitulo
	_comprobar(titulo != null, "arranca la pantalla de título")
	_comprobar(titulo.boton_continuar.disabled, "sin partida, «Continuar» está desactivado")
	titulo.nueva_partida()
	_comprobar(await _llegar_a(CAMARA), "«Nueva partida» empieza en la Cámara del Despertar")

	# --- Recompensa del Prefecto ---
	change_scene_to_file(SALON)
	await _llegar_a(SALON)
	var salon: Node = current_scene
	var fragmento: FragmentoContinuidad = salon.get_node("FragmentoPrefecto") as FragmentoContinuidad
	var prefecto: Prefecto = salon.get_node("Prefecto") as Prefecto
	var nereth: Nereth = salon.get_node("Nereth") as Nereth
	_comprobar(not fragmento.activo(), "el Fragmento no aparece mientras el Prefecto sigue en pie")
	prefecto.vida.recibir_dano(prefecto.vida.maximo * 2.0)
	await _esperar(3)
	_comprobar(fragmento.activo(), "al caer el Prefecto aparece el Fragmento de Continuidad")
	nereth.reaparecer(fragmento.global_position + Vector3(0.0, 0.1, 0.0))
	await _esperar(5)
	_comprobar(_partida.fragmento_obtenido_ya(&"fragmento_elyndor_prefecto") and not fragmento.visible, "tocar el Fragmento lo recoge y queda guardado")
	var recuerdo: PantallaRecuerdo = null
	for hijo: Node in salon.get_children():
		if hijo is PantallaRecuerdo:
			recuerdo = hijo
	_comprobar(recuerdo != null and recuerdo.texto_frase().contains("el último intervalo no se ha cerrado"), "al tocarlo, Nereth vive el recuerdo con la frase oficial")

	# --- Salida al fin de la demo ---
	nereth.reaparecer(Vector3(21.0, 0.1, 0.0))
	await _esperar(2)
	nereth.reaparecer(Vector3(23.0, 0.1, 0.0))
	_comprobar(await _llegar_a(FIN), "cruzar la puerta abierta lleva al fin de la demo")
	var fin: PantallaFinDemo = current_scene as PantallaFinDemo
	_comprobar(fin != null and fin.resumen.text.contains("Fragmentos de Continuidad: 1"), "el resumen cuenta el Fragmento")
	_comprobar(fin != null and fin.resumen.text.contains("derrotado"), "el resumen registra la derrota del Prefecto")
	_comprobar(fin != null and (fin.get_node("Centro/Texto") as Label).text.contains("No recuperes los fragmentos"), "al salir de Elyndor se oye a Maelis")

	# --- Vuelta al título y continuar ---
	_partida.escena_ancla = SALON
	_partida.posicion_reaparicion = Vector3(-20.0, 0.1, 0.0)
	_partida.hay_reaparicion = true
	_partida.guardar()
	fin.volver_al_titulo()
	_comprobar(await _llegar_a(TITULO), "«Volver al título» funciona")
	titulo = current_scene as PantallaTitulo
	_comprobar(not titulo.boton_continuar.disabled, "con partida, «Continuar» está activo")
	titulo.continuar()
	_comprobar(await _llegar_a(SALON), "«Continuar» lleva a la sala del último Ancla")

	# --- Nueva partida con confirmación ---
	change_scene_to_file(TITULO)
	await _llegar_a(TITULO)
	titulo = current_scene as PantallaTitulo
	titulo.nueva_partida()
	await _esperar(3)
	_comprobar(_escena() == TITULO and _partida.hay_reaparicion, "con partida, «Nueva partida» pide confirmación primero")
	titulo.nueva_partida()
	_comprobar(await _llegar_a(CAMARA), "al confirmar empieza de cero en la Cámara del Despertar")
	_comprobar(not _partida.existe_partida() or _partida.fragmentos.is_empty(), "la partida anterior se ha borrado")
	_comprobar(_partida.fragmentos.is_empty() and not _partida.hay_reaparicion, "la memoria de la partida está vacía")

	_partida.nueva_partida()
	print("RESULTADO: %s (%d fallos)" % ["OK" if _fallos == 0 else "FALLO", _fallos])
	quit(_fallos)


func _llegar_a(escena: String) -> bool:
	for i: int in 180:
		if _escena() == escena and not GestorSalas.global().cambiando():
			return true
		await physics_frame
	return false


func _escena() -> String:
	return current_scene.scene_file_path if current_scene else ""


func _esperar(frames: int) -> void:
	for i: int in frames:
		await physics_frame


func _comprobar(condicion: bool, descripcion: String) -> void:
	print(("  [OK]    " if condicion else "  [FALLO] ") + descripcion)
	if not condicion:
		_fallos += 1
