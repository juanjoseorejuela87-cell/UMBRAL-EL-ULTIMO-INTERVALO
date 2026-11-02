extends SceneTree
## Prueba automática de la pantalla de título 3D y fin de la demo (TAREA-013).
## Uso: Godot_console.exe --headless --path D:\UMBRAL -s res://tests/test_titulo.gd
## Código de salida = número de comprobaciones fallidas.

const TITULO: String = "res://scenes/ui/titulo/titulo.tscn"
const CAMARA: String = "res://scenes/niveles/elyndor/camara_despertar.tscn"
const FIN: String = "res://scenes/ui/fin_demo/fin_demo.tscn"
const VIGIA: String = "res://scenes/enemigos/vigia_hueco/vigia_hueco.tscn"

var _partida: GestorPartida
var _fallos: int = 0


func _initialize() -> void:
	ConfigControles.registrar()
	_partida = GestorPartida.global()
	_partida.ruta_guardado = "user://prueba_titulo.json"
	_partida.nueva_partida()
	GestorSalas.global().duracion_fundido = 0.0
	_ejecutar.call_deferred()


func _ejecutar() -> void:
	# 1. Carga del título y fondo 3D
	change_scene_to_file(TITULO)
	await _llegar_a(TITULO)
	var titulo: PantallaTitulo = current_scene as PantallaTitulo
	_comprobar(titulo != null, "la pantalla de título carga con éxito")
	var fondo: FondoTitulo = titulo.get_node_or_null("FondoTitulo") as FondoTitulo
	_comprobar(fondo != null, "el título incluye la escena de fondo 3D FondoTitulo")
	_comprobar(fondo != null and fondo.tiene_camara_activa(), "el fondo 3D tiene una Camera3D activa")
	_comprobar(fondo != null and fondo.tiene_figura_nereth(), "el estrado 3D incluye la figura de Nereth")
	_comprobar(fondo != null and fondo.figura_nereth.position.x > 1.5,
		"la figura de Nereth está desplazada a un tercio lateral (x = %.1f > 1.5) dejando libre el menú" % (fondo.figura_nereth.position.x if fondo and fondo.figura_nereth else 0.0))
	_comprobar(fondo != null and fondo.camara.position.z >= 6.0,
		"la cámara está suficientemente alejada (z = %.1f >= 6.0) para mostrar el estrado entero y la arquitectura" % (fondo.camara.position.z if fondo and fondo.camara else 0.0))
	_comprobar(fondo != null and fondo.simbolo_dais != null, "el estrado cuenta con el símbolo de los Arquitectos")
	_comprobar(fondo != null and fondo.columnas_fantasma != null and fondo.columnas_fantasma.get_child_count() >= 2,
		"existen columnas fantasma preparadas para el pulso de Desfase")

	# 2. Comprobación del pulso de Desfase
	var fase_inicial: bool = GestorFase.global().en_desfase()
	_comprobar(not fase_inicial, "GestorFase empieza en Realidad")
	fondo.lanzar_pulso_desfase()
	_comprobar(fondo.esta_en_pulso(), "el pulso de Desfase visual se activa")
	await _esperar(5)
	_comprobar(GestorFase.global().en_desfase() == false, "el pulso visual de Desfase NO cambia el estado global de Fase")

	# 3. Estilo de interfaz y botones del título
	var aura: Node = titulo.get_node_or_null("AuraLegibilidad")
	_comprobar(aura != null and aura is TextureRect, "existe un degradado/aura suave detrás del menú para legibilidad")
	_comprobar(titulo.boton_continuar != null and titulo.boton_continuar.disabled, "sin partida guardada, «Continuar» está desactivado")
	var color_desactivado: Color = titulo.boton_continuar.get_theme_color("font_disabled_color")
	_comprobar(color_desactivado.v >= 0.65 and color_desactivado.a >= 0.45,
		"«Continuar» desactivado tiene tono claro apagado y legible (v = %.2f, a = %.2f)" % [color_desactivado.v, color_desactivado.a])
	_comprobar(titulo.boton_nueva != null and not titulo.boton_nueva.disabled, "«Nueva partida» está activo")
	_comprobar(titulo.boton_opciones != null and not titulo.boton_opciones.disabled, "«Opciones» está activo")
	_comprobar(titulo.boton_salir != null and not titulo.boton_salir.disabled, "«Salir» está activo")
	var idx_nueva: int = titulo.boton_nueva.get_index()
	var idx_opciones: int = titulo.boton_opciones.get_index()
	var idx_salir: int = titulo.boton_salir.get_index()
	_comprobar(idx_opciones == idx_nueva + 1 and idx_salir == idx_opciones + 1,
		"el botón Opciones está colocado entre Nueva partida y Salir")

	var estilo_normal: StyleBox = titulo.boton_nueva.get_theme_stylebox("normal")
	_comprobar(estilo_normal is StyleBoxEmpty, "los botones del título no tienen fondo gris por defecto (StyleBoxEmpty)")
	var estilo_foco: StyleBox = titulo.boton_nueva.get_theme_stylebox("focus")
	_comprobar(estilo_foco is StyleBoxFlat and (estilo_foco as StyleBoxFlat).border_width_bottom > 0,
		"los botones tienen subrayado/borde inferior dorado en foco")
	if estilo_foco is StyleBoxFlat:
		_comprobar((estilo_foco as StyleBoxFlat).expand_margin_left <= 8.0,
			"el botón enfocado tiene márgenes compactos ajustados al texto (<= 8 px)")

	# 4. Submenú de Opciones y Panel de Ajustes
	titulo.mostrar_menu_opciones()
	await _esperar(2)
	_comprobar(titulo.menu_opciones.visible and not titulo.menu_principal.visible,
		"abrir Opciones muestra el submenú y oculta el menú principal")

	titulo.mostrar_sonido()
	await _esperar(2)
	_comprobar(titulo.panel_ajustes.visible and titulo.panel_ajustes.panel_sonido.visible and not titulo.menu_opciones.visible,
		"abrir Sonido muestra el panel de sonido")

	titulo.panel_ajustes.deslizador_musica.value = 0.55
	await _esperar(2)
	var vol_m: float = GestorSonido.global().volumen(GestorSonido.BUS_MUSICA)
	_comprobar(absf(vol_m - 0.55) < 0.02,
		"mover el deslizador cambia el volumen del bus (GestorSonido.volumen = %.2f)" % vol_m)

	titulo.panel_ajustes.boton_volver_sonido.pressed.emit()
	await _esperar(2)
	_comprobar(titulo.menu_opciones.visible and not titulo.panel_ajustes.visible,
		"Volver desde Sonido regresa al submenú de opciones")

	titulo.mostrar_graficos()
	await _esperar(2)
	_comprobar(titulo.panel_ajustes.visible and titulo.panel_ajustes.panel_graficos.visible and not titulo.menu_opciones.visible,
		"abrir Gráficos muestra el panel de gráficos")

	titulo.panel_ajustes.boton_volver_graficos.pressed.emit()
	await _esperar(2)
	_comprobar(titulo.menu_opciones.visible and not titulo.panel_ajustes.visible,
		"Volver desde Gráficos regresa al submenú de opciones")

	titulo.mostrar_menu_principal()
	await _esperar(2)
	_comprobar(titulo.menu_principal.visible and not titulo.menu_opciones.visible,
		"Volver desde el submenú regresa al menú principal del título")

	# Restaurar volumen
	GestorSonido.global().fijar_volumen(GestorSonido.BUS_MUSICA, 1.0)

	# 5. Navegación a Nueva Partida
	titulo.nueva_partida()
	_comprobar(await _llegar_a(CAMARA), "«Nueva partida» navega correctamente a la Cámara del Despertar")

	# 5. Pantalla de Fin de Demo
	change_scene_to_file(FIN)
	await _llegar_a(FIN)
	var fin: PantallaFinDemo = current_scene as PantallaFinDemo
	_comprobar(fin != null, "la pantalla de fin de demo carga correctamente")
	var label_texto: Label = fin.get_node_or_null("Centro/Texto") as Label
	_comprobar(label_texto != null and label_texto.text.contains("No recuperes los fragmentos sin comprender lo que estás devolviendo"),
		"el fin de la demo conserva la frase oficial de Maelis")
	var fondo_amanecer: Node = fin.get_node_or_null("FondoAmanecer")
	_comprobar(fondo_amanecer is TextureRect, "el fin de la demo tiene un fondo de amanecer con degradado")
	var siluetas: Node = fin.get_node_or_null("SiluetasTorres")
	_comprobar(siluetas != null and siluetas.get_child_count() > 0, "el fin de la demo incluye siluetas de torres en el horizonte")
	var boton_volver: Button = fin.boton_titulo
	_comprobar(boton_volver != null and boton_volver.get_theme_stylebox("normal") is StyleBoxEmpty,
		"el botón de fin de demo comparte el nuevo estilo sin fondo gris")

	# 6. Retoque de contraste del Vigía Hueco
	var escena_vigia: PackedScene = load(VIGIA) as PackedScene
	_comprobar(escena_vigia != null, "la escena del Vigía Hueco carga")
	var inst_vigia: Node = escena_vigia.instantiate()
	root.add_child(inst_vigia)
	await _esperar(2)
	var cuerpo: MeshInstance3D = inst_vigia.get_node_or_null("Visual/Cuerpo") as MeshInstance3D
	_comprobar(cuerpo != null, "el Vigía conserva Visual/Cuerpo")
	var mat_cuerpo: StandardMaterial3D = cuerpo.get_active_material(0) as StandardMaterial3D
	_comprobar(mat_cuerpo != null, "el material activo del cuerpo existe")
	if mat_cuerpo:
		_comprobar(mat_cuerpo.rim_enabled, "el material del cuerpo del Vigía tiene rim lighting activado para contraste")
		_comprobar(mat_cuerpo.albedo_color.v > 0.45, "el albedo del cuerpo del Vigía es más claro para recortarse contra fondos oscuros")
	inst_vigia.queue_free()

	print("RESULTADO: %s (%d fallos)" % ["OK" if _fallos == 0 else "FALLO", _fallos])
	quit(_fallos)


func _llegar_a(escena: String) -> bool:
	for i: int in 180:
		if _escena() == escena and not GestorSalas.global().cambiando():
			return true
		await physics_frame
	return false


func _escena() -> String:
	return current_scene.scene_file_path if current_scene else ""


func _esperar(frames: int) -> void:
	for i: int in frames:
		await physics_frame


func _comprobar(condicion: bool, descripcion: String) -> void:
	if condicion:
		print("  [OK]    %s" % descripcion)
	else:
		_fallos += 1
		print("  [FALLO] %s" % descripcion)
