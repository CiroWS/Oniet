extends KinematicBody2D



onready var timer_giro = $TimerGiro
onready var campo_de_vision = $CampoDeVision

var esta_mirando = false
var jugador_en_zona = null

# Variables para comparar la posición
var posicion_inicial = Vector2.ZERO
var margen_tolerancia = 2.0 # Píxeles que se permite mover antes de castigar

func _ready():
	timer_giro.connect("timeout", self, "_on_TimerGiro_timeout")
	campo_de_vision.connect("body_entered", self, "_on_CampoDeVision_body_entered")
	campo_de_vision.connect("body_exited", self, "_on_CampoDeVision_body_exited")

func _process(delta):
	# Solo evaluamos si el profesor está de frente Y el jugador está en su área
	if esta_mirando and jugador_en_zona != null:
		_evaluar_cambio_de_posicion()

func _on_TimerGiro_timeout():
	esta_mirando = !esta_mirando
	
	if esta_mirando:
		print("¡El profesor se dio vuelta!")
		
		# SI EL JUGADOR ESTÁ EN EL ÁREA, GUARDAMOS SU POSICIÓN EN ESTE INSTANTE
		if jugador_en_zona != null:
			posicion_inicial = jugador_en_zona.global_position
			print("Posición registrada al girar: ", posicion_inicial)
			
	else:
		print("El profesor se volvió a dar de espaldas.")

func _evaluar_cambio_de_posicion():

	var distancia_movida = jugador_en_zona.global_position.distance_to(posicion_inicial)
	

	if distancia_movida > margen_tolerancia:
		print("¡Te atrapó! Te moviste ", distancia_movida, " píxeles.")
		

		Global.vidas -= 1
		print("Vidas restantes: ", Global.vidas)
		
	
		esta_mirando = false
		_castigar_jugador()

func _castigar_jugador():
	
	jugador_en_zona.global_position = Vector2(100, 100)

func _on_CampoDeVision_body_entered(body):
	if body.is_in_group("Jugador"):
		jugador_en_zona = body
		
		if esta_mirando:
			posicion_inicial = jugador_en_zona.global_position

func _on_CampoDeVision_body_exited(body):
	if body == jugador_en_zona:
		jugador_en_zona = null
