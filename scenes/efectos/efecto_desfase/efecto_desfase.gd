class_name EfectoDesfase
extends CanvasLayer
## Tinte de pantalla del Desfase: multiplica la imagen por un color frío al
## entrar y vuelve al color neutro al salir. Muy barato (un solo rectángulo).

@export var color_desfase: Color = Color(0.62, 0.72, 1.0)
@export var duracion_fundido: float = 0.3

var _tween: Tween
var _fase: GestorFase = GestorFase.global()

@onready var _tinte: ColorRect = $Tinte


func _ready() -> void:
	_fase.cambiada.connect(_al_cambiar)
	_tinte.color = color_desfase if _fase.en_desfase() else Color.WHITE


func _al_cambiar(estado: GestorFase.Estado) -> void:
	if _tween:
		_tween.kill()
	var destino: Color = color_desfase if estado == GestorFase.Estado.DESFASE else Color.WHITE
	_tween = create_tween()
	_tween.tween_property(_tinte, "color", destino, duracion_fundido)
