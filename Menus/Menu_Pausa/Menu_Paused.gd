extends CanvasLayer



func _input(event):
	if event.is_action_pressed("esc"):
		$Pausad.visible = true
		get_tree().paused = true





func _on_Cont_pressed():
	$Pausad.visible= false
	get_tree().paused = false


func _on_Sal_pressed():
	get_tree().paused = false
	get_tree().change_scene("res://Menus/Menu_principal/Menu_principal.tscn")
