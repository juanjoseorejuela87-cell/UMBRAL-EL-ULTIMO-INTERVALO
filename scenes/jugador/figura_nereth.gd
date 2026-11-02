class_name FiguraNereth
extends Node3D
## Figura de Nereth (hito 14) con animación procedural (carrera, salto, esquiva,
## ataque, guardia), sin huesos; solo lee el estado de Nereth, no lo cambia.
## Usa el modelo por piezas de `modelo` (assets/modelos/nereth/, hecho con
## tools/blender/nereth.py: pivotes Raiz, Torso, Piernas, Brazos, Mano, Capa,
## Segmento0…, Fragmento0…). Sin modelo, construye una versión con primitivas.
## Debe ser hija del nodo Visual de Nereth (Visual voltea con scale.x).

## Modelo con esqueleto (assets/modelos/nereth/nereth_animable.glb, generado con
## TripoSR y tools/blender/esqueleto.py). Tiene prioridad sobre `modelo`.
@export var modelo_animable: PackedScene
## Giro de la espada respecto al hueso de la mano (el hueso apunta hacia abajo).
@export var giro_espada_mano: Vector3 = Vector3(PI, 0.0, 0.0)
## Metal máximo de los materiales del modelo (ver _cargar_modelo_animable).
@export var metal_maximo: float = 0.2
## Intensidad de la luz de borde en los modelos con textura (0 = sin ella).
@export var luz_borde: float = 0.8
## Modelo por piezas de Nereth y de la Espada del Umbral (opcionales).
@export var modelo: PackedScene
@export var espada: PackedScene

@export_group("Colores")
@export var color_capa: Color = Color(0.07, 0.07, 0.09)
@export var color_ropa: Color = Color(0.14, 0.14, 0.17)
@export var color_piel: Color = Color(0.84, 0.8, 0.78)
## Marcas de Continuidad (violeta, hoja de personaje del director).
@export var color_dorado: Color = Color(0.55, 0.32, 1.0)
@export var color_hoja: Color = Color(0.62, 0.62, 0.7)

@export_group("Animación")
@export var frecuencia_paso: float = 11.0
@export var amplitud_paso: float = 0.75
@export var segmentos_capa: int = 5
@export var largo_segmento_capa: float = 0.22
## Cuánto se levanta la capa con la velocidad (radianes a velocidad máxima).
@export var vuelo_capa: float = 0.55
## Giro de los fragmentos del hombro (rad/s): casi quietos en la Realidad,
## desbordados en el Desfase (hoja de personaje).
@export var giro_fragmentos_realidad: float = 0.4
@export var giro_fragmentos_desfase: float = 2.6

var _nereth: Nereth
var _ciclo: float = 0.0
var _tiempo: float = 0.0
var _ataque_t: float = -1.0
var _ataque_duracion: float = 0.0
var _ataque_preparacion: float = 0.0
var _ataque_activo: float = 0.0
var _ataque_pesado: bool = false
var _giro_capa: float = 0.0
var _inicio_esquiva: float = 0.0

var _raiz: Node3D
var _pierna_delante: Node3D
var _pierna_detras: Node3D
var _brazo_espada: Node3D
var _brazo_libre: Node3D
var _torso: Node3D
var _capa: Array[Node3D] = []
var _fragmentos: Array[Node3D] = []
var _base_fragmentos: Array[Vector3] = []
var _centro_fragmentos: Vector3 = Vector3.ZERO
var _giro_fragmentos: float = 0.0
var _esqueleto: Skeleton3D
var _huesos: Dictionary = {}


func _ready() -> void:
	_nereth = owner as Nereth
	if _nereth == null and get_parent():
		_nereth = get_parent().get_parent() as Nereth
	if modelo_animable:
		_cargar_modelo_animable()
	elif modelo:
		_cargar_modelo()
	else:
		_construir()
	if _nereth:
		# Las variables @onready de Nereth aún no existen: los hijos se preparan antes.
		var combate: CombateNereth = _nereth.get_node(^"Combate") as CombateNereth
		combate.ataque_iniciado.connect(_al_iniciar_ataque)
		combate.ataque_terminado.connect(func() -> void: _ataque_t = -1.0)
		_nereth.esquiva_iniciada.connect(func() -> void: _inicio_esquiva = _tiempo)


# --- Construcción -----------------------------------------------------------

