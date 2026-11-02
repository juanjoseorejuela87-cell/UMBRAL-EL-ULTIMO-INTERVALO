class_name CompositorMusica
extends RefCounted
## Música provisional sintetizada por código (D-029): cada pista es un bucle
## compuesto a partir de una partitura sencilla (acordes de coro, bajo en
## ostinato, percusión grave y campanas). Se compone una vez, fuera del hilo
## principal (ver GestorSonido.musica), y se guarda en caché.

const FRECUENCIA: int = 22050

## Partituras. Notas en semitonos MIDI (69 = La 440 Hz).
## acordes: un acorde por grupo de `compases_por_acorde` compases.
## bajo: ostinato de corcheas (se repite cada compás, transportado a la raíz del acorde);
##   largo_bajo (opcional): duración de cada nota en corcheas (por defecto 0,9).
## percusion: golpes por compás en corcheas (0–7).
## campanas: [compás, corchea, nota].
const PISTAS: Dictionary = {
	&"prefecto": {
		"tempo": 84.0,
		"compases": 8,
		"compases_por_acorde": 2,
		"acordes": [[62, 65, 69], [58, 62, 65], [55, 58, 62], [57, 61, 64]],
		"bajo": [0, 0, 3, 0, 2, 0, -2, 0],
		"percusion": [0, 3, 4, 6],
		"campanas": [[0, 0, 74], [2, 0, 70], [4, 0, 67], [6, 0, 73], [6, 4, 76]],
		"volumen": 0.55,
	},
	# Exploración de Elyndor: lenta, sin percusión, bajo largo y campanas lejanas
	# (las campanas que suenan sin que nadie las toque, LORE §4.1).
	&"elyndor": {
		"tempo": 56.0,
		"compases": 8,
		"compases_por_acorde": 2,
		"acordes": [[62, 65, 69], [60, 64, 67], [58, 62, 65], [57, 60, 64]],
		"bajo": [0],
		"largo_bajo": 8,
		"percusion": [],
		"campanas": [[1, 2, 81], [3, 5, 77], [5, 1, 79], [7, 4, 76]],
		"volumen": 0.4,
	},
}


static func duracion(nombre: StringName) -> float:
	var p: Dictionary = PISTAS[nombre]
	return float(p["compases"]) * 4.0 * 60.0 / float(p["tempo"])


static func _hz(nota: float) -> float:
	return 440.0 * pow(2.0, (nota - 69.0) / 12.0)


## Compone la pista completa como bucle WAV de 16 bits mono.
static func componer(nombre: StringName) -> AudioStreamWAV:
	var p: Dictionary = PISTAS[nombre]
	var negra: float = 60.0 / float(p["tempo"])
	var compas: float = negra * 4.0
	var total: float = duracion(nombre)
	var muestras: int = int(total * FRECUENCIA)
	var mezcla := PackedFloat32Array()
	mezcla.resize(muestras)

	var acordes: Array = p["acordes"]
	var por_acorde: int = p["compases_por_acorde"]
	for c: int in int(p["compases"]):
		var acorde: Array = acordes[(c / por_acorde) % acordes.size()]
		var inicio_compas: float = c * compas
		# Coro: un acorde sostenido por grupo de compases
		if c % por_acorde == 0:
			for nota: int in acorde:
				_coro(mezcla, inicio_compas, compas * por_acorde, _hz(nota), 0.11)
			_coro(mezcla, inicio_compas, compas * por_acorde, _hz(acorde[0] - 24), 0.1)
		# Bajo en corcheas sobre la raíz del acorde
		var raiz: int = acorde[0] - 24
		var bajo: Array = p["bajo"]
		var largo_bajo: float = float(p.get("largo_bajo", 0.9)) * negra * 0.5
		for i: int in bajo.size():
			_bajo(mezcla, inicio_compas + i * negra * 0.5, largo_bajo, _hz(raiz + bajo[i]), 0.2)
		# Percusión grave
		for golpe: int in p["percusion"]:
			var fuerte: bool = golpe == 0
			_timbal(mezcla, inicio_compas + golpe * negra * 0.5, 0.55 if fuerte else 0.35)
	for campana: Array in p["campanas"]:
		_campana(mezcla, campana[0] * compas + campana[1] * negra * 0.5, _hz(campana[2]), 0.12)

	return _a_wav(mezcla, float(p["volumen"]))


# --- Instrumentos -------------------------------------------------------------
# Todos escriben envolviendo al principio del bucle (índice % muestras), así las
# colas que pasan del final suenan al empezar de nuevo y el bucle no corta.

