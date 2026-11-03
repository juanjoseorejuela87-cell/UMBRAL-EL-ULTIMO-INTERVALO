class_name GestorSonido
extends Node
## Audio del juego (autoload "Sonido"): buses (Música, Efectos, Ambiente), un
## grupo de reproductores reutilizables y una biblioteca de efectos.
## Mientras no haya grabaciones, los efectos se SINTETIZAN por código (barridos
## de tono y ruido con envolvente) la primera vez que se piden. Para sustituir
## uno por un archivo real basta con añadirlo a `archivos`.

const BUS_MUSICA: StringName = &"Musica"
const BUS_EFECTOS: StringName = &"Efectos"
const BUS_AMBIENTE: StringName = &"Ambiente"
const FRECUENCIA_MUESTREO: int = 22050

## Receta de cada efecto sintetizado:
## [duración s, tono inicial Hz, tono final Hz, mezcla de ruido 0-1,
##  ataque s, filtro del ruido 0-1 (bajo = más grave), armónico extra (×tono, 0 = no)]
const RECETAS: Dictionary = {
	&"golpe": [0.08, 180.0, 90.0, 0.7, 0.002, 0.35, 0.0],
	&"critico": [0.24, 300.0, 110.0, 0.5, 0.002, 0.45, 2.0],
	&"parry": [0.3, 1250.0, 1500.0, 0.1, 0.002, 0.8, 1.5],
	&"herida": [0.16, 140.0, 70.0, 0.6, 0.002, 0.3, 0.0],
	&"bloqueo": [0.1, 420.0, 300.0, 0.4, 0.002, 0.5, 0.0],
	&"esquiva": [0.14, 0.0, 0.0, 1.0, 0.03, 0.25, 0.0],
	&"salto": [0.08, 250.0, 420.0, 0.1, 0.005, 0.5, 0.0],
	&"desfase_entrar": [0.35, 220.0, 660.0, 0.15, 0.06, 0.6, 1.5],
	&"desfase_salir": [0.3, 660.0, 220.0, 0.15, 0.04, 0.6, 1.5],
	&"rechazo": [0.32, 200.0, 55.0, 0.35, 0.005, 0.4, 0.0],
	&"coser": [0.28, 500.0, 900.0, 0.05, 0.02, 0.7, 2.0],
	&"desgarro": [0.18, 900.0, 300.0, 0.4, 0.002, 0.6, 0.0],
	&"ancla": [0.9, 330.0, 330.0, 0.0, 0.01, 0.5, 1.5],
	&"fragmento": [1.1, 523.0, 523.0, 0.0, 0.01, 0.5, 1.5],
	&"esencia": [0.7, 330.0, 660.0, 0.05, 0.08, 0.6, 2.0],
	&"ui_mover": [0.04, 620.0, 620.0, 0.0, 0.002, 0.5, 0.0],
	&"ui_aceptar": [0.09, 500.0, 800.0, 0.0, 0.003, 0.5, 0.0],
}

## Recetas de ambientes en bucle: [tono base Hz, mezcla de ruido, filtro, pulso Hz]
const AMBIENTES: Dictionary = {
	&"elyndor": [55.0, 0.35, 0.08, 0.15],
	&"prefecto": [41.2, 0.25, 0.06, 0.4],
}
const DURACION_AMBIENTE: float = 4.0
## Música de fondo de cada ambiente (sin entrada = silencio; el jefe pone la suya).
const MUSICA_DE_AMBIENTE: Dictionary = {
	&"elyndor": &"elyndor",
}

@export var reproductores: int = 12
## Volumen de la música en reproducción plena y nivel de silencio de los fundidos.
@export var volumen_musica_db: float = -4.0
@export var silencio_db: float = -40.0
## Los volúmenes se guardan junto a la calidad gráfica (ver ConfiguracionGrafica).
var ruta_ajustes: String = "user://ajustes.cfg"
## Sustitutos con grabación real: nombre -> AudioStream.
@export var archivos: Dictionary = {}

var _cache: Dictionary = {}
var _reproductores: Array[AudioStreamPlayer] = []
var _siguiente: int = 0
var _ambiente: AudioStreamPlayer
var _ambiente_actual: StringName = &""
var _musica: AudioStreamPlayer
var _musica_actual: StringName = &""
var _tween_musica: Tween
var _composiciones: Dictionary = {}

static var _instancia: GestorSonido


func _init() -> void:
	_instancia = self


## Acceso sin depender del nombre del autoload (ver GestorFase.global()).
static func global() -> GestorSonido:
	return _instancia


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	if DisplayServer.get_name() == "headless":
		# Las pruebas no tocan los ajustes reales del jugador.
		ruta_ajustes = "user://ajustes_pruebas.cfg"
	for bus: StringName in [BUS_MUSICA, BUS_EFECTOS, BUS_AMBIENTE]:
		_asegurar_bus(bus)
	cargar_volumenes()
	for i: int in reproductores:
		var reproductor := AudioStreamPlayer.new()
		reproductor.bus = BUS_EFECTOS
		add_child(reproductor)
		_reproductores.append(reproductor)
	_ambiente = AudioStreamPlayer.new()
	_ambiente.bus = BUS_AMBIENTE
	_ambiente.volume_db = -10.0
	add_child(_ambiente)
	_musica = AudioStreamPlayer.new()
	_musica.bus = BUS_MUSICA
	add_child(_musica)
	if DisplayServer.get_name() != "headless":
		# La música de exploración se compone mientras el jugador está en el título.
		preparar_musica.call_deferred(&"elyndor")


