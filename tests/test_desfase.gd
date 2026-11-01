extends SceneTree
## Prueba automática del sistema de Desfase y de la Resonancia.
## Uso: Godot_console.exe --headless --path D:\UMBRAL -s res://tests/test_desfase.gd
## Código de salida = número de comprobaciones fallidas.

const SALA: String = "res://scenes/niveles/pruebas/sala_desfase.tscn"

var _sala: Node
var _nereth: Nereth
var _res: ComponenteResonancia
var _fase: GestorFase
var _fallos: int = 0


func _initialize() -> void:
	ConfigControles.registrar()
	_fase = GestorFase.global()
	_sala = (load(SALA) as PackedScene).instantiate()
	root.add_child(_sala)
	_nereth = _sala.get_node("Nereth") as Nereth
	_ejecutar.call_deferred()


func _ejecutar() -> void:
	_res = _nereth.resonancia
	var puente: CSGBox3D = _sala.get_node("Geometria/PuenteDesfase") as CSGBox3D
	var muro_real: CSGBox3D = _sala.get_node("Geometria/MuroReal") as CSGBox3D
	await _esperar(30)

	# Estados y apariencia
	_comprobar(not _fase.en_desfase(), "empieza en la Realidad")
	_comprobar(_nereth.collision_mask == 3, "en la Realidad choca con lo común y lo real")
	_comprobar(not puente.visible, "lo que solo existe en el Desfase es invisible en la Realidad")
	await _pulsar(&"desfase")
	_comprobar(_fase.en_desfase(), "el botón de Desfase cambia de estado")
	_comprobar(_res.actual > _res.maximo - 0.5, "en Calma entrar en Desfase es gratis")
	_comprobar(_nereth.invulnerable, "la transición hace a Nereth intangible")
	_comprobar(puente.visible, "en el Desfase aparece el puente")
	_comprobar(muro_real.visible and muro_real.material_override != null, "lo real se ve como silueta desde el Desfase")
	_comprobar(_nereth.collision_mask == 5, "en el Desfase choca con lo común y lo del Desfase")

	# Consumo en Calma
	var antes: float = _res.actual
	await _esperar(60)
	_comprobar(absf((antes - _res.actual) - _res.consumo_calma) < 0.3, "consumo en Calma ≈ %.1f/s (%.2f)" % [_res.consumo_calma, antes - _res.actual])

	# Recorrido por la sala en Desfase
	_nereth.reaparecer(Vector3(-6.0, 0.05, 0.0))
	await _mantener(&"mover_derecha", 70)
	_comprobar(_nereth.global_position.x > 0.0 and _nereth.is_on_floor(), "cruza el puente del Desfase (x = %.1f)" % _nereth.global_position.x)
	_nereth.reaparecer(Vector3(4.0, 0.05, 0.0))
	await _mantener(&"mover_derecha", 40)
	_comprobar(_nereth.global_position.x > 6.5, "atraviesa el muro real en Desfase (x = %.1f)" % _nereth.global_position.x)
	await _mantener(&"mover_derecha", 60)
	_comprobar(_nereth.global_position.x < 10.8, "el muro del Desfase bloquea (x = %.1f)" % _nereth.global_position.x)

	# No se puede volver a la Realidad dentro de un sólido real
	var bloqueos: Array[int] = [0]
	_nereth.fase.cambio_bloqueado.connect(func() -> void: bloqueos[0] += 1)
	_nereth.reaparecer(Vector3(6.0, 0.05, 0.0))
	await _esperar(5)
	await _pulsar(&"desfase")
	_comprobar(_fase.en_desfase() and bloqueos[0] == 1, "el cambio se bloquea si Nereth quedaría dentro de un muro")

	# Caer al desaparecer el suelo real
	_nereth.reaparecer(Vector3(17.0, 0.05, 0.0))
	await _esperar(90)
	_comprobar(_nereth.global_position.x < -10.0, "sin suelo real cae y reaparece al inicio (x = %.1f)" % _nereth.global_position.x)

	# Recuperación en Calma
	_nereth.fase.reiniciar()
	_res.actual = 50.0
	await _esperar(60)
	_comprobar(_res.actual >= 70.0, "en Calma la Resonancia se recupera rápido (%.1f)" % _res.actual)

	# Régimen de Amenaza (zona de presión)
	_nereth.reaparecer(Vector3(24.0, 0.05, 0.0))
	await _esperar(10)
	_comprobar(_res.amenaza(), "la zona de presión activa el régimen de Amenaza")
	_res.actual = 50.0
	await _pulsar(&"desfase")
	_comprobar(absf(_res.actual - (50.0 - _res.coste_entrada_amenaza)) < 0.5, "en Amenaza entrar cuesta %.0f (%.1f)" % [_res.coste_entrada_amenaza, _res.actual])
	var consumo_inicial: float = _res.consumo_actual()
	await _esperar(120)
	_comprobar(_res.consumo_actual() > consumo_inicial, "en Amenaza el consumo crece con el tiempo")

	# Rechazo
	_res.gastar(_res.actual)
	await _esperar(3)
	_comprobar(not _fase.en_desfase(), "al agotar la Resonancia hay Rechazo a la Realidad")
	_comprobar(_nereth.estado == Nereth.Estado.ATURDIDO, "el Rechazo aturde a Nereth")
	await _esperar(40)
	_comprobar(_nereth.estado != Nereth.Estado.ATURDIDO, "el aturdimiento termina")
	_res.actual = 50.0
	await _pulsar(&"desfase")
	_comprobar(not _fase.en_desfase(), "tras el Rechazo no se puede volver a entrar enseguida")
	await _esperar(130)
	await _pulsar(&"desfase")
	_comprobar(_fase.en_desfase(), "pasado el bloqueo se puede volver a entrar")

	# Recuperación limitada en Amenaza
	_nereth.fase.reiniciar()
	_res.actual = 28.0
	await _esperar(120)
	_comprobar(is_equal_approx(_res.actual, _res.maximo * _res.limite_recuperacion_amenaza), "en Amenaza la recuperación pasiva se detiene en el 30 %% (%.1f)" % _res.actual)

	# Desfase preciso
	_res.actual = 50.0
	await _pulsar(&"desfase")
	var tras_entrar: float = _res.actual
	var golpe := InfoGolpe.new()
	var recibido: bool = (_nereth.get_node("CajaDano") as CajaDano).recibir_golpe(golpe)
	_comprobar(not recibido, "durante la transición el golpe atraviesa")
	_comprobar(_res.actual > tras_entrar + 9.0, "Desfase preciso: devuelve Resonancia (%.1f → %.1f)" % [tras_entrar, _res.actual])

	# Golpear gana Resonancia
	_nereth.fase.reiniciar()
	_nereth.reaparecer(Vector3(26.5, 0.05, 0.0))
	_nereth.mirando = 1.0
	await _esperar(10)
	_res.actual = 10.0
	await _pulsar(&"atacar_ligero")
	await _esperar(25)
	_comprobar(_res.actual >= 14.0, "conectar un golpe da Resonancia (%.1f)" % _res.actual)

	print("RESULTADO: %s (%d fallos)" % ["OK" if _fallos == 0 else "FALLO", _fallos])
	quit(_fallos)


func _mantener(accion: StringName, frames: int) -> void:
	Input.action_press(accion)
	await _esperar(frames)
	Input.action_release(accion)
	await _esperar(8)


## Pulsa una acción un frame y espera a que Nereth lo procese (la señal
## physics_frame llega antes de que los nodos procesen su frame).
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
