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
	if Global.dungeon==false:
		$Control.visible=false
	else:
		$Control.visible=true

func _on_vida_cambiada(nueva_vida: int) -> void:
	Vida.value = nueva_vida

