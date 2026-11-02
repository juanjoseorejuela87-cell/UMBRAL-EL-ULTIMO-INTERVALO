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
	_comprobar(_sonido.musica_actual() == &"elyndor", "el ambiente de Elyndor pide su música de exploración")
	_sonido.ambiente(&"")
	await _esperar(2)
	_comprobar(not ambiente.playing, "el ambiente se puede detener")
	_comprobar(_sonido.musica_actual() == &"", "detener el ambiente (menús) también calla la música")

	# Volumen por bus
	_sonido.fijar_volumen(GestorSonido.BUS_EFECTOS, 0.5)
	var db: float = AudioServer.get_bus_volume_db(AudioServer.get_bus_index(GestorSonido.BUS_EFECTOS))
	_comprobar(absf(db - linear_to_db(0.5)) < 0.01, "se puede ajustar el volumen de cada bus")
	var copia: ConfigFile = ConfigFile.new()
	copia.load(_sonido.ruta_ajustes)
	_comprobar(absf(float(copia.get_value("sonido", "Efectos", -1.0)) - 0.5) < 0.001, "el volumen se guarda en los ajustes")
	_sonido.fijar_volumen(GestorSonido.BUS_EFECTOS, 0.2, false)
	_sonido.cargar_volumenes()
	_comprobar(absf(_sonido.volumen(GestorSonido.BUS_EFECTOS) - 0.5) < 0.01, "el volumen guardado se recupera al cargar")
	_sonido.fijar_volumen(GestorSonido.BUS_EFECTOS, 1.0)

	# Música sintetizada: se compone en segundo plano, en bucle y con fundidos
	var inicio: int = Time.get_ticks_msec()
	_sonido.musica(&"prefecto", 0.1)
	while not _sonido.musica_sonando() and Time.get_ticks_msec() - inicio < 40000:
		await process_frame
	print("  (música compuesta en %d ms)" % (Time.get_ticks_msec() - inicio))
	_comprobar(_sonido.musica_lista(&"prefecto") and _sonido.musica_sonando(), "la música del Prefecto se compone y empieza a sonar")
	var pista: AudioStreamWAV = _sonido._cache[&"musica_prefecto"] as AudioStreamWAV
	var esperado_musica: int = int(CompositorMusica.duracion(&"prefecto") * CompositorMusica.FRECUENCIA)
	_comprobar(pista.loop_mode == AudioStreamWAV.LOOP_FORWARD and absi(pista.data.size() / 2 - esperado_musica) <= 1 and _tiene_sonido(pista.data),
		"la música dura %.1f s y está en bucle" % CompositorMusica.duracion(&"prefecto"))
	_comprobar(_sonido._musica.bus == GestorSonido.BUS_MUSICA, "la música suena por el bus Música")
	var exploracion: AudioStreamWAV = CompositorMusica.componer(&"elyndor")
	_comprobar(exploracion.loop_mode == AudioStreamWAV.LOOP_FORWARD and _tiene_sonido(exploracion.data),
		"la música de exploración de Elyndor se compone en bucle (%.1f s)" % CompositorMusica.duracion(&"elyndor"))
	_sonido.musica(&"", 0.1)
	await _esperar(20)
	_comprobar(not _sonido.musica_sonando() and _sonido.musica_actual() == &"", "la música se apaga con un fundido")

	# Composiciones en segundo plano terminadas: con un hilo componiendo, la
	# física va a saltos y la prueba de controles sería poco fiable.
	var espera: int = Time.get_ticks_msec()
	while not _sonido._composiciones.is_empty() and Time.get_ticks_msec() - espera < 40000:
		await process_frame

	# Conexión con Nereth: saltar suena
	var sala: Node = (load(SALA) as PackedScene).instantiate()
	root.add_child(sala)
	await _esperar(30)
	# Con el equipo cargado puede tardar más en tocar suelo; sin suelo el salto
	# quedaría en el búfer y sonaría después de la comprobación.
	var jugador: Nereth = sala.find_children("*", "Nereth", true, false)[0] as Nereth
	for i: int in 300:
		if jugador.is_on_floor():
			break
		await physics_frame
	_olvidar(&"salto")
	await _pulsar(&"saltar")
	_comprobar(_lanzado(&"salto"), "al saltar suena el efecto de salto")
	await _esperar(40)
	_olvidar(&"esquiva")
	await _pulsar(&"esquivar")
	_comprobar(_lanzado(&"esquiva"), "al esquivar suena el efecto de esquiva")

	print("RESULTADO: %s (%d fallos)" % ["OK" if _fallos == 0 else "FALLO", _fallos])
	quit(_fallos)


func _tiene_sonido(datos: PackedByteArray) -> bool:
	for i: int in range(0, datos.size(), 64):
		if datos.decode_s16(i) != 0:
			return true
	return false


## Si el efecto se ha lanzado: algún reproductor lo tiene asignado. No se
## exige que siga sonando porque efectos de 0,08 s pueden acabar antes de la
## comprobación cuando el equipo va cargado.
func _lanzado(nombre: StringName) -> bool:
	var flujo: AudioStream = _sonido.obtener(nombre)
	for hijo: Node in _sonido.get_children():
		var reproductor: AudioStreamPlayer = hijo as AudioStreamPlayer
		if reproductor and reproductor.stream == flujo:
			return true
	return false


func _olvidar(nombre: StringName) -> void:
	var flujo: AudioStream = _sonido.obtener(nombre)
	for hijo: Node in _sonido.get_children():
		var reproductor: AudioStreamPlayer = hijo as AudioStreamPlayer
		if reproductor and reproductor.stream == flujo:
			reproductor.stop()
			reproductor.stream = null


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
