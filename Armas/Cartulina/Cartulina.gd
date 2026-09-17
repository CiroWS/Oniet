extends Node2D

var estado_ataque = false
var danio = 25

func _ready():
	pass # Replace with function body.



func _input(event):
	if event.is_action_pressed("Disparo"):
		ataque()


func ataque(): 
	print("Atque")
	#animacion
	estado_ataque = true
	$pegada.start()
	


func _on_Area2D_body_entered(body):
	if body.is_in_group("Enemigos"):
		if body.has_method("recibir_danio"):
			body.recibir_danio(danio)


func _on_pegada_timeout():
	print("Deja de atacar")
