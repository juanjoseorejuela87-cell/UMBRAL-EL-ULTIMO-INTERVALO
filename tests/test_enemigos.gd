extends SceneTree
## Prueba automática de los enemigos (corpóreo, eco, bifásico), la defensa de
## Nereth (guardia, parry, guardia rota) y el Desgarro.
## Uso: Godot_console.exe --headless --path D:\UMBRAL -s res://tests/test_enemigos.gd
## Código de salida = número de comprobaciones fallidas.

const SALA: String = "res://scenes/niveles/pruebas/sala_enemigos.tscn"

var _sala: Node
var _nereth: Nereth
var _vigia: Enemigo
var _eco: Enemigo
var _guardian: Enemigo
var _fallos: int = 0


func _initialize() -> void:
	ConfigControles.registrar()
	GestorPartida.global().ruta_guardado = "user://prueba_enemigos.json"
	GestorPartida.global().borrar_memoria()
	_sala = (load(SALA) as PackedScene).instantiate()
	root.add_child(_sala)
	_nereth = _sala.get_node("Nereth") as Nereth
	_vigia = _sala.get_node("VigiaHueco") as Enemigo
	_eco = _sala.get_node("EcoRezagado") as Enemigo
	_guardian = _sala.get_node("GuardianPartido") as Enemigo
	_ejecutar.call_deferred()


