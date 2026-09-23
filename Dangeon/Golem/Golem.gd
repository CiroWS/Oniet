extends KinematicBody2D

export (float) var velocidad = 60.0
export (float) var margen_alineacion = 16.0
export (float) var alcance_vision = 300.0


onready var pecho = $PechoPosition
onready var rayo = $PechoPosition/Disparo_golem
onready var line_of_sight = $LineOfSight
onready var ataque_timer = $AtaqueTimer
onready var cooldown_timer = $CooldownTimer

var jugador: Node2D = null
var esta_atacando: bool = false
var puede_atacar: bool = true

enum Direccion { ABAJO, ARRIBA, DERECHA, IZQUIERDA }

func _ready():
	var jugadores = get_tree().get_nodes_in_group("jugador")
	if jugadores.size() > 0:
		jugador = jugadores[0]
		
	ataque_timer.one_shot = true
	cooldown_timer.one_shot = true
	ataque_timer.connect("timeout", self, "_on_AtaqueTimer_timeout")
	cooldown_timer.connect("timeout", self, "_on_CooldownTimer_timeout")

func _physics_process(_delta):
	if not jugador or esta_atacando:
		return
		
	var dir_ataque = comprobar_alineacion_cardinal()
	
	if dir_ataque != -1 and puede_atacar:
		if tiene_linea_de_vision():
			apuntar_pecho(dir_ataque)
			iniciar_ataque()
			return

	perseguir_jugador()

func comprobar_alineacion_cardinal() -> int:
	var diff = jugador.global_position - global_position
	
	if diff.length() > alcance_vision:
		return -1
	
	# Eje Y (Arriba / Abajo)
	if abs(diff.x) <= margen_alineacion:
		return Direccion.ABAJO if diff.y > 0 else Direccion.ARRIBA
			
	# Eje X (Izquierda / Derecha)
	if abs(diff.y) <= margen_alineacion:
		return Direccion.DERECHA if diff.x > 0 else Direccion.IZQUIERDA
			
	return -1

func tiene_linea_de_vision() -> bool:
	line_of_sight.global_position = global_position
	line_of_sight.cast_to = line_of_sight.to_local(jugador.global_position)
	line_of_sight.force_raycast_update()
	
	if line_of_sight.is_colliding():
		return line_of_sight.get_collider() == jugador
	return false

func apuntar_pecho(direccion: int):
	# Rotamos el Position2D para que el rayo apunte en la dirección correcta
	match direccion:
		Direccion.ABAJO:
			pecho.rotation_degrees = 0
		Direccion.ARRIBA:
			pecho.rotation_degrees = 180
		Direccion.DERECHA:
			pecho.rotation_degrees = -90
		Direccion.IZQUIERDA:
			pecho.rotation_degrees = 90

func perseguir_jugador():
	var direccion = (jugador.global_position - global_position).normalized()
	move_and_slide(direccion * velocidad)

func iniciar_ataque():
	esta_atacando = true
	puede_atacar = false
	
	rayo.disparar()
	ataque_timer.start(1.2)

func _on_AtaqueTimer_timeout():
	rayo.detener_disparo()
	cooldown_timer.start(2.0)

func _on_CooldownTimer_timeout():
	esta_atacando = false
	puede_atacar = true
