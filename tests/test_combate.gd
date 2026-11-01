extends SceneTree
## Prueba automática del combate base de Nereth contra el muñeco de práctica.
## Uso: Godot_console.exe --headless --path D:\UMBRAL -s res://tests/test_combate.gd
## Código de salida = número de comprobaciones fallidas.

const SALA: String = "res://scenes/niveles/pruebas/sala_combate.tscn"

var _nereth: Nereth
var _muneco: MunecoPractica
var _golpes: Array[InfoGolpe] = []
var _fallos: int = 0


func _initialize() -> void:
	ConfigControles.registrar()
	var sala: Node = (load(SALA) as PackedScene).instantiate()
	root.add_child(sala)
	_nereth = sala.get_node("Nereth") as Nereth
	_muneco = sala.get_node("MunecoMedio") as MunecoPractica
	_ejecutar.call_deferred()


func _ejecutar() -> void:
	_muneco.golpe_procesado.connect(func(info: InfoGolpe) -> void: _golpes.append(info))
	await _esperar(30)
	var arma: DatosArma = _nereth.combate.arma

	# Golpe ligero
	await _pulsar(&"atacar_ligero")
	await _esperar(25)
	_comprobar(_golpes.size() == 1, "el ataque ligero golpea al muñeco (%d golpes)" % _golpes.size())
	if _golpes.size() >= 1:
		_comprobar(is_equal_approx(_golpes[0].dano_aplicado, arma.ligeros[0].dano), "aplica el daño del primer ligero")
	_comprobar(_muneco.vida.actual < _muneco.vida.maximo, "el muñeco pierde vida")
	_comprobar(_nereth.resistencia.actual < _nereth.resistencia.maximo, "atacar gasta resistencia")
	await _restablecer()

	# Cadena de tres ligeros con pulsaciones durante la recuperación
	var nombres: Array[StringName] = []
	_nereth.combate.ataque_iniciado.connect(func(d: DatosAtaque) -> void: nombres.append(d.nombre))
	for i: int in 3:
		await _pulsar(&"atacar_ligero")
		await _esperar(14)
	await _esperar(30)
	_comprobar(nombres == [&"espada_ligero_1", &"espada_ligero_2", &"espada_ligero_3"], "encadena los tres ligeros %s" % [nombres])
	_comprobar(_golpes.size() == 3, "los tres ligeros conectan (%d)" % _golpes.size())
	_comprobar(_nereth.estado == Nereth.Estado.SUELO, "Nereth recupera el control tras la cadena")
	await _restablecer()

	# Pesado sin cargar frente a pesado cargado
	await _pulsar(&"atacar_pesado")
	await _esperar(70)
	var dano_simple: float = _golpes[0].dano_aplicado if _golpes.size() > 0 else 0.0
	await _restablecer()
	Input.action_press(&"atacar_pesado")
	await _esperar(60)
	Input.action_release(&"atacar_pesado")
	await _esperar(70)
	var dano_cargado: float = _golpes[0].dano_aplicado if _golpes.size() > 0 else 0.0
	_comprobar(dano_simple > 0.0 and dano_cargado > dano_simple * 1.4, "el pesado cargado hace más daño (%.1f > %.1f)" % [dano_cargado, dano_simple])
	await _restablecer()

	# Romper postura y Golpe de Umbral
	_muneco.postura.acumular(_muneco.postura.maximo)
	_comprobar(_muneco.postura.en_ruptura, "llenar la postura provoca la Ruptura")
	await _pulsar(&"atacar_ligero")
	await _esperar(25)
	var critico: bool = _golpes.size() > 0 and _golpes[0].critico
	_comprobar(critico, "golpear en Ruptura es un Golpe de Umbral")
	if critico:
		_comprobar(is_equal_approx(_golpes[0].dano_aplicado, arma.ligeros[0].dano * _nereth.combate.multiplicador_golpe_umbral), "el Golpe de Umbral multiplica el daño")
	_comprobar(not _muneco.postura.en_ruptura, "el Golpe de Umbral consume la Ruptura")
	await _restablecer()

	# Cancelar la recuperación con esquiva (pulsada un poco antes: entra por el buffer)
	await _pulsar(&"atacar_ligero")
	await _esperar(11)
	_comprobar(_nereth.combate.atacando(), "sigue atacando antes de la ventana de cancelación")
	Input.action_press(&"mover_izquierda")
	await _pulsar(&"esquivar")
	await _esperar(4)
	Input.action_release(&"mover_izquierda")
	_comprobar(_nereth.estado == Nereth.Estado.ESQUIVA, "la esquiva cancela la recuperación del ataque")
	_comprobar(not _nereth.combate.atacando(), "el ataque queda interrumpido")
	await _esperar(40)

	# Resistencia agotada impide atacar y luego se recupera
	_nereth.resistencia.consumir(_nereth.resistencia.maximo)
	var antes: int = _golpes.size()
	await _pulsar(&"atacar_ligero")
	await _esperar(25)
	_comprobar(_golpes.size() == antes, "sin resistencia no se puede atacar")
	await _esperar(150)
	_comprobar(is_equal_approx(_nereth.resistencia.actual, _nereth.resistencia.maximo), "la resistencia se recupera")

	print("RESULTADO: %s (%d fallos)" % ["OK" if _fallos == 0 else "FALLO", _fallos])
	quit(_fallos)


## Recoloca a Nereth frente al muñeco y limpia estado entre comprobaciones.
func _restablecer() -> void:
	await _esperar(40)
	_nereth.global_position = Vector3(0.0, 0.05, 0.0)
	_nereth.velocity = Vector3.ZERO
	_nereth.mirando = 1.0
	_nereth.resistencia.actual = _nereth.resistencia.maximo
	_muneco.reiniciar()
	_golpes.clear()
	await _esperar(5)


func _pulsar(accion: StringName) -> void:
	Input.action_press(accion)
	await _esperar(1)
	Input.action_release(accion)


func _esperar(frames: int) -> void:
	for i: int in frames:
		await physics_frame


func _comprobar(condicion: bool, descripcion: String) -> void:
	print(("  [OK]    " if condicion else "  [FALLO] ") + descripcion)
	if not condicion:
		_fallos += 1
