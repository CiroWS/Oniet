extends Node2D

func _on_Area2D_body_entered(body):
	if body.is_in_group("player"):
		$vida.play()
		queue_free()
		Global.vidajugador += 25
		if Global.vidajugador > 100:
			Global.vidajugador = 100




func _on_Area2D_area_entered(area):
	if area.is_in_group("player"):
		$vida.play()
		queue_free()
		Global.vidajugador += 25
		if Global.vidajugador > 100:
			Global.vidajugador = 100

