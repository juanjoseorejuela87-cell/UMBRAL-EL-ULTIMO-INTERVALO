extends SceneTree
## Prueba automática de las figuras estilizadas de los enemigos (TAREA-012).
## Uso: Godot_console.exe --headless --path D:\UMBRAL -s res://tests/test_figuras_enemigos.gd
## Código de salida = número de comprobaciones fallidas.

const ESCENA_VIGIA: String = "res://scenes/enemigos/vigia_hueco/vigia_hueco.tscn"
const ESCENA_ECO: String = "res://scenes/enemigos/eco_rezagado/eco_rezagado.tscn"
const ESCENA_GUARDIAN: String = "res://scenes/enemigos/guardian_partido/guardian_partido.tscn"
const ESCENA_PREFECTO: String = "res://scenes/enemigos/prefecto/prefecto.tscn"

var _fallos: int = 0


func _initialize() -> void:
	ConfigControles.registrar()
	_ejecutar.call_deferred()


func _ejecutar() -> void:
	await _esperar(3)

	var enemigos: Dictionary = {
		"VigiaHueco": {
			"escena": ESCENA_VIGIA,
			"radio": 0.4,
			"alto": 1.9,
		},
		"EcoRezagado": {
			"escena": ESCENA_ECO,
			"radio": 0.32,
			"alto": 1.6,
		},
		"GuardianPartido": {
			"escena": ESCENA_GUARDIAN,
			"radio": 0.6,
			"alto": 2.4,
		},
		"Prefecto": {
			"escena": ESCENA_PREFECTO,
			"radio": 0.55,
			"alto": 2.8,
		},
	}

	for nombre: String in enemigos:
		var datos: Dictionary = enemigos[nombre]
		var pack: PackedScene = load(datos["escena"]) as PackedScene
		_comprobar(pack != null, "%s: la escena existe" % nombre)
		if pack == null:
			continue

		var inst: Enemigo = pack.instantiate() as Enemigo
		root.add_child(inst)
		await _esperar(2)

		# 1. Conserva Visual/Cuerpo
		var cuerpo: MeshInstance3D = inst.get_node_or_null(^"Visual/Cuerpo") as MeshInstance3D
		_comprobar(cuerpo != null, "%s: conserva el nodo Visual/Cuerpo como MeshInstance3D" % nombre)

		# 2. Tiene varias piezas bajo Visual (>= 3 y <= 25)
		var mallas: Array[Node] = inst.get_node(^"Visual").find_children("*", "MeshInstance3D", true, false)
		_comprobar(mallas.size() >= 4, "%s: tiene múltiples piezas bajo Visual (%d piezas)" % [nombre, mallas.size()])
		_comprobar(mallas.size() <= 25, "%s: respeta el presupuesto de mallas (<= 25: tiene %d)" % [nombre, mallas.size()])

		# 3. Sin luces nuevas añadidas a la figura
		var luces: Array[Node] = inst.find_children("*", "Light3D", true, false)
		_comprobar(luces.is_empty(), "%s: no incluye nodos de luz" % nombre)

		# 4. Colisión intacta
		var col: CollisionShape3D = inst.get_node_or_null(^"Colision") as CollisionShape3D
		_comprobar(col != null and col.shape is CapsuleShape3D, "%s: conserva forma de cápsula en Colision" % nombre)
		if col and col.shape is CapsuleShape3D:
			var capsula: CapsuleShape3D = col.shape as CapsuleShape3D
			_comprobar(absf(capsula.radius - float(datos["radio"])) < 0.01,
				"%s: el radio de colisión se mantiene (%.2f == %.2f)" % [nombre, capsula.radius, datos["radio"]])
			_comprobar(absf(capsula.height - float(datos["alto"])) < 0.01,
				"%s: la altura de colisión se mantiene (%.2f == %.2f)" % [nombre, capsula.height, datos["alto"]])

		# 5. Piezas comparten el material de Cuerpo tras _ready
		if cuerpo != null:
			var mat_cuerpo: Material = cuerpo.get_active_material(0)
			var piezas_compartidas: int = 0
			var pieza_secundaria: MeshInstance3D = null
			for m: Node in mallas:
				var mi: MeshInstance3D = m as MeshInstance3D
				if mi != cuerpo and mi.get_active_material(0) == mat_cuerpo:
					piezas_compartidas += 1
					if pieza_secundaria == null:
						pieza_secundaria = mi

			_comprobar(piezas_compartidas >= 2,
				"%s: al menos 2 piezas secundarias comparten el material de Cuerpo (%d encontradas)" % [nombre, piezas_compartidas])

			# 6. Comprobar que tras un golpe la emisión se ve en una pieza que no sea Cuerpo
			if pieza_secundaria != null and mat_cuerpo is StandardMaterial3D:
				var mat_std: StandardMaterial3D = mat_cuerpo as StandardMaterial3D
				inst._destellar(false)
				_comprobar(mat_std.emission_enabled and mat_std.emission_energy_multiplier > 0.1,
					"%s: tras un golpe la pieza secundaria (%s) muestra la emisión compartida" % [nombre, pieza_secundaria.name])

		# 7. Caso especial Eco: invisible en Realidad y visible en Desfase
		if nombre == "EcoRezagado":
			GestorFase.global().cambiar(GestorFase.Estado.REALIDAD)
			await _esperar(2)
			_comprobar(not cuerpo.visible, "EcoRezagado: Cuerpo no es visible en la Realidad")
			GestorFase.global().cambiar(GestorFase.Estado.DESFASE)
			await _esperar(2)
			_comprobar(cuerpo.visible, "EcoRezagado: Cuerpo es visible en el Desfase")

		inst.queue_free()
		await _esperar(2)

	GestorFase.global().cambiar(GestorFase.Estado.REALIDAD)
	print("RESULTADO: %s (%d fallos)" % ["OK" if _fallos == 0 else "FALLO", _fallos])
	quit(_fallos)


func _esperar(frames: int) -> void:
	for i: int in frames:
		await process_frame


func _comprobar(condicion: bool, descripcion: String) -> void:
	print(("  [OK]    " if condicion else "  [FALLO] ") + descripcion)
	if not condicion:
		_fallos += 1
