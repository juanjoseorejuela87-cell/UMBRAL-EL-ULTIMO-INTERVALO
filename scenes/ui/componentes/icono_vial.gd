class_name IconoVial
extends Panel
## Vial de cristal de una Esencia, dibujado con vectores (nítido a cualquier
## escala): cuello con tapón de latón, cuerpo redondo, líquido ámbar con brillo
## y reflejo del cristal. Vacío: cristal oscuro con un poso.

const COLOR_LIQUIDO: Color = Color(0.98, 0.66, 0.16)
const COLOR_LIQUIDO_OSCURO: Color = Color(0.62, 0.26, 0.05)
const COLOR_CRISTAL: Color = Color(0.78, 0.82, 0.88, 0.55)
const COLOR_LATON: Color = Color(0.72, 0.56, 0.28)

var lleno: bool = true:
	set(v):
		lleno = v
		set_meta(&"lleno", v)
		queue_redraw()


func _init() -> void:
	custom_minimum_size = Vector2(18, 26)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_theme_stylebox_override(&"panel", StyleBoxEmpty.new())
	set_meta(&"lleno", true)


func _process(_delta: float) -> void:
	if lleno:
		queue_redraw()


func _draw() -> void:
	var w: float = size.x
	var h: float = size.y
	var cx: float = w * 0.5
	var radio: float = minf(w * 0.46, h * 0.32)
	var centro: Vector2 = Vector2(cx, h - radio - 1.0)
	var cuello_w: float = radio * 0.62
	var cuello_top: float = h * 0.16
	var cuello_bot: float = centro.y - radio * 0.8

	# Sombra.
	draw_circle(centro + Vector2(0, 1.5), radio + 1.0, Color(0, 0, 0, 0.55))
	# Cuerpo de cristal (fondo).
	draw_circle(centro, radio, Color(0.06, 0.05, 0.07, 0.9))
	draw_rect(Rect2(cx - cuello_w * 0.5, cuello_top, cuello_w, cuello_bot - cuello_top + 2.0), Color(0.06, 0.05, 0.07, 0.9))

	if lleno:
		var vaiven: float = sin(Time.get_ticks_msec() * 0.003) * 0.6
		# Líquido: gradiente por anillos concéntricos (claro arriba-izquierda).
		var pasos: int = 6
		for i: int in range(pasos):
			var t: float = float(i) / float(pasos - 1)
			var c: Color = COLOR_LIQUIDO_OSCURO.lerp(COLOR_LIQUIDO, t)
			draw_circle(centro + Vector2(-radio * 0.18, -radio * 0.18) * t, radio * (0.88 - t * 0.5), c)
		# Nivel en el cuello.
		draw_rect(Rect2(cx - cuello_w * 0.38, cuello_bot - radio * 0.25 + vaiven, cuello_w * 0.76, radio * 0.6), COLOR_LIQUIDO_OSCURO.lerp(COLOR_LIQUIDO, 0.5))
		# Resplandor.
		draw_circle(centro, radio * 1.25, Color(COLOR_LIQUIDO.r, COLOR_LIQUIDO.g * 0.8, 0.1, 0.12))
	else:
		# Poso.
		draw_arc(centro, radio * 0.78, deg_to_rad(40), deg_to_rad(140), 10, Color(0.35, 0.2, 0.08, 0.7), 2.0, true)

	# Contorno del cristal.
	draw_arc(centro, radio, deg_to_rad(-60), deg_to_rad(240), 24, COLOR_CRISTAL, 1.2, true)
	draw_line(Vector2(cx - cuello_w * 0.5, cuello_top), Vector2(cx - cuello_w * 0.5, cuello_bot + 1.0), COLOR_CRISTAL, 1.2, true)
	draw_line(Vector2(cx + cuello_w * 0.5, cuello_top), Vector2(cx + cuello_w * 0.5, cuello_bot + 1.0), COLOR_CRISTAL, 1.2, true)
	# Reflejo del cristal.
	draw_arc(centro, radio * 0.72, deg_to_rad(200), deg_to_rad(250), 8, Color(1, 1, 1, 0.65 if lleno else 0.35), 1.6, true)
	# Tapón de latón y labio.
	draw_rect(Rect2(cx - cuello_w * 0.62, cuello_top - 2.0, cuello_w * 1.24, 2.5), COLOR_LATON.lightened(0.2))
	draw_rect(Rect2(cx - cuello_w * 0.42, 1.0, cuello_w * 0.84, cuello_top - 3.0), COLOR_LATON.darkened(0.25) if lleno else COLOR_LATON.darkened(0.55))