func _ejecutar() -> void:
	_congelar(_eco, true)
	_congelar(_guardian, true)
	await _esperar(20)

	# --- Vigía Hueco (corpóreo, medio) ---
	_colocar(-3.0, 1.0)
	_comprobar(await _esperar_hasta(func() -> bool: return _vigia.estado == Enemigo.Estado.PERSECUCION, 30), "el Vigía detecta a Nereth y le persigue")
	_comprobar(_nereth.resonancia.amenaza(), "un enemigo en alerta activa el régimen de Amenaza")
	var telegrafiado: Array[bool] = [false]
	_vigia.ataque_telegrafiado.connect(func(_d: DatosAtaque) -> void: telegrafiado[0] = true)
	var golpeado: bool = await _esperar_hasta(func() -> bool: return _nereth.vida.actual < _nereth.vida.maximo, 240)
	_comprobar(golpeado and telegrafiado[0], "el Vigía telegrafía su ataque y hace daño")

	# Bloqueo
	await _restablecer(_vigia, -1.4, 1.0)
	Input.action_press(&"guardia")
	var bloqueado: bool = await _esperar_hasta(func() -> bool: return _nereth.resistencia.actual < _nereth.resistencia.maximo, 240)
	Input.action_release(&"guardia")
	_comprobar(bloqueado and is_equal_approx(_nereth.vida.actual, _nereth.vida.maximo), "la guardia bloquea: sin daño y gasta resistencia")

	# Parry
	await _restablecer(_vigia, -1.4, 1.0)
	_nereth.resonancia.actual = 50.0
	var parries: Array[int] = [0]
	_nereth.parry_realizado.connect(func(_i: InfoGolpe) -> void: parries[0] += 1)
	await _esperar_hasta(func() -> bool: return _vigia.estado == Enemigo.Estado.ATAQUE \
			and _vigia.etapa == Enemigo.Etapa.PREPARACION \
			and _vigia.tiempo_en_etapa() >= _vigia.ataque_actual.preparacion - 0.05, 240)
	Input.action_press(&"guardia")
	await _esperar_hasta(func() -> bool: return parries[0] > 0, 30)
	Input.action_release(&"guardia")
	_comprobar(parries[0] == 1, "guardia en el último instante = parry")
	_comprobar(is_equal_approx(_nereth.vida.actual, _nereth.vida.maximo), "el parry evita todo el daño")
	_comprobar(_vigia.postura.en_ruptura or _vigia.postura.actual >= _vigia.postura.maximo * _vigia.postura_por_parry - 1.0, "el parry carga mucha postura al enemigo (%.1f)" % _vigia.postura.actual)
	_comprobar(_vigia.estado == Enemigo.Estado.ATURDIDO or _vigia.estado == Enemigo.Estado.RUPTURA, "el parry deja al enemigo vendido")
	_comprobar(_nereth.resonancia.actual >= 60.0, "el parry devuelve Resonancia (%.1f)" % _nereth.resonancia.actual)

	# Guardia de espaldas
	await _restablecer(_vigia, -1.4, -1.0)
	Input.action_press(&"guardia")
	var dano_espalda: bool = await _esperar_hasta(func() -> bool: return _nereth.vida.actual < _nereth.vida.maximo, 240)
	Input.action_release(&"guardia")
	_comprobar(dano_espalda, "la guardia no protege la espalda")

	# Guardia rota
	await _restablecer(_vigia, -1.4, 1.0)
	var roturas: Array[int] = [0]
	_nereth.guardia_rota.connect(func() -> void: roturas[0] += 1)
	Input.action_press(&"guardia")
	await _esperar_hasta(func() -> bool: return _vigia.estado == Enemigo.Estado.ATAQUE \
			and _vigia.etapa == Enemigo.Etapa.PREPARACION \
			and _vigia.tiempo_en_etapa() >= _vigia.ataque_actual.preparacion - 0.02, 240)
	_nereth.resistencia.consumir(_nereth.resistencia.actual - 3.0)
	await _esperar_hasta(func() -> bool: return roturas[0] > 0, 30)
	Input.action_release(&"guardia")
	_comprobar(roturas[0] == 1 and _nereth.estado == Nereth.Estado.ATURDIDO, "sin resistencia la guardia se rompe y aturde")
	_comprobar(absf(_nereth.vida.actual - (_nereth.vida.maximo - _vigia.ataques[0].dano * 0.5)) < 0.1, "la guardia rota deja pasar la mitad del daño")

	# Corpóreo frente a Nereth en el Desfase
	await _restablecer(_vigia, -1.4, 1.0)
	_nereth.fase.intentar_cambiar()
	await _esperar(200)
	_comprobar(GestorFase.global().en_desfase() and is_equal_approx(_nereth.vida.actual, _nereth.vida.maximo), "en el Desfase los ataques del corpóreo atraviesan a Nereth")
	_congelar(_vigia, true)
	_colocar(_vigia.global_position.x - 1.4, 1.0)
	var postura_antes: float = _vigia.postura.actual
	await _pulsar(&"atacar_ligero")
	await _esperar(20)
	_comprobar(is_equal_approx(_vigia.vida.actual, _vigia.vida.maximo) and _vigia.postura.actual > postura_antes, "desde el Desfase solo se golpean sus Hilos (postura, no vida)")
	_nereth.fase.reiniciar()

	# --- Eco Rezagado (solo Desfase, ligero) ---
	_congelar(_eco, false)
	_colocar(18.6, 1.0)
	await _esperar(10)
	_comprobar(not (_eco.get_node("CajaDano") as CajaDano).activa, "en la Realidad el eco no se puede golpear")
	_comprobar(not (_eco.get_node("Visual/Cuerpo") as MeshInstance3D).visible, "en la Realidad el eco es invisible")
	await _esperar(120)
	_comprobar(is_equal_approx(_nereth.vida.actual, _nereth.vida.maximo), "en la Realidad el eco no puede dañar a Nereth")
	_nereth.fase.intentar_cambiar()
	await _esperar(5)
	_eco.reiniciar()
	_congelar(_eco, true)
	await _liberar()
	_colocar(18.6, 1.0)
	_comprobar((_eco.get_node("Visual/Cuerpo") as MeshInstance3D).visible, "en el Desfase el eco aparece")
	await _pulsar(&"atacar_ligero")
	await _esperar(12)
	_comprobar(_eco.vida.actual < _eco.vida.maximo, "en el Desfase el eco recibe daño (Nereth: %s, Desfase: %s, Resonancia: %.0f)" % [Nereth.Estado.keys()[_nereth.estado], GestorFase.global().en_desfase(), _nereth.resonancia.actual])
	_comprobar(_eco.estado == Enemigo.Estado.ATURDIDO, "el eco (ligero) se interrumpe con cualquier golpe")
	_nereth.fase.reiniciar()
	_congelar(_eco, true)

	# --- Guardián Partido (bifásico, pesado) ---
	await _liberar()
	_colocar(38.4, 1.0)
	await _esperar(5)
	await _pulsar(&"atacar_ligero")
	await _esperar(20)
	var dano_realidad: float = _guardian.vida.maximo - _guardian.vida.actual
	_comprobar(is_equal_approx(dano_realidad, 10.0 * _guardian.multiplicador_dano_realidad), "en la Realidad el bifásico está blindado (%.1f de daño)" % dano_realidad)
	await _liberar()
	_nereth.fase.intentar_cambiar()
	await _esperar(25)
	var vida_antes: float = _guardian.vida.actual
	await _pulsar(&"atacar_ligero")
	await _esperar(20)
	var dano_desfase: float = vida_antes - _guardian.vida.actual
	_comprobar(is_equal_approx(dano_desfase, 10.0 * _guardian.multiplicador_dano_desfase), "en el Desfase sus Hilos quedan expuestos (%.1f de daño)" % dano_desfase)
	_comprobar(_guardian.estado != Enemigo.Estado.ATURDIDO, "el bifásico (pesado) no se interrumpe con golpes normales")

	# Desgarro: cortar un ataque
	_guardian.reiniciar()
	_nereth.resonancia.restaurar()
	_colocar(38.0, 1.0)
	_congelar(_guardian, false)
	var efectos: Array[StringName] = []
	_nereth.costura.desgarro_realizado.connect(func(_e: Enemigo, efecto: StringName) -> void: efectos.append(efecto))
	await _esperar_hasta(func() -> bool: return _guardian.estado == Enemigo.Estado.ATAQUE and _guardian.etapa == Enemigo.Etapa.PREPARACION, 240)
	var res_antes: float = _nereth.resonancia.actual
	await _pulsar(&"coser")
	_comprobar(efectos == [&"cortar"] and _guardian.estado == Enemigo.Estado.ATURDIDO, "el Desgarro corta un ataque en preparación (efectos %s, Nereth: %s, Desfase: %s)" % [efectos, Nereth.Estado.keys()[_nereth.estado], GestorFase.global().en_desfase()])
	_comprobar(res_antes - _nereth.resonancia.actual >= _nereth.costura.coste_desgarro - 1.0, "el Desgarro cuesta Resonancia")

	# Desgarro: exponer
	_congelar(_guardian, true)
	await _esperar(95)
	await _pulsar(&"coser")
	_comprobar(efectos.size() == 2 and efectos[1] == &"exponer" and _guardian.expuesto_restante > 0.0, "sin ataque en curso, el Desgarro expone al enemigo")
	vida_antes = _guardian.vida.actual
	await _pulsar(&"atacar_ligero")
	await _esperar(20)
	var dano_expuesto: float = vida_antes - _guardian.vida.actual
	_comprobar(is_equal_approx(dano_expuesto, 10.0 * _guardian.multiplicador_dano_desfase * _guardian.multiplicador_expuesto), "expuesto recibe más daño (%.1f)" % dano_expuesto)
	_nereth.fase.reiniciar()

	# --- Muerte y reinicio ---
	_congelar(_vigia, false)
	_vigia.vida.recibir_dano(1000.0)
	_comprobar(_vigia.estado == Enemigo.Estado.MUERTO and not _vigia.visible, "el enemigo muere y desaparece")
	GestorPartida.global().reaparecer(_nereth)
	await _esperar(2)
	_comprobar(_vigia.estado == Enemigo.Estado.REPOSO and _vigia.visible and is_equal_approx(_vigia.vida.actual, _vigia.vida.maximo), "al reaparecer (o descansar) el enemigo vuelve")

	print("RESULTADO: %s (%d fallos)" % ["OK" if _fallos == 0 else "FALLO", _fallos])
	quit(_fallos)


