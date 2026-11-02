extends SceneTree
## Prueba automática del kit gótico ampliado y sala muestrario (TAREA-015).
## Uso: Godot_console.exe --headless --path D:\UMBRAL -s res://tests/test_kit_gotico.gd

const ESCENAS_KIT: Array[String] = [
	"res://scenes/mundo/kit_gotico/vidriera.tscn",
	"res://scenes/mundo/kit_gotico/vidriera_rota.tscn",
	"res://scenes/mundo/kit_gotico/barandilla.tscn",
	"res://scenes/mundo/kit_gotico/barandilla_rota.tscn",
	"res://scenes/mundo/kit_gotico/brasero.tscn",
	"res://scenes/mundo/kit_gotico/brasero_apagado.tscn",
	"res://scenes/mundo/kit_gotico/estatua_arquitecto.tscn",
	"res://scenes/mundo/kit_gotico/estatua_arquitecto_rota.tscn",
	"res://scenes/mundo/kit_gotico/reja.tscn",
	"res://scenes/mundo/kit_gotico/muro_roto.tscn",
]

const ESCENA_MUESTRARIO: String = "res://scenes/niveles/pruebas/sala_kit_gotico.tscn"

var _fallos: int = 0


func _initialize() -> void:
	_ejecutar.call_deferred()


func _ejecutar() -> void:
	# 1. Carga e instanciación de cada pieza individual
	for ruta: String in ESCENAS_KIT:
		var nombre: String = ruta.get_file().get_basename()
		var recurso: PackedScene = load(ruta) as PackedScene
		_comprobar(recurso != null, "%s: la escena existe y carga correctamente" % nombre)
		if recurso == null:
			continue
		var instancia: Node = recurso.instantiate()
		_comprobar(instancia != null, "%s: se instancia sin errores" % nombre)
		if instancia:
			root.add_child(instancia)
			await process_frame
			instancia.queue_free()
			await process_frame

	# 2. Pruebas específicas del Brasero
	var escena_brasero: PackedScene = load("res://scenes/mundo/kit_gotico/brasero.tscn") as PackedScene
	if escena_brasero:
		var brasero_defecto: Node = escena_brasero.instantiate()
		root.add_child(brasero_defecto)
		await process_frame
		var luz_defecto: OmniLight3D = brasero_defecto.get_node_or_null("Luz") as OmniLight3D
		_comprobar(
			luz_defecto != null and not luz_defecto.visible,
			"Brasero: con_luz = false por defecto no activa la luz puntual"
		)
		brasero_defecto.queue_free()
		await process_frame

		var brasero_con_luz: Node = escena_brasero.instantiate()
		brasero_con_luz.set("con_luz", true)
		root.add_child(brasero_con_luz)
		await process_frame
		var luz_activa: OmniLight3D = brasero_con_luz.get_node_or_null("Luz") as OmniLight3D
		_comprobar(
			luz_activa != null and luz_activa.visible,
			"Brasero: con_luz = true activa la luz puntual correctamente"
		)
		brasero_con_luz.queue_free()
		await process_frame

	# 3. Prueba de la sala muestrario y alternancia con ElementoFase
	var escena_sala: PackedScene = load(ESCENA_MUESTRARIO) as PackedScene
	_comprobar(escena_sala != null, "sala_kit_gotico.tscn: la escena muestrario existe")
	if escena_sala:
		var sala: Node = escena_sala.instantiate()
		root.add_child(sala)
		await process_frame
		await process_frame

		var estatua_real: Node = sala.get_node_or_null("Muestrario/ParejaFaseEjemplo/EstatuaRealidad")
		var estatua_desfase: Node = sala.get_node_or_null("Muestrario/ParejaFaseEjemplo/EstatuaDesfase")
		_comprobar(estatua_real != null and estatua_desfase != null, "la pareja de ejemplo con ElementoFase existe en la sala")

		if estatua_real and estatua_desfase:
			var elem_real: ElementoFase = estatua_real.get_node_or_null("ElementoFase") as ElementoFase
			var elem_desfase: ElementoFase = estatua_desfase.get_node_or_null("ElementoFase") as ElementoFase
			_comprobar(elem_real != null and elem_desfase != null, "ambas piezas tienen su nodo ElementoFase asignado")

			var fase: GestorFase = GestorFase.global()
			fase.cambiar(GestorFase.Estado.REALIDAD)
			await process_frame
			_comprobar(
				elem_real.existe_en_estado(GestorFase.Estado.REALIDAD),
				"en Realidad: la pieza rota existe en su estado principal"
			)
			_comprobar(
				not elem_desfase.existe_en_estado(GestorFase.Estado.REALIDAD),
				"en Realidad: la pieza de Desfase no existe en este estado"
			)

			fase.cambiar(GestorFase.Estado.DESFASE)
			await process_frame
			_comprobar(
				elem_desfase.existe_en_estado(GestorFase.Estado.DESFASE),
				"en Desfase: la pieza intacta existe en su estado principal"
			)
			_comprobar(
				not elem_real.existe_en_estado(GestorFase.Estado.DESFASE),
				"en Desfase: la pieza de Realidad pasa a silueta / fuera de estado principal"
			)

			fase.cambiar(GestorFase.Estado.REALIDAD)
			await process_frame

		sala.queue_free()
		await process_frame

	print("RESULTADO: %s (%d fallos)" % ["OK" if _fallos == 0 else "FALLO", _fallos])
	quit(_fallos)


func _comprobar(condicion: bool, descripcion: String) -> void:
	print(("  [OK]    " if condicion else "  [FALLO] ") + descripcion)
	if not condicion:
		_fallos += 1
