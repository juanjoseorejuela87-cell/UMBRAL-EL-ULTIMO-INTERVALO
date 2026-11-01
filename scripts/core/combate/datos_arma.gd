class_name DatosArma
extends Resource
## Conjunto de ataques de una familia de armas (Espada del Umbral, Mandoble...).

@export var nombre: String = ""
## Cadena de ataques ligeros en orden.
@export var ligeros: Array[DatosAtaque] = []
@export var pesado: DatosAtaque
@export var aereo: DatosAtaque
