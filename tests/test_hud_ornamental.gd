extends SceneTree
## Prueba automática del HUD rediseñado (Fase 1 de la directiva de Hermes).
## Comprueba:
## 1. BarraOrnamental: la barra rezagada ámbar se queda atrás al recibir daño y
##    alcanza al relleno con el Tween (TRANS_CUBIC + EASE_OUT, 0,6 s).
## 2. La estamina parpadea al agotarse y deja de hacerlo al recuperarse.
## 3. El medallón de Resonancia sigue el valor y la gema se enciende en el Desfase.
## 4. Al caer Nereth aparece «EL INTERVALO SE HA CERRADO» y se retira sola o al pulsar.
## 5. La barra de jefe del Salón del Prefecto: título ceremonial, aparece al
##    empezar el combate, la postura crece con los golpes y se oculta al reiniciar.
## Uso: Godot_console.exe --headless --path D:\UMBRAL -s res://tests/test_hud_ornamental.gd
## Código de salida = número de comprobaciones fallidas.

const SALA: String = "res://scenes/niveles/pruebas/sala_combate.tscn"
const SALON: String = "res://scenes/niveles/elyndor/salon_prefecto.tscn"
const RUTA_PRUEBA: String = "user://prueba_hud_ornamental.json"

var _fallos: int = 0


func _initialize() -> void:
	ConfigControles.registrar()
	GestorPartida.global().ruta_guardado = RUTA_PRUEBA
	GestorPartida.global().borrar_memoria()
	_ejecutar.call_deferred()


