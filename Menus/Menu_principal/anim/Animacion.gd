extends Node2D

func _ready():
	$Chiri.play("default")
	$Ciro.play("default")
	$Lau.play("default")
	$Ishma.play("default")

func _physics_process(delta):
	$Chiri.position.x += 5
	$Ciro.position.x += 5
	$Lau.position.x += 5
	$Ishma.position.x += 5


func _on_Timer_timeout():
	get_tree().change_scene("res://cinematica/cinematica.tscn")
