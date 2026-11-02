extends SceneTree
## Herramienta de medición de rendimiento en hardware real para UMBRAL.
## Uso:
##   Godot_console.exe --path D:\UMBRAL -s res://tools/medir_rendimiento.gd

const PUNTOS_MEDICION: Array[Dictionary] = [
	{
		"nombre": "Pantalla de Título",
		"escena": "res://scenes/ui/titulo/titulo.tscn",
		"posiciones": [0.0],
		"es_nivel": false
	},
	{
		"nombre": "Cámara del Despertar",
		"escena": "res://scenes/niveles/elyndor/camara_despertar.tscn",
		"posiciones": [-2.5, 6.0],
		"es_nivel": true
	},
	{
		"nombre": "Ruinas bajo Elyndor (Barrio)",
		"escena": "res://scenes/niveles/elyndor/barrio_desprendido.tscn",
		"posiciones": [-16.0, 35.0, 75.0, 100.0],
		"es_nivel": true
	},
	{
		"nombre": "Salón del Prefecto",
		"escena": "res://scenes/niveles/elyndor/salon_prefecto.tscn",
		"posiciones": [-19.0, 0.0, 19.0],
		"es_nivel": true
	}
]

var _graficos: ConfiguracionGrafica
var _fase: GestorFase
var _resultados: Array[Dictionary] = []


func _initialize() -> void:
	ConfigControles.registrar()
	_graficos = ConfiguracionGrafica.global()
	_fase = GestorFase.global()

	if _graficos:
		_graficos.reinicio_permitido = false

	_ejecutar.call_deferred()


func _ejecutar() -> void:
	await _esperar_frames(2)
	if _graficos:
		_graficos.cambiar(ConfiguracionGrafica.Preajuste.BAJO)
	print("\n" + "=".repeat(60))
	print("   UMBRAL: Medición de Rendimiento (Preajuste: %s)" % [
		ConfiguracionGrafica.NOMBRES[_graficos.preajuste] if _graficos else "Desconocido"
	])
	print("   Dispositivo: %s | Renderizador: %s" % [
		RenderingServer.get_video_adapter_name(),
		RenderingServer.get_current_rendering_method()
	])
	print("=".repeat(60) + "\n")

	for item: Dictionary in PUNTOS_MEDICION:
		var ruta_escena: String = item["escena"]
		var nombre_sala: String = item["nombre"]
		var es_nivel: bool = item["es_nivel"]
		var posiciones: Array = item["posiciones"]

		change_scene_to_file(ruta_escena)
		await _esperar_escena(ruta_escena)

		# Desactivar IA de enemigos si los hay para mediciones estables
		if current_scene:
			for enemigo: Node in current_scene.find_children("*", "Enemigo", true, false):
				enemigo.set("ia_activa", false)

		for pos_x: float in posiciones:
			if es_nivel:
				var nereth: Nereth = _obtener_nereth()
				if nereth:
					nereth.reaparecer(Vector3(pos_x, 1.0, 0.0))
					var cam: Node = current_scene.find_child("CamaraLateral", true, false)
					if cam == null:
						cam = current_scene.find_child("Camara", true, false)
					if cam and cam.has_method(&"saltar_a_objetivo"):
						cam.call(&"saltar_a_objetivo")

			# Medir en Realidad
			if _fase:
				_fase.cambiar(GestorFase.Estado.REALIDAD)
			await _esperar_frames(30)
			var met_realidad: Dictionary = await _medir_intervalo(3.0)
			_guardar_resultado(nombre_sala, pos_x, "Realidad", met_realidad)
			print("  [OK] %s (x=%.1f) Realidad: %.1f FPS (min %.1f, %d draw calls)" % [
				nombre_sala, pos_x, met_realidad["fps_medio"], met_realidad["fps_min"], met_realidad["draw_calls"]
			])

			# Medir en Desfase si es sala de nivel
			if es_nivel and _fase:
				_fase.cambiar(GestorFase.Estado.DESFASE)
				await _esperar_frames(30)
				var met_desfase: Dictionary = await _medir_intervalo(3.0)
				_guardar_resultado(nombre_sala, pos_x, "Desfase", met_desfase)
				print("  [OK] %s (x=%.1f) Desfase:  %.1f FPS (min %.1f, %d draw calls)" % [
					nombre_sala, pos_x, met_desfase["fps_medio"], met_desfase["fps_min"], met_desfase["draw_calls"]
				])

	_imprimir_tabla()
	quit(0)


func _obtener_nereth() -> Nereth:
	if current_scene == null:
		return null
	var n: Node = current_scene.get_node_or_null("Nereth")
	if n is Nereth:
		return n as Nereth
	return get_first_node_in_group(&"jugador") as Nereth


func _esperar_escena(ruta: String) -> void:
	for i: int in 60:
		await process_frame
		if current_scene and current_scene.scene_file_path == ruta:
			await _esperar_frames(10)
			return


func _esperar_frames(n: int) -> void:
	for i: int in n:
		await process_frame


func _medir_intervalo(duracion_seg: float) -> Dictionary:
	var inicio_msec: float = Time.get_ticks_msec()
	var frames: int = 0
	var fps_min: float = 9999.0
	var total_draw_calls: int = 0
	var total_primitivas: int = 0
	var muestras_info: int = 0
	var ultimo_usec: int = Time.get_ticks_usec()

	while (Time.get_ticks_msec() - inicio_msec) / 1000.0 < duracion_seg:
		await process_frame
		frames += 1
		var ahora_usec: int = Time.get_ticks_usec()
		var dt_usec: int = ahora_usec - ultimo_usec
		ultimo_usec = ahora_usec
		if dt_usec > 0:
			var fps_inst: float = 1000000.0 / float(dt_usec)
			if fps_inst < fps_min:
				fps_min = fps_inst

		var dc: int = RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME)
		var prim: int = RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_PRIMITIVES_IN_FRAME)
		total_draw_calls += dc
		total_primitivas += prim
		muestras_info += 1

	var tiempo_real_seg: float = (Time.get_ticks_msec() - inicio_msec) / 1000.0
	var fps_medio: float = float(frames) / tiempo_real_seg if tiempo_real_seg > 0.0 else 0.0
	var media_dc: int = int(round(float(total_draw_calls) / float(muestras_info))) if muestras_info > 0 else 0
	var media_prim: int = int(round(float(total_primitivas) / float(muestras_info))) if muestras_info > 0 else 0

	return {
		"fps_medio": fps_medio,
		"fps_min": fps_min if fps_min < 9999.0 else fps_medio,
		"draw_calls": media_dc,
		"primitivas": media_prim
	}


func _guardar_resultado(sala: String, x: float, estado: String, datos: Dictionary) -> void:
	_resultados.append({
		"sala": sala,
		"x": x,
		"estado": estado,
		"fps_medio": datos["fps_medio"],
		"fps_min": datos["fps_min"],
		"draw_calls": datos["draw_calls"],
		"primitivas": datos["primitivas"]
	})


func _imprimir_tabla() -> void:
	print("\n| Sala | Posición (x) | Fase | FPS Medio | FPS Mín | Draw Calls | Primitivas |")
	print("|---|---|---|---|---|---|---|")
	for r: Dictionary in _resultados:
		var pos_str: String = "N/A" if r["sala"].begins_with("Pantalla") else ("x = %.1f" % r["x"])
		print("| %s | %s | %s | **%.1f** | %.1f | %d | %d |" % [
			r["sala"],
			pos_str,
			r["estado"],
			r["fps_medio"],
			r["fps_min"],
			r["draw_calls"],
			r["primitivas"]
		])
	print("\n")
