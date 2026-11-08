extends SceneTree
## Vista previa del HUD rediseñado en el Salón del Prefecto, para revisar el
## aspecto sin abrir el editor. Fotograma 0-80: combate con daño y postura
## (barra rezagada ámbar, QUIEBRE); 90+: caída de Nereth (pantalla de muerte).
## Uso:
##   Godot_console.exe --path D:\UMBRAL -s res://tools/vista_hud.gd --write-movie C:\ruta\f.png --fixed-fps 30 --quit-after 150

const SALON: String = "res://scenes/niveles/elyndor/salon_prefecto.tscn"

var _sala: Node
var _nereth: Nereth
var _prefecto: Prefecto
var _fotograma: int = 0


func _initialize() -> void:
	ConfigControles.registrar()
	GestorPartida.global().ruta_guardado = "user://vista_hud.json"
	GestorPartida.global().borrar_memoria()
	_sala = (load(SALON) as PackedScene).instantiate()
	root.add_child(_sala)
	_nereth = _sala.get_node("Nereth") as Nereth
	_prefecto = _sala.get_node("Prefecto") as Prefecto
	_prefecto.ia_activa = false
	process_frame.connect(_cada_fotograma)


func _cada_fotograma() -> void:
	_fotograma += 1
	match _fotograma:
		5:
			_nereth.global_position = _prefecto.global_position + Vector3(-4.0, 0.5, 0.0)
		10:
			_prefecto.combate_iniciado.emit()
		30:
			_nereth.vida.recibir_dano(30.0)
			_prefecto.vida.recibir_dano(_prefecto.vida.maximo * 0.3)
			_prefecto.postura.acumular(_prefecto.postura.maximo * 0.55)
			_nereth.resistencia.consumir(_nereth.resistencia.actual + 1.0)
			_nereth.resonancia.establecer(_nereth.resonancia.maximo * 0.6)
		33:
			_nereth.esencias.cargas = 2
			_nereth.esencias.cargas_cambiadas.emit(2, 3)
		60:
			_prefecto.postura.acumular(_prefecto.postura.maximo)
		90:
			_nereth.vida.recibir_dano(_nereth.vida.maximo * 10.0)
