extends KinematicBody2D

onready var timer_giro = $TimerGiro
onready var campo_de_vision = $CampoDeVision

var esta_mirando = false
var jugador_en_zona = null

# Bandera para evitar que el castigo se ejecute múltiples veces seguidas
var ya_castigado = false

# Variables para comparar la posición
var posicion_inicial = Vector2.ZERO
var margen_tolerancia = 2.0 # Píxeles de margen antes de castigar

func _ready():
	randomize()
	timer_giro.connect("timeout", self, "_on_TimerGiro_timeout")
	_reiniciar_timer_aleatorio()

func _process(_delta):
	# Solo evalúa si la profesora YA está mirando activamente
	if esta_mirando and jugador_en_zona != null and not ya_castigado:
		_evaluar_cambio_de_posicion()

func _on_TimerGiro_timeout():
	ya_castigado = false
	_cambiar_estado_mirada(!esta_mirando)
	_reiniciar_timer_aleatorio()

func _reiniciar_timer_aleatorio():
	var tiempo_random = rand_range(2.0, 4.0)
	timer_giro.wait_time = tiempo_random
	timer_giro.start()

func _cambiar_estado_mirada(debe_mirar: bool):
	if debe_mirar:
		# 1. Giramos el Sprite visualmente
		$Sprite.rotation_degrees = 0
		print("¡La profesora se está dando vuelta!")
		
		# Mantenemos esta_mirando en FALSE durante el medio segundo de gracia
		esta_mirando = false
		
		# 2. Esperamos el tiempo de reacción
		yield(get_tree().create_timer(0.5), "timeout")
		
		# 3. Guardamos la posición inicial DEL MOMENTO en que termina el medio segundo
		if jugador_en_zona != null:
			posicion_inicial = jugador_en_zona.global_position
		
		# 4. AHORA SÍ activamos la mirada activa para empezar a castigar
		esta_mirando = true
		print("¡La profesora está MIRANDO ATENTAMENTE!")
	else:
		# De espaldas: desactivamos la mirada inmediatamente
		esta_mirando = false
		$Sprite.rotation_degrees = 180
		print("La profesora se volvió a dar de espaldas.")

func _evaluar_cambio_de_posicion():
	var distancia_movida = jugador_en_zona.global_position.distance_to(posicion_inicial)
	
	if distancia_movida > margen_tolerancia:
		ya_castigado = true
		
		print("¡TE ATRAPÓ! Restando 1 vida y volviendo al principio...")
		Global.Llamdos_de_atencion += 1
		print("Llamados de atención: ", Global.Llamdos_de_atencion)
		
		# Mandar al alumno al inicio del camino
		var aula = get_tree().current_scene
		if aula.has_method("reiniciar_alumno"):
			aula.reiniciar_alumno()
		
		# Espera 1.5 segundos antes de volver a ponerse de espaldas
		yield(get_tree().create_timer(1.5), "timeout")
		
		# Volver a ponerse de espaldas
		_cambiar_estado_mirada(false)
		_reiniciar_timer_aleatorio()

func _on_CampoDeVision_area_entered(area):
	if area.is_in_group("Jugador"):
		jugador_en_zona = area

func _on_CampoDeVision_area_exited(area):
	if area == jugador_en_zona:
		jugador_en_zona = null
