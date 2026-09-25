extends CanvasLayer


onready var Vida = $Control/ProgressBar


func _ready():
	$Control/HBoxContainer/Button.icon = preload("res://Armas/capacitor/capacitor bomba.png")
	$Control/HBoxContainer/Button2.icon = preload("res://Armas/capacitor/capacitor bomba.png")
	$Control/HBoxContainer/Button3.icon = preload("res://Armas/capacitor/capacitor bomba.png")
	Vida.value = Global.vidajugador
	var player = get_tree().get_nodes_in_group("player")[0]
	player.connect("vida_cambiada", self, "_on_vida_cambiada")
	
func _process(delta):
	$moneda/Label.text=str(Global.moneda)


func _on_vida_cambiada(nueva_vida: int) -> void:
	Vida.value = nueva_vida
