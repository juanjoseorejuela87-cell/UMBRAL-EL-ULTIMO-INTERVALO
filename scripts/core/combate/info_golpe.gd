class_name InfoGolpe
extends RefCounted
## Datos de un golpe que viaja de una CajaGolpe a una CajaDano.

enum TipoDano { FISICO, RESONANTE }

var dano: float = 0.0
var dano_postura: float = 0.0
var tipo: TipoDano = TipoDano.FISICO
## Sentido horizontal del golpe (1 = hacia la derecha).
var direccion: float = 1.0
var origen: Node3D
var nombre_ataque: StringName = &""
## Multiplicador que aplica el receptor si está en Ruptura (Golpe de Umbral).
var multiplicador_critico: float = 2.5
## Lo marca el receptor si el golpe fue un Golpe de Umbral.
var critico: bool = false
## Daño final aplicado por el receptor.
var dano_aplicado: float = 0.0
