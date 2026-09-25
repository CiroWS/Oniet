extends CanvasLayer

func _ready():
	$jugadoranimacion.play("subiendo")
	$fondo.play("fondo")
	$sonido.play()



func _on_jugadoranimacion_animation_finished(anim_name):
	if anim_name=="subiendo":
		get_tree().change_scene("res://mapa/mapa.tscn")


func _on_sonido_finished():
	$sonido.play()
