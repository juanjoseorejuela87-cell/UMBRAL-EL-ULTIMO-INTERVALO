class_name FragmentoContinuidad
extends Area3D
## Fragmento de Continuidad: se recoge al tocarlo y queda guardado en la partida.
## Puede permanecer oculto hasta que ocurra un acontecimiento (p. ej. la derrota
## de un jefe). Diseño: documentation/LORE.md §2.6.

signal recogido(id: StringName)

## Identificador único en todo el juego.
@export var id: StringName = &""
## Si se indica, el Fragmento no aparece hasta que la partida registre este evento.
@export var aparece_con_evento: StringName = &""
@export var velocidad_giro: float = 1.2
@export var amplitud_flotacion: float = 0.15

var _tiempo: float = 0.0
var _altura_base: float = 0.0

@onready var _cristal: Node3D = $Cristal


func _ready() -> void:
	_altura_base = _cristal.position.y
	body_entered.connect(_al_entrar)
	var partida: GestorPartida = GestorPartida.global()
	partida.evento_registrado.connect(_al_registrarse_evento)
	if partida.fragmento_obtenido_ya(id):
		_desactivar()
	elif aparece_con_evento != &"" and not partida.evento_ocurrido(aparece_con_evento):
		_desactivar()


func activo() -> bool:
	return visible and monitoring


func _process(delta: float) -> void:
	if not visible:
		return
	_tiempo += delta
	_cristal.rotation.y += velocidad_giro * delta
	_cristal.position.y = _altura_base + sin(_tiempo * 2.0) * amplitud_flotacion


func _al_entrar(cuerpo: Node3D) -> void:
	if not cuerpo is Nereth or not activo():
		return
	GestorPartida.global().registrar_fragmento(id)
	_desactivar()
	recogido.emit(id)


func _al_registrarse_evento(evento: StringName) -> void:
	if evento == aparece_con_evento and not GestorPartida.global().fragmento_obtenido_ya(id):
		visible = true
		set_deferred(&"monitoring", true)


func _desactivar() -> void:
	visible = false
	set_deferred(&"monitoring", false)
