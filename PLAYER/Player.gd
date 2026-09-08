extends KinematicBody2D

var speed = 100
onready var motion = Vector2.ZERO

var ultimo_mov = "Frente"

func get_axis() -> Vector2:
	var axis = Vector2.ZERO
	if axis.y == 0:
		axis.x = int(Input.is_action_pressed("ui_right"))-int(Input.is_action_pressed("ui_left"))
	if axis.x == 0:
		axis.y = int(Input.is_action_pressed("ui_down"))-int(Input.is_action_pressed("ui_up"))
	return axis

func motion_ctrl(): 
	if get_axis() == Vector2.ZERO:
		motion = Vector2.ZERO
	else:
		motion = get_axis().normalized()*speed
	if motion==Vector2(0,-100):
		$AnimatedSprite.play("Espalda")
		ultimo_mov="Espalda"
	elif motion==Vector2(0,100):
		$AnimatedSprite.play("Caminar")
		ultimo_mov="Frente"
	elif motion==Vector2(100,0):
		$AnimatedSprite.flip_h=true
		$AnimatedSprite.play("Costado")
		ultimo_mov="Costado"
	elif motion==Vector2(-100,0):
		$AnimatedSprite.flip_h=false
		$AnimatedSprite.play("Costado")
		ultimo_mov="Costado"
	elif motion==Vector2.ZERO:
		if ultimo_mov == "Espalda":
			$AnimatedSprite.play("Idle_Espalda")
		elif ultimo_mov == "Frente":
			$AnimatedSprite.play("Idle_Frente")
		elif ultimo_mov == "Costado":
			$AnimatedSprite.play("Idle_Costado")
func _physics_process(delta):
	motion_ctrl() 
	motion = move_and_collide(motion * delta)
	

