extends Control




func _on_Button2_pressed():
	get_tree().quit()


func _on_Button_pressed():
	get_tree().change_scene("res://Aula/Aula.tscn")


func _on_musica_finished():
	$musica.play()
