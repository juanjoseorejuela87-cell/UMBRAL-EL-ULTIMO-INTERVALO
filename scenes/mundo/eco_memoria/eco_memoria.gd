class_name EcoMemoria
extends Area3D
## Eco de memoria: escena del pasado que Nereth percibe en el Desfase
## (GAMEPLAY.md §7.4). Los ecos ocultos solo aparecen después de obtener el
## Fragmento de Memoria, que permite reconocerlos (LORE.md §12.2, A6).
## Al tocarlo se vive el recuerdo y queda registrado en la partida.

signal percibido(id: StringName)

const PREFIJO_EVENTO: String = "eco_"

## Identificador único en todo el juego.
@export var id: StringName = &""
## Fragmento necesario para reconocer el eco (vacío = siempre reconocible).
@export var requiere_fragmento: StringName = &"fragmento_elyndor_prefecto"
@export var titulo: String = "Eco de memoria"
@export_multiline var texto: String = ""
@export var velocidad_pulso: float = 1.6
## Brillo de un eco ya vivido respecto a uno nuevo.
@export var brillo_percibido: float = 0.35

var _tiempo: float = 0.0
var _fase: GestorFase = GestorFase.global()
var _partida: GestorPartida = GestorPartida.global()

@onready var _figura: GeometryInstance3D = $Figura


func _ready() -> void:
	body_entered.connect(_al_entrar)
	_fase.cambiada.connect(_al_cambiar_fase.unbind(1))
	_partida.fragmento_obtenido.connect(_al_cambiar_fase.unbind(1))
	_al_cambiar_fase()


func evento() -> StringName:
	return StringName(PREFIJO_EVENTO + String(id))


func reconocible() -> bool:
	return requiere_fragmento == &"" or _partida.fragmento_obtenido_ya(requiere_fragmento)


func ya_percibido() -> bool:
	return _partida.evento_ocurrido(evento())


## Visible solo en el Desfase y si Nereth puede reconocerlo.
func activo() -> bool:
	return visible and monitoring


func _process(delta: float) -> void:
	if not visible:
		return
	_tiempo += delta
	var brillo: float = brillo_percibido if ya_percibido() else 1.0
	_figura.transparency = 1.0 - brillo * (0.55 + 0.25 * sin(_tiempo * velocidad_pulso))


func _al_cambiar_fase() -> void:
	var mostrar: bool = _fase.en_desfase() and reconocible()
	visible = mostrar
	set_deferred(&"monitoring", mostrar)


func _al_entrar(cuerpo: Node3D) -> void:
	if not cuerpo is Nereth or not activo() or ya_percibido():
		return
	_partida.registrar_evento(evento())
	GestorSonido.global().reproducir(&"fragmento", -6.0, 0.0)
	if texto != "":
		PantallaRecuerdo.mostrar(get_tree(), titulo, texto, "")
	percibido.emit(id)
