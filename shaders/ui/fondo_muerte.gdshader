shader_type canvas_item;
// Fondo de la pantalla de muerte: negro con un corazón carmesí que late
// despacio, humo que deriva y viñeta. Barato (sin texturas).

uniform vec4 color_carmesi : source_color = vec4(0.42, 0.02, 0.05, 1.0);
uniform float intensidad : hint_range(0.0, 2.0) = 1.0;

float ruido(vec2 q) {
	vec2 i = floor(q);
	vec2 f = fract(q);
	f = f * f * (3.0 - 2.0 * f);
	float a = fract(sin(dot(i, vec2(127.1, 311.7))) * 43758.5453);
	float b = fract(sin(dot(i + vec2(1, 0), vec2(127.1, 311.7))) * 43758.5453);
	float c = fract(sin(dot(i + vec2(0, 1), vec2(127.1, 311.7))) * 43758.5453);
	float d = fract(sin(dot(i + vec2(1, 1), vec2(127.1, 311.7))) * 43758.5453);
	return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

void fragment() {
	vec2 uv = UV;
	vec2 q = (uv - 0.5) * vec2(1.6, 1.0);
	float r = length(q);
	// Humo con ondas encadenadas (suave; el ruido de valor dejaba bloques).
	float humo = 0.5
		+ 0.25 * sin(uv.x * 6.0 + TIME * 0.3 + sin(uv.y * 5.0 - TIME * 0.2) * 1.5)
		+ 0.25 * sin(uv.y * 7.0 - TIME * 0.25 + sin(uv.x * 4.0 + TIME * 0.1) * 2.0);
	float latido = 0.85 + 0.15 * sin(TIME * 1.6);
	float nucleo = (1.0 - smoothstep(0.0, 0.75, r)) * latido;
	vec3 col = color_carmesi.rgb * nucleo * (0.55 + 0.6 * humo) * intensidad;
	// Franja horizontal tenue tras el texto.
	col += color_carmesi.rgb * 0.35 * (1.0 - smoothstep(0.0, 0.09, abs(uv.y - 0.47))) * (1.0 - smoothstep(0.2, 0.75, abs(q.x)));
	// Viñeta.
	col *= 1.0 - smoothstep(0.45, 1.05, r);
	COLOR = vec4(col, COLOR.a);
}
