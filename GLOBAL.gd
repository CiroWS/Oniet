extends Node

var Vidas : int = 10

var vidajugador : int = 200

var Llamdos_de_atencion : int = 0 

var monedas : int = 0

var moneda : int = 1000

var armas = [true, false, false, false, false]

var posicion

var bicho

var Armas_activas = true
var figus : int = 1

signal nopausa(k)

onready var rng : RandomNumberGenerator = RandomNumberGenerator.new()
func random(a, b):
	rng.randomize()
	return rng.randf_range(a, b)
 
signal acertijo_resuelto(profe_id)

var acertijos_resueltos = [false, false, false, false, false]

func resolver_acertijo(profe_id: int):
	if not acertijos_resueltos[profe_id - 1]:
		acertijos_resueltos[profe_id - 1] = true
		emit_signal("acertijo_resuelto", profe_id)
