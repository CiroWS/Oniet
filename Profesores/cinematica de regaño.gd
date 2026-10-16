extends CanvasLayer

var cine: Array = [
	{
		"imagen": preload("res://Profesores/Maestro regañando al estudiante avergonzado.png"),
		"nombre": "Maestro",
		"dialogo": "Que haces aca afuera..."
	},
	{
		"imagen": preload("res://Profesores/Maestro y alumno ante la puerta (1).png"),
		"nombre": "Maestro",
		"dialogo": "Vamos, volve al aula, ya te va a llegar la sancion"
	}]
	
var indice: int = 0
var cambiando: bool = false

func _ready():
	cambiando = true
	$AnimationPlayer.play("transicion")
	yield(get_tree().create_timer(0.5), "timeout")
	mostrardiapositiva()

func _input(event):
	if event.is_action_pressed("espacio") and cambiando==false:
		$p.play()
		cambiar()

func cambiar():
	indice+=1
	if indice>=cine.size():
		get_tree().change_scene("res://Aula/Aula.tscn")
		return
	
	cambiando = true
	$AnimationPlayer.play("transicion")
	yield(get_tree().create_timer(0.5), "timeout")
	mostrardiapositiva()
	

func mostrardiapositiva():
	var datos = cine[indice]
	$imagen.texture = datos["imagen"]
	$dialogo/prota.text = datos["nombre"]
	$dialogo/texto.text = datos["dialogo"]

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name=="transicion":
		cambiando=false
