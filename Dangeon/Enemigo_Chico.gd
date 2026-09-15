extends KinematicBody2D

export var vida = 50
export var danio = 20
export var velocidad = 90

var jugador = null
var puede_atacar = true

onready var timer_ataque = $TimerAtaque
onready var area_ataque = $AreaAtaque

func _ready():
	add_to_group("Enemigos")
	
	# Buscar al jugador en el grupo "Jugador"
	var jugadores = get_tree().get_nodes_in_group("Jugador")
	if jugadores.size() > 0:
		jugador = jugadores[0]

func _process(_delta):
	if jugador:
		# Perseguir al jugador constantemente
		var direccion = (jugador.global_position - global_position).normalized()
		move_and_slide(direccion * velocidad)
		
		# Verificar si el jugador está en rango para morder
		if puede_atacar:
			for body in area_ataque.get_overlapping_bodies():
				if body.is_in_group("Jugador"):
					morder(body)
					break

func morder(objetivo):
	puede_atacar = false
	print("¡El enemigo te mordió y causó ", danio, " de daño!")
	
	if objetivo.has_method("recibir_danio"):
		objetivo.recibir_danio(danio)
		
	timer_ataque.start()

func _on_TimerAtaque_timeout():
	puede_atacar = true

func recibir_danio(cantidad):
	vida -= cantidad
	if vida <= 0:
		queue_free()
	



func _on_Aradao_area_entered(area):
	if area.is_in_group("Cremona"):
		queue_free()
