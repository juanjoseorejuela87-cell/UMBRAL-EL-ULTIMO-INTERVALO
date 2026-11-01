extends SceneTree
## Prueba automática del cambio de sala (GestorSalas, TransicionSala,
## PuntoEntrada) y de la reaparición en un Ancla de otra sala.
## Uso: Godot_console.exe --headless --path D:\UMBRAL -s res://tests/test_transiciones.gd
## Código de salida = número de comprobaciones fallidas.

const SALA_A: String = "res://scenes/niveles/pruebas/sala_transicion_a.tscn"
const SALA_B: String = "res://scenes/niveles/pruebas/sala_transicion_b.tscn"

var _fallos: int = 0


func _initialize() -> void:
	ConfigControles.registrar()
	GestorPartida.global().ruta_guardado = "user://prueba_transiciones.json"
	GestorPartida.global().borrar_memoria()
	GestorSalas.global().duracion_fundido = 0.0
	_ejecutar.call_deferred()


func _ejecutar() -> void:
	change_scene_to_file(SALA_A)
	await _esperar(10)
	_comprobar(_escena() == SALA_A, "carga la sala A")

	# A -> B conservando vida y Resonancia
	var nereth: Nereth = _nereth()
	nereth.vida.establecer(60.0)
	nereth.resonancia.establecer(40.0)
	nereth.reaparecer(Vector3(9.5, 0.1, 0.0))
	var llego: bool = await _esperar_hasta(func() -> bool: return _escena() == SALA_B and not GestorSalas.global().cambiando(), 60)
	_comprobar(llego, "entrar en la transición lleva a la sala B")
	nereth = _nereth()
	_comprobar(nereth != null and absf(nereth.global_position.x - (-6.0)) < 0.3, "Nereth aparece en la entrada «desde_a»")
	# La Resonancia se regenera en Calma: basta con que no se haya reiniciado al máximo.
	_comprobar(nereth != null and is_equal_approx(nereth.vida.actual, 60.0) and absf(nereth.resonancia.actual - 40.0) < 3.0, "la vida y la Resonancia se conservan entre salas (%.1f, %.1f)" % [nereth.vida.actual, nereth.resonancia.actual])
	_comprobar(nereth != null and is_equal_approx(nereth.mirando, 1.0), "Nereth mira hacia donde indica la entrada")

	# B -> A
	await _esperar(5)
	nereth.reaparecer(Vector3(-9.5, 0.1, 0.0))
	llego = await _esperar_hasta(func() -> bool: return _escena() == SALA_A and not GestorSalas.global().cambiando(), 60)
	nereth = _nereth()
	_comprobar(llego and nereth != null and absf(nereth.global_position.x - 6.0) < 0.3, "de vuelta en A, aparece en «desde_b»")

	# Reaparición en un Ancla de otra sala
	var partida: GestorPartida = GestorPartida.global()
	partida.escena_ancla = SALA_B
	partida.posicion_reaparicion = Vector3(3.0, 0.1, 0.0)
	partida.hay_reaparicion = true
	nereth.vida.recibir_dano(nereth.vida.maximo)
	llego = await _esperar_hasta(func() -> bool: return _escena() == SALA_B and not GestorSalas.global().cambiando(), 60)
	nereth = _nereth()
	_comprobar(llego and nereth != null and absf(nereth.global_position.x - 3.0) < 0.3, "al caer, reaparece en el Ancla de la otra sala")
	_comprobar(nereth != null and is_equal_approx(nereth.vida.actual, nereth.vida.maximo), "reaparece con la vida completa")

	print("RESULTADO: %s (%d fallos)" % ["OK" if _fallos == 0 else "FALLO", _fallos])
	quit(_fallos)


func _escena() -> String:
	return current_scene.scene_file_path if current_scene else ""


func _nereth() -> Nereth:
	return get_first_node_in_group(Nereth.GRUPO) as Nereth


func _esperar_hasta(condicion: Callable, max_frames: int) -> bool:
	for i: int in max_frames:
		if condicion.call():
			return true
		await physics_frame
	return condicion.call()


func _esperar(frames: int) -> void:
	for i: int in frames:
		await physics_frame


func _comprobar(condicion: bool, descripcion: String) -> void:
	print(("  [OK]    " if condicion else "  [FALLO] ") + descripcion)
	if not condicion:
		_fallos += 1
