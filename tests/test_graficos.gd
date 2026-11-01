extends SceneTree
## Prueba automática de la calidad gráfica escalable (hito 12, D-017):
## preajustes, guardado, luces de la sala y efectos de la atmósfera.
## Uso: Godot_console.exe --headless --path D:\UMBRAL -s res://tests/test_graficos.gd
## Código de salida = número de comprobaciones fallidas.

const SALA: String = "res://scenes/niveles/elyndor/camara_despertar.tscn"

var _graficos: ConfiguracionGrafica
var _fallos: int = 0


func _initialize() -> void:
	ConfigControles.registrar()
	_graficos = ConfiguracionGrafica.global()
	_ejecutar.call_deferred()


func _ejecutar() -> void:
	await _esperar(2)
	_comprobar(_graficos != null, "existe el autoload de gráficos")
	_comprobar(not _graficos.reinicio_permitido, "sin pantalla nunca se reinicia el juego")
	_comprobar(_graficos.ruta_ajustes != "user://ajustes.cfg", "las pruebas no tocan los ajustes reales")

	# Grupos de renderizador
	_comprobar(_graficos.metodo_deseado(ConfiguracionGrafica.Preajuste.BAJO) == "gl_compatibility"
		and _graficos.metodo_deseado(ConfiguracionGrafica.Preajuste.MEDIO) == "gl_compatibility",
		"BAJO y MEDIO usan Compatibility")
	_comprobar(_graficos.metodo_deseado(ConfiguracionGrafica.Preajuste.ALTO) == "forward_plus"
		and _graficos.metodo_deseado(ConfiguracionGrafica.Preajuste.ULTRA) == "forward_plus",
		"ALTO y ULTRA usan Forward+")
	_comprobar(ConfiguracionGrafica.AJUSTES.size() == ConfiguracionGrafica.NOMBRES.size(), "hay ajustes para cada preajuste")
	var en_completo: bool = RenderingServer.get_current_rendering_method() == ConfiguracionGrafica.METODO_COMPLETO
	_comprobar(_graficos.requiere_reinicio(ConfiguracionGrafica.Preajuste.ULTRA) != en_completo
		and _graficos.requiere_reinicio(ConfiguracionGrafica.Preajuste.BAJO) == en_completo,
		"solo pide reinicio el preajuste del otro renderizador")

	change_scene_to_file(SALA)
	await _esperar_escena(SALA)
	var atmosfera: AtmosferaFase = current_scene.find_children("*", "AtmosferaFase", true, false)[0] as AtmosferaFase
	# Luces que en la escena tienen sombra (la calidad actual puede habérsela quitado).
	var luces: Array[Light3D] = []
	for nodo: Node in current_scene.find_children("*", "Light3D", true, false):
		var luz: Light3D = nodo as Light3D
		if luz.has_meta(&"sombra_original") and bool(luz.get_meta(&"sombra_original")):
			luces.append(luz)
	_comprobar(not luces.is_empty(), "la sala tiene luces puntuales con sombra (%d)" % luces.size())

	# BAJO: sin sombras puntuales, sin brillo, resolución reducida
	var senal: Array[int] = []
	_graficos.calidad_cambiada.connect(func(p: ConfiguracionGrafica.Preajuste) -> void: senal.append(p))
	_graficos.cambiar(ConfiguracionGrafica.Preajuste.BAJO)
	await _esperar(2)
	_comprobar(senal.has(ConfiguracionGrafica.Preajuste.BAJO), "cambiar la calidad emite la señal")
	_comprobar(root.scaling_3d_scale < 1.0 and root.msaa_3d == Viewport.MSAA_DISABLED, "BAJO reduce la resolución interna y quita el antialiasing")
	_comprobar(not atmosfera.environment.glow_enabled and not atmosfera.environment.ssao_enabled, "BAJO apaga el brillo y la oclusión")
	var sin_sombras: bool = true
	for luz: Light3D in luces:
		sin_sombras = sin_sombras and not luz.shadow_enabled
	_comprobar(sin_sombras, "BAJO quita las sombras de las luces puntuales")

	# ULTRA: todo encendido; las sombras originales vuelven
	_graficos.cambiar(ConfiguracionGrafica.Preajuste.ULTRA)
	await _esperar(2)
	_comprobar(root.scaling_3d_scale == 1.0 and root.msaa_3d == Viewport.MSAA_4X, "ULTRA usa resolución completa y MSAA 4x")
	var env: Environment = atmosfera.environment
	var extras: Array[bool] = [env.ssao_enabled, env.ssil_enabled, env.sdfgi_enabled, env.volumetric_fog_enabled]
	if RenderingServer.get_current_rendering_method() == ConfiguracionGrafica.METODO_COMPLETO:
		_comprobar(env.glow_enabled and not extras.has(false), "ULTRA enciende brillo, SSAO, SSIL, SDFGI y niebla volumétrica")
	else:
		_comprobar(env.glow_enabled and not extras.has(true), "ULTRA sin Forward+ todavía: brillo sí, efectos de Forward+ en espera")
	var con_sombras: bool = true
	for luz: Light3D in luces:
		con_sombras = con_sombras and luz.shadow_enabled
	_comprobar(con_sombras, "las luces recuperan sus sombras al subir la calidad")
	_comprobar(current_scene != null and current_scene.scene_file_path == SALA, "cambiar de renderizador sin pantalla no cierra el juego")

	# Las luces de una sala nueva se adaptan al entrar
	_graficos.cambiar(ConfiguracionGrafica.Preajuste.BAJO)
	var nueva: OmniLight3D = OmniLight3D.new()
	nueva.shadow_enabled = true
	current_scene.add_child(nueva)
	await _esperar(2)
	_comprobar(not nueva.shadow_enabled, "una luz que entra después también respeta la calidad")

	# Guardado
	_graficos.cambiar(ConfiguracionGrafica.Preajuste.ALTO)
	var copia: ConfiguracionGrafica = ConfiguracionGrafica.new()
	copia.ruta_ajustes = _graficos.ruta_ajustes
	_comprobar(copia.cargar() and copia.preajuste == ConfiguracionGrafica.Preajuste.ALTO, "la calidad se guarda y se recupera")
	copia.free()
	ConfiguracionGrafica._instancia = _graficos
	var detectado: ConfiguracionGrafica.Preajuste = _graficos.detectar_preajuste()
	_comprobar(ConfiguracionGrafica.NOMBRES.size() > detectado, "la detección automática devuelve un preajuste válido (%s)" % ConfiguracionGrafica.NOMBRES[detectado])

	_graficos.cambiar(ConfiguracionGrafica.Preajuste.MEDIO)
	DirAccess.remove_absolute(ProjectSettings.globalize_path(_graficos.ruta_ajustes))
	print("Fallos: %d" % _fallos)
	quit(_fallos)


func _esperar(frames: int) -> void:
	for i: int in frames:
		await physics_frame


func _esperar_escena(ruta: String) -> void:
	for i: int in 60:
		await physics_frame
		if current_scene and current_scene.scene_file_path == ruta:
			await physics_frame
			return


func _comprobar(condicion: bool, descripcion: String) -> void:
	print(("  [OK]    " if condicion else "  [FALLO] ") + descripcion)
	if not condicion:
		_fallos += 1