func _exit_tree() -> void:
	for tarea: int in _composiciones.values():
		WorkerThreadPool.wait_for_task_completion(tarea)
	_composiciones.clear()


## Reproduce un efecto. `variacion` cambia el tono al azar (±) para que las
## repeticiones no suenen idénticas. Devuelve el reproductor usado (o null).
func reproducir(nombre: StringName, volumen_db: float = 0.0, variacion: float = 0.06) -> AudioStreamPlayer:
	var flujo: AudioStream = obtener(nombre)
	if flujo == null:
		return null
	var reproductor: AudioStreamPlayer = _reproductores[_siguiente]
	_siguiente = (_siguiente + 1) % _reproductores.size()
	reproductor.stream = flujo
	reproductor.volume_db = volumen_db
	reproductor.pitch_scale = 1.0 + randf_range(-variacion, variacion)
	reproductor.play()
	return reproductor


## Cambia el ambiente en bucle (&"" lo detiene) y la música de fondo que le
## corresponde (MUSICA_DE_AMBIENTE); en menús, &"" silencia ambas.
func ambiente(nombre: StringName) -> void:
	if nombre == _ambiente_actual:
		return
	_ambiente_actual = nombre
	musica(MUSICA_DE_AMBIENTE.get(nombre, &""))
	if nombre == &"" or not AMBIENTES.has(nombre):
		_ambiente.stop()
		return
	_ambiente.stream = _obtener_ambiente(nombre)
	_ambiente.play()


func ambiente_actual() -> StringName:
	return _ambiente_actual


## Cambia la música con un fundido (&"" la apaga). Si la pista aún no está
## compuesta, se compone en segundo plano y empieza al terminar.
func musica(nombre: StringName, fundido: float = 1.5) -> void:
	if nombre == _musica_actual:
		return
	_musica_actual = nombre
	if nombre == &"" or not CompositorMusica.PISTAS.has(nombre):
		_fundir_musica(silencio_db, fundido, true)
		return
	if _cache.has(_clave_musica(nombre)):
		_arrancar_musica(nombre, fundido)
	else:
		preparar_musica(nombre)


func musica_actual() -> StringName:
	return _musica_actual


func musica_sonando() -> bool:
	return _musica.playing


## Compone una pista por adelantado (p. ej. al entrar en la sala del jefe).
func preparar_musica(nombre: StringName) -> void:
	if _cache.has(_clave_musica(nombre)) or _composiciones.has(nombre) 			or not CompositorMusica.PISTAS.has(nombre):
		return
	_composiciones[nombre] = WorkerThreadPool.add_task(func() -> void:
		var wav: AudioStreamWAV = CompositorMusica.componer(nombre)
		_musica_compuesta.call_deferred(nombre, wav))


func musica_lista(nombre: StringName) -> bool:
	return _cache.has(_clave_musica(nombre))


func _musica_compuesta(nombre: StringName, wav: AudioStreamWAV) -> void:
	if _composiciones.has(nombre):
		WorkerThreadPool.wait_for_task_completion(_composiciones[nombre])
		_composiciones.erase(nombre)
	_cache[_clave_musica(nombre)] = wav
	if _musica_actual == nombre:
		_arrancar_musica(nombre, 1.5)


func _arrancar_musica(nombre: StringName, fundido: float) -> void:
	_musica.stream = _cache[_clave_musica(nombre)]
	_musica.volume_db = silencio_db
	_musica.play()
	_fundir_musica(volumen_musica_db, fundido, false)


func _fundir_musica(hasta_db: float, duracion: float, detener: bool) -> void:
	if _tween_musica:
		_tween_musica.kill()
	_tween_musica = create_tween()
	_tween_musica.tween_property(_musica, "volume_db", hasta_db, maxf(duracion, 0.01))
	if detener:
		_tween_musica.tween_callback(_musica.stop)


func _clave_musica(nombre: StringName) -> StringName:
	return StringName("musica_" + String(nombre))


## Volumen lineal (0–1) de un bus. Se guarda salvo que `guardar` sea false.
func fijar_volumen(bus: StringName, lineal: float, guardar: bool = true) -> void:
	var indice: int = AudioServer.get_bus_index(bus)
	if indice < 0:
		return
	AudioServer.set_bus_volume_db(indice, linear_to_db(clampf(lineal, 0.0, 1.0)))
	if guardar:
		var archivo := ConfigFile.new()
		archivo.load(ruta_ajustes)
		archivo.set_value("sonido", String(bus), clampf(lineal, 0.0, 1.0))
		archivo.save(ruta_ajustes)


