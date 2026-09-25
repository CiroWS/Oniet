extends KinematicBody2D

export (int) var speed = 100
export (int) var vida_max = 200
onready var motion = Vector2.ZERO
var ultimo_mov = "Idle_Costado"
export (PackedScene) var Cremona
export (PackedScene) var Cartulina
export (PackedScene) var Lapiz
export (PackedScene) var Piedrapapeltijera
export (PackedScene) var Capacitor
var arma = "cartulina"
var canshoot = true

var dialog_active = false

signal muerte

signal vida_cambiada(nueva_vida)


func _ready():
	add_to_group("Jugador")
	Global.vidajugador = vida_max
	$AnimatedSprite.connect("frame_changed", self, "_on_AnimatedSprite_frame_changed")



func _input(event):
	if dialog_active:
		return
	if event.is_action_pressed("Disparo") and canshoot and Global.Armas_activas:
		Disparo_ctrl()
		canshoot = false
		$cooldown.start()
	elif event.is_action_pressed("cartulina") :
		$cooldown.wait_time = 0.2
		arma = "cartulina"
	elif event.is_action_pressed("cremona")and Global.armas[1]:
		$cooldown.wait_time = 0.5
		arma = "cremona"
	elif event.is_action_pressed("lapiz")and Global.armas[2]:
		$cooldown.wait_time = 0.5
		arma = "lapiz"
	elif event.is_action_pressed("piedrapapeltijera")and Global.armas[4]:
		$cooldown.wait_time = 1.0
		arma = "piedrapapeltijera"
	elif event.is_action_pressed("capacitor")and Global.armas[3]:
		$cooldown.wait_time = 0.5
		arma = "capacitor"



func set_dialog_active(value: bool) -> void:
	dialog_active = value
	if value:
		motion = Vector2.ZERO


func get_axis() -> Vector2:
	var axis = Vector2.ZERO
	if dialog_active:
		return axis
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
	emit_signal("vida_cambiada",Global.vidajugador)
	motion_ctrl()
	var collision = move_and_collide(motion * delta)


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
	elif arma == "lapiz":
		var LAPIZ = Lapiz.instance()
		add_child(LAPIZ)
		var direccion = (get_global_mouse_position() - global_position).normalized()
		var distancia = 5.0
		var inicio = global_position
		LAPIZ.position = Vector2.ZERO
		LAPIZ.rotation = direccion_mouse.angle()
		LAPIZ.position = (direccion * distancia)
		global_position = inicio + (direccion * (distancia+10))
		yield(get_tree().create_timer(0.2), "timeout")
		LAPIZ.queue_free()
	elif arma == "piedrapapeltijera":
		var PIEDRA = Piedrapapeltijera.instance()
		add_child(PIEDRA)
		PIEDRA.set_forward_direction(direccion_mouse)
	elif arma == "capacitor":
		var cap = Capacitor.instance()
		add_child(cap)
		cap.rotation = direccion_mouse.angle()
		cap.set_forward_direction(direccion_mouse)


func recibir_danio(cantidad):
	if Global.vidajugador <= 0:
			emit_signal("muerte")

	Global.vidajugador -= cantidad
	modulate = Color(1, 0.4, 0.4)
	yield(get_tree().create_timer(0.15), "timeout")
	modulate = Color(1, 1, 1)

	if Global.vidajugador <= 0:
		emit_signal("muerte")
			
			


func _on_cooldown_timeout():
	canshoot = true


func _on_AnimatedSprite_frame_changed():
	if get_axis() != Vector2.ZERO:
		$"sonido de caminata".pitch_scale = rand_range(0.85, 1.15)
		$"sonido de caminata".play()
