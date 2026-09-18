extends KinematicBody2D

export (int) var speed = 100
export (int) var vida = 100
onready var motion = Vector2.ZERO
var ultimo_mov = "Frente"
var canshoot = true
var vida_player = 100
export (PackedScene) var Cremona
export (PackedScene) var Cartulina
var arma = "cartulina"


func _ready():
	add_to_group("Jugador")
	$BarraVida.value = vida_player

func _input(event):
	if event.is_action_pressed("Disparo") and canshoot:
		Disparo_ctrl()
		canshoot = false
		$cooldown.start()
	elif event.is_action_pressed("cartulina"):
		arma = "cartulina"
	elif event.is_action_pressed("cremona"):
		arma = "cremona"
		
		

func get_axis() -> Vector2:
	var axis = Vector2.ZERO
	if axis.y == 0:
		axis.x = int(Input.is_action_pressed("D")) - int(Input.is_action_pressed("A"))
	if axis.x == 0:
		axis.y = int(Input.is_action_pressed("S")) - int(Input.is_action_pressed("W"))
	return axis

func motion_ctrl(): 
	if get_axis() == Vector2.ZERO:
		motion = Vector2.ZERO
	else:
		motion = get_axis().normalized() * speed
		
	if motion == Vector2(0, -100):
		$AnimatedSprite.play("Espalda")
		ultimo_mov = "Espalda"
	elif motion == Vector2(0, 100):
		$AnimatedSprite.play("Caminar")
		ultimo_mov = "Frente"
	elif motion == Vector2(100, 0):
		$AnimatedSprite.flip_h = true
		$AnimatedSprite.play("Costado")
		ultimo_mov = "Costado"
	elif motion == Vector2(-100, 0):
		$AnimatedSprite.flip_h = false
		$AnimatedSprite.play("Costado")
		ultimo_mov = "Costado"
	elif motion == Vector2.ZERO:
		if ultimo_mov == "Espalda":
			$AnimatedSprite.play("Idle_Espalda")
		elif ultimo_mov == "Frente":
			$AnimatedSprite.play("Idle_Frente")
		elif ultimo_mov == "Costado":
			$AnimatedSprite.play("Idle_Costado")

func _physics_process(delta):
	motion_ctrl() 
	motion = move_and_collide(motion * delta)

func Disparo_ctrl():
	var direccion_mouse = (get_global_mouse_position() - global_position).normalized()
	if arma == "cremona":
		if Cremona == null:
			return
		var CREMONA = Cremona.instance()
		get_parent().add_child(CREMONA)
		CREMONA.global_position = global_position
		CREMONA.set_forward_direction(direccion_mouse)

	elif arma == "cartulina":
		if Cartulina == null:
			return
		var CARTULINA = Cartulina.instance()
		add_child(CARTULINA)               
		CARTULINA.position = Vector2.ZERO    
		CARTULINA.rotation = direccion_mouse.angle()
	

func recibir_danio(cantidad):
	vida -= cantidad
	$BarraVida.value = vida_player
	print("Jugador recibió daño. Vida restante: ", vida)
	if vida <= 0:
		print("¡Jugador Muerto!")
		queue_free()

func _on_cooldown_timeout():
	canshoot = true

