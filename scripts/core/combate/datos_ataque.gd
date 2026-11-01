class_name DatosAtaque
extends Resource
## Definición de un ataque: tiempos de cada fase, daño y caja de golpe.
## Tiempos en segundos. Diseño: documentation/GAMEPLAY.md §2.

@export var nombre: StringName = &""

@export_group("Fases")
## Carga máxima mientras se mantiene el botón (0 = no cargable).
@export var carga_maxima: float = 0.0
@export var preparacion: float = 0.1
@export var activo: float = 0.08
@export var recuperacion: float = 0.22
## Segundos desde el inicio de la recuperación a partir de los que se puede
## encadenar otro ataque o cancelar con esquiva.
@export var inicio_cancelacion: float = 0.05

@export_group("Efecto")
@export var dano: float = 10.0
@export var dano_postura: float = 8.0
@export var tipo_dano: InfoGolpe.TipoDano = InfoGolpe.TipoDano.FISICO
## Multiplicador de daño y postura con la carga completa.
@export var multiplicador_carga: float = 1.6
@export var coste_resistencia: float = 12.0
## Resonancia que gana Nereth al conectar (clave en régimen de Amenaza).
@export var ganancia_resonancia: float = 4.0
## Velocidad hacia delante al empezar el ataque (solo en suelo).
@export var impulso: float = 1.5

@export_group("Caja de golpe")
@export var tamano_caja: Vector3 = Vector3(1.4, 1.0, 1.0)
## Posición relativa a Nereth mirando a la derecha; X se refleja al girar.
@export var desplazamiento_caja: Vector3 = Vector3(0.9, 1.0, 0.0)
