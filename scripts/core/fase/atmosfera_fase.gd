class_name AtmosferaFase
extends WorldEnvironment
## Atmósfera de una sala que cambia con el estado de la realidad
## (documentation/GUIA_ARTE.md §2): niebla, luz ambiental, brillo y color se
## funden entre el ajuste de la Realidad (cálido, denso) y el del Desfase
## (frío, nítido). Sustituye al WorldEnvironment de la sala.

@export_group("Realidad")
@export var niebla_realidad: Color = Color(0.36, 0.3, 0.25)
@export var densidad_realidad: float = 0.012
@export var ambiente_realidad: Color = Color(0.45, 0.38, 0.32)
@export var energia_ambiente_realidad: float = 0.45
@export var brillo_realidad: float = 0.6
@export var saturacion_realidad: float = 0.85

@export_group("Desfase")
@export var niebla_desfase: Color = Color(0.25, 0.36, 0.6)
@export var densidad_desfase: float = 0.007
@export var ambiente_desfase: Color = Color(0.5, 0.62, 0.9)
@export var energia_ambiente_desfase: float = 0.7
@export var brillo_desfase: float = 1.0
@export var saturacion_desfase: float = 0.7

@export_group("Transición")
@export var duracion: float = 0.35

var _tween: Tween
var _fase: GestorFase = GestorFase.global()


func _ready() -> void:
	if environment == null:
		environment = Environment.new()
	else:
		environment = environment.duplicate()
	environment.fog_enabled = true
	# La niebla no tiñe el fondo: el negro de las salas subterráneas se conserva.
	environment.fog_sky_affect = 0.0
	environment.glow_enabled = true
	environment.adjustment_enabled = true
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	_fase.cambiada.connect(_al_cambiar)
	var graficos: ConfiguracionGrafica = ConfiguracionGrafica.global()
	if graficos:
		graficos.calidad_cambiada.connect(_al_cambiar_calidad)
		_al_cambiar_calidad(graficos.preajuste)
	_aplicar(1.0 if _fase.en_desfase() else 0.0)


## Efectos de entorno según la calidad (D-017). SSAO, SSIL, SDFGI y la niebla
## volumétrica solo existen en Forward+ (ALTO y ULTRA); Compatibility los ignora.
func _al_cambiar_calidad(_preajuste: ConfiguracionGrafica.Preajuste) -> void:
	var a: Dictionary = ConfiguracionGrafica.global().ajustes()
	# Hasta que el reinicio cambie de renderizador, no se piden efectos que el
	# actual no tiene (el motor avisaría por cada uno).
	var completo: bool = RenderingServer.get_current_rendering_method() == ConfiguracionGrafica.METODO_COMPLETO
	environment.glow_enabled = a["brillo"]
	environment.ssao_enabled = completo and a["ssao"]
	environment.ssil_enabled = completo and a["ssil"]
	environment.sdfgi_enabled = completo and a["sdfgi"]
	environment.volumetric_fog_enabled = completo and a["niebla_volumetrica"]
	environment.volumetric_fog_density = 0.01
	environment.volumetric_fog_length = 40.0


## 0 = Realidad, 1 = Desfase (valores intermedios durante la transición).
func _aplicar(mezcla: float) -> void:
	environment.fog_light_color = niebla_realidad.lerp(niebla_desfase, mezcla)
	environment.fog_density = lerpf(densidad_realidad, densidad_desfase, mezcla)
	environment.ambient_light_color = ambiente_realidad.lerp(ambiente_desfase, mezcla)
	environment.ambient_light_energy = lerpf(energia_ambiente_realidad, energia_ambiente_desfase, mezcla)
	environment.glow_intensity = lerpf(brillo_realidad, brillo_desfase, mezcla)
	environment.adjustment_saturation = lerpf(saturacion_realidad, saturacion_desfase, mezcla)
	environment.volumetric_fog_albedo = environment.fog_light_color


func _al_cambiar(estado: GestorFase.Estado) -> void:
	if _tween:
		_tween.kill()
	var desde: float = 0.0 if estado == GestorFase.Estado.DESFASE else 1.0
	var hasta: float = 1.0 - desde
	_tween = create_tween()
	_tween.tween_method(_aplicar, desde, hasta, duracion)
