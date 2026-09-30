extends Control
var Mano = preload("res://Mano_Cursor.png")

func _on_Button2_pressed():
	get_tree().quit()


func _on_Button_pressed():
	get_tree().change_scene("res://Menus/Menu_principal/anim/Animacion.tscn")


func _on_musica_finished():
	$musica.play()
func _ready():
	Input.set_custom_mouse_cursor(Mano,Input.CURSOR_ARROW,Vector2(16,16))
