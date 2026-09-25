extends Area2D

# --- Disparo ---
export (PackedScene) var bala_scene
export var intervalo_disparo := 3.8 # Ajustado a la duración de la animación (38 frames a 10 FPS)
export var velocidad_bala := 400.0
var danio_bala := 5

var player: Node = null

# Secuencia de modos: se van alternando en este orden, uno por disparo
const MODOS := ["8_direcciones", "circulo", "espiral", "dirigido", "doble_espiral"]
var modo_index := 0

# -- Modo "8_direcciones" --
export var cantidad_direcciones := 16
export var oleadas_direcciones := 3
export var intervalo_oleada := 0.12

# -- Modo "circulo" --
export var cantidad_proyectiles_circulo := 12
export var velocidad_rotacion_circulo := 0.2
var angulo_circulo := 0.0

# -- Modo "espiral" (varios brazos que giran mientras disparan) --
export var brazos_espiral := 3
export var oleadas_espiral := 8
export var intervalo_oleada_espiral := 0.05
export var paso_rotacion_espiral := 0.35
var angulo_espiral := 0.0

# -- Modo "dirigido" (apunta al jugador) --
export var balas_dirigido := 5
export var spread_dirigido := 0.6  # radianes de abanico total

# -- Modo "doble_espiral" (dos espirales en sentidos opuestos) --
export var brazos_doble_espiral := 2
export var oleadas_doble_espiral := 6
export var intervalo_oleada_doble := 0.05
export var paso_rotacion_doble := 0.3
var angulo_doble_a := 0.0
var angulo_doble_b := 0.0

# --- Vida ---
export var vida_maxima := 100
var vida_actual := 0

signal torreta_daniada(vida_actual, vida_maxima)
signal torreta_destruida


func _ready() -> void:
	vida_actual = vida_maxima

	$Timer.wait_time = intervalo_disparo
	$Timer.connect("timeout", self, "_on_Timer_timeout")
	$AnimatedSprite.connect("frame_changed", self, "_on_AnimatedSprite_frame_changed")

	var jugadores = get_tree().get_nodes_in_group("Jugador")
	if jugadores.size() > 0:
		player = jugadores[0]

	$Timer.start()


func _on_Timer_timeout() -> void:
	# Reinicia y reproduce la animación desde el frame 0
	$AnimatedSprite.frame = 0
	$AnimatedSprite.play()


func _on_AnimatedSprite_frame_changed() -> void:
	$cargarlaser.play()
	# Activa el disparo exactamente en el frame 17
	if $AnimatedSprite.frame == 17:
		_disparar()


func _disparar() -> void:
	match MODOS[modo_index]:
		"8_direcciones":
			_disparar_direcciones()
		"circulo":
			_disparar_circulo()
		"espiral":
			_disparar_espiral()
		"dirigido":
			_disparar_dirigido()
		"doble_espiral":
			_disparar_doble_espiral()

	modo_index = randi() % MODOS.size()
	$ataque.play()


func _disparar_direcciones() -> void:
	for oleada in range(oleadas_direcciones):
		var offset := 0.0
		if oleadas_direcciones > 1:
			offset = (TAU / cantidad_direcciones) * (float(oleada) / oleadas_direcciones)

		for i in range(cantidad_direcciones):
			var angulo = offset + (TAU / cantidad_direcciones) * i
			_crear_bala(Vector2(cos(angulo), sin(angulo)))

		if oleada < oleadas_direcciones - 1:
			yield(get_tree().create_timer(intervalo_oleada), "timeout")


func _disparar_circulo() -> void:
	for i in range(cantidad_proyectiles_circulo):
		var angulo = angulo_circulo + (TAU / cantidad_proyectiles_circulo) * i
		_crear_bala(Vector2(cos(angulo), sin(angulo)))
	angulo_circulo += velocidad_rotacion_circulo


func _disparar_espiral() -> void:
	for oleada in range(oleadas_espiral):
		var base = angulo_espiral + paso_rotacion_espiral * oleada
		for b in range(brazos_espiral):
			var angulo = base + (TAU / brazos_espiral) * b
			_crear_bala(Vector2(cos(angulo), sin(angulo)))
		if oleada < oleadas_espiral - 1:
			yield(get_tree().create_timer(intervalo_oleada_espiral), "timeout")
	angulo_espiral += paso_rotacion_espiral * oleadas_espiral


func _disparar_dirigido() -> void:
	if player == null:
		var jugadores = get_tree().get_nodes_in_group("Jugador")
		if jugadores.size() > 0:
			player = jugadores[0]
		else:
			return

	var angulo_base = (player.global_position - global_position).angle()
	for i in range(balas_dirigido):
		var t := 0.0
		if balas_dirigido > 1:
			t = (float(i) / (balas_dirigido - 1)) - 0.5
		var angulo = angulo_base + t * spread_dirigido
		_crear_bala(Vector2(cos(angulo), sin(angulo)))


func _disparar_doble_espiral() -> void:
	for oleada in range(oleadas_doble_espiral):
		var base_a = angulo_doble_a + paso_rotacion_doble * oleada
		var base_b = angulo_doble_b - paso_rotacion_doble * oleada
		for b in range(brazos_doble_espiral):
			var off = (TAU / brazos_doble_espiral) * b
			_crear_bala(Vector2(cos(base_a + off), sin(base_a + off)))
			_crear_bala(Vector2(cos(base_b + off), sin(base_b + off)))
		if oleada < oleadas_doble_espiral - 1:
			yield(get_tree().create_timer(intervalo_oleada_doble), "timeout")
	angulo_doble_a += paso_rotacion_doble * oleadas_doble_espiral
	angulo_doble_b -= paso_rotacion_doble * oleadas_doble_espiral


func _crear_bala(direccion: Vector2) -> void:
	if bala_scene == null:
		push_warning("Torreta: falta asignar bala_scene en el Inspector")
		return

	var bala = bala_scene.instance()
	bala.direccion = direccion
	bala.velocidad = velocidad_bala
	bala.danio = danio_bala
	bala.origen = self
	get_tree().current_scene.add_child(bala)
	bala.global_position = global_position


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
