extends CanvasLayer

var cine: Array = [
	{
		"imagen": preload("res://cinematica/escena 1.png"),
		"nombre": "Oliver",
		"dialogo": "Solo me falta una, nose donde podre conseguirla"
	},
	{
		"imagen": preload("res://cinematica/escena 2.png"),
		"nombre": "Curso",
		"dialogo": "...Y con esa formula llegamos al resultado de 2..."
	},
	{
		"imagen": preload("res://cinematica/escena 3.png"),
		"nombre": "",
		"dialogo": ""
	},
	{
		"imagen": preload("res://cinematica/escena 4.png"),
		"nombre": "Oliver",
		"dialogo": "Nooooooo"
	},
	{
		"imagen": preload("res://cinematica/escena 5.png"),
		"nombre": "Oliver",
		"dialogo": "Mis figus :(, aparte no vino nadie"
	},
	{
		"imagen": preload("res://cinematica/escena 6.png"),
		"nombre": "Oliver",
		"dialogo": "Tengo que ir a recuperarlas"
	}
]

var indice: int = 0
var cambiando: bool = false

func _ready():
	cambiando = true
	$AnimationPlayer.play("escenas")
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
	$AnimationPlayer.play("escenas")
	yield(get_tree().create_timer(0.5), "timeout")
	mostrardiapositiva()
	

func mostrardiapositiva():
	var datos = cine[indice]
	$imagen.texture = datos["imagen"]
	$dialogo/prota.text = datos["nombre"]
	$dialogo/texto.text = datos["dialogo"]

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name=="escenas":
		cambiando=false
