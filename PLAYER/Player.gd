extends KinematicBody2D

export (int) var speed = 200
export (int) var vida_max = 200
onready var motion = Vector2.ZERO
var ultimo_mov = "Idle_Costado"
var canshoot = true
export (PackedScene) var Cremona
export (PackedScene) var Cartulina
export (PackedScene) var Lapiz
export (PackedScene) var Piedrapapeltijera
export (PackedScene) var Capacitor
var arma = "cartulina"

# True mientras el jugador está en un diálogo (por ej. con Profe_1).
# Mientras esté activo, no se mueve ni dispara.
var dialog_active = false

signal vida_cambiada(nueva_vida)


func _ready():
	add_to_group("Jugador")
	Global.vidajugador = vida_max



func _input(event):
	if dialog_active:
		return

	if event.is_action_pressed("Disparo") and canshoot:
		Disparo_ctrl()
		canshoot = false
		$cooldown.start()
	elif event.is_action_pressed("cartulina"):
		$cooldown.wait_time = 0.2
		arma = "cartulina"
	elif event.is_action_pressed("cremona"):
		$cooldown.wait_time = 0.5
		arma = "cremona"
	elif event.is_action_pressed("lapiz"):
		$cooldown.wait_time = 0.5
		arma = "lapiz"
	elif event.is_action_pressed("piedrapapeltijera"):
		$cooldown.wait_time = 1.0
		arma = "piedrapapeltijera"
	elif event.is_action_pressed("capacitor"):
		$cooldown.wait_time = 0.5
		arma = "capacitor"


# Llamado por un NPC (ej. Profe_1) para bloquear/desbloquear al jugador
# mientras dura el diálogo.
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
	# Sin invulnerabilidad: si te pegan dos enemigos juntos, se suman los dos golpes.
	# El control de "no me peguen demasiado seguido" ahora vive en cada enemigo
	# (cooldown de ataque en Enemigo_Peque.gd).
	Global.vidajugador -= cantidad
	# Flash rojo solo como feedback visual, no bloquea nada
	modulate = Color(1, 0.4, 0.4)
	yield(get_tree().create_timer(0.15), "timeout")
	modulate = Color(1, 1, 1)
	if Global.vidajugador <= 0:
		queue_free()
	emit_signal("vida_cambiada",Global.vidajugador)


func _on_cooldown_timeout():
	canshoot = true
