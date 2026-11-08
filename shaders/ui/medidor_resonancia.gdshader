shader_type canvas_item;
// Medallón de Resonancia: disco de hierro con doble aro de oro viejo, arco de
// 270° con la Resonancia (pulso etéreo), marca del límite de Amenaza y gema
// central que se enciende en el Desfase.

uniform float valor : hint_range(0.0, 1.0) = 1.0;
uniform float limite : hint_range(0.0, 1.0) = 0.3;
uniform float amenaza : hint_range(0.0, 1.0) = 0.0;
uniform float desfase : hint_range(0.0, 1.0) = 0.0;
uniform float destello : hint_range(0.0, 1.0) = 0.0;
uniform vec4 color_destello : source_color = vec4(1.0, 0.3, 0.2, 1.0);
uniform vec4 color_calma : source_color = vec4(0.52, 0.36, 0.95, 1.0);
uniform vec4 color_amenaza : source_color = vec4(0.92, 0.22, 0.30, 1.0);
uniform vec4 color_oro : source_color = vec4(0.72, 0.56, 0.28, 1.0);
uniform vec4 color_hierro : source_color = vec4(0.075, 0.07, 0.08, 1.0);

const float ARCO = 0.75; // 270° (TAU es una constante integrada)

float banda(float r, float a, float b, float s) {
	return smoothstep(a - s, a, r) * (1.0 - smoothstep(b, b + s, r));
}

float ruido(vec2 q) {
	vec2 i = floor(q);
	vec2 f = fract(q);
	f = f * f * (3.0 - 2.0 * f);
	float h00 = fract(sin(dot(i, vec2(127.1, 311.7))) * 43758.5453);
	float h10 = fract(sin(dot(i + vec2(1, 0), vec2(127.1, 311.7))) * 43758.5453);
	float h01 = fract(sin(dot(i + vec2(0, 1), vec2(127.1, 311.7))) * 43758.5453);
	float h11 = fract(sin(dot(i + vec2(1, 1), vec2(127.1, 311.7))) * 43758.5453);
	return mix(mix(h00, h10, f.x), mix(h01, h11, f.x), f.y);
}

void fragment() {
	vec2 q = UV * 2.0 - 1.0;
	float r = length(q);
	float s = fwidth(r) * 1.2;
	// Arco de 270°: empieza abajo-izquierda (225°) y avanza en sentido horario,
	// pasando por arriba, hasta abajo-derecha (-45°). La Y de pantalla va hacia abajo.
	float ang = atan(-q.y, q.x);
	float t = mod(radians(225.0) - ang, TAU) / TAU;
	float en_arco = step(t, ARCO);
	float frac_arco = t / ARCO;

	vec4 col = vec4(0.0);
	// Sombra exterior.
	col = mix(col, vec4(0.0, 0.0, 0.0, 0.55), 1.0 - smoothstep(0.93, 1.0, r));
	// Disco de hierro con viñeta.
	float disco = 1.0 - smoothstep(0.90 - s, 0.90, r);
	vec3 hierro = color_hierro.rgb * (1.25 - r * 0.6);
	col = mix(col, vec4(hierro, 0.96), disco);

	// Pista del arco (canal hundido).
	float pista = banda(r, 0.60, 0.80, s) * en_arco;
	col.rgb = mix(col.rgb, vec3(0.02, 0.015, 0.03), pista * 0.9);

	// Relleno de Resonancia con pulso etéreo.
	vec3 base = mix(color_calma.rgb, color_amenaza.rgb, amenaza);
	float n = ruido(vec2(frac_arco * 14.0 - TIME * 1.3, r * 9.0 + TIME * 0.6));
	float pulso = 0.75 + 0.25 * sin(TIME * 3.2 - frac_arco * 9.0);
	float relleno = banda(r, 0.62, 0.78, s) * en_arco * step(frac_arco, valor);
	vec3 eter = base * (0.65 + 0.55 * n) * pulso;
	eter += vec3(0.35) * (1.0 - smoothstep(0.0, 0.05, abs(r - 0.70))) * 0.6; // hebra central
	col.rgb = mix(col.rgb, eter, relleno);
	// Brillo en la punta del relleno.
	float punta = (1.0 - smoothstep(0.0, 0.035, abs(frac_arco - valor))) * banda(r, 0.58, 0.82, s) * en_arco;
	col.rgb += base * punta * 0.9 * step(0.01, valor);

	// Marca del límite de Amenaza.
	float marca = (1.0 - smoothstep(0.0, 0.012, abs(frac_arco - limite))) * banda(r, 0.56, 0.84, s) * en_arco * amenaza;
	col.rgb = mix(col.rgb, vec3(1.0, 0.75, 0.55), marca);

	// Doble aro de oro viejo con bisel (claro arriba-izquierda, oscuro abajo-derecha).
	float luz = 0.75 + 0.45 * dot(normalize(q + 1e-4), normalize(vec2(-0.6, -0.8)));
	float aro_ext = banda(r, 0.85, 0.90, s);
	float aro_int = banda(r, 0.53, 0.56, s);
	float aro_gema = banda(r, 0.31, 0.34, s);
	vec3 oro = color_oro.rgb * luz;
	col.rgb = mix(col.rgb, oro, aro_ext);
	col.rgb = mix(col.rgb, oro * 0.85, aro_int);
	col.rgb = mix(col.rgb, oro * 0.9, aro_gema);
	// Remaches en los extremos del arco y arriba.
	for (int k = 0; k < 3; k++) {
		float a = (k == 0) ? radians(225.0) : (k == 1) ? radians(-45.0) : radians(90.0);
		vec2 c = vec2(cos(a), -sin(a)) * 0.875;
		float rm = 1.0 - smoothstep(0.035, 0.035 + s, length(q - c));
		col.rgb = mix(col.rgb, color_oro.rgb * 1.3, rm);
	}

	// Gema central: apagada en Realidad, viva en el Desfase.
	float gema = 1.0 - smoothstep(0.30 - s, 0.30, r);
	float facetas = 0.8 + 0.2 * sign(sin(atan(q.y, q.x) * 3.0));
	vec3 gema_off = vec3(0.10, 0.08, 0.16) * facetas * (1.3 - r * 2.0);
	vec3 gema_on = mix(color_calma.rgb, vec3(0.85, 0.8, 1.0), 1.0 - r / 0.3) * facetas * (0.85 + 0.25 * sin(TIME * 4.0));
	col.rgb = mix(col.rgb, mix(gema_off, gema_on, desfase), gema);
	// Halo de la gema en el Desfase.
	col.rgb += color_calma.rgb * desfase * 0.35 * (1.0 - smoothstep(0.30, 0.52, r)) * (1.0 - gema);

	// Destello de aviso.
	col.rgb = mix(col.rgb, color_destello.rgb, destello * disco * 0.75);
	COLOR = col;
}