## Modelo con esqueleto: la animación de siempre se calcula sobre pivotes
## invisibles y luego se copia a los huesos (_aplicar_esqueleto).
func _cargar_modelo_animable() -> void:
	var instancia: Node3D = modelo_animable.instantiate() as Node3D
	add_child(instancia)
	_raiz = instancia
	_esqueleto = instancia.find_children("*", "Skeleton3D", true, false)[0] as Skeleton3D
	for i: int in _esqueleto.get_bone_count():
		_huesos[_esqueleto.get_bone_name(i)] = i
	_pierna_delante = _pivote(self, Vector3.ZERO, "PivotePiernaDelante")
	_pierna_detras = _pivote(self, Vector3.ZERO, "PivotePiernaDetras")
	_torso = _pivote(self, Vector3.ZERO, "PivoteTorso")
	_brazo_libre = _pivote(self, Vector3.ZERO, "PivoteBrazoLibre")
	_brazo_espada = _pivote(self, Vector3.ZERO, "PivoteBrazoEspada")
	# Color por vértice de TripoSR como color base; materiales con textura (TRELLIS)
	# con el metal atenuado: sin reflejos (Compatibility) el metal se ve negro.
	for nodo: Node in instancia.find_children("*", "MeshInstance3D", true, false):
		var mi: MeshInstance3D = nodo as MeshInstance3D
		for s: int in mi.mesh.get_surface_count():
			var original: BaseMaterial3D = mi.get_active_material(s) as BaseMaterial3D
			if original and original.albedo_texture:
				var ajustado: BaseMaterial3D = original.duplicate() as BaseMaterial3D
				if ajustado.metallic > metal_maximo:
					ajustado.metallic = metal_maximo
					ajustado.metallic_texture = null
					ajustado.roughness = maxf(ajustado.roughness, 0.6)
				# Luz de borde: separa la silueta oscura (ropa negra) del fondo
				ajustado.rim_enabled = true
				ajustado.rim = luz_borde
				ajustado.rim_tint = 0.35
				mi.set_surface_override_material(s, ajustado)
			var colores: Variant = mi.mesh.surface_get_arrays(s)[Mesh.ARRAY_COLOR]
			if colores != null and (colores as PackedColorArray).size() > 0:
				var mat: StandardMaterial3D = StandardMaterial3D.new()
				mat.vertex_color_use_as_albedo = true
				mat.roughness = 0.75
				mi.set_surface_override_material(s, mat)
	if espada and _huesos.has("Mano.R"):
		var enganche := BoneAttachment3D.new()
		_esqueleto.add_child(enganche)
		enganche.bone_name = "Mano.R"
		var hoja: Node3D = espada.instantiate() as Node3D
		enganche.add_child(hoja)
		hoja.rotation = giro_espada_mano


## Gira un hueso alrededor del eje Z del modelo (el de la cámara), como los pivotes.
func _rotar_hueso(nombre: String, angulo: float) -> void:
	if not _huesos.has(nombre):
		return
	var indice: int = _huesos[nombre]
	var padre: int = _esqueleto.get_bone_parent(indice)
	var base_padre: Basis = _esqueleto.get_bone_global_rest(padre).basis if padre >= 0 else Basis()
	var giro := Basis(Vector3.BACK, angulo)
	var local: Basis = (base_padre.inverse() * giro * base_padre) * _esqueleto.get_bone_rest(indice).basis
	_esqueleto.set_bone_pose_rotation(indice, local.get_rotation_quaternion())


func _aplicar_esqueleto() -> void:
	var muslo_r: float = _pierna_delante.rotation.z
	var muslo_l: float = _pierna_detras.rotation.z
	_rotar_hueso("Muslo.R", muslo_r)
	_rotar_hueso("Muslo.L", muslo_l)
	# La rodilla se dobla cuando el muslo va hacia atrás
	_rotar_hueso("Pierna.R", -maxf(0.0, -muslo_r) * 1.3 - 0.05)
	_rotar_hueso("Pierna.L", -maxf(0.0, -muslo_l) * 1.3 - 0.05)
	_rotar_hueso("BrazoSup.L", _brazo_libre.rotation.z)
	_rotar_hueso("BrazoSup.R", _brazo_espada.rotation.z)
	_rotar_hueso("Antebrazo.L", 0.25)
	_rotar_hueso("Antebrazo.R", 0.35)
	_rotar_hueso("Columna", _torso.rotation.z * 0.6)
	_rotar_hueso("Pecho", _torso.rotation.z * 0.4)

