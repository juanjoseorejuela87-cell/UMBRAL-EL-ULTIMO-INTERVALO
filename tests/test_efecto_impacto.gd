extends SceneTree
## Prueba automática del efecto visual de impacto (TAREA-008).
## Uso: Godot_console.exe --headless --path D:\UMBRAL -s res://tests/test_efecto_impacto.gd
## Código de salida = número de comprobaciones fallidas.

const ESCENA_IMPACTO: String = "res://scenes/efectos/impacto/impacto.tscn"

var _fallos: int = 0


func _initialize() -> void:
	_ejecutar.call_deferred()


func _ejecutar() -> void:
	var escena: PackedScene = load(ESCENA_IMPACTO) as PackedScene
	_comprobar(escena != null, "la escena impacto.tscn existe y carga correctamente")
	if escena == null:
		quit(1)
		return

	var tipos: Array[StringName] = [&"golpe", &"critico", &"parry", &"herida", &"desfase"]

	for tipo: StringName in tipos:
		var efecto: EfectoImpacto = escena.instantiate() as EfectoImpacto
		_comprobar(efecto != null, "se instancia EfectoImpacto para el tipo «%s»" % tipo)
		root.add_child(efecto)
		efecto.configurar(tipo)

		var chispas: CPUParticles3D = efecto.get_node_or_null("Chispas") as CPUParticles3D
		_comprobar(chispas != null, "«%s» contiene un nodo CPUParticles3D" % tipo)
		_comprobar(chispas != null and chispas.one_shot, "«%s» tiene one_shot = true" % tipo)
		_comprobar(chispas != null and chispas.emitting, "«%s» comienza emitiendo partículas" % tipo)
		_comprobar(chispas != null and chispas.amount <= 30, "«%s» tiene <= 30 partículas (%d)" % [tipo, chispas.amount if chispas else 0])

		var liberado: bool = false
		var tiempo_inicio: float = Time.get_ticks_msec() / 1000.0
		for frame: int in 90:
			await process_frame
			if not is_instance_valid(efecto):
				liberado = true
				break

		var tiempo_transcurrido: float = (Time.get_ticks_msec() / 1000.0) - tiempo_inicio
		_comprobar(liberado, "el efecto «%s» se libera solo en menos de 1.5 s (t = %.2f s)" % [tipo, tiempo_transcurrido])

	print("RESULTADO: %s (%d fallos)" % ["OK" if _fallos == 0 else "FALLO", _fallos])
	quit(_fallos)


func _comprobar(condicion: bool, descripcion: String) -> void:
	print(("  [OK]    " if condicion else "  [FALLO] ") + descripcion)
	if not condicion:
		_fallos += 1