func volumen(bus: StringName) -> float:
	var indice: int = AudioServer.get_bus_index(bus)
	return db_to_linear(AudioServer.get_bus_volume_db(indice)) if indice >= 0 else 0.0


func cargar_volumenes() -> void:
	var archivo := ConfigFile.new()
	if archivo.load(ruta_ajustes) != OK:
		return
	for bus: StringName in [BUS_MUSICA, BUS_EFECTOS, BUS_AMBIENTE]:
		if archivo.has_section_key("sonido", String(bus)):
			fijar_volumen(bus, float(archivo.get_value("sonido", String(bus))), false)


func obtener(nombre: StringName) -> AudioStream:
	if archivos.has(nombre):
		return archivos[nombre]
	if not RECETAS.has(nombre):
		push_warning("Sonido desconocido: %s" % nombre)
		return null
	if not _cache.has(nombre):
		_cache[nombre] = _sintetizar(RECETAS[nombre])
	return _cache[nombre]


func _asegurar_bus(nombre: StringName) -> void:
	if AudioServer.get_bus_index(nombre) >= 0:
		return
	AudioServer.add_bus()
	var indice: int = AudioServer.bus_count - 1
	AudioServer.set_bus_name(indice, nombre)
	AudioServer.set_bus_send(indice, &"Master")


func _sintetizar(receta: Array) -> AudioStreamWAV:
	var duracion: float = receta[0]
	var tono_inicial: float = receta[1]
	var tono_final: float = receta[2]
	var ruido: float = receta[3]
	var ataque: float = maxf(receta[4], 0.001)
	var filtro: float = receta[5]
	var armonico: float = receta[6]
	var muestras: int = int(duracion * FRECUENCIA_MUESTREO)
	var datos := PackedByteArray()
	datos.resize(muestras * 2)
	var fase: float = 0.0
	var fase_armonico: float = 0.0
	var ruido_filtrado: float = 0.0
	for i: int in muestras:
		var t: float = float(i) / FRECUENCIA_MUESTREO
		var progreso: float = t / duracion
		var tono: float = lerpf(tono_inicial, tono_final, progreso)
		fase += TAU * tono / FRECUENCIA_MUESTREO
		fase_armonico += TAU * tono * armonico / FRECUENCIA_MUESTREO
		var senal: float = sin(fase)
		if armonico > 0.0:
			senal = senal * 0.7 + sin(fase_armonico) * 0.3
		ruido_filtrado = lerpf(ruido_filtrado, randf_range(-1.0, 1.0), filtro)
		var mezcla: float = senal * (1.0 - ruido) + ruido_filtrado * ruido * 1.6
		var envolvente: float = minf(t / ataque, 1.0) * pow(1.0 - progreso, 2.0)
		datos.encode_s16(i * 2, int(clampf(mezcla * envolvente * 0.8, -1.0, 1.0) * 32767.0))
	return _crear_wav(datos, false)


func _obtener_ambiente(nombre: StringName) -> AudioStreamWAV:
	var clave: StringName = StringName("ambiente_" + String(nombre))
	if _cache.has(clave):
		return _cache[clave]
	var receta: Array = AMBIENTES[nombre]
	var tono: float = receta[0]
	var ruido: float = receta[1]
	var filtro: float = receta[2]
	var pulso: float = receta[3]
	var muestras: int = int(DURACION_AMBIENTE * FRECUENCIA_MUESTREO)
	var datos := PackedByteArray()
	datos.resize(muestras * 2)
	var ruido_filtrado: float = 0.0
	for i: int in muestras:
		var t: float = float(i) / FRECUENCIA_MUESTREO
		# Frecuencias que completan ciclos enteros en el bucle: sin saltos al repetir.
		var base: float = sin(TAU * roundf(tono * DURACION_AMBIENTE) / DURACION_AMBIENTE * t)
		var quinta: float = sin(TAU * roundf(tono * 1.5 * DURACION_AMBIENTE) / DURACION_AMBIENTE * t)
		var lento: float = 0.75 + 0.25 * sin(TAU * roundf(pulso * DURACION_AMBIENTE) / DURACION_AMBIENTE * t)
		ruido_filtrado = lerpf(ruido_filtrado, randf_range(-1.0, 1.0), filtro)
		var mezcla: float = (base * 0.6 + quinta * 0.25) * (1.0 - ruido) + ruido_filtrado * ruido * 2.0
		datos.encode_s16(i * 2, int(clampf(mezcla * lento * 0.5, -1.0, 1.0) * 32767.0))
	var wav: AudioStreamWAV = _crear_wav(datos, true)
	_cache[clave] = wav
	return wav


func _crear_wav(datos: PackedByteArray, en_bucle: bool) -> AudioStreamWAV:
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = FRECUENCIA_MUESTREO
	wav.stereo = false
	wav.data = datos
	if en_bucle:
		wav.loop_mode = AudioStreamWAV.LOOP_FORWARD
		wav.loop_begin = 0
		wav.loop_end = datos.size() / 2
	return wav
