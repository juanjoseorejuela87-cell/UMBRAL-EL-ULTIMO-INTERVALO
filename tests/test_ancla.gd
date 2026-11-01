extends SceneTree
## Prueba automática de las Anclas de Continuidad y del guardado.
## Uso: Godot_console.exe --headless --path D:\UMBRAL -s res://tests/test_ancla.gd
## Código de salida = número de comprobaciones fallidas.

const SALA: String = "res://scenes/niveles/pruebas/sala_ancla.tscn"
const RUTA_PRUEBA: String = "user://prueba_partida.json"

var _sala: Node
var _nereth: Nereth
var _partida: GestorPartida
var _fallos: int = 0


func _initialize() -> void:
	ConfigControles.registrar()
	_partida = GestorPartida.global()
	_partida.ruta_guardado = RUTA_PRUEBA
	_partida.borrar_memoria()
	_borrar_archivo()
	_sala = (load(SALA) as PackedScene).instantiate()
	root.add_child(_sala)
	_nereth = _sala.get_node("Nereth") as Nereth
	_ejecutar.call_deferred()


func _ejecutar() -> void:
	var ancla_a: AnclaContinuidad = _sala.get_node("AnclaA") as AnclaContinuidad
	var ancla_b: AnclaContinuidad = _sala.get_node("AnclaB") as AnclaContinuidad
	var distorsion: CSGBox3D = _sala.get_node("Geometria/Distorsion") as CSGBox3D
	var muneco: MunecoPractica = _sala.get_node("Muneco") as MunecoPractica
	await _esperar(30)

	_comprobar(ancla_a.estado == AnclaContinuidad.Estado.DORMIDA, "el Ancla empieza dormida")
	_comprobar(distorsion.visible and distorsion.use_collision, "la distorsión de la zona está activa")

	# Estabilizar
	_nereth.reaparecer(Vector3(-8.0, 0.05, 0.0))
	await _esperar(5)
	await _pulsar(&"interactuar")
	_comprobar(ancla_a.estado == AnclaContinuidad.Estado.ESTABILIZADA, "interactuar estabiliza el Ancla")
	_comprobar(_partida.ancla_estabilizada(&"pruebas_ancla_a"), "la partida registra el Ancla estabilizada")
	_comprobar(not distorsion.visible and not distorsion.use_collision, "estabilizar retira la distorsión")
	_comprobar(FileAccess.file_exists(RUTA_PRUEBA), "estabilizar guarda la partida")

	# Descansar restaura y reinicia la zona
	_nereth.vida.recibir_dano(40.0)
	_nereth.resistencia.consumir(60.0)
	_nereth.resonancia.gastar(70.0)
	muneco.vida.recibir_dano(50.0)
	muneco.postura.acumular(30.0)
	await _pulsar(&"interactuar")
	_comprobar(is_equal_approx(_nereth.vida.actual, _nereth.vida.maximo), "descansar restaura la vida")
	_comprobar(is_equal_approx(_nereth.resistencia.actual, _nereth.resistencia.maximo), "descansar restaura la resistencia")
	_comprobar(is_equal_approx(_nereth.resonancia.actual, _nereth.resonancia.maximo), "descansar restaura la Resonancia")
	_comprobar(is_equal_approx(muneco.vida.actual, muneco.vida.maximo) and is_zero_approx(muneco.postura.actual), "descansar reinicia la zona (el muñeco vuelve a su estado)")
	_comprobar(_partida.ancla_actual == &"pruebas_ancla_a", "el Ancla pasa a ser el punto de reaparición")

	# Descansar desde el Desfase devuelve a la Realidad
	_nereth.fase.intentar_cambiar()
	await _esperar(25)
	await _pulsar(&"interactuar")
	_comprobar(not GestorFase.global().en_desfase(), "descansar devuelve a la Realidad")

	# Ancla con reto
	_nereth.reaparecer(Vector3(8.0, 0.05, 0.0))
	await _esperar(5)
	await _pulsar(&"interactuar")
	_comprobar(ancla_b.estado == AnclaContinuidad.Estado.DORMIDA, "un Ancla con reto pendiente no se estabiliza")
	ancla_b.completar_reto()
	await _pulsar(&"interactuar")
	_comprobar(ancla_b.estado == AnclaContinuidad.Estado.ESTABILIZADA, "completado el reto, se estabiliza")

	# Derrota: reaparición en el último Ancla
	_nereth.reaparecer(Vector3(-12.0, 0.05, 0.0))
	await _esperar(5)
	_nereth.vida.recibir_dano(_nereth.vida.maximo)
	await _esperar(3)
	_comprobar(absf(_nereth.global_position.x - 8.0) < 0.5, "al ser derrotado reaparece en el último Ancla (x = %.1f)" % _nereth.global_position.x)
	_comprobar(is_equal_approx(_nereth.vida.actual, _nereth.vida.maximo), "reaparece con la vida completa")

	# Persistencia
	_partida.borrar_memoria()
	_comprobar(not _partida.ancla_estabilizada(&"pruebas_ancla_a"), "(memoria vaciada)")
	_comprobar(_partida.cargar(), "la partida se carga desde el archivo")
	_comprobar(_partida.ancla_estabilizada(&"pruebas_ancla_a") and _partida.ancla_estabilizada(&"pruebas_ancla_b"), "las Anclas estabilizadas persisten")
	_comprobar(_partida.ancla_actual == &"pruebas_ancla_b" and _partida.hay_reaparicion, "el punto de reaparición persiste")

	# Un Ancla ya estabilizada en la partida aparece estabilizada al cargar la sala
	var sala2: Node = (load(SALA) as PackedScene).instantiate()
	root.add_child(sala2)
	await _esperar(2)
	_comprobar((sala2.get_node("AnclaA") as AnclaContinuidad).estado == AnclaContinuidad.Estado.ESTABILIZADA, "al recargar, el Ancla sigue estabilizada")
	_comprobar(not (sala2.get_node("Geometria/Distorsion") as CSGBox3D).visible, "al recargar, la distorsión sigue retirada")
	sala2.queue_free()

	_borrar_archivo()
	print("RESULTADO: %s (%d fallos)" % ["OK" if _fallos == 0 else "FALLO", _fallos])
	quit(_fallos)


func _borrar_archivo() -> void:
	if FileAccess.file_exists(RUTA_PRUEBA):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(RUTA_PRUEBA))


func _pulsar(accion: StringName) -> void:
	Input.action_press(accion)
	await _esperar(1)
	Input.action_release(accion)
	await _esperar(1)


func _esperar(frames: int) -> void:
	for i: int in frames:
		await physics_frame


func _comprobar(condicion: bool, descripcion: String) -> void:
	print(("  [OK]    " if condicion else "  [FALLO] ") + descripcion)
	if not condicion:
		_fallos += 1
