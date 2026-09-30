extends Node2D

var estado_ataque = false
var danio = 25
var ya_golpeados = []

func _ready():
	ataque()

func ataque():
	estado_ataque = true
	$pegada.start()
	yield(get_tree(), "physics_frame")
	for body in $Area2D.get_overlapping_bodies():
		golpear(body)

func _on_Area2D_body_entered(body):
	golpear(body)

func golpear(body):
	if not estado_ataque:
		return
	if body in ya_golpeados:
		return
	if body.is_in_group("Enemigos") and body.has_method("recibir_danio"):
		ya_golpeados.append(body)
		body.recibir_danio(danio)

func _on_pegada_timeout():
	estado_ataque = false
	queue_free()
