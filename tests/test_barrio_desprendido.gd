extends SceneTree
## Prueba de carga y consistencia del nivel Barrio Desprendido de Elyndor.
## Uso: Godot_console.exe --headless --path D:\UMBRAL -s res://tests/test_barrio_desprendido.gd
## Código de salida = número de comprobaciones fallidas.

const ESCENA: String = "res://scenes/niveles/elyndor/barrio_desprendido.tscn"

var _sala: Node
var _nereth: Nereth
var _fase: GestorFase
var _fallos: int = 0


func _initialize() -> void:
	ConfigControles.registrar()
	_fase = GestorFase.global()
	if _fase:
		_fase.cambiar(GestorFase.Estado.REALIDAD)

	_sala = (load(ESCENA) as PackedScene).instantiate()
	root.add_child(_sala)
	_nereth = _sala.get_node("Nereth") as Nereth
	_ejecutar.call_deferred()


func _ejecutar() -> void:
	await _esperar(30)

	# 1. Carga de Nereth y que no caiga al vacío
	_comprobar(_nereth != null, "Nereth está instanciado en la escena")
	_comprobar(_nereth.is_on_floor(), "Nereth se apoya correctamente en el suelo de entrada")
	_comprobar(_nereth.global_position.y > -2.0, "Nereth no cae al vacío al iniciar (y = %.2f)" % _nereth.global_position.y)

	# 2. Comprobar que existe al menos un Ancla
	var anclas: Array[Node] = _sala.find_children("*", "AnclaContinuidad", true, false)
	if anclas.is_empty():
		anclas = _sala.find_children("*Ancla*", "", true, false)
	_comprobar(anclas.size() >= 1, "la escena contiene al menos un Ancla (%d encontradas)" % anclas.size())

	# 3. Comprobar Elementos Cosibles: debe haber Puntada (tipo 0) y Remiendo (tipo 1)
	var cosibles: Array[Node] = _sala.find_children("*", "ElementoCosible", true, false)
	var hay_puntada: bool = false
	var hay_remiendo: bool = false
	for c: Node in cosibles:
		var elem: ElementoCosible = c as ElementoCosible
		if elem.tipo == 0:
			hay_puntada = true
		elif elem.tipo == 1:
			hay_remiendo = true

	_comprobar(hay_puntada, "la escena incluye al menos un elemento de tipo Puntada")
	_comprobar(hay_remiendo, "la escena incluye al menos un elemento de tipo Remiendo")

	# 4. Comprobar presencia de ZonaPresion y ZonaCaida
	var presiones: Array[Node] = _sala.find_children("*", "ZonaPresion", true, false)
	var caidas: Array[Node] = _sala.find_children("*", "ZonaCaida", true, false)
	_comprobar(presiones.size() >= 1, "la escena tiene zona de presión configurada")
	_comprobar(caidas.size() >= 2, "la escena tiene al menos dos zonas de caída configuradas (%d encontradas)" % caidas.size())

	# 5. Comprobar presencia de enemigos reales del hito 6
	var enemigos: Array[Node] = _sala.find_children("*", "Enemigo", true, false)
	_comprobar(enemigos.size() >= 3, "la escena contiene al menos tres enemigos reales (%d encontrados)" % enemigos.size())
	_comprobar(_sala.get_node_or_null("VigiaPlaza") != null, "la escena incluye al Vigía Hueco (VigiaPlaza)")
	_comprobar(_sala.get_node_or_null("EcoPlaza") != null, "la escena incluye al Eco Rezagado (EcoPlaza)")
	_comprobar(_sala.get_node_or_null("GuardianReceptor") != null, "la escena incluye al Guardián Partido (GuardianReceptor)")

	# 6. Comprobación de altura libre sobre las Puntadas (hueco >= 2.2 u para Nereth)
	var puente_atajo: CSGBox3D = _sala.get_node("Geometria/PuenteRemiendoAtajo") as CSGBox3D
	var p1_box: CSGBox3D = _sala.get_node("Geometria/Puntada1") as CSGBox3D
	var p2_box: CSGBox3D = _sala.get_node("Geometria/Puntada2") as CSGBox3D
	var cara_inf_puente: float = puente_atajo.global_position.y - puente_atajo.size.y * 0.5
	var cara_sup_p1: float = p1_box.global_position.y + p1_box.size.y * 0.5
	var cara_sup_p2: float = p2_box.global_position.y + p2_box.size.y * 0.5
	var hueco_p1: float = cara_inf_puente - cara_sup_p1
	var hueco_p2: float = cara_inf_puente - cara_sup_p2
	_comprobar(hueco_p1 >= 2.2, "altura libre sobre Puntada 1 suficiente (%.2f u >= 2.2 u)" % hueco_p1)
	_comprobar(hueco_p2 >= 2.2, "altura libre sobre Puntada 2 suficiente (%.2f u >= 2.2 u)" % hueco_p2)

	# 7. Comprobación de punto de costura en el Remiendo (solo accesible desde el final)
	var remiendo_cosible: ElementoCosible = puente_atajo.get_node("Cosible") as ElementoCosible
	var ancla: AnclaContinuidad = _sala.get_node("AnclaBarrio") as AnclaContinuidad
	_comprobar(remiendo_cosible.punto_costura != null, "el Remiendo del atajo tiene punto_costura asignado")

	# Con el Ancla dormida no está disponible
	_comprobar(not remiendo_cosible.disponible(), "con el Ancla dormida el Remiendo no está disponible")

	# Estabilizar el Ancla para comprobar la selección de objetivo según distancia
	ancla.estado = AnclaContinuidad.Estado.ESTABILIZADA
	_comprobar(remiendo_cosible.disponible(), "con el Ancla estabilizada el Remiendo queda disponible")

	# Desactivar IA de enemigos para que no interrumpan la prueba física de recorrido
	for e: Node in enemigos:
		if "ia_activa" in e:
			e.set("ia_activa", false)

	# Desde el Rellano del Ancla (x = 35): fuera de alcance
	_nereth.restaurar()
	_nereth.reaparecer(Vector3(35.0, 1.55, 0.0))
	await _esperar(5)
	await _pulsar(&"desfase")
	await _esperar(10)
	var dist_ancla: float = remiendo_cosible.distancia_a(_nereth.global_position)
	_comprobar(dist_ancla > 6.0, "desde el Ancla el Remiendo está fuera de alcance (%.1f u > 6.0 u)" % dist_ancla)
	_comprobar(_nereth.costura.objetivo != remiendo_cosible, "desde el Ancla no se puede seleccionar el Remiendo")

	# Desde el SueloReceptorAlto (x = 79.5): al alcance
	_nereth.reaparecer(Vector3(79.5, 4.55, 0.0))
	await _esperar(10)
	var dist_receptor: float = remiendo_cosible.distancia_a(_nereth.global_position)
	_comprobar(dist_receptor <= 6.0, "desde el receptor el Remiendo está al alcance (%.1f u <= 6.0 u)" % dist_receptor)
	_comprobar(_nereth.costura.objetivo == remiendo_cosible, "desde el receptor el Remiendo es el objetivo de Costura")

	# 8. Recorrido real de la cadena de Puntadas:
	# A) Puntadas empiezan sin coser
	var p1_cosible: ElementoCosible = p1_box.get_node("Cosible") as ElementoCosible
	var p2_cosible: ElementoCosible = p2_box.get_node("Cosible") as ElementoCosible
	_comprobar(not p1_cosible.esta_cosido(), "Puntada 1 empieza sin coser")
	_comprobar(not p2_cosible.esta_cosido(), "Puntada 2 empieza sin coser")

	# B) Cadena canónica:
	# 1. Al borde de la plaza en Desfase con Nereth completamente restaurado
	_nereth.restaurar()
	_nereth.reaparecer(Vector3(63.5, 1.05, 0.0))
	await _esperar(10)
	if not _fase.en_desfase():
		await _pulsar(&"desfase")
		await _esperar(15)
	_comprobar(_fase.en_desfase(), "Nereth entra en Desfase al borde del foso")

	# 2. Desde el borde, coser Puntada 1
	_comprobar(_nereth.costura.objetivo == p1_cosible, "desde el borde el objetivo de Costura es Puntada 1")
	await _mantener(&"coser", 45)
	_comprobar(p1_cosible.esta_cosido(), "Puntada 1 queda cosida")

	# 3. Salta a Puntada 1 (de x = 63.5 a x = 69.0)
	Input.action_press(&"mover_derecha")
	await _esperar(10)
	Input.action_press(&"saltar")
	await _esperar(25)
	Input.action_release(&"saltar")
	await _esperar(20)
	Input.action_release(&"mover_derecha")
	await _esperar(10)
	_comprobar(_nereth.is_on_floor() and absf(_nereth.global_position.x - 69.0) < 1.8, "Nereth aterriza en Puntada 1 (x = %.1f, y = %.1f)" % [_nereth.global_position.x, _nereth.global_position.y])

	# 4. Desde Puntada 1, como P1 ya está cosida, el objetivo pasa a ser Puntada 2
	_comprobar(_nereth.costura.objetivo == p2_cosible, "desde Puntada 1 el objetivo de Costura pasa a ser Puntada 2")
	_nereth.resonancia.actual = 100.0
	await _mantener(&"coser", 45)
	_comprobar(p2_cosible.esta_cosido(), "Puntada 2 queda cosida (Puntada 1 se suelta)")

	# 5. Salta a Puntada 2 en Desfase (de x = 69 a x = 73.4)
	Input.action_press(&"mover_derecha")
	await _esperar(5)
	Input.action_press(&"saltar")
	await _esperar(28)
	Input.action_release(&"saltar")
	await _esperar(20)
	Input.action_release(&"mover_derecha")
	await _esperar(10)
	_comprobar(_nereth.is_on_floor() and absf(_nereth.global_position.x - 73.4) < 1.8, "Nereth aterriza en Puntada 2 en Desfase (x = %.1f, y = %.1f)" % [_nereth.global_position.x, _nereth.global_position.y])

	# 6. Vuelve a la Realidad apoyado sobre Puntada 2 (que existe en Realidad por estar cosida)
	await _pulsar(&"desfase")
	await _esperar(15)
	_comprobar(not _fase.en_desfase(), "Nereth vuelve con éxito a la Realidad")
	_comprobar(_nereth.is_on_floor() and _nereth.global_position.y > 2.5, "Nereth se apoya en Puntada 2 en la Realidad (y = %.1f)" % _nereth.global_position.y)

	# 7. Salta al SueloReceptorAlto (solo-Realidad)
	Input.action_press(&"mover_derecha")
	await _esperar(5)
	Input.action_press(&"saltar")
	await _esperar(32)
	Input.action_release(&"saltar")
	await _esperar(25)
	Input.action_release(&"mover_derecha")
	await _esperar(15)
	_comprobar(_nereth.is_on_floor() and _nereth.global_position.x >= 77.0 and _nereth.global_position.y >= 4.0, "Nereth corona el SueloReceptorAlto con éxito (x = %.1f, y = %.1f)" % [_nereth.global_position.x, _nereth.global_position.y])

	# 9. Contraste negativo: sin coser Puntada 2, intentar apoyarse en la Realidad hace caer al vacío
	p2_cosible.soltar()
	_nereth.restaurar()
	_nereth.reaparecer(Vector3(63.5, 1.05, 0.0))
	await _esperar(5)
	if not _fase.en_desfase():
		await _pulsar(&"desfase")
		await _esperar(15)
	# Salto a Puntada 1 en Desfase
	Input.action_press(&"mover_derecha")
	await _esperar(10)
	Input.action_press(&"saltar")
	await _esperar(25)
	Input.action_release(&"saltar")
	await _esperar(20)
	Input.action_release(&"mover_derecha")
	await _esperar(10)
	# Salto a Puntada 2 en Desfase sin coser
	_comprobar(not p2_cosible.esta_cosido(), "Puntada 2 no está cosida para la prueba de contraste")
	Input.action_press(&"mover_derecha")
	await _esperar(5)
	Input.action_press(&"saltar")
	await _esperar(28)
	Input.action_release(&"saltar")
	await _esperar(20)
	Input.action_release(&"mover_derecha")
	await _esperar(10)
	# Intentar pasar a Realidad sin Puntada cosida: no se sostiene y cae
	await _pulsar(&"desfase")
	await _esperar(40)
	_comprobar(_nereth.global_position.y < 2.0 or not _nereth.is_on_floor(), "sin coser Puntada 2, Nereth no puede sostenerse en Realidad y cae al foso (y = %.1f)" % _nereth.global_position.y)

	# 10. Conexión con el Salón del Prefecto (TAREA-006):
	# A) Comprobar existencia y configuración de los PuntoEntrada
	var puntos_entrada: Array[Node] = _sala.find_children("*", "PuntoEntrada", true, false)
	var entrada_inicio: PuntoEntrada = null
	var entrada_desde_salon: PuntoEntrada = null
	for pe: Node in puntos_entrada:
		var p: PuntoEntrada = pe as PuntoEntrada
		if p.id == &"inicio":
			entrada_inicio = p
		elif p.id == &"desde_salon":
			entrada_desde_salon = p

	_comprobar(entrada_inicio != null, "existe el PuntoEntrada «inicio»")
	if entrada_inicio:
		_comprobar(absf(entrada_inicio.global_position.x - (-16.0)) < 1.0, "«inicio» está ubicado al principio del nivel (x = %.1f)" % entrada_inicio.global_position.x)
		_comprobar(is_equal_approx(entrada_inicio.mirando, 1.0), "«inicio» mira hacia la derecha")

	_comprobar(entrada_desde_salon != null, "existe el PuntoEntrada «desde_salon»")
	if entrada_desde_salon:
		_comprobar(is_equal_approx(entrada_desde_salon.mirando, -1.0), "«desde_salon» mira hacia la izquierda")

	# B) Comprobar TransicionSala hacia el Salón del Prefecto
	var transiciones: Array[Node] = _sala.find_children("*", "TransicionSala", true, false)
	var transicion_salon: TransicionSala = null
	for t: Node in transiciones:
		var tr: TransicionSala = t as TransicionSala
		if tr.escena_destino == "res://scenes/niveles/elyndor/salon_prefecto.tscn":
			transicion_salon = tr

	_comprobar(transicion_salon != null, "existe la TransicionSala hacia el Salón del Prefecto")
	if transicion_salon:
		_comprobar(transicion_salon.entrada_destino == &"desde_barrio", "la transición apunta a la entrada «desde_barrio»")
		_comprobar(transicion_salon.collision_mask & 8 != 0, "la transición detecta la capa del jugador (8)")

	# C) Comprobar que «desde_salon» está fuera de la transición
	if entrada_desde_salon and transicion_salon:
		var col_transicion: CollisionShape3D = transicion_salon.get_node("Forma") as CollisionShape3D
		var box: BoxShape3D = col_transicion.shape as BoxShape3D
		var mitad_x: float = box.size.x * 0.5 if box else 1.0
		var min_x_transicion: float = transicion_salon.global_position.x - mitad_x
		var max_x_transicion: float = transicion_salon.global_position.x + mitad_x
		var x_punto: float = entrada_desde_salon.global_position.x
		var fuera: bool = x_punto < min_x_transicion or x_punto > max_x_transicion
		_comprobar(fuera, "el PuntoEntrada «desde_salon» (x = %.1f) está fuera de la transición (rango x = %.1f..%.1f)" % [x_punto, min_x_transicion, max_x_transicion])

	# 11. Comprobaciones de reambientación Ruinas bajo Elyndor (TAREA-010):
	# A) Presencia de AtmosferaFase
	var atmosfera: AtmosferaFase = _sala.get_node_or_null("Atmosfera") as AtmosferaFase
	if not atmosfera:
		var atmos: Array[Node] = _sala.find_children("*", "AtmosferaFase", true, false)
		if not atmos.is_empty():
			atmosfera = atmos[0] as AtmosferaFase
	_comprobar(atmosfera != null, "la escena cuenta con AtmosferaFase para el control de fase ambiental")

	# B) Columnas Realidad/Desfase: al menos 4 pares con existe_en opuestos
	var pares_columnas: int = 0
	var col_realidad: Node = _sala.get_node_or_null("ColumnasRealidad")
	var col_desfase: Node = _sala.get_node_or_null("ColumnasDesfase")
	if col_realidad and col_desfase:
		for hijo_r: Node in col_realidad.get_children():
			var elem_r: ElementoFase = hijo_r.get_node_or_null("ElementoFase") as ElementoFase
			if not elem_r or elem_r.existe_en != ElementoFase.Existencia.REALIDAD:
				continue
			var pos_r: Vector3 = (hijo_r as Node3D).global_position
			for hijo_d: Node in col_desfase.get_children():
				var elem_d: ElementoFase = hijo_d.get_node_or_null("ElementoFase") as ElementoFase
				if not elem_d or elem_d.existe_en != ElementoFase.Existencia.DESFASE:
					continue
				var pos_d: Vector3 = (hijo_d as Node3D).global_position
				if pos_r.distance_to(pos_d) < 0.1:
					pares_columnas += 1
					break
	_comprobar(pares_columnas >= 4, "existen al menos 4 pares de columnas Realidad/Desfase (%d encontrados)" % pares_columnas)

	# C) Transición a la Cámara del Despertar y verificación de spawn seguro
	var transicion_camara: TransicionSala = null
	for t: Node in transiciones:
		var tr: TransicionSala = t as TransicionSala
		if tr.escena_destino == "res://scenes/niveles/elyndor/camara_despertar.tscn":
			transicion_camara = tr
			break
	_comprobar(transicion_camara != null, "existe la TransicionSala hacia la Cámara del Despertar")
	if transicion_camara:
		_comprobar(transicion_camara.entrada_destino == &"desde_ruinas", "la transición apunta a la entrada «desde_ruinas»")
		_comprobar(transicion_camara.collision_mask & 8 != 0, "la transición detecta la capa del jugador (8)")
		if entrada_inicio:
			var col_tr: CollisionShape3D = transicion_camara.get_node("Forma") as CollisionShape3D
			var box_tr: BoxShape3D = col_tr.shape as BoxShape3D
			var mitad_x_camara: float = box_tr.size.x * 0.5 if box_tr else 1.0
			var min_x_cam: float = transicion_camara.global_position.x - mitad_x_camara
			var max_x_cam: float = transicion_camara.global_position.x + mitad_x_camara
			var x_inicio: float = entrada_inicio.global_position.x
			var fuera_cam: bool = x_inicio < min_x_cam or x_inicio > max_x_cam
			_comprobar(fuera_cam, "el PuntoEntrada «inicio» (x = %.1f) está fuera de la transición a la cámara (rango x = %.1f..%.1f)" % [x_inicio, min_x_cam, max_x_cam])

	print("RESULTADO: %s (%d fallos)" % ["OK" if _fallos == 0 else "FALLO", _fallos])
	quit(_fallos)


func _esperar(frames: int) -> void:
	for i: int in frames:
		await physics_frame


func _mantener(accion: StringName, frames: int) -> void:
	Input.action_press(accion)
	await _esperar(frames)
	Input.action_release(accion)
	await _esperar(2)


func _pulsar(accion: StringName) -> void:
	Input.action_press(accion)
	await _esperar(1)
	Input.action_release(accion)
	await _esperar(1)


func _comprobar(condicion: bool, descripcion: String) -> void:
	print(("  [OK]    " if condicion else "  [FALLO] ") + descripcion)
	if not condicion:
		_fallos += 1
