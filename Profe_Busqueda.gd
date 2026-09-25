extends KinematicBody2D

# ================== CONFIGURACIÓN (ajustable desde el inspector) ==================
export var velocidad: float = 60.0
export var radio_vision: float = 150.0
export var angulo_vision: float = 70.0        # grados totales del cono (35° a cada lado)
export var tiempo_min_cambio: float = 1.5
export var tiempo_max_cambio: float = 3.5
export (int, LAYERS_2D_PHYSICS) var mascara_paredes = 1   # capas que bloquean la visión (paredes/mundo de esa planta)

# --- Nombres de las animaciones del AnimatedSprite (los cargás vos) ---
export var anim_lateral: String = ""    # una sola animación, se espeja según el lado
export var anim_frente: String = ""     # caminando hacia abajo / hacia la cámara
export var anim_espaldas: String = ""   # caminando hacia arriba / de espaldas

signal vio_al_jugador

var jugador = null
var direccion: Vector2 = Vector2.RIGHT
var detectado: bool = false


func _ready() -> void:
	randomize()
	var jugadores = get_tree().get_nodes_in_group("player")
	if jugadores.size() > 0:
		jugador = jugadores[0]
	elegir_nueva_direccion()


func _physics_process(delta: float) -> void:
	if detectado or jugador == null:
		return

	# --- Vagabundeo ---
	move_and_slide(direccion * velocidad)
	if is_on_wall():
		elegir_nueva_direccion()

	actualizar_animacion()

	# --- Chequeo de visión ---
	if puede_ver_al_jugador():
		detectado = true
		emit_signal("vio_al_jugador")
		# Acá conectás la señal "vio_al_jugador" desde afuera (por ejemplo en mapa.gd)
		# y ahí restás vidas de tu variable Global. Ejemplo:
		# Global.vidas -= 1


func elegir_nueva_direccion() -> void:
	var angulo = rand_range(0, TAU)
	direccion = Vector2(cos(angulo), sin(angulo))
	$TimerVagar.wait_time = rand_range(tiempo_min_cambio, tiempo_max_cambio)
	$TimerVagar.start()


func actualizar_animacion() -> void:
	var nombre_animacion: String

	if abs(direccion.x) > abs(direccion.y):
		nombre_animacion = anim_lateral
		$AnimatedSprite.flip_h = direccion.x < 0   # mira a la izquierda -> espeja el sprite
	else:
		nombre_animacion = anim_frente if direccion.y > 0 else anim_espaldas
		$AnimatedSprite.flip_h = false

	if nombre_animacion != "" and $AnimatedSprite.animation != nombre_animacion:
		$AnimatedSprite.play(nombre_animacion)


func puede_ver_al_jugador() -> bool:
	var hacia_jugador: Vector2 = jugador.global_position - global_position
	var distancia: float = hacia_jugador.length()

	if distancia > radio_vision:
		return false

	var angulo_actual = rad2deg(direccion.angle_to(hacia_jugador))
	if abs(angulo_actual) > angulo_vision / 2.0:
		return false

	return hay_linea_de_vision()


func hay_linea_de_vision() -> bool:
	var espacio = get_world_2d().direct_space_state
	var resultado = espacio.intersect_ray(global_position, jugador.global_position, [self], mascara_paredes)
	if resultado.empty():
		return true
	return resultado.collider == jugador


func _on_TimerVagar_timeout() -> void:
	elegir_nueva_direccion()


func resetear_deteccion() -> void:
	detectado = false
