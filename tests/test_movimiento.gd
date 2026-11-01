extends SceneTree
## Prueba automática del movimiento de Nereth.
## Uso: Godot_console.exe --headless --path D:\UMBRAL -s res://tests/test_movimiento.gd
## Código de salida = número de comprobaciones fallidas.

const SALA: String = "res://scenes/niveles/pruebas/sala_movimiento.tscn"

var _nereth: Nereth
var _fallos: int = 0


func _initialize() -> void:
	ConfigControles.registrar()
	var sala: Node = (load(SALA) as PackedScene).instantiate()
	root.add_child(sala)
	_nereth = sala.get_node("Nereth") as Nereth
	_ejecutar.call_deferred()


func _ejecutar() -> void:
	await _esperar(40)
	_comprobar(_nereth.is_on_floor(), "Nereth cae y se apoya en el suelo")

	# Aceleración y velocidad máxima
	var x_inicial: float = _nereth.global_position.x
	Input.action_press(&"mover_derecha")
	await _esperar(30)
	_comprobar(is_equal_approx(_nereth.velocity.x, _nereth.velocidad_maxima), "alcanza la velocidad máxima")
	Input.action_release(&"mover_derecha")
	_comprobar(_nereth.global_position.x > x_inicial + 2.0, "avanza hacia la derecha")
	await _esperar(8)
	_comprobar(is_zero_approx(_nereth.velocity.x), "frena en menos de 8 frames")

	# Salto completo frente a salto corto
	var altura_completa: float = await _medir_salto(40)
	var altura_corta: float = await _medir_salto(3)
	_comprobar(absf(altura_completa - _nereth.altura_salto) < 0.35, "salto completo ≈ altura_salto (%.2f)" % altura_completa)
	_comprobar(altura_corta < altura_completa * 0.6, "salto variable: el salto corto es menor (%.2f)" % altura_corta)

	# Esquiva hacia la izquierda (a la derecha está el escalón de la sala)
	var x_antes: float = _nereth.global_position.x
	var vio_invulnerable: bool = false
	Input.action_press(&"mover_izquierda")
	Input.action_press(&"esquivar")
	await _esperar(1)
	Input.action_release(&"esquivar")
	Input.action_release(&"mover_izquierda")
	for i: int in 20:
		vio_invulnerable = vio_invulnerable or _nereth.invulnerable
		await _esperar(1)
	var recorrido: float = absf(_nereth.global_position.x - x_antes)
	_comprobar(absf(recorrido - _nereth.distancia_esquiva) < 0.5, "la esquiva recorre ≈ distancia_esquiva (%.2f)" % recorrido)
	_comprobar(vio_invulnerable and not _nereth.invulnerable, "invulnerabilidad solo durante la esquiva")

	_comprobar(is_zero_approx(_nereth.global_position.z), "Nereth permanece en el plano Z = 0")

	print("RESULTADO: %s (%d fallos)" % ["OK" if _fallos == 0 else "FALLO", _fallos])
	quit(_fallos)


func _medir_salto(frames_pulsado: int) -> float:
	await _esperar(20)
	var y_inicial: float = _nereth.global_position.y
	var y_maxima: float = y_inicial
	Input.action_press(&"saltar")
	for i: int in 90:
		if i == frames_pulsado:
			Input.action_release(&"saltar")
		await _esperar(1)
		y_maxima = maxf(y_maxima, _nereth.global_position.y)
	Input.action_release(&"saltar")
	return y_maxima - y_inicial


func _esperar(frames: int) -> void:
	for i: int in frames:
		await physics_frame


func _comprobar(condicion: bool, descripcion: String) -> void:
	print(("  [OK]    " if condicion else "  [FALLO] ") + descripcion)
	if not condicion:
		_fallos += 1
