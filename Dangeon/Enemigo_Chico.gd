extends KinematicBody2D

export var vida = 50
export var danio = 20
export var velocidad = 90

var jugador = null
var puede_atacar = true
var esta_muerto = false
var esta_atacando = false

# Target del jugador guardado para infligir daño en el frame preciso
var objetivo_actual = null

onready var timer_ataque = $TimerAtaque
onready var area_ataque = $AreaAtaque
onready var sprite = $AnimatedSprite

func _ready():
	add_to_group("Enemigos")
	
	# Buscar al jugador en el grupo "Jugador"
	var jugadores = get_tree().get_nodes_in_group("Jugador")
	if jugadores.size() > 0:
		jugador = jugadores[0]
	
	# Conectar señales del AnimatedSprite por código
	sprite.connect("animation_finished", self, "_on_AnimatedSprite_animation_finished")
	sprite.connect("frame_changed", self, "_on_AnimatedSprite_frame_changed")

func _process(_delta):
	# Si está muerto o atacando, no debe moverse ni procesar persecución
	if esta_muerto:
		return
		
	if esta_atacando:
		return

	if jugador:
		# Perseguir al jugador constantemente
		var direccion = (jugador.global_position - global_position).normalized()
		move_and_slide(direccion * velocidad)
		
		# Cambiar animación de caminar y orientar el sprite
		if direccion.x != 0:
			sprite.flip_h = direccion.x < 0
		sprite.play("caminar")
		
		# Verificar si el jugador está en rango para morder
		if puede_atacar:
			for body in area_ataque.get_overlapping_bodies():
				if body.is_in_group("Jugador"):
					iniciar_ataque(body)
					break

func iniciar_ataque(objetivo):
	puede_atacar = false
	esta_atacando = true
	objetivo_actual = objetivo
	
	# Inicia la animación de ataque desde el principio
	sprite.play("atacar")
	timer_ataque.start()

func morder_impacto():
	# Esta función inflige el daño real
	if objetivo_actual and is_instance_valid(objetivo_actual):
		print("¡El enemigo te mordió y causó ", danio, " de daño!")
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
	
	# Desactivar las colisiones para que no siga estorbando ni recibiendo golpes
	$CollisionShape2D.set_deferred("disabled", true)
	area_ataque.get_node("CollisionShape2D").set_deferred("disabled", true)
	
	# Detener movimiento e iniciar animación de muerte
	sprite.play("Dead")

# --- SEÑALES DEL ANIMATEDSPRITE ---

func _on_AnimatedSprite_frame_changed():
	# Si está en la animación de ataque y llega al frame donde muerde
	# Cambia el número 2 por el número de frame exacto donde se ve el golpe (empieza en 0)
	if sprite.animation == "Ataque" and sprite.frame == 2:
		morder_impacto()

func _on_AnimatedSprite_animation_finished():
	if sprite.animation == "Ataque":
		esta_atacando = false
		objetivo_actual = null
		
	elif sprite.animation == "Dead":
		# Espera a que termine la animación de muerte completa antes de borrar el nodo
		queue_free()

func _on_TimerAtaque_timeout():
	puede_atacar = true
