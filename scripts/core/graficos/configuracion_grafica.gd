class_name ConfiguracionGrafica
extends Node
## Calidad gráfica escalable (autoload "Graficos", D-017): el juego debe ir bien
## en PC modestos y aprovechar los potentes.
## - BAJO y MEDIO usan el renderizador Compatibility; ALTO y ULTRA, Forward+.
##   Cambiar entre ambos grupos requiere reiniciar el juego (lo hace solo).
## - Cada preajuste fija resolución interna, antialiasing, sombras y efectos de
##   atmósfera. Las salas se adaptan al cargarse (luces) y AtmosferaFase lee
##   los efectos de entorno de aquí.
## - La elección se guarda en user://ajustes.cfg; el primer arranque la deduce
##   del tipo de tarjeta gráfica.

signal calidad_cambiada(preajuste: Preajuste)

enum Preajuste { BAJO, MEDIO, ALTO, ULTRA }

const NOMBRES: Array[String] = ["Bajo", "Medio", "Alto", "Ultra"]
const METODO_LIGERO: String = "gl_compatibility"
const METODO_COMPLETO: String = "forward_plus"
const ARG_REINICIO: String = "--umbral-reinicio-graficos"

## Ajustes de cada preajuste, en el orden de Preajuste.
const AJUSTES: Array[Dictionary] = [
	{"escala_3d": 0.75, "msaa": Viewport.MSAA_DISABLED, "sombra_direccional": 1024, "atlas_sombras": 1024,
		"sombras_puntuales": false, "brillo": false, "ssao": false, "ssil": false, "sdfgi": false, "niebla_volumetrica": false},
	{"escala_3d": 1.0, "msaa": Viewport.MSAA_2X, "sombra_direccional": 2048, "atlas_sombras": 2048,
		"sombras_puntuales": true, "brillo": true, "ssao": false, "ssil": false, "sdfgi": false, "niebla_volumetrica": false},
	{"escala_3d": 1.0, "msaa": Viewport.MSAA_2X, "sombra_direccional": 4096, "atlas_sombras": 4096,
		"sombras_puntuales": true, "brillo": true, "ssao": true, "ssil": false, "sdfgi": false, "niebla_volumetrica": true},
	{"escala_3d": 1.0, "msaa": Viewport.MSAA_4X, "sombra_direccional": 4096, "atlas_sombras": 8192,
		"sombras_puntuales": true, "brillo": true, "ssao": true, "ssil": true, "sdfgi": true, "niebla_volumetrica": true},
]

var ruta_ajustes: String = "user://ajustes.cfg"
var preajuste: Preajuste = Preajuste.MEDIO
## Si es false no se reinicia nunca (editor, pruebas, sin pantalla).
var reinicio_permitido: bool = true

static var _instancia: ConfiguracionGrafica


func _init() -> void:
	_instancia = self


## Acceso sin depender del nombre del autoload (ver GestorFase.global()).
static func global() -> ConfiguracionGrafica:
	return _instancia


func _ready() -> void:
	reinicio_permitido = DisplayServer.get_name() != "headless" and not OS.has_feature("editor")
	if DisplayServer.get_name() == "headless":
		# Las pruebas no tocan los ajustes reales del jugador.
		ruta_ajustes = "user://ajustes_pruebas.cfg"
	if not cargar():
		preajuste = detectar_preajuste()
		guardar()
	_aplicar()
	get_tree().node_added.connect(_al_anadir_nodo)
	_comprobar_renderizador()


func ajustes() -> Dictionary:
	return AJUSTES[preajuste]


func usa_renderizador_completo(p: Preajuste = preajuste) -> bool:
	return p >= Preajuste.ALTO


func metodo_deseado(p: Preajuste = preajuste) -> String:
	return METODO_COMPLETO if usa_renderizador_completo(p) else METODO_LIGERO


## Para avisar al jugador antes de cambiar: true si el preajuste pide otro
## renderizador y el juego se reiniciará (se pierde lo no guardado en un Ancla).
func requiere_reinicio(p: Preajuste) -> bool:
	var actual: String = RenderingServer.get_current_rendering_method()
	return actual != "" and actual != "dummy" and actual != metodo_deseado(p)


## Cambia la calidad. Devuelve true si hace falta reiniciar para el
## renderizador (y, si está permitido, reinicia).
func cambiar(nuevo: Preajuste) -> bool:
	preajuste = nuevo
	guardar()
	_aplicar()
	calidad_cambiada.emit(preajuste)
	return _comprobar_renderizador()


## Primer arranque: gráfica integrada o desconocida → BAJO; dedicada → ALTO.
func detectar_preajuste() -> Preajuste:
	match RenderingServer.get_video_adapter_type():
		RenderingDevice.DEVICE_TYPE_DISCRETE_GPU:
			return Preajuste.ALTO
		RenderingDevice.DEVICE_TYPE_INTEGRATED_GPU:
			return Preajuste.BAJO
		_:
			return Preajuste.BAJO


func guardar() -> void:
	var archivo := ConfigFile.new()
	archivo.load(ruta_ajustes)
	archivo.set_value("graficos", "preajuste", NOMBRES[preajuste])
	archivo.save(ruta_ajustes)


func cargar() -> bool:
	var archivo := ConfigFile.new()
	if archivo.load(ruta_ajustes) != OK or not archivo.has_section_key("graficos", "preajuste"):
		return false
	var indice: int = NOMBRES.find(str(archivo.get_value("graficos", "preajuste")))
	if indice < 0:
		return false
	preajuste = indice as Preajuste
	return true


func _aplicar() -> void:
	var a: Dictionary = ajustes()
	var vista: Viewport = get_viewport()
	vista.scaling_3d_scale = a["escala_3d"]
	vista.msaa_3d = a["msaa"]
	vista.positional_shadow_atlas_size = a["atlas_sombras"]
	RenderingServer.directional_shadow_atlas_set_size(a["sombra_direccional"], true)
	for nodo: Node in get_tree().root.find_children("*", "Light3D", true, false):
		_ajustar_luz(nodo as Light3D)


## Las luces que van entrando (salas nuevas) se adaptan a la calidad.
func _al_anadir_nodo(nodo: Node) -> void:
	if nodo is Light3D:
		_ajustar_luz.call_deferred(nodo as Light3D)


## Sin sombras puntuales en BAJO; la luz direccional conserva la suya.
func _ajustar_luz(luz: Light3D) -> void:
	if not is_instance_valid(luz) or luz is DirectionalLight3D:
		return
	if not luz.has_meta(&"sombra_original"):
		luz.set_meta(&"sombra_original", luz.shadow_enabled)
	luz.shadow_enabled = bool(luz.get_meta(&"sombra_original")) and bool(ajustes()["sombras_puntuales"])


## Si el renderizador en uso no es el del preajuste, reinicia con el correcto.
func _comprobar_renderizador() -> bool:
	var actual: String = RenderingServer.get_current_rendering_method()
	var deseado: String = metodo_deseado()
	if actual == "" or actual == "dummy" or actual == deseado:
		return false
	if OS.get_cmdline_user_args().has(ARG_REINICIO):
		# Ya se reinició y el motor no pudo usar Forward+ (sin Vulkan/D3D12):
		# se baja a MEDIO para no reiniciar en cada arranque.
		if usa_renderizador_completo():
			preajuste = Preajuste.MEDIO
			guardar()
			_aplicar()
			calidad_cambiada.emit(preajuste)
		return false
	if reinicio_permitido:
		OS.set_restart_on_exit(true, ["--rendering-method", deseado, "--", ARG_REINICIO])
		get_tree().quit()
	return true