func _cargar_modelo() -> void:
	var instancia: Node3D = modelo.instantiate() as Node3D
	add_child(instancia)
	_raiz = instancia.find_child("Raiz", true, false) as Node3D
	_pierna_delante = instancia.find_child("PiernaDelante", true, false) as Node3D
	_pierna_detras = instancia.find_child("PiernaDetras", true, false) as Node3D
	_torso = instancia.find_child("Torso", true, false) as Node3D
	_brazo_libre = instancia.find_child("BrazoLibre", true, false) as Node3D
	_brazo_espada = instancia.find_child("BrazoEspada", true, false) as Node3D
	for i: int in segmentos_capa:
		var seg: Node3D = instancia.find_child("Segmento%d" % i, true, false) as Node3D
		if seg:
			_capa.append(seg)
	var mano: Node3D = instancia.find_child("Mano", true, false) as Node3D
	if espada and mano:
		mano.add_child(espada.instantiate())
	for nodo: Node in _torso.get_children():
		if String(nodo.name).begins_with("Fragmento"):
			_fragmentos.append(nodo as Node3D)
			_centro_fragmentos += (nodo as Node3D).position
	if not _fragmentos.is_empty():
		_centro_fragmentos /= float(_fragmentos.size())
		for f: Node3D in _fragmentos:
			_base_fragmentos.append(f.position - _centro_fragmentos)


func _material(color: Color, brillo: float = 0.0) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = color
	m.roughness = 0.85
	if brillo > 0.0:
		m.emission_enabled = true
		m.emission = color
		m.emission_energy_multiplier = brillo
	return m


func _malla(padre: Node3D, malla: Mesh, material: Material, posicion: Vector3, nombre: String) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	mi.name = nombre
	mi.mesh = malla
	mi.material_override = material
	mi.position = posicion
	padre.add_child(mi)
	return mi


func _pivote(padre: Node3D, posicion: Vector3, nombre: String) -> Node3D:
	var n := Node3D.new()
	n.name = nombre
	n.position = posicion
	padre.add_child(n)
	return n


func _capsula(radio: float, alto: float) -> CapsuleMesh:
	var c := CapsuleMesh.new()
	c.radius = radio
	c.height = alto
	c.radial_segments = 10
	c.rings = 4
	return c


