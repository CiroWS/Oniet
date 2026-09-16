extends KinematicBody2D

export var vida = 100
export var danio = 20
export var velocidad = 90

var jugador = null
var puede_atacar = true
var esta_muerto = false
var esta_atacando = false
var objetivo_actual = null

onready var timer_ataque = $TimerAtaque
onready var area_ataque = $AreaAtaque
onready var sprite = $AnimatedSprite

func _ready():
	add_to_group("Enemigos")
	
	var jugadores = get_tree().get_nodes_in_group("Jugador")
	if jugadores.size() > 0:
		jugador = jugadores[0]
	
	sprite.connect("animation_finished", self, "_on_AnimatedSprite_animation_finished")
	sprite.connect("frame_changed", self, "_on_AnimatedSprite_frame_changed")

func _process(_delta):
	if esta_muerto or esta_atacando:
		return

	# Si el jugador no se encontró al inicio, intenta buscarlo de nuevo
	if !is_instance_valid(jugador):
		var jugadores = get_tree().get_nodes_in_group("Jugador")
		if jugadores.size() > 0:
			jugador = jugadores[0]
		return

	# Persecución constante
	var direccion = (jugador.global_position - global_position).normalized()
	move_and_slide(direccion * velocidad)
	
	if direccion.x != 0:
		sprite.flip_h = direccion.x < 0
	sprite.play("caminar")
	
	# Detectar si entra en área para morder
	if puede_atacar:
		for body in area_ataque.get_overlapping_bodies():
			if body.is_in_group("Jugador"):
				iniciar_ataque(body)
				break

func iniciar_ataque(objetivo):
	puede_atacar = false
	esta_atacando = true
	objetivo_actual = objetivo
	sprite.play("atacar")
	timer_ataque.start()

func morder_impacto():
	if objetivo_actual and is_instance_valid(objetivo_actual):
		if objetivo_actual.has_method("recibir_danio"):
			objetivo_actual.recibir_danio(danio)

func recibir_danio(cantidad):
	if esta_muerto:
		return
	vida -= cantidad
	if vida <= 0:
		ejecutar_muerte()

func ejecutar_muerte():
	esta_muerto = true
	$CollisionShape2D.set_deferred("disabled", true)
	area_ataque.get_node("CollisionShape2D").set_deferred("disabled", true)
	if has_node("Hitbox/CollisionShape2D"):
		$Hitbox/CollisionShape2D.set_deferred("disabled", true)
	sprite.play("Dead")

func _on_AnimatedSprite_frame_changed():
	if sprite.animation == "atacar" and sprite.frame == 2:
		morder_impacto()

func _on_AnimatedSprite_animation_finished():
	if sprite.animation == "atacar":
		esta_atacando = false
		objetivo_actual = null
	elif sprite.animation == "Dead":
		queue_free()

func _on_TimerAtaque_timeout():
	puede_atacar = true

func _on_Hitbox_area_entered(area):
	if area.is_in_group("Cremona"):
		recibir_danio(50)
		area.queue_free() 
