extends Node

var Vidas : int = 10

var vidajugador : int = 200

var Llamdos_de_atencion : int = 0 

var monedas : int = 0

var moneda : int = 0

var armas = [true, false, false, false, false]

var posicion

var bicho

onready var rng : RandomNumberGenerator = RandomNumberGenerator.new()
func random(a, b):
	rng.randomize()
	return rng.randf_range(a, b)
 