func _construir() -> void:
	var capa := _material(color_capa)
	var ropa := _material(color_ropa)
	var piel := _material(color_piel)
	var dorado := _material(color_dorado, 1.6)
	var hoja := _material(color_hoja)
	hoja.metallic = 0.8
	hoja.roughness = 0.3

	_raiz = _pivote(self, Vector3.ZERO, "Raiz")

	# Piernas (pivote en la cadera); separadas en profundidad para leerse de lado
	var pierna := _capsula(0.085, 0.88)
	_pierna_detras = _pivote(_raiz, Vector3(0, 0.88, -0.1), "PiernaDetras")
	_malla(_pierna_detras, pierna, ropa, Vector3(0, -0.42, 0), "Malla")
	_pierna_delante = _pivote(_raiz, Vector3(0, 0.88, 0.1), "PiernaDelante")
	_malla(_pierna_delante, pierna, ropa, Vector3(0, -0.42, 0), "Malla")

	# Torso, cinturón y cabeza con capucha
	_torso = _pivote(_raiz, Vector3(0, 0.9, 0), "Torso")
	var tronco := CylinderMesh.new()
	tronco.top_radius = 0.17
	tronco.bottom_radius = 0.13
	tronco.height = 0.62
	tronco.radial_segments = 10
	_malla(_torso, tronco, ropa, Vector3(0, 0.31, 0), "Tronco")
	var cinto := CylinderMesh.new()
	cinto.top_radius = 0.145
	cinto.bottom_radius = 0.145
	cinto.height = 0.05
	cinto.radial_segments = 10
	_malla(_torso, cinto, dorado, Vector3(0, 0.03, 0), "Cinturon")
	var cabeza := SphereMesh.new()
	cabeza.radius = 0.12
	cabeza.height = 0.25
	cabeza.radial_segments = 12
	cabeza.rings = 6
	_malla(_torso, cabeza, piel, Vector3(0.02, 0.74, 0), "Cabeza")
	var capucha := SphereMesh.new()
	capucha.radius = 0.155
	capucha.height = 0.31
	capucha.radial_segments = 12
	capucha.rings = 6
	_malla(_torso, capucha, capa, Vector3(-0.035, 0.77, 0), "Pelo")
	var pico := CylinderMesh.new()
	pico.top_radius = 0.0
	pico.bottom_radius = 0.09
	pico.height = 0.22
	pico.radial_segments = 8
	# Mechón de pelo negro que cae sobre la cara (hoja de personaje: sin capucha).
	var mechon := _malla(_torso, pico, capa, Vector3(0.1, 0.78, 0), "Mechon")
	mechon.rotation.z = -2.5
	var broche := SphereMesh.new()
	broche.radius = 0.03
	broche.height = 0.06
	_malla(_torso, broche, dorado, Vector3(0.12, 0.56, 0), "Broche")

	# Brazos (pivote en el hombro); el de delante lleva la espada
	var brazo := _capsula(0.055, 0.6)
	_brazo_libre = _pivote(_torso, Vector3(0, 0.56, -0.2), "BrazoLibre")
	_malla(_brazo_libre, brazo, ropa, Vector3(0, -0.27, 0), "Malla")
	_brazo_espada = _pivote(_torso, Vector3(0, 0.56, 0.2), "BrazoEspada")
	_malla(_brazo_espada, brazo, ropa, Vector3(0, -0.27, 0), "Malla")
	var mano := _pivote(_brazo_espada, Vector3(0, -0.55, 0), "Mano")
	var guarda := BoxMesh.new()
	guarda.size = Vector3(0.05, 0.04, 0.2)
	_malla(mano, guarda, dorado, Vector3.ZERO, "Guarda")
	var filo := BoxMesh.new()
	filo.size = Vector3(0.05, 0.85, 0.02)
	var espada := _malla(mano, filo, hoja, Vector3(0.0, -0.45, 0), "Hoja")
	var veta := BoxMesh.new()
	veta.size = Vector3(0.012, 0.75, 0.025)
	_malla(espada, veta, dorado, Vector3(0.0, 0.0, 0), "Veta")

	# Capa: segmentos encadenados desde los hombros, por detrás del cuerpo
	var tela := BoxMesh.new()
	# Con grosor en X: de perfil la capa se ve como un volumen, no como una línea.
	tela.size = Vector3(0.11, largo_segmento_capa + 0.02, 0.36)
	var padre: Node3D = _pivote(_torso, Vector3(-0.15, 0.56, 0), "Capa")
	for i: int in segmentos_capa:
		var seg := _pivote(padre, Vector3(0, -largo_segmento_capa if i > 0 else 0.0, 0), "Segmento%d" % i)
		var m := _malla(seg, tela, capa, Vector3(0, -largo_segmento_capa * 0.5, 0), "Malla")
		m.scale = Vector3(1.0 + 0.18 * i, 1, 1.0 + 0.1 * i)
		m.position.x = -0.02 * i
		_capa.append(seg)
		padre = seg


# --- Animación -------------------------------------------------------------

func _al_iniciar_ataque(datos: DatosAtaque) -> void:
	_ataque_preparacion = datos.preparacion
	_ataque_activo = datos.activo
	_ataque_duracion = datos.preparacion + datos.activo + datos.recuperacion
	_ataque_pesado = datos.fuerza != InfoGolpe.Fuerza.LIGERA
	_ataque_t = 0.0


