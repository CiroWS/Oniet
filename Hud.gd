extends CanvasLayer


onready var Vida = $Control/ProgressBar


func _ready():
	Vida.value = Global.vidajugador
	var player = get_tree().get_nodes_in_group("player")[0]
	player.connect("vida_cambiada", self, "_on_vida_cambiada")
	$Control/ProgressBar/AnimatedSprite.play("default")
	var botones = $Control/HBoxContainer.get_children()
	for i in range(Global.armas.size()):
		botones[i].disabled = not Global.armas[i]
		
	
	
func _process(delta):
	$moneda/Label.text=str(Global.moneda)
	$sancion/Label.text=str(Global.sancion)
	$Mate/Label.text = str("X", Global.Mates)
	if Global.arma == "cartulina":
		$Control/HBoxContainer/Button.rect_scale = Vector2(1.2,1.2)
		$Control/HBoxContainer/Button2.rect_scale = Vector2(1,1)
		$Control/HBoxContainer/Button3.rect_scale = Vector2(1,1)
		$Control/HBoxContainer/Button4.rect_scale = Vector2(1,1)
		$Control/HBoxContainer/Button5.rect_scale = Vector2(1,1)
	elif Global.arma == "cremona":
		$Control/HBoxContainer/Button2.rect_scale = Vector2(1.2,1.2)
		$Control/HBoxContainer/Button.rect_scale = Vector2(1,1)
		$Control/HBoxContainer/Button3.rect_scale = Vector2(1,1)
		$Control/HBoxContainer/Button4.rect_scale = Vector2(1,1)
		$Control/HBoxContainer/Button5.rect_scale = Vector2(1,1)
	elif Global.arma == "capacitor":
		$Control/HBoxContainer/Button3.rect_scale = Vector2(1.2,1.2)
		$Control/HBoxContainer/Button2.rect_scale = Vector2(1,1)
		$Control/HBoxContainer/Button.rect_scale = Vector2(1,1)
		$Control/HBoxContainer/Button4.rect_scale = Vector2(1,1)
		$Control/HBoxContainer/Button5.rect_scale = Vector2(1,1)
	elif Global.arma == "lapiz":
		$Control/HBoxContainer/Button4.rect_scale =Vector2(1.2,1.2)
		$Control/HBoxContainer/Button2.rect_scale = Vector2(1,1)
		$Control/HBoxContainer/Button3.rect_scale = Vector2(1,1)
		$Control/HBoxContainer/Button.rect_scale = Vector2(1,1)
		$Control/HBoxContainer/Button5.rect_scale = Vector2(1,1)
	elif Global.arma == "piedrapapeltijera":
		$Control/HBoxContainer/Button5.rect_scale =Vector2(1.2,1.2)
		$Control/HBoxContainer/Button2.rect_scale = Vector2(1,1)
		$Control/HBoxContainer/Button3.rect_scale = Vector2(1,1)
		$Control/HBoxContainer/Button4.rect_scale = Vector2(1,1)
		$Control/HBoxContainer/Button.rect_scale = Vector2(1,1)


	if Global.dungeon==false:
		$Control.visible=false
		$Mate.visible = false
	else:
		$Control.visible=true
		$Mate.visible = true

func _on_vida_cambiada(nueva_vida: int) -> void:
	Vida.value = nueva_vida

