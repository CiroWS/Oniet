extends KinematicBody2D

var speed = 100
onready var motion = Vector2.ZERO



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

func _physics_process(delta):
	motion_ctrl() 
	motion = move_and_collide(motion * delta)
	
