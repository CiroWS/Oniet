extends KinematicBody2D

onready var timer_giro = $TimerGiro
onready var campo_de_vision = $CampoDeVision

var esta_mirando = false
var jugador_en_zona = null

# Variables para comparar la posición
var posicion_inicial = Vector2.ZERO
var margen_tolerancia = 2.0 # Píxeles de margen antes de castigar

func _ready():
	timer_giro.connect("timeout", self, "_on_TimerGiro_timeout")
	campo_de_vision.connect("body_entered", self, "_on_CampoDeVision_body_entered")
	campo_de_vision.connect("body_exited", self, "_on_CampoDeVision_body_exited")

func _process(delta):
	# Evaluamos continuamente mientras esté mirando y estés dentro de su área
	if esta_mirando and jugador_en_zona != null:
		_evaluar_cambio_de_posicion()

func _on_TimerGiro_timeout():
	# Cambia alternadamente entre mirar y dar la espalda
	_cambiar_estado_mirada(!esta_mirando)

func _cambiar_estado_mirada(debe_mirar: bool):
	esta_mirando = debe_mirar
	
	if esta_mirando:
		print("¡El profesor se dio vuelta y está MIRANDO!")
		# Registrar la posición exacta del jugador en el momento en que se da vuelta
		if jugador_en_zona != null:
			posicion_inicial = jugador_en_zona.global_position
	else:
		print("El profesor se volvió a dar de espaldas.")

func _evaluar_cambio_de_posicion():
	var distancia_movida = jugador_en_zona.global_position.distance_to(posicion_inicial)
	
	# Si el jugador superó el margen de tolerancia de movimiento
	if distancia_movida > margen_tolerancia:
		print("¡TE ATRAPÓ! Restando 1 vida y volviendo a darse vuelta...")
		
		# 1. Restamos la vida en la variable global
		Global.Llamdos_de_atencion += 1
		print("Llamados de atencion: ", Global.Llamdos_de_atencion)
		
		# 2. Obligamos al profesor a ponerse de espaldas INMEDIATAMENTE
		_cambiar_estado_mirada(false)
		
		# 3. Reiniciamos el Timer para que empiece a contar desde cero de espaldas
		timer_giro.start()

func _on_CampoDeVision_body_entered(body):
	if body.is_in_group("Jugador"):
		jugador_en_zona = body
		if esta_mirando:
			posicion_inicial = jugador_en_zona.global_position

func _on_CampoDeVision_body_exited(body):
	if body == jugador_en_zona:
		jugador_en_zona = null
