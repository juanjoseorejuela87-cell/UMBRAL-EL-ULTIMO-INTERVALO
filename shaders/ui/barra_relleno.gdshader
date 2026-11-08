shader_type canvas_item;
// Relleno de barra del HUD: relieve vertical, filo de luz superior, reflejo que
// recorre la barra y destello de alerta (estamina agotada, rechazo...).
// «tamano» es el tamaño de la barra COMPLETA en píxeles: así el reflejo no se
// deforma cuando el relleno se acorta.

uniform vec2 tamano = vec2(300.0, 16.0);
uniform float destello : hint_range(0.0, 1.0) = 0.0;
uniform vec4 color_destello : source_color = vec4(1.0, 0.95, 0.85, 1.0);
uniform float velocidad_reflejo = 0.22;
uniform float intensidad_reflejo : hint_range(0.0, 1.0) = 0.18;
uniform float vetas : hint_range(0.0, 1.0) = 0.12;

varying vec2 p;

void vertex() {
	p = VERTEX / max(tamano, vec2(1.0));
}

float ruido(vec2 q) {
	return fract(sin(dot(q, vec2(12.9898, 78.233))) * 43758.5453);
}

void fragment() {
	vec4 c = COLOR;
	// Relieve: más claro arriba, sombra abajo (sensación de cristal/esmalte).
	c.rgb *= mix(1.28, 0.62, smoothstep(0.05, 1.0, p.y));
	// Filo de luz superior.
	c.rgb += vec3(0.20) * (1.0 - smoothstep(0.0, 0.2, p.y));
	// Vetas finas horizontales (textura de líquido/hilo).
	float v = ruido(vec2(floor(p.x * tamano.x / 3.0), floor(p.y * 6.0)));
	c.rgb *= 1.0 - vetas * 0.5 + vetas * v * 0.5;
	// Reflejo que recorre la barra.
	float x = fract(TIME * velocidad_reflejo) * 1.8 - 0.4;
	float d = p.x - x - (p.y - 0.5) * 0.08;
	c.rgb += intensidad_reflejo * exp(-d * d * 260.0) * (1.1 - p.y);
	// Destello de alerta.
	c.rgb = mix(c.rgb, color_destello.rgb, destello);
	COLOR = c;
}
