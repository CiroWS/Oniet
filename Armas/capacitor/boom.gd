extends Node2D


func _on_Area2D_body_entered(body):
	if body.is_in_group("Enemigos"):
		if body.has_method("recibir_danio"):
				body.recibir_danio(50)


func _on_AnimatedSprite_animation_finished():
	queue_free()