## Voz de coro: dos osciladores ligeramente desafinados con vibrato y
## entrada/salida lentas. (Es la parte más cara: variables locales y pocas
## operaciones por muestra.)
static func _coro(mezcla: PackedFloat32Array, inicio: float, largo: float, hz: float, vol: float) -> void:
	var n: int = mezcla.size()
	var desde: int = int(inicio * FRECUENCIA)
	var cuenta: int = int(largo * FRECUENCIA)
	var ataque: float = minf(1.2, largo * 0.4)
	var fase_a: float = 0.0
	var fase_b: float = 0.0
	var paso: float = TAU * hz / FRECUENCIA
	var paso_vibrato: float = TAU * 5.0 / FRECUENCIA
	var escala: float = vol * 0.5
	for i: int in cuenta:
		var t: float = float(i) / FRECUENCIA
		var env: float = minf(t / ataque, 1.0) * minf((largo - t) / ataque, 1.0)
		var vibrato: float = 1.0 + 0.003 * sin(paso_vibrato * i)
		fase_a += paso * vibrato
		fase_b += paso * 1.005 * vibrato
		var s: float = sin(fase_a) + sin(fase_b) + 0.3 * sin(fase_a * 2.0)
		mezcla[(desde + i) % n] += s * env * escala


## Bajo pulsado: suma de armónicos (casi diente de sierra) con caída rápida.
static func _bajo(mezcla: PackedFloat32Array, inicio: float, largo: float, hz: float, vol: float) -> void:
	var n: int = mezcla.size()
	var desde: int = int(inicio * FRECUENCIA)
	var cuenta: int = int(largo * FRECUENCIA)
	var fase: float = 0.0
	for i: int in cuenta:
		var t: float = float(i) / FRECUENCIA
		fase += TAU * hz / FRECUENCIA
		var s: float = sin(fase) + 0.5 * sin(fase * 2.0) + 0.25 * sin(fase * 3.0)
		# La caída se alarga con la nota: las notas largas sostienen.
		var env: float = minf(t / 0.005, 1.0) * exp(-t * 2.7 / largo) * minf((largo - t) / 0.01, 1.0)
		mezcla[(desde + i) % n] += s * env * vol


## Timbal grave: tono que cae de 90 a 45 Hz con un poco de ruido al golpear.
static func _timbal(mezcla: PackedFloat32Array, inicio: float, vol: float) -> void:
	var n: int = mezcla.size()
	var desde: int = int(inicio * FRECUENCIA)
	var largo: float = 0.6
	var fase: float = 0.0
	for i: int in int(largo * FRECUENCIA):
		var t: float = float(i) / FRECUENCIA
		fase += TAU * lerpf(90.0, 45.0, minf(t / 0.25, 1.0)) / FRECUENCIA
		var golpe: float = randf_range(-1.0, 1.0) * exp(-t * 60.0) * 0.4
		mezcla[(desde + i) % n] += (sin(fase) * exp(-t * 5.0) + golpe) * vol


## Campana: parciales inarmónicos con cola larga.
static func _campana(mezcla: PackedFloat32Array, inicio: float, hz: float, vol: float) -> void:
	var n: int = mezcla.size()
	var desde: int = int(inicio * FRECUENCIA)
	var parciales: Array[float] = [1.0, 2.0, 2.76, 5.4]
	var pesos: Array[float] = [1.0, 0.5, 0.35, 0.15]
	for i: int in int(3.0 * FRECUENCIA):
		var t: float = float(i) / FRECUENCIA
		var s: float = 0.0
		for k: int in parciales.size():
			s += sin(TAU * hz * parciales[k] * t) * pesos[k] * exp(-t * (1.2 + k))
		mezcla[(desde + i) % n] += s * minf(t / 0.003, 1.0) * vol


static func _a_wav(mezcla: PackedFloat32Array, volumen: float) -> AudioStreamWAV:
	var pico: float = 0.001
	for v: float in mezcla:
		pico = maxf(pico, absf(v))
	var datos := PackedByteArray()
	datos.resize(mezcla.size() * 2)
	var escala: float = volumen / pico
	for i: int in mezcla.size():
		datos.encode_s16(i * 2, int(clampf(mezcla[i] * escala, -1.0, 1.0) * 32767.0))
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = FRECUENCIA
	wav.stereo = false
	wav.data = datos
	wav.loop_mode = AudioStreamWAV.LOOP_FORWARD
	wav.loop_begin = 0
	wav.loop_end = mezcla.size()
	return wav
