extends SceneTree
## Prueba automática de la Cámara del Despertar: primer uso obligado del
## Desfase, símbolos que reaccionan a Nereth, atmósfera por estado y salida.
## Uso: Godot_console.exe --headless --path D:\UMBRAL -s res://tests/test_camara_despertar.gd
## Código de salida = número de comprobaciones fallidas.

const CAMARA: String = "res://scenes/niveles/elyndor/camara_despertar.tscn"
const RUINAS: String = "res://scenes/niveles/elyndor/barrio_desprendido.tscn"

var _fallos: int = 0


func _initialize() -> void:
	ConfigControles.registrar()
	GestorPartida.global().ruta_guardado = "user://prueba_camara.json"
	GestorPartida.global().borrar_memoria()
	GestorSalas.global().duracion_fundido = 0.0
	_ejecutar.call_deferred()


func _ejecutar() -> void:
	GestorSalas.global().ir_a_entrada(CAMARA, &"inicio")
	_comprobar(await _llegar_a(CAMARA), "carga la Cámara del Despertar")
	var sala: Node = current_scene
	var nereth: Nereth = sala.get_node("Nereth") as Nereth
	await _esperar(30)
	_comprobar(nereth.is_on_floor() and absf(nereth.global_position.x - (-2.5)) < 0.5, "Nereth despierta sobre el estrado")

	# Comprobaciones de TAREA-019: DecoradoKit en la Cámara del Despertar
	var decorado_kit: Node = sala.get_node_or_null("DecoradoKit")
	_comprobar(decorado_kit != null, "existe el nodo contenedor DecoradoKit en la Cámara")
	if decorado_kit != null:
		var elems_fase: Array[Node] = decorado_kit.find_children("*", "ElementoFase", true, false)
		var c_realidad: int = 0
		var c_desfase: int = 0
		for ef_node: Node in elems_fase:
			var ef: ElementoFase = ef_node as ElementoFase
			if ef.existe_en == ElementoFase.Existencia.REALIDAD:
				c_realidad += 1
			elif ef.existe_en == ElementoFase.Existencia.DESFASE:
				c_desfase += 1
		var pares: int = mini(c_realidad, c_desfase)
		_comprobar(pares >= 2, "DecoradoKit en la Cámara cuenta con al menos 2 parejas Realidad/Desfase (%d encontradas)" % pares)

		# Luces: como mucho una luz nueva
		var luces: Array[Node] = decorado_kit.find_children("*", "Light3D", true, false)
		var luces_activas: int = 0
		for l: Node in luces:
			var light: Light3D = l as Light3D
			if light.visible:
				luces_activas += 1
		_comprobar(luces_activas <= 1, "DecoradoKit en la Cámara no añade más de una luz nueva (%d luces)" % luces_activas)

		# Colisiones: ninguna pieza añade colisión
		var colision: bool = false
		for h: Node in decorado_kit.find_children("*", "", true, false):
			if h is CollisionObject3D or h is CollisionShape3D or (h is CSGShape3D and (h as CSGShape3D).use_collision):
				colision = true
				break
		_comprobar(not colision, "ninguna pieza del DecoradoKit en la Cámara añade colisiones")

	# Los símbolos reaccionan a su presencia
	var simbolo: SimboloArquitectos = sala.get_node("SimboloDais1") as SimboloArquitectos
	var material: StandardMaterial3D = simbolo.material_override as StandardMaterial3D
	_comprobar(material.emission_energy_multiplier > 0.5, "los símbolos del estrado se iluminan junto a Nereth (%.2f)" % material.emission_energy_multiplier)

	# El derrumbe bloquea en la Realidad
	nereth.reaparecer(Vector3(6.0, 0.1, 0.0))
	await _mantener(&"mover_derecha", 90)
	_comprobar(nereth.global_position.x < 9.8, "en la Realidad el derrumbe bloquea la salida (x = %.1f)" % nereth.global_position.x)

	# La atmósfera cambia al entrar en el Desfase
	var atmosfera: AtmosferaFase = sala.get_node("Atmosfera") as AtmosferaFase
	var densidad_real: float = atmosfera.environment.fog_density
	nereth.fase.intentar_cambiar()
	await _esperar(40)
	_comprobar(not is_equal_approx(atmosfera.environment.fog_density, densidad_real) and is_equal_approx(atmosfera.environment.fog_density, atmosfera.densidad_desfase), "la niebla cambia al ajuste del Desfase")

	# En el Desfase se pasa y la salida lleva a las Ruinas
	await _mantener(&"mover_derecha", 50)
	_comprobar(nereth.global_position.x > 11.5 or _escena() == RUINAS, "en el Desfase el derrumbe no existe y se puede pasar")
	Input.action_press(&"mover_derecha")
	var llego: bool = await _llegar_a(RUINAS)
	Input.action_release(&"mover_derecha")
	_comprobar(llego, "la salida lleva a las Ruinas bajo Elyndor")

	GestorPartida.global().nueva_partida()
	print("RESULTADO: %s (%d fallos)" % ["OK" if _fallos == 0 else "FALLO", _fallos])
	quit(_fallos)


func _llegar_a(escena: String) -> bool:
	for i: int in 240:
		if _escena() == escena and not GestorSalas.global().cambiando():
			return true
		await physics_frame
	return false


func _escena() -> String:
	return current_scene.scene_file_path if current_scene else ""


func _mantener(accion: StringName, frames: int) -> void:
	Input.action_press(accion)
	await _esperar(frames)
	Input.action_release(accion)
	await _esperar(5)


func _esperar(frames: int) -> void:
	for i: int in frames:
		await physics_frame


func _comprobar(condicion: bool, descripcion: String) -> void:
	print(("  [OK]    " if condicion else "  [FALLO] ") + descripcion)
	if not condicion:
		_fallos += 1
