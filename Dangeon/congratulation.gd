extends CanvasLayer

func _ready():
	$jugadoranimacion.play("subiendo")
	$fondo.play("fondo")




func _on_jugadoranimacion_animation_finished(anim_name):
	if anim_name=="subiendo":
		get_tree().change_scene("res://mapa/mapa.tscn")
