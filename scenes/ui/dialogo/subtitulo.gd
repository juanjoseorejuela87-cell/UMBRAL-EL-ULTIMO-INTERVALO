class_name Subtitulo
extends CanvasLayer
## Subtítulos de diálogo en la parte inferior de la pantalla: nombre de quien
## habla y una o varias líneas que se suceden y se desvanecen solas. No detiene
## el juego. Solo hay uno a la vez: uno nuevo sustituye al anterior.

const ESCENA: String = "res://scenes/ui/dialogo/subtitulo.tscn"
const GRUPO: StringName = &"subtitulo"

## Segundos por línea: base más un extra por carácter, para que dé tiempo a leer.
@export var segundos_base: float = 1.6
@export var segundos_por_caracter: float = 0.045
@export var fundido: float = 0.3

@onready var _caja: Control = %Caja
@onready var _hablante: Label = %Hablante
@onready var _texto: Label = %Texto


## Muestra las líneas de `hablante` sobre la escena actual.
static func mostrar(arbol: SceneTree, hablante: String, lineas: PackedStringArray) -> Subtitulo:
	for anterior: Node in arbol.get_nodes_in_group(GRUPO):
		anterior.queue_free()
	var subtitulo: Subtitulo = (load(ESCENA) as PackedScene).instantiate() as Subtitulo
	var contenedor: Node = arbol.current_scene if arbol.current_scene else arbol.root
	contenedor.add_child(subtitulo)
	subtitulo.decir(hablante, lineas)
	return subtitulo


func _ready() -> void:
	add_to_group(GRUPO)


func decir(hablante: String, lineas: PackedStringArray) -> void:
	_hablante.text = hablante
	_caja.modulate.a = 0.0
	var tween: Tween = create_tween()
	for linea: String in lineas:
		tween.tween_callback(_texto.set.bind(&"text", linea))
		tween.tween_property(_caja, "modulate:a", 1.0, fundido)
		tween.tween_interval(segundos_base + segundos_por_caracter * linea.length())
		tween.tween_property(_caja, "modulate:a", 0.0, fundido)
	tween.tween_callback(queue_free)


func texto_actual() -> String:
	return _texto.text
