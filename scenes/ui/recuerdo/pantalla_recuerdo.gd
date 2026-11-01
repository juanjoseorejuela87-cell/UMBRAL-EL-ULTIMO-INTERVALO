class_name PantallaRecuerdo
extends CanvasLayer
## Recuerdo ajeno que Nereth vive al tocar un Fragmento de Continuidad
## (LORE.md §4.1): destello dorado, la visión descrita en pocas palabras y una
## frase. No detiene el juego y desaparece sola.

const ESCENA: String = "res://scenes/ui/recuerdo/pantalla_recuerdo.tscn"

@export var duracion: float = 6.0

@onready var _velo: ColorRect = $Velo
@onready var _titulo: Label = %Titulo
@onready var _vision: Label = %Vision
@onready var _frase: Label = %Frase


## Crea y muestra un recuerdo sobre la escena actual.
static func mostrar(arbol: SceneTree, titulo: String, vision: String, frase: String) -> PantallaRecuerdo:
	var pantalla: PantallaRecuerdo = (load(ESCENA) as PackedScene).instantiate() as PantallaRecuerdo
	var contenedor: Node = arbol.current_scene if arbol.current_scene else arbol.root
	contenedor.add_child(pantalla)
	pantalla.presentar(titulo, vision, frase)
	return pantalla


func presentar(titulo: String, vision: String, frase: String) -> void:
	_titulo.text = titulo
	_vision.text = vision
	_frase.text = "«%s»" % frase
	for nodo: CanvasItem in [_velo, _titulo, _vision, _frase]:
		nodo.modulate.a = 0.0
	var tween: Tween = create_tween()
	tween.tween_property(_velo, "modulate:a", 1.0, 0.25)
	tween.tween_property(_velo, "modulate:a", 0.35, 0.8)
	tween.parallel().tween_property(_titulo, "modulate:a", 1.0, 0.8)
	tween.tween_property(_vision, "modulate:a", 1.0, 0.8)
	tween.tween_property(_frase, "modulate:a", 1.0, 1.0)
	tween.tween_interval(maxf(duracion - 4.6, 0.5))
	tween.tween_property(_velo, "modulate:a", 0.0, 1.0)
	tween.parallel().tween_property(_titulo, "modulate:a", 0.0, 1.0)
	tween.parallel().tween_property(_vision, "modulate:a", 0.0, 1.0)
	tween.parallel().tween_property(_frase, "modulate:a", 0.0, 1.0)
	tween.tween_callback(queue_free)


func texto_frase() -> String:
	return _frase.text
