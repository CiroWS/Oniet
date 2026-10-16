extends KinematicBody2D

func _physics_process(delta):
	if $RayCast2D.is_colliding():
		if $RayCast2D.get_collider() and $RayCast2D.get_collider().is_in_group("player"):
			Global.sancion+=1
			get_tree().change_scene("res://Profesores/cinematica de regaño.tscn")


func _on_deteccion_body_entered(body):
	if body.is_in_group("player"):
		Global.sancion+=1
		get_tree().change_scene("res://Profesores/cinematica de regaño.tscn")
