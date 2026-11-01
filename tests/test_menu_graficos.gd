extends SceneTree
## Prueba automática de la sección «Gráficos» en el menú de pausa (TAREA-011).
## Uso: Godot_console.exe --headless --path D:\UMBRAL -s res://tests/test_menu_graficos.gd
## Código de salida = número de comprobaciones fallidas.

const ESCENA_PAUSA: String = "res://scenes/ui/pausa/menu_pausa.tscn"

var _graficos: ConfiguracionGrafica
var _fallos: int = 0
var _menu: MenuPausa


func _initialize() -> void:
	ConfigControles.registrar()
	MenuPausa.asegurar_accion_pausa()
	_graficos = ConfiguracionGrafica.global()
	var escena: PackedScene = load(ESCENA_PAUSA) as PackedScene
	_menu = escena.instantiate() as MenuPausa
	root.add_child(_menu)
	_ejecutar.call_deferred()


func _ejecutar() -> void:
	await _esperar(3)

	_comprobar(_graficos != null, "existe el autoload de gráficos")
	_comprobar(_menu != null, "la escena de pausa se instancia correctamente")

	# 1. Botón Gráficos existe entre Sonido y Volver al título
	_comprobar(_menu.boton_graficos != null, "el botón Gráficos existe")
	var idx_sonido: int = _menu.boton_sonido.get_index()
	var idx_graficos: int = _menu.boton_graficos.get_index()
	var idx_titulo: int = _menu.boton_volver_titulo.get_index()
	_comprobar(idx_graficos == idx_sonido + 1 and idx_titulo == idx_graficos + 1,
		"el botón Gráficos está colocado entre Sonido y Volver al título")

	# 2. Abrir la sección de gráficos
	_menu.abrir()
	await _esperar(2)
	_menu.mostrar_graficos()
	await _esperar(2)
	_comprobar(_menu.panel_graficos.visible and not _menu.menu_opciones.visible,
		"la sección Gráficos es visible y el menú principal se oculta")

	# 3. El selector de calidad tiene los cuatro nombres y muestra el preajuste actual
	_comprobar(_menu.selector_calidad != null, "el selector de calidad existe")
	_comprobar(_menu.selector_calidad.item_count == ConfiguracionGrafica.NOMBRES.size(),
		"el selector tiene los 4 preajustes")
	for i: int in ConfiguracionGrafica.NOMBRES.size():
		_comprobar(_menu.selector_calidad.get_item_text(i) == ConfiguracionGrafica.NOMBRES[i],
			"el preajuste %d es «%s»" % [i, ConfiguracionGrafica.NOMBRES[i]])

	var preajuste_inicial: ConfiguracionGrafica.Preajuste = _graficos.preajuste
	_comprobar(_menu.selector_calidad.selected == preajuste_inicial as int,
		"el selector muestra el preajuste actual (%s)" % ConfiguracionGrafica.NOMBRES[preajuste_inicial])

	_comprobar(_menu.texto_descripcion_calidad != null and not _menu.texto_descripcion_calidad.text.is_empty(),
		"muestra la descripción del preajuste enfocado")

	# 4. Cambiar entre preajustes del mismo renderizador (BAJO <-> MEDIO)
	# Ambos usan gl_compatibility en headless, no requieren reinicio.
	var otro_mismo_render: ConfiguracionGrafica.Preajuste = (
		ConfiguracionGrafica.Preajuste.BAJO
		if preajuste_inicial != ConfiguracionGrafica.Preajuste.BAJO
		else ConfiguracionGrafica.Preajuste.MEDIO
	)
	_comprobar(not _graficos.requiere_reinicio(otro_mismo_render),
		"el cambio a %s no requiere reinicio" % ConfiguracionGrafica.NOMBRES[otro_mismo_render])

	_menu.seleccionar_preajuste(otro_mismo_render)
	await _esperar(2)
	_comprobar(not _menu.panel_confirmacion_reinicio.visible,
		"no se pide confirmación si no requiere reinicio")
	_comprobar(_graficos.preajuste == otro_mismo_render,
		"elegir preajuste dentro del mismo renderizador cambia la calidad directamente a %s" % ConfiguracionGrafica.NOMBRES[otro_mismo_render])
	_comprobar(_menu.selector_calidad.selected == otro_mismo_render as int,
		"el selector refleja el nuevo preajuste")

	# 5. Elegir preajuste que requiere reinicio (ALTO o ULTRA)
	var preajuste_con_reinicio: ConfiguracionGrafica.Preajuste = ConfiguracionGrafica.Preajuste.ALTO
	_comprobar(_graficos.requiere_reinicio(preajuste_con_reinicio),
		"el cambio a ALTO requiere reinicio")

	var preajuste_antes_de_intento: ConfiguracionGrafica.Preajuste = _graficos.preajuste
	_menu.seleccionar_preajuste(preajuste_con_reinicio)
	await _esperar(2)

	_comprobar(_menu.panel_confirmacion_reinicio.visible,
		"elegir preajuste que pide reinicio muestra la confirmación en el panel")
	_comprobar(_menu.texto_aviso_reinicio.text.contains("reiniciará") and _menu.texto_aviso_reinicio.text.contains("Ancla"),
		"el texto de aviso menciona reinicio y pérdida desde la última Ancla")

	# 6. Cancelar la confirmación
	_menu.cancelar_reinicio()
	await _esperar(2)
	_comprobar(not _menu.panel_confirmacion_reinicio.visible,
		"«Cancelar» oculta el panel de confirmación")
	_comprobar(_graficos.preajuste == preajuste_antes_de_intento,
		"«Cancelar» NO cambia el preajuste en el núcleo")
	_comprobar(_menu.selector_calidad.selected == preajuste_antes_de_intento as int,
		"«Cancelar» devuelve el selector al preajuste actual")

	# 7. Confirmar reinicio
	_menu.seleccionar_preajuste(preajuste_con_reinicio)
	await _esperar(2)
	_comprobar(_menu.panel_confirmacion_reinicio.visible,
		"vuelve a mostrar la confirmación al elegir ALTO")

	_menu.confirmar_reinicio()
	await _esperar(2)
	_comprobar(not _menu.panel_confirmacion_reinicio.visible,
		"«Reiniciar» oculta la confirmación")
	_comprobar(_graficos.preajuste == preajuste_con_reinicio,
		"«Reiniciar» cambia el preajuste a ALTO")
	_comprobar(not _graficos.reinicio_permitido,
		"en modo headless no se fuerza la salida del proceso")

	# 8. Volver al menú principal
	_menu.mostrar_menu_principal()
	await _esperar(2)
	_comprobar(_menu.menu_opciones.visible and not _menu.panel_graficos.visible,
		"«Volver» regresa al menú principal de pausa")

	# Restaurar preajuste original y limpiar
	_graficos.cambiar(preajuste_inicial)
	_menu.cerrar()
	_menu.queue_free()

	print("RESULTADO: %s (%d fallos)" % ["OK" if _fallos == 0 else "FALLO", _fallos])
	quit(_fallos)


func _esperar(frames: int) -> void:
	for i: int in frames:
		await process_frame


func _comprobar(condicion: bool, descripcion: String) -> void:
	print(("  [OK]    " if condicion else "  [FALLO] ") + descripcion)
	if not condicion:
		_fallos += 1
