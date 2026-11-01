extends SceneTree
## Prueba automática de los ecos de memoria ocultos (LORE.md §12.2, A6): solo se
## ven en el Desfase y tras obtener el Fragmento de Memoria; al tocarlos se vive
## el recuerdo y queda registrado.
## Uso: Godot_console.exe --headless --path D:\UMBRAL -s res://tests/test_eco_memoria.gd
## Código de salida = número de comprobaciones fallidas.

const CAMARA: String = "res://scenes/niveles/elyndor/camara_despertar.tscn"
const SALON: String = "res://scenes/niveles/elyndor/salon_prefecto.tscn"
const FRAGMENTO: StringName = &"fragmento_elyndor_prefecto"

var _fallos: int = 0


func _initialize() -> void:
	ConfigControles.registrar()
	GestorPartida.global().ruta_guardado = "user://prueba_eco.json"
	GestorPartida.global().nueva_partida()
	GestorSalas.global().duracion_fundido = 0.0
	_ejecutar.call_deferred()


func _ejecutar() -> void:
	var partida: GestorPartida = GestorPartida.global()
	GestorSalas.global().ir_a_entrada(CAMARA, &"inicio")
	_comprobar(await _llegar_a(CAMARA), "carga la Cámara del Despertar")
	var sala: Node = current_scene
	var nereth: Nereth = sala.get_node("Nereth") as Nereth
	var eco: EcoMemoria = sala.get_node("EcoCamara") as EcoMemoria
	await _esperar(20)

	# Sin el Fragmento de Memoria el eco no se reconoce, ni siquiera en el Desfase
	_comprobar(not eco.activo(), "en la Realidad el eco no se ve")
	nereth.fase.intentar_cambiar()
	await _esperar(20)
	_comprobar(GestorFase.global().en_desfase() and not eco.activo(), "sin el Fragmento de Memoria el eco sigue oculto en el Desfase")
	nereth.reaparecer(eco.global_position + Vector3(0, 0.1, 0))
	await _esperar(15)
	_comprobar(not eco.ya_percibido(), "tocar un eco oculto no hace nada")

	# Con el Fragmento aparece (solo en el Desfase)
	nereth.reaparecer(eco.global_position + Vector3(-5, 0.1, 0))
	await _esperar(10)
	partida.registrar_fragmento(FRAGMENTO)
	await _esperar(3)
	_comprobar(GestorFase.global().en_desfase() and eco.activo(), "con el Fragmento de Memoria el eco aparece en el Desfase")
	GestorFase.global().cambiar(GestorFase.Estado.REALIDAD)
	await _esperar(3)
	_comprobar(not eco.activo(), "el eco desaparece al volver a la Realidad")
	GestorFase.global().cambiar(GestorFase.Estado.DESFASE)
	await _esperar(3)

	# Tocarlo muestra el recuerdo y lo registra en la partida
	nereth.reaparecer(eco.global_position + Vector3(0, 0.1, 0))
	await _esperar(15)
	_comprobar(eco.ya_percibido() and partida.evento_ocurrido(&"eco_elyndor_camara_vigilia"), "tocar el eco lo registra en la partida")
	var id_camara: StringName = eco.id
	var pantalla: PantallaRecuerdo = _buscar_recuerdo()
	_comprobar(pantalla != null and pantalla.texto_frase() == "", "se vive el recuerdo del eco (sin frase de Maelis)")
	_comprobar(eco.activo(), "un eco ya vivido sigue visible, más tenue")

	# El Salón tiene su eco con un id distinto
	GestorSalas.global().ir_a_entrada(SALON, &"desde_barrio")
	_comprobar(await _llegar_a(SALON), "carga el Salón del Prefecto")
	var eco_salon: EcoMemoria = current_scene.get_node("EcoPuertasAbiertas") as EcoMemoria
	_comprobar(eco_salon.id != id_camara and eco_salon.texto != "" and not eco_salon.ya_percibido(), "el Salón tiene su propio eco por descubrir")

	partida.nueva_partida()
	GestorFase.global().cambiar(GestorFase.Estado.REALIDAD)
	print("RESULTADO: %s (%d fallos)" % ["OK" if _fallos == 0 else "FALLO", _fallos])
	quit(_fallos)


func _buscar_recuerdo() -> PantallaRecuerdo:
	for nodo: Node in root.find_children("*", "CanvasLayer", true, false):
		if nodo is PantallaRecuerdo:
			return nodo as PantallaRecuerdo
	return null


func _llegar_a(escena: String) -> bool:
	for i: int in 240:
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
