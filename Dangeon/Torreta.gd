extends Area2D

# --- Disparo ---
export (PackedScene) var bala_scene
export var intervalo_disparo := 3.8 # Ajustado a la duración de la animación (38 frames a 10 FPS)
export var velocidad_bala := 400.0
var danio_bala := 10

# --- Patrón y Alternancia ---
export (String, "8_direcciones", "circulo") var modo_disparo := "8_direcciones"
export var cantidad_proyectiles_circulo := 12
export var velocidad_rotacion_circulo := 0.2

# --- Vida ---
export var vida_maxima := 100
var vida_actual := 0

signal torreta_daniada(vida_actual, vida_maxima)
signal torreta_destruida

var angulo_actual := 0.0

const DIRECCIONES_8 = [
	Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT,
	Vector2(1, 1), Vector2(-1, 1), Vector2(1, -1), Vector2(-1, -1)
]


func _ready() -> void:
	vida_actual = vida_maxima

	$Timer.wait_time = intervalo_disparo
	$Timer.connect("timeout", self, "_on_Timer_timeout")
	$AnimatedSprite.connect("frame_changed", self, "_on_AnimatedSprite_frame_changed")
	
	$Timer.start()


func _on_Timer_timeout() -> void:
	# Reinicia y reproduce la animación desde el frame 0
	$AnimatedSprite.frame = 0
	$AnimatedSprite.play()


func _on_AnimatedSprite_frame_changed() -> void:
	# Activa el disparo exactamente en el frame 37 (el frame 38 contado de 0 a 37)
	if $AnimatedSprite.frame == 17:
		_disparar()


func _disparar() -> void:
	match modo_disparo:
		"8_direcciones":
			_disparar_8_direcciones()
			modo_disparo = "circulo" # Alterna al siguiente patrón
		"circulo":
			_disparar_circulo()
			modo_disparo = "8_direcciones" # Alterna al primer patrón


func _disparar_8_direcciones() -> void:
	for dir in DIRECCIONES_8:
		_crear_bala(dir.normalized())


func _disparar_circulo() -> void:
	for i in range(cantidad_proyectiles_circulo):
		var angulo = angulo_actual + (TAU / cantidad_proyectiles_circulo) * i
		var dir = Vector2(cos(angulo), sin(angulo))
		_crear_bala(dir)
	angulo_actual += velocidad_rotacion_circulo


func _crear_bala(direccion: Vector2) -> void:
	if bala_scene == null:
		push_warning("Torreta: falta asignar bala_scene en el Inspector")
		return

	var bala = bala_scene.instance()
	get_tree().current_scene.add_child(bala)
	bala.global_position = global_position
	bala.direccion = direccion
	bala.velocidad = velocidad_bala
	bala.danio = danio_bala


func recibir_danio(cantidad: int) -> void:
	vida_actual -= cantidad
	vida_actual = max(vida_actual, 0)
	emit_signal("torreta_daniada", vida_actual, vida_maxima)

	if vida_actual <= 0:
		_destruir()


func _destruir() -> void:
	emit_signal("torreta_destruida")
	$Timer.stop()
	queue_free()
