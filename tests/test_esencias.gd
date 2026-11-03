extends SceneTree
## Prueba automática de las Esencias (curación de Nereth): gastar cargas, curar
## tras beber, quedar vulnerable (un golpe interrumpe y la carga se pierde) y
## rellenar al restaurar (descanso en un Ancla o reaparición).
## Uso: Godot_console.exe --headless --path D:\UMBRAL -s res://tests/test_esencias.gd
## Código de salida = número de comprobaciones fallidas.

const SALA: String = "res://scenes/niveles/pruebas/sala_combate.tscn"

var _fallos: int = 0


func _initialize() -> void:
	ConfigControles.registrar()
	_ejecutar.call_deferred()


func _ejecutar() -> void:
	var sala: Node = (load(SALA) as PackedScene).instantiate()
	root.add_child(sala)
	var nereth: Nereth = sala.find_children("*", "Nereth", true, false)[0] as Nereth
	var esencias: EsenciasNereth = nereth.esencias
	for i: int in 300:
		if nereth.is_on_floor():
			break
		await physics_frame
	await _esperar(5)

	_comprobar(esencias.cargas == esencias.cargas_maximas and esencias.cargas_maximas == 3, "empieza con 3 Esencias")

	# Con la vida llena no se gasta ninguna
	await _pulsar(&"curar")
	_comprobar(esencias.cargas == 3 and nereth.estado != Nereth.Estado.CURANDO, "con la vida llena no se bebe")

	# Beber cura un 40 % de la vida máxima tras la duración
	nereth.vida.establecer(30.0)
	await _pulsar(&"curar")
	_comprobar(nereth.estado == Nereth.Estado.CURANDO and esencias.cargas == 2, "pulsar curar gasta una carga y deja a Nereth bebiendo")
	await _esperar_segundos(esencias.duracion + 0.2)
	var esperado: float = 30.0 + nereth.vida.maximo * esencias.curacion
	_comprobar(absf(nereth.vida.actual - esperado) < 0.5, "al terminar recupera el 40 %% de la vida (%.0f)" % nereth.vida.actual)
	_comprobar(nereth.estado != Nereth.Estado.CURANDO, "después recupera el control")

	# Un golpe durante la curación la interrumpe: la carga se pierde y no cura
	nereth.vida.establecer(30.0)
	await _pulsar(&"curar")
	var golpe := InfoGolpe.new()
	golpe.dano = 5.0
	golpe.direccion = -nereth.mirando
	nereth.call(&"_al_recibir_golpe", golpe)
	await _esperar_segundos(esencias.duracion + 0.2)
	_comprobar(esencias.cargas == 1 and nereth.vida.actual < 30.0, "un golpe interrumpe la curación y la carga se pierde")

	# Sin cargas no se puede curar
	await _pulsar(&"curar")
	await _esperar_segundos(esencias.duracion + 0.2)
	await _pulsar(&"curar")
	_comprobar(esencias.cargas == 0 and nereth.estado != Nereth.Estado.CURANDO, "sin Esencias no se puede beber")

	# Descansar o reaparecer las rellena
	nereth.restaurar()
	_comprobar(esencias.cargas == 3, "restaurar (Ancla, reaparición) rellena las Esencias")

	print("RESULTADO: %s (%d fallos)" % ["OK" if _fallos == 0 else "FALLO", _fallos])
	quit(_fallos)


func _pulsar(accion: StringName) -> void:
	Input.action_press(accion)
	for i: int in 3:
		await process_frame
	await _esperar(2)
	Input.action_release(accion)
	await _esperar(2)


func _esperar_segundos(segundos: float) -> void:
	var fin: int = Time.get_ticks_msec() + int(segundos * 1000.0)
	while Time.get_ticks_msec() < fin:
		await physics_frame


func _esperar(frames: int) -> void:
	for i: int in frames:
		await physics_frame


func _comprobar(condicion: bool, descripcion: String) -> void:
	print(("  [OK]    " if condicion else "  [FALLO] ") + descripcion)
	if not condicion:
		_fallos += 1
