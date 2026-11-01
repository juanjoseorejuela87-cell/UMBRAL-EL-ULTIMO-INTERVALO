class_name MunecoPractica
extends StaticBody3D
## Muñeco de práctica: recibe golpes, acumula postura, entra en Ruptura y
## recibe Golpes de Umbral. No muere: recupera la vida tras unos segundos.

signal golpe_procesado(info: InfoGolpe)

enum Peso { LIGERO, MEDIO, PESADO }

@export var peso: Peso = Peso.MEDIO
@export var espera_recuperar_vida: float = 3.0

## Último golpe recibido (para pruebas y depuración).
var ultimo_golpe: InfoGolpe

var _sin_golpes: float = 0.0
var _material: StandardMaterial3D
var _tween_destello: Tween

@onready var vida: ComponenteVida = $Vida
@onready var postura: ComponentePostura = $Postura
@onready var _caja_dano: CajaDano = $CajaDano
@onready var _cuerpo: MeshInstance3D = $Cuerpo


func _ready() -> void:
	_material = (_cuerpo.get_active_material(0) as StandardMaterial3D).duplicate()
	_cuerpo.set_surface_override_material(0, _material)
	_caja_dano.golpe_recibido.connect(_al_recibir_golpe)
	postura.rota.connect(_actualizar_color)
	postura.recuperada.connect(_actualizar_color)
	vida.agotada.connect(vida.restaurar)


func _physics_process(delta: float) -> void:
	_sin_golpes += delta
	if _sin_golpes >= espera_recuperar_vida and vida.actual < vida.maximo:
		vida.restaurar()


## Deja el muñeco como nuevo (para pruebas).
func reiniciar() -> void:
	vida.restaurar()
	if postura.en_ruptura or postura.actual > 0.0:
		postura.terminar_ruptura()
	ultimo_golpe = null


func _al_recibir_golpe(info: InfoGolpe) -> void:
	_sin_golpes = 0.0
	if postura.en_ruptura:
		info.critico = true
		info.dano_aplicado = info.dano * info.multiplicador_critico
		postura.terminar_ruptura()
	else:
		info.dano_aplicado = info.dano
		postura.acumular(info.dano_postura)
	vida.recibir_dano(info.dano_aplicado)
	ultimo_golpe = info
	_destellar(info.critico)
	golpe_procesado.emit(info)


func _destellar(critico: bool) -> void:
	if _tween_destello:
		_tween_destello.kill()
	_material.emission_enabled = true
	_material.emission = Color(1.0, 0.9, 0.5) if critico else Color(1.0, 1.0, 1.0)
	_material.emission_energy_multiplier = 2.0 if critico else 1.0
	_tween_destello = create_tween()
	_tween_destello.tween_property(_material, "emission_energy_multiplier", 0.0, 0.15)
	_tween_destello.tween_callback(_actualizar_color)


func _actualizar_color() -> void:
	if postura.en_ruptura:
		_material.emission_enabled = true
		_material.emission = Color(0.9, 0.6, 0.15)
		_material.emission_energy_multiplier = 0.8
	else:
		_material.emission_enabled = false