func _process(delta: float) -> void:
	if _nereth == null:
		return
	_tiempo += delta
	var vel: Vector3 = _nereth.velocity
	var rapidez: float = clampf(absf(vel.x) / maxf(_nereth.velocidad_maxima, 0.01), 0.0, 1.0)
	var e: Nereth.Estado = _nereth.estado

	var pierna_a: float = 0.0
	var pierna_b: float = 0.0
	var brazo_a: float = 0.0
	var brazo_espada: float = -0.25
	var inclinacion: float = 0.0
	var agacha: float = 0.0
	var giro: float = 0.0

	match e:
		Nereth.Estado.SUELO:
			_ciclo += delta * frecuencia_paso * rapidez
			var s: float = sin(_ciclo)
			pierna_a = s * amplitud_paso * rapidez
			pierna_b = -pierna_a
			brazo_a = -s * 0.6 * rapidez
			brazo_espada = -0.35 + s * 0.15 * rapidez
			inclinacion = -0.18 * rapidez
			agacha = absf(cos(_ciclo)) * 0.04 * rapidez
		Nereth.Estado.AIRE:
			var sube: float = clampf(vel.y / 8.0, -1.0, 1.0)
			pierna_a = 0.55 + 0.2 * sube
			pierna_b = -0.35
			brazo_a = 0.6 + 0.6 * sube
			brazo_espada = -0.6
			inclinacion = -0.1
		Nereth.Estado.ESQUIVA:
			pierna_a = 1.1
			pierna_b = 0.6
			brazo_a = 1.0
			brazo_espada = 0.8
			agacha = 0.35
			giro = -TAU * clampf(_tiempo_esquiva(), 0.0, 1.0)
		Nereth.Estado.GUARDIA:
			pierna_a = 0.3
			pierna_b = -0.35
			brazo_espada = 1.45
			brazo_a = 0.4
			agacha = 0.08
			inclinacion = -0.08
		Nereth.Estado.ATURDIDO:
			pierna_a = -0.2
			pierna_b = 0.25
			brazo_a = -0.6
			brazo_espada = -0.9
			inclinacion = 0.35
		Nereth.Estado.ACCION:
			pierna_a = 0.45
			pierna_b = -0.4
			brazo_a = -0.3
			agacha = 0.06

	if _ataque_t >= 0.0:
		_ataque_t += delta
		brazo_espada = _angulo_ataque()
		inclinacion = -0.15 if _ataque_t > _ataque_preparacion else 0.1

	var suave: float = 1.0 - exp(-delta * 18.0)
	_pierna_delante.rotation.z = lerp_angle(_pierna_delante.rotation.z, pierna_a, suave)
	_pierna_detras.rotation.z = lerp_angle(_pierna_detras.rotation.z, pierna_b, suave)
	_brazo_libre.rotation.z = lerp_angle(_brazo_libre.rotation.z, brazo_a, suave)
	var suave_espada: float = 1.0 - exp(-delta * (40.0 if _ataque_t >= 0.0 else 14.0))
	_brazo_espada.rotation.z = lerp_angle(_brazo_espada.rotation.z, brazo_espada, suave_espada)
	_torso.rotation.z = lerp_angle(_torso.rotation.z, inclinacion, suave)
	_raiz.position.y = lerpf(_raiz.position.y, -agacha, suave)
	_raiz.rotation.z = giro if e == Nereth.Estado.ESQUIVA else lerp_angle(_raiz.rotation.z, 0.0, suave)
	_animar_capa(delta, rapidez, vel.y)
	_animar_fragmentos(delta)
	if _esqueleto:
		_aplicar_esqueleto()


## Ataque: el brazo sube (preparación), cae en arco (activo) y vuelve.
func _angulo_ataque() -> float:
	var alto: float = 3.4 if _ataque_pesado else 3.0
	var bajo: float = 0.45
	if _ataque_t < _ataque_preparacion:
		return alto
	if _ataque_t < _ataque_preparacion + _ataque_activo:
		var k: float = (_ataque_t - _ataque_preparacion) / maxf(_ataque_activo, 0.001)
		return lerpf(alto, bajo, k)
	return bajo


## Progreso de la esquiva en curso (0–1): una voltereta completa.
func _tiempo_esquiva() -> float:
	return (_tiempo - _inicio_esquiva) / maxf(_nereth.duracion_esquiva, 0.01)


## La capa se levanta hacia atrás con la velocidad y ondea; al caer, sube.
func _animar_capa(delta: float, rapidez: float, vel_y: float) -> void:
	var objetivo: float = -vuelo_capa * rapidez - clampf(-vel_y / 18.0, 0.0, 1.0) * 0.8
	_giro_capa = lerpf(_giro_capa, objetivo, 1.0 - exp(-delta * 6.0))
	for i: int in _capa.size():
		var onda: float = sin(_tiempo * 6.0 - i * 0.9) * (0.06 + 0.1 * rapidez)
		var base: float = _giro_capa * 0.6 if i == 0 else _giro_capa * 0.4 / float(_capa.size() - 1)
		_capa[i].rotation.z = base + onda


## Los fragmentos orbitan junto al hombro izquierdo; en el Desfase se aceleran.
func _animar_fragmentos(delta: float) -> void:
	if _fragmentos.is_empty():
		return
	var desfase: bool = GestorFase.global() != null and GestorFase.global().en_desfase()
	_giro_fragmentos += delta * (giro_fragmentos_desfase if desfase else giro_fragmentos_realidad)
	for i: int in _fragmentos.size():
		var f: Node3D = _fragmentos[i]
		f.position = _centro_fragmentos + _base_fragmentos[i].rotated(Vector3.FORWARD, _giro_fragmentos)
		f.position.y += sin(_tiempo * 2.0 + i) * 0.01
		f.rotation.y += delta * (3.0 if desfase else 0.8)
