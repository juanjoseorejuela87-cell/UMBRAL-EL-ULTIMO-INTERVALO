class_name GestorPartida
extends Node
## Estado persistente de la partida (autoload "Partida"): Anclas estabilizadas,
## punto de reaparición y descansos. Se guarda en JSON en user://.
## Diseño: documentation/GAMEPLAY.md §5.

signal guardada
signal descanso_realizado
signal evento_registrado(id: StringName)
signal fragmento_obtenido(id: StringName)

const VERSION_GUARDADO: int = 1
## Grupo de nodos que vuelven a su estado inicial al descansar en un Ancla
## (la zona "repite sus acontecimientos"). Deben tener un método reiniciar().
const GRUPO_REINICIO: StringName = &"reinicio_descanso"

var ruta_guardado: String = "user://partida.json"
var anclas_estabilizadas: Array[StringName] = []
var remiendos: Array[StringName] = []
## Acontecimientos únicos ya ocurridos (jefes derrotados, puertas abiertas...).
var eventos: Array[StringName] = []
## Fragmentos de Continuidad recogidos.
var fragmentos: Array[StringName] = []
var ancla_actual: StringName = &""
var escena_ancla: String = ""
var posicion_reaparicion: Vector3 = Vector3.ZERO
var hay_reaparicion: bool = false

static var _instancia: GestorPartida


func _init() -> void:
	_instancia = self


## Acceso sin depender del nombre del autoload (ver GestorFase.global()).
static func global() -> GestorPartida:
	return _instancia


func _ready() -> void:
	cargar()


func ancla_estabilizada(id: StringName) -> bool:
	return id in anclas_estabilizadas


func estabilizar_ancla(id: StringName) -> void:
	if not ancla_estabilizada(id):
		anclas_estabilizadas.append(id)


func remiendo_hecho(id: StringName) -> bool:
	return id in remiendos


## Un Remiendo es permanente: se registra y se guarda en el acto.
func registrar_remiendo(id: StringName) -> void:
	if id == &"":
		push_warning("Remiendo sin id: no se guardará.")
		return
	if not remiendo_hecho(id):
		remiendos.append(id)
		guardar()


func evento_ocurrido(id: StringName) -> bool:
	return id in eventos


## Registra un acontecimiento único y guarda en el acto.
func registrar_evento(id: StringName) -> void:
	if not evento_ocurrido(id):
		eventos.append(id)
		guardar()
		evento_registrado.emit(id)


func fragmento_obtenido_ya(id: StringName) -> bool:
	return id in fragmentos


func registrar_fragmento(id: StringName) -> void:
	if not fragmento_obtenido_ya(id):
		fragmentos.append(id)
		guardar()
		fragmento_obtenido.emit(id)


func existe_partida() -> bool:
	return FileAccess.file_exists(ruta_guardado)


## Empieza de cero: vacía la memoria y borra el archivo de guardado.
func nueva_partida() -> void:
	borrar_memoria()
	if existe_partida():
		DirAccess.remove_absolute(ProjectSettings.globalize_path(ruta_guardado))


## Descanso en un Ancla: restaura a Nereth, fija la reaparición, reinicia la
## zona y guarda.
func descansar(nereth: Nereth, id: StringName, posicion: Vector3) -> void:
	ancla_actual = id
	var escena: Node = nereth.get_tree().current_scene
	escena_ancla = escena.scene_file_path if escena else ""
	posicion_reaparicion = posicion
	hay_reaparicion = true
	nereth.restaurar()
	nereth.get_tree().call_group(GRUPO_REINICIO, &"reiniciar")
	guardar()
	descanso_realizado.emit()


## Tras una derrota: Nereth vuelve al último Ancla con todo restaurado.
func reaparecer(nereth: Nereth) -> void:
	# Si el último Ancla está en otra sala, se viaja a ella.
	var escena: Node = nereth.get_tree().current_scene
	var escena_actual: String = escena.scene_file_path if escena else ""
	if hay_reaparicion and escena_ancla != "" and escena_actual != "" and escena_ancla != escena_actual:
		GestorSalas.global().ir_a_posicion(escena_ancla, posicion_reaparicion, true)
		return
	if hay_reaparicion:
		nereth.reaparecer(posicion_reaparicion)
	nereth.restaurar()
	nereth.get_tree().call_group(GRUPO_REINICIO, &"reiniciar")


func guardar() -> bool:
	var datos: Dictionary = {
		"version": VERSION_GUARDADO,
		"anclas_estabilizadas": anclas_estabilizadas.map(func(id: StringName) -> String: return String(id)),
		"remiendos": remiendos.map(func(id: StringName) -> String: return String(id)),
		"eventos": eventos.map(func(id: StringName) -> String: return String(id)),
		"fragmentos": fragmentos.map(func(id: StringName) -> String: return String(id)),
		"ancla_actual": String(ancla_actual),
		"escena_ancla": escena_ancla,
		"posicion_reaparicion": [posicion_reaparicion.x, posicion_reaparicion.y, posicion_reaparicion.z],
		"hay_reaparicion": hay_reaparicion,
	}
	var archivo: FileAccess = FileAccess.open(ruta_guardado, FileAccess.WRITE)
	if archivo == null:
		push_error("No se pudo guardar la partida en %s" % ruta_guardado)
		return false
	archivo.store_string(JSON.stringify(datos, "\t"))
	archivo.close()
	guardada.emit()
	return true


func cargar() -> bool:
	if not FileAccess.file_exists(ruta_guardado):
		return false
	var datos: Variant = JSON.parse_string(FileAccess.get_file_as_string(ruta_guardado))
	if not datos is Dictionary:
		push_warning("Guardado ilegible en %s; se ignora." % ruta_guardado)
		return false
	var d: Dictionary = datos
	borrar_memoria()
	for id: Variant in d.get("anclas_estabilizadas", []):
		anclas_estabilizadas.append(StringName(str(id)))
	for id: Variant in d.get("remiendos", []):
		remiendos.append(StringName(str(id)))
	for id: Variant in d.get("eventos", []):
		eventos.append(StringName(str(id)))
	for id: Variant in d.get("fragmentos", []):
		fragmentos.append(StringName(str(id)))
	ancla_actual = StringName(str(d.get("ancla_actual", "")))
	escena_ancla = str(d.get("escena_ancla", ""))
	var p: Array = d.get("posicion_reaparicion", [0.0, 0.0, 0.0])
	posicion_reaparicion = Vector3(float(p[0]), float(p[1]), float(p[2]))
	hay_reaparicion = bool(d.get("hay_reaparicion", false))
	return true


## Vacía el estado en memoria (no toca el archivo).
func borrar_memoria() -> void:
	anclas_estabilizadas.clear()
	remiendos.clear()
	eventos.clear()
	fragmentos.clear()
	ancla_actual = &""
	escena_ancla = ""
	posicion_reaparicion = Vector3.ZERO
	hay_reaparicion = false
