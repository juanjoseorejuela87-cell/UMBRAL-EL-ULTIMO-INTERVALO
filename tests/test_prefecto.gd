extends SceneTree
## Prueba automática del Prefecto de las Puertas (primer jefe).
## Uso: Godot_console.exe --headless --path D:\UMBRAL -s res://tests/test_prefecto.gd
## Código de salida = número de comprobaciones fallidas.

const SALA: String = "res://scenes/niveles/pruebas/sala_prefecto.tscn"
const RUTA_PRUEBA: String = "user://prueba_prefecto.json"

var _sala: Node
var _nereth: Nereth
var _prefecto: Prefecto
var _fallos: int = 0


func _initialize() -> void:
	ConfigControles.registrar()
	GestorPartida.global().ruta_guardado = RUTA_PRUEBA
	GestorPartida.global().borrar_memoria()
	_borrar_archivo()
	_sala = (load(SALA) as PackedScene).instantiate()
	root.add_child(_sala)
	_nereth = _sala.get_node("Nereth") as Nereth
	_prefecto = _sala.get_node("Prefecto") as Prefecto
	_ejecutar.call_deferred()


func _ejecutar() -> void:
	await _esperar(20)
	var suelo_izq: ElementoFase = _sala.get_node("Geometria/SueloIzquierdo/ElementoFase") as ElementoFase
	var salida: CSGBox3D = _sala.get_node("Geometria/PuertaSalida") as CSGBox3D

	# --- Fase 1 ---
	_comprobar(_prefecto.fase_actual == 1, "empieza en la fase 1 (Custodia)")
	_colocar(2.0, 1.0)
	var ataco: bool = await _esperar_hasta(func() -> bool: return _prefecto.estado == Enemigo.Estado.ATAQUE, 300)
	_comprobar(ataco and _prefecto.ataque_actual in _prefecto.ataques_fase_1, "en la fase 1 usa sus ataques de Custodia")

	# --- Fase 2 ---
	_calmar()
	_nereth.restaurar()
	_prefecto.vida.recibir_dano(_prefecto.vida.maximo * 0.36)
	_comprobar(_prefecto.fase_actual == 2, "al 64 % de vida pasa a la fase 2 (Puertas cruzadas)")
	await _esperar(2)
	_comprobar(_contar_ecos() == _prefecto.ecos_fase_2, "invoca %d ecos (%d)" % [_prefecto.ecos_fase_2, _contar_ecos()])

	# Travesía: desaparece y solo el Desfase revela la salida
	_colocar(-6.0, 1.0)
	_prefecto._iniciar_travesia()
	_comprobar(_prefecto.en_travesia and not _prefecto.visible, "entra por una puerta y desaparece")
	_comprobar(_prefecto.puerta_destino != _prefecto.puerta_entrada, "sale por otra puerta distinta")
	_comprobar(not _prefecto._marca_salida.visible, "en la Realidad no se ve por dónde saldrá")
	_nereth.fase.intentar_cambiar()
	await _esperar(3)
	_comprobar(_prefecto._marca_salida.visible, "en el Desfase se ve la puerta de salida")
	await _esperar(int(_prefecto.duracion_travesia * 60.0) + 5)
	_comprobar(not _prefecto.en_travesia and absf(_prefecto.global_position.x - _prefecto.puerta_destino.global_position.x) < 0.5, "reaparece por la puerta de salida")
	_comprobar(_prefecto.estado == Enemigo.Estado.ATAQUE and _prefecto.ataque_actual == _prefecto.ataque_salida, "al salir ataca")

	# Trampa: coser la puerta de entrada mientras viaja
	_calmar()
	_prefecto._iniciar_travesia()
	var entrada: CSGBox3D = _prefecto.puerta_entrada
	(entrada.get_node("Cosible") as ElementoCosible).coser()
	await _esperar(int(_prefecto.duracion_travesia * 60.0) + 5)
	_comprobar(_prefecto.postura.en_ruptura and absf(_prefecto.global_position.x - entrada.global_position.x) < 0.5, "coser su puerta de entrada lo atrapa en Ruptura")
	(entrada.get_node("Cosible") as ElementoCosible).soltar()
	_prefecto.postura.terminar_ruptura()
	_nereth.fase.reiniciar()

	# --- Fase 3 ---
	_calmar()
	_prefecto.vida.recibir_dano(_prefecto.vida.actual - _prefecto.vida.maximo * 0.29)
	_comprobar(_prefecto.fase_actual == 3, "al 29 % pasa a la fase 3 (Umbral abierto)")
	_comprobar(is_equal_approx(_prefecto.multiplicador_dano_realidad, 0.25), "en la fase 3 está blindado en la Realidad")
	_comprobar(suelo_izq.existe_en == ElementoFase.Existencia.DESFASE, "en la fase 3 los suelos laterales solo existen en el Desfase")

	# Cierre sin refugio
	_nereth.restaurar()
	_colocar(0.0, 1.0)
	_prefecto.ia_activa = true
	_prefecto.iniciar_cierre()
	var herido: bool = await _esperar_hasta(func() -> bool: return _nereth.vida.actual < _nereth.vida.maximo, 200)
	_comprobar(herido, "el Cierre de todas las puertas golpea a toda la sala")

	# Cierre con refugio en una puerta cosida
	_calmar()
	await _esperar(30)
	_nereth.restaurar()
	var puerta_c: CSGBox3D = _sala.get_node("Puertas/PuertaC") as CSGBox3D
	(puerta_c.get_node("Cosible") as ElementoCosible).coser()
	_colocar(puerta_c.global_position.x, 1.0)
	_prefecto.ia_activa = true
	_prefecto.iniciar_cierre()
	await _esperar(170)
	_comprobar(is_equal_approx(_nereth.vida.actual, _nereth.vida.maximo), "una puerta cosida protege del Cierre")
	_calmar()

	# --- Reinicio si Nereth cae ---
	GestorPartida.global().reaparecer(_nereth)
	await _esperar(3)
	_comprobar(_prefecto.fase_actual == 1 and is_equal_approx(_prefecto.vida.actual, _prefecto.vida.maximo), "si Nereth cae, el combate empieza de cero")
	_comprobar(_contar_ecos() == 0 and suelo_izq.existe_en == ElementoFase.Existencia.AMBOS, "el reinicio retira los ecos y restaura el suelo")

	# --- Derrota ---
	_comprobar(salida.visible and salida.use_collision, "la salida está cerrada durante el combate")
	_prefecto.vida.recibir_dano(_prefecto.vida.maximo * 2.0)
	await _esperar(2)
	_comprobar(_prefecto.estado == Enemigo.Estado.MUERTO and GestorPartida.global().evento_ocurrido(Prefecto.EVENTO_DERROTA), "al caer, la partida registra su derrota")
	_comprobar(not salida.visible and not salida.use_collision, "al caer, se abre la salida")
	GestorPartida.global().reaparecer(_nereth)
	await _esperar(2)
	_comprobar(_prefecto.estado == Enemigo.Estado.MUERTO, "una vez derrotado no vuelve al reaparecer")

	# Persistencia
	var sala2: Node = (load(SALA) as PackedScene).instantiate()
	root.add_child(sala2)
	await _esperar(2)
	var prefecto2: Prefecto = sala2.get_node("Prefecto") as Prefecto
	_comprobar(prefecto2.estado == Enemigo.Estado.MUERTO and not prefecto2.visible, "al recargar, el Prefecto sigue derrotado")
	_comprobar(not (sala2.get_node("Geometria/PuertaSalida") as CSGBox3D).visible, "al recargar, la salida sigue abierta")
	sala2.queue_free()

	# Comprobaciones de TAREA-019: DecoradoKit en el Salón del Prefecto
	var esc_salon: PackedScene = load("res://scenes/niveles/elyndor/salon_prefecto.tscn") as PackedScene
	var inst_salon: Node = esc_salon.instantiate() if esc_salon else null
	_comprobar(inst_salon != null, "la escena del Salón del Prefecto carga correctamente")
	if inst_salon:
		var decorado_kit: Node = inst_salon.get_node_or_null("DecoradoKit")
		_comprobar(decorado_kit != null, "existe el nodo contenedor DecoradoKit en el Salón del Prefecto")
		if decorado_kit:
			var elems_fase: Array[Node] = decorado_kit.find_children("*", "ElementoFase", true, false)
			var c_real: int = 0
			var c_desf: int = 0
			for ef_node: Node in elems_fase:
				var ef: ElementoFase = ef_node as ElementoFase
				if ef.existe_en == ElementoFase.Existencia.REALIDAD:
					c_real += 1
				elif ef.existe_en == ElementoFase.Existencia.DESFASE:
					c_desf += 1
			var pares: int = mini(c_real, c_desf)
			_comprobar(pares >= 2, "DecoradoKit en el Salón cuenta con al menos 2 parejas Realidad/Desfase (%d encontradas)" % pares)

			# Como mucho un brasero con luz puntual activa
			var braseros: Array[Node] = decorado_kit.find_children("*", "Brasero", true, false)
			if braseros.is_empty():
				braseros = decorado_kit.find_children("*Brasero*", "", true, false)
			var con_luz_cuenta: int = 0
			for b: Node in braseros:
				if b.get("con_luz") == true:
					con_luz_cuenta += 1
			_comprobar(con_luz_cuenta <= 1, "DecoradoKit en el Salón tiene como mucho un brasero con luz puntual (%d con luz)" % con_luz_cuenta)

			# Sin colisiones añadidas
			var colision: bool = false
			for h: Node in decorado_kit.find_children("*", "", true, false):
				if h is CollisionObject3D or h is CollisionShape3D or (h is CSGShape3D and (h as CSGShape3D).use_collision):
					colision = true
					break
			_comprobar(not colision, "ninguna pieza del DecoradoKit en el Salón añade colisiones")
		inst_salon.free()

	_borrar_archivo()
	print("RESULTADO: %s (%d fallos)" % ["OK" if _fallos == 0 else "FALLO", _fallos])
	quit(_fallos)


func _contar_ecos() -> int:
	var total: int = 0
	for nodo: Node in _sala.get_children():
		if nodo is Enemigo and not nodo is Prefecto and not nodo.is_queued_for_deletion():
			total += 1
	return total


## Detiene al Prefecto para poder forzar situaciones concretas.
func _calmar() -> void:
	_prefecto.ia_activa = false
	_prefecto._caja_golpe.monitoring = false
	if _prefecto.estado != Enemigo.Estado.MUERTO and _prefecto.estado != Enemigo.Estado.RUPTURA:
		_prefecto.estado = Enemigo.Estado.PERSECUCION


func _colocar(x: float, mirando: float) -> void:
	_nereth.reaparecer(Vector3(x, 0.05, 0.0))
	_nereth.mirando = mirando


func _borrar_archivo() -> void:
	if FileAccess.file_exists(RUTA_PRUEBA):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(RUTA_PRUEBA))


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
