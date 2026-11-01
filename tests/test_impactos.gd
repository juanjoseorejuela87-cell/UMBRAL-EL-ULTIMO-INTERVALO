extends SceneTree
## Prueba automática de la sensación de impacto: parada de impacto (hitstop) y
## temblor de cámara al golpear y al recibir daño.
## Uso: Godot_console.exe --headless --path D:\UMBRAL -s res://tests/test_impactos.gd
## Código de salida = número de comprobaciones fallidas.

const SALA: String = "res://scenes/niveles/pruebas/sala_combate.tscn"

var _sala: Node
var _nereth: Nereth
var _camara: CamaraLateral
var _impactos: DirectorImpactos
var _fallos: int = 0


func _initialize() -> void:
	ConfigControles.registrar()
	_impactos = DirectorImpactos.global()
	_sala = (load(SALA) as PackedScene).instantiate()
	root.add_child(_sala)
	_nereth = _sala.get_node("Nereth") as Nereth
	_camara = _sala.get_node("Camara") as CamaraLateral
	_ejecutar.call_deferred()


func _ejecutar() -> void:
	await _esperar(30)

	# Sin pantalla la parada viene desactivada (no altera las demás pruebas)
	_comprobar(not _impactos.parada_activa, "sin pantalla la parada de impacto está desactivada")

	# Parada de impacto (activada a mano para probarla)
	_impactos.parada_activa = true
	_impactos._parar(0.05)
	_comprobar(_impactos.en_parada() and is_equal_approx(Engine.time_scale, _impactos.escala_tiempo_parada), "la parada de impacto ralentiza el tiempo")
	var termino: bool = false
	for i: int in 600:
		await process_frame
		if not _impactos.en_parada():
			termino = true
			break
	_comprobar(termino and is_equal_approx(Engine.time_scale, 1.0), "al terminar, el tiempo vuelve a la normalidad")
	_impactos.parada_activa = false

	# Temblor de cámara directo
	var base: Vector3 = _camara.global_position
	_camara.temblar(0.5, 0.2)
	await _esperar(2)
	_comprobar(_camara.temblando(), "la cámara tiembla")
	await _esperar(30)
	_comprobar(not _camara.temblando(), "el temblor se desvanece solo")
	_comprobar(_camara.global_position.distance_to(base) < 0.6, "tras el temblor la cámara vuelve a su seguimiento")

	# Golpear al muñeco hace temblar la cámara
	_nereth.reaparecer(Vector3(0.0, 0.05, 0.0))
	_nereth.mirando = 1.0
	await _esperar(5)
	var tembló: Array[bool] = [false]
	Input.action_press(&"atacar_ligero")
	await _esperar(1)
	Input.action_release(&"atacar_ligero")
	for i: int in 25:
		await physics_frame
		tembló[0] = tembló[0] or _camara.temblando()
	_comprobar(tembló[0], "conectar un golpe hace temblar la cámara")

	# Recibir daño hace temblar la cámara
	await _esperar(40)
	var golpe := InfoGolpe.new()
	golpe.dano = 5.0
	golpe.direccion = -1.0
	(_nereth.get_node("CajaDano") as CajaDano).recibir_golpe(golpe)
	await _esperar(2)
	_comprobar(_camara.temblando() and _nereth.vida.actual < _nereth.vida.maximo, "recibir daño hace temblar la cámara")

	# Accesibilidad: escala 0 desactiva el temblor
	await _esperar(40)
	_camara.escala_temblor = 0.0
	_camara.temblar(0.5, 0.2)
	await _esperar(2)
	_comprobar(not _camara.temblando(), "con escala de temblor 0 no hay temblor")

	print("RESULTADO: %s (%d fallos)" % ["OK" if _fallos == 0 else "FALLO", _fallos])
	quit(_fallos)


func _esperar(frames: int) -> void:
	for i: int in frames:
		await physics_frame


func _comprobar(condicion: bool, descripcion: String) -> void:
	print(("  [OK]    " if condicion else "  [FALLO] ") + descripcion)
	if not condicion:
		_fallos += 1
