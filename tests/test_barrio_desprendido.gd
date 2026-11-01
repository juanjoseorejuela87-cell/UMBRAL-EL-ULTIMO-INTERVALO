extends SceneTree
## Prueba de carga y consistencia del nivel Barrio Desprendido de Elyndor.
## Uso: Godot_console.exe --headless --path D:\UMBRAL -s res://tests/test_barrio_desprendido.gd
## Código de salida = número de comprobaciones fallidas.

const ESCENA: String = "res://scenes/niveles/elyndor/barrio_desprendido.tscn"

var _sala: Node
var _nereth: Nereth
var _fallos: int = 0


func _initialize() -> void:
	ConfigControles.registrar()
	var gestor_fase: GestorFase = GestorFase.global()
	if gestor_fase:
		gestor_fase.cambiar(GestorFase.Estado.REALIDAD)

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
	_comprobar(caidas.size() >= 1, "la escena tiene zona de caída configurada")

	print("RESULTADO: %s (%d fallos)" % ["OK" if _fallos == 0 else "FALLO", _fallos])
	quit(_fallos)


func _esperar(frames: int) -> void:
	for i: int in frames:
		await physics_frame


func _comprobar(condicion: bool, descripcion: String) -> void:
	print(("  [OK]    " if condicion else "  [FALLO] ") + descripcion)
	if not condicion:
		_fallos += 1
