extends Node2D

onready var hijo_camino = $Camino/Hijocamino
onready var alumno_sprite = $AlumnoSprite
var c = 1

func _ready():
	alumno_sprite.position = hijo_camino.position
	$musica_tensionante.play()
	$Player/Camera2D.current = false 

func _process(delta):
	if $Profesor/tension.playing==true: 
		$musica_tensionante.stop()
		c=1
	elif $Profesor/tension.playing==false:
		if c==1:
			$musica_tensionante.play()
		c+=1

func _input(event):
	if event.is_action_pressed("ui_accept"):
		hijo_camino.offset += 10
		alumno_sprite.position = hijo_camino.position


func reiniciar_alumno():
	hijo_camino.offset = 0
	alumno_sprite.position = hijo_camino.position
	Global.Llamdos_de_atencion += 1 
	if Global.Llamdos_de_atencion > 3 :
		Global.Llamdos_de_atencion = 0 
		Global.sancion+= 1 
		if Global.sancion == 12:
			get_tree().change_scene("res://Menus/Menu_principal/Menu_principal.tscn")
			Global.armas = [true , false , false , false , false ]
			Global.sancion = 0 
			Global.moneda = 0 
			Global.Llamdos_de_atencion = 0 



func _on_Area2D_area_entered(area):
	if area.is_in_group("Jugador"):
		get_tree().change_scene("res://mapa/mapa.tscn")



func _on_musica_tensionante_finished():
	$musica_tensionante.play()


func _on_murmullo_finished():
	$murmullo.play()
