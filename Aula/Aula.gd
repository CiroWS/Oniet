extends Node2D

onready var hijo_camino = $Camino/Hijocamino
onready var alumno_sprite = $AlumnoSprite

func _ready():
	alumno_sprite.position = hijo_camino.position

func _input(event):
	if event.is_action_pressed("ui_accept"):
		hijo_camino.offset += 10
		alumno_sprite.position = hijo_camino.position

# Función que invoca el profesor cuando detecta movimiento
func reiniciar_alumno():
	hijo_camino.offset = 0
	alumno_sprite.position = hijo_camino.position


func _on_Area2D_area_entered(area):
	if area.is_in_group("Jugador"):
		get_tree().change_scene("res://mapa/mapa.tscn")