func _ejecutar() -> void:
	# --- 1. Barra ornamental aislada -------------------------------------------
	var barra: BarraOrnamental = (load("res://scenes/ui/componentes/barra_ornamental.tscn") as PackedScene).instantiate() as BarraOrnamental
	root.add_child(barra)
	barra.size = Vector2(300, 16)
	await _esperar(2)
	barra.fijar(100.0, 100.0, false)
	barra.fijar(40.0, 100.0, true)
	_comprobar(is_equal_approx(barra.fraccion(), 0.4), "el relleno baja al instante al recibir daño")
	_comprobar(barra.fraccion_rezagada() > 0.95, "la barra rezagada ámbar se queda atrás al principio")
	await _segundos(1.2)
	_comprobar(absf(barra.fraccion_rezagada() - 0.4) < 0.01, "la barra rezagada alcanza al relleno tras el Tween (%.3f)" % barra.fraccion_rezagada())
	barra.fijar(90.0, 100.0, true)
	_comprobar(is_equal_approx(barra.fraccion_rezagada(), 0.9), "al curarse la barra rezagada sube con el relleno")
	barra.queue_free()

	# --- 2-4. HUD en una sala con Nereth ------------------------------------------
	var sala: Node = (load(SALA) as PackedScene).instantiate()
	root.add_child(sala)
	var nereth: Nereth = null
	var hud: HudJuego = null
	for nodo: Node in sala.find_children("*", "", true, false):
		if nodo is Nereth:
			nereth = nodo as Nereth
		elif nodo is HudJuego:
			hud = nodo as HudJuego
	for i: int in 300:
		if nereth and nereth.is_on_floor():
			break
		await physics_frame
	await _esperar(5)
	_comprobar(hud != null and nereth != null, "HUD y Nereth en la sala")
	if hud and nereth:
		# Vida
		_comprobar(is_equal_approx(hud.barra_vida().fraccion(), 1.0), "la vida empieza llena")
		nereth.vida.recibir_dano(25.0)
		await _esperar(2)
		_comprobar(hud.barra_vida().fraccion() < 0.99 and hud.barra_vida().fraccion_rezagada() > hud.barra_vida().fraccion(), "el daño deja ver la barra ámbar rezagada")

		# Estamina
		var intentos: int = 0
		while nereth.resistencia.actual > 0.5 and intentos < 50:
			nereth.resistencia.consumir(nereth.resistencia.actual + 1.0)
			intentos += 1
		await _esperar(2)
		_comprobar(hud.barra_estamina().en_alerta(), "la estamina agotada parpadea (shader de alerta)")
		nereth.resistencia.restaurar()
		await _esperar(2)
		_comprobar(not hud.barra_estamina().en_alerta(), "la alerta de estamina se apaga al recuperarse")

		# Resonancia y Desfase
		var material: ShaderMaterial = (hud.get_node("Raiz/Bloque/Medallon") as ColorRect).material as ShaderMaterial
		nereth.resonancia.establecer(nereth.resonancia.maximo * 0.2)
		await _segundos(0.2)
		var v_medallon: float = float(material.get_shader_parameter(&"valor"))
		var v_real: float = nereth.resonancia.actual / nereth.resonancia.maximo
		_comprobar(absf(v_medallon - v_real) < 0.08 and v_medallon < 0.5, "el medallón sigue la Resonancia (%.2f / %.2f)" % [v_medallon, v_real])
		GestorFase.global().cambiada.emit(GestorFase.Estado.DESFASE)
		await _segundos(0.5)
		_comprobar(float(material.get_shader_parameter(&"desfase")) > 0.95, "la gema del medallón se enciende en el Desfase")
		GestorFase.global().cambiada.emit(GestorFase.Estado.REALIDAD)
		await _segundos(0.5)

		# Muerte
		var pantalla: PantallaMuerte = hud.pantalla_muerte()
		_comprobar(not pantalla.visible, "la pantalla de muerte empieza oculta")
		nereth.vida.recibir_dano(nereth.vida.maximo * 10.0)
		await _esperar(2)
		_comprobar(pantalla.visible and pantalla.abierta(), "al caer aparece «EL INTERVALO SE HA CERRADO»")
		var titulo: Label = pantalla.get_node("Centro/Columna/Titulo") as Label
		_comprobar(titulo.text == "EL INTERVALO SE HA CERRADO", "la inscripción es la oficial")
		_comprobar(nereth.vida.actual > 0.0, "la reaparición en el Altar es inmediata (sin carga)")
		pantalla.cerrar()
		await _segundos(1.0)
		_comprobar(not pantalla.visible, "«Reaparecer en el Altar» retira la pantalla")
		nereth.vida.recibir_dano(nereth.vida.maximo * 10.0)
		await _esperar(2)
		_comprobar(pantalla.abierta(), "una nueva caída vuelve a mostrar la pantalla")
		await _segundos(pantalla.duracion + 2.0)
		_comprobar(not pantalla.visible, "la pantalla se retira sola si nadie pulsa")
	sala.queue_free()
	await _esperar(2)

	# --- 5. Barra de jefe del Prefecto ------------------------------------------
	var salon: Node = (load(SALON) as PackedScene).instantiate()
	root.add_child(salon)
	await _esperar(5)
	var barra_jefe: HUDBossSekiro = salon.get_node_or_null("CapaJefe/BarraJefe") as HUDBossSekiro
	var prefecto: Prefecto = salon.get_node_or_null("Prefecto") as Prefecto
	_comprobar(barra_jefe != null and prefecto != null, "el Salón tiene barra de jefe y Prefecto")
	if barra_jefe and prefecto:
		_comprobar(barra_jefe.titulo() == "EL PREFECTO DE LAS PUERTAS", "título ceremonial: %s" % barra_jefe.titulo())
		_comprobar(not barra_jefe.mostrada(), "la barra espera a que empiece el combate")
		prefecto.combate_iniciado.emit()
		await _esperar(2)
		_comprobar(barra_jefe.mostrada(), "la barra aparece al empezar el combate")
		prefecto.postura.acumular(prefecto.postura.maximo * 0.5)
		await _esperar(2)
		_comprobar(barra_jefe.barra_postura().fraccion() > 0.3, "la postura crece en la barra (desde el centro)")
		prefecto.vida.recibir_dano(prefecto.vida.maximo * 0.25)
		await _esperar(2)
		_comprobar(barra_jefe.barra_vida().fraccion() < 0.8, "la vida del jefe baja en la barra")
		prefecto.reiniciar()
		await _esperar(2)
		_comprobar(not barra_jefe.mostrada(), "la barra se oculta cuando el combate se reinicia")
	salon.queue_free()
	await _esperar(2)

	GestorPartida.global().borrar_memoria()
	print("RESULTADO: %s (%d fallos)" % ["OK" if _fallos == 0 else "FALLO", _fallos])
	quit(_fallos)


func _esperar(frames: int) -> void:
	for i: int in frames:
		await physics_frame


func _segundos(s: float) -> void:
	await create_timer(s).timeout


func _comprobar(condicion: bool, descripcion: String) -> void:
	print(("  [OK]    " if condicion else "  [FALLO] ") + descripcion)
	if not condicion:
		_fallos += 1
