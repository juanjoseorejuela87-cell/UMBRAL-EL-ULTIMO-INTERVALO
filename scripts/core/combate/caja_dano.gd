class_name CajaDano
extends Area3D
## Zona que puede recibir golpes (hurtbox). El dueño escucha golpe_recibido.

signal golpe_recibido(info: InfoGolpe)

## Si es false, los golpes se ignoran (p. ej. durante la invulnerabilidad).
var activa: bool = true


func recibir_golpe(info: InfoGolpe) -> bool:
	if not activa:
		return false
	golpe_recibido.emit(info)
	return true