## Termina cualquier acción de Nereth sin cambiar de estado de la realidad.
func _liberar() -> void:
	await _esperar(30)
	_nereth.combate.interrumpir()
	_nereth.costura.cancelar()
	_nereth.terminar_accion()
	await _esperar(2)


## Restaura a Nereth y al enemigo, y los coloca frente a frente.
func _restablecer(enemigo: Enemigo, x_nereth: float, mirando: float) -> void:
	_nereth.restaurar()
	enemigo.reiniciar()
	_congelar(enemigo, false)
	_colocar(enemigo.global_position.x + x_nereth, mirando)
	await _esperar(5)


func _colocar(x: float, mirando: float) -> void:
	_nereth.reaparecer(Vector3(x, 0.05, 0.0))
	_nereth.mirando = mirando


## Detiene la IA sin sacar al enemigo de la física (process_mode = DISABLED
## también desactivaría sus cajas de colisión).
func _congelar(enemigo: Enemigo, congelado: bool) -> void:
	enemigo.ia_activa = not congelado
	if congelado and enemigo.estado != Enemigo.Estado.MUERTO:
		enemigo.estado = Enemigo.Estado.REPOSO


func _esperar_hasta(condicion: Callable, max_frames: int) -> bool:
	for i: int in max_frames:
		if condicion.call():
			return true
		await physics_frame
	return condicion.call()


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
