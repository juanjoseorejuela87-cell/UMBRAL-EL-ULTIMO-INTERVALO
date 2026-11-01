extends SceneTree
## Prueba automática del audio base: buses, efectos sintetizados, ambiente en
## bucle y conexión con las acciones de Nereth.
## Uso: Godot_console.exe --headless --path D:\UMBRAL -s res://tests/test_sonido.gd
## Código de salida = número de comprobaciones fallidas.

const SALA: String = "res://scenes/niveles/pruebas/sala_combate.tscn"

var _sonido: GestorSonido
var _fallos: int = 0


func _initialize() -> void:
	ConfigControles.registrar()
	_sonido = GestorSonido.global()
	_ejecutar.call_deferred()


func _ejecutar() -> void:
	await _esperar(2)

	# Buses
	for bus: StringName in [GestorSonido.BUS_MUSICA, GestorSonido.BUS_EFECTOS, GestorSonido.BUS_AMBIENTE]:
		_comprobar(AudioServer.get_bus_index(bus) >= 0, "existe el bus «%s»" % bus)

	# Todos los efectos se sintetizan con la duración esperada
	var correctos: int = 0
	for nombre: StringName in GestorSonido.RECETAS:
		var wav: AudioStreamWAV = _sonido.obtener(nombre) as AudioStreamWAV
		var esperado: int = int(float(GestorSonido.RECETAS[nombre][0]) * GestorSonido.FRECUENCIA_MUESTREO) * 2
		if wav and wav.data.size() == esperado and _tiene_sonido(wav.data):
			correctos += 1
	_comprobar(correctos == GestorSonido.RECETAS.size(), "se sintetizan los %d efectos (%d correctos)" % [GestorSonido.RECETAS.size(), correctos])
	_comprobar(_sonido.obtener(&"golpe") == _sonido.obtener(&"golpe"), "los efectos se generan una sola vez (caché)")
	_comprobar(_sonido.obtener(&"no_existe") == null, "un efecto desconocido no rompe nada")

	# Reproducción
	var reproductor: AudioStreamPlayer = _sonido.reproducir(&"golpe")
	_comprobar(reproductor != null and reproductor.playing and reproductor.bus == GestorSonido.BUS_EFECTOS, "reproducir suena por el bus de efectos")
	var otro: AudioStreamPlayer = _sonido.reproducir(&"parry")
	_comprobar(otro != reproductor, "varios efectos a la vez usan reproductores distintos")

	# Ambiente en bucle
	_sonido.ambiente(&"elyndor")
	await _esperar(2)
	var ambiente: AudioStreamPlayer = _buscar_ambiente()
	var wav_ambiente: AudioStreamWAV = ambiente.stream as AudioStreamWAV if ambiente else null
	_comprobar(_sonido.ambiente_actual() == &"elyndor" and ambiente != null and ambiente.playing, "el ambiente de Elyndor suena")
	_comprobar(wav_ambiente != null and wav_ambiente.loop_mode == AudioStreamWAV.LOOP_FORWARD, "el ambiente está en bucle")
	_sonido.ambiente(&"")
	await _esperar(2)
	_comprobar(not ambiente.playing, "el ambiente se puede detener")

	# Volumen por bus
	_sonido.fijar_volumen(GestorSonido.BUS_EFECTOS, 0.5)
	var db: float = AudioServer.get_bus_volume_db(AudioServer.get_bus_index(GestorSonido.BUS_EFECTOS))
	_comprobar(absf(db - linear_to_db(0.5)) < 0.01, "se puede ajustar el volumen de cada bus")
	_sonido.fijar_volumen(GestorSonido.BUS_EFECTOS, 1.0)

	# Conexión con Nereth: saltar suena
	var sala: Node = (load(SALA) as PackedScene).instantiate()
	root.add_child(sala)
	await _esperar(30)
	await _pulsar(&"saltar")
	_comprobar(_sonando(&"salto"), "al saltar suena el efecto de salto")
	await _esperar(40)
	await _pulsar(&"esquivar")
	_comprobar(_sonando(&"esquiva"), "al esquivar suena el efecto de esquiva")

	print("RESULTADO: %s (%d fallos)" % ["OK" if _fallos == 0 else "FALLO", _fallos])
	quit(_fallos)


func _tiene_sonido(datos: PackedByteArray) -> bool:
	for i: int in range(0, datos.size(), 64):
		if datos.decode_s16(i) != 0:
			return true
	return false


func _sonando(nombre: StringName) -> bool:
	var flujo: AudioStream = _sonido.obtener(nombre)
	for hijo: Node in _sonido.get_children():
		var reproductor: AudioStreamPlayer = hijo as AudioStreamPlayer
		if reproductor and reproductor.stream == flujo and reproductor.playing:
			return true
	return false


func _buscar_ambiente() -> AudioStreamPlayer:
	for hijo: Node in _sonido.get_children():
		var reproductor: AudioStreamPlayer = hijo as AudioStreamPlayer
		if reproductor and reproductor.bus == GestorSonido.BUS_AMBIENTE:
			return reproductor
	return null


## Mantiene la acción varios fotogramas de proceso y de física: con carga
## puede haber varios pasos de física por fotograma y una pulsación más corta
## no llegaría a verse como «recién pulsada».
func _pulsar(accion: StringName) -> void:
	Input.action_press(accion)
	for i: int in 3:
		await process_frame
	await _esperar(2)
	Input.action_release(accion)


func _esperar(frames: int) -> void:
	for i: int in frames:
		await physics_frame


func _comprobar(condicion: bool, descripcion: String) -> void:
	print(("  [OK]    " if condicion else "  [FALLO] ") + descripcion)
	if not condicion:
		_fallos += 1
