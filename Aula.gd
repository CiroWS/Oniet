extends Node2D


func _ready():
	$Alumno_Escape.position = $Path2D/PathFollow2D.position
func _input(event):
	if event.is_action_pressed("ui_accept"):
		$Path2D/PathFollow2D.offset += 10
		$Alumno_Escape.position = $Path2D/PathFollow2D.position
