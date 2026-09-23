extends CanvasLayer



func _input(event):
	if event.is_action_pressed("esc"):
		$Pausad.visible = true
		$BG.visible = true
		get_tree().paused = true





func _on_Cont_pressed():
	$Pausad.visible= false
	$BG.visible = false
	get_tree().paused = false


func _on_Sal_pressed():
	$BG.visible = false
	get_tree().paused = false
	get_tree().change_scene("res://Menus/Menu_principal/Menu_principal.tscn")


func _on_pausa_finished():
	$pausa.play()
