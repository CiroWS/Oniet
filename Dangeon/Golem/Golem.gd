extends KinematicBody2D



export (float) var velocidad = 55.0
export (float) var margen_alineacion = 22.0 
export (float) var alcance_vision = 500.0
export (int) var vida_max = 5000       

export (float) var tiempo_aviso = 0.8    
export (float) var tiempo_disparo = 1.6  
export (float) var tiempo_espera = 2.5  

enum Direccion { ABAJO, ARRIBA, DERECHA, IZQUIERDA }
enum Estado { PERSIGUIENDO, AVISANDO, DISPARANDO, MURIENDO }

onready var pecho = $PechoPosition
onready var rayo = $PechoPosition/Disparo_golem
onready var anim_sprite = $AnimatedSprite
onready var tween = $Tween
onready var barra_vida = $BossUI/BarraVida
onready var nombre_boss = $BossUI/NombreBoss

var jugador: Node2D = null
var estado = Estado.PERSIGUIENDO
var vida: float = 0.0
var tiempo_estado: float = 0.0
var cooldown_ataque: float = 1.5 
var tiempo_flash: float = 0.0


func _ready():
	vida = vida_max
	barra_vida.max_value = vida_max
	barra_vida.value = vida
	rayo.golem = self
	buscar_jugador()


func buscar_jugador():

	var lista = get_tree().get_nodes_in_group("Jugador")
	if lista.empty():
		lista = get_tree().get_nodes_in_group("player")
	if lista.size() > 0:
		jugador = lista[0]



func posicion_objetivo() -> Vector2:
	if jugador.has_node("CollisionShape2D"):
		return jugador.get_node("CollisionShape2D").global_position
	return jugador.global_position


func _physics_process(delta):

	if tiempo_flash > 0.0:
		tiempo_flash -= delta
		if tiempo_flash <= 0.0 and estado != Estado.MURIENDO:
			modulate = Color(1, 1, 1, 1)

	if estado == Estado.MURIENDO:
		return


#sixseven67

	if not is_instance_valid(jugador):
		if estado != Estado.PERSIGUIENDO:
			terminar_ataque()
		buscar_jugador()
		return

	match estado:
		Estado.PERSIGUIENDO:
			logica_persecucion(delta)
		Estado.AVISANDO:
			tiempo_estado -= delta
			if tiempo_estado <= 0.0:
				iniciar_disparo()
		Estado.DISPARANDO:
			tiempo_estado -= delta
			if tiempo_estado <= 0.0:
				terminar_ataque()


func logica_persecucion(delta):
	cooldown_ataque -= delta
	var dir_ataque = comprobar_alineacion_cardinal()

	if dir_ataque != -1 and cooldown_ataque <= 0.0:
		iniciar_aviso(dir_ataque)
	else:
		perseguir_jugador()


func comprobar_alineacion_cardinal() -> int:
	var diff = posicion_objetivo() - pecho.global_position

	if diff.length() > alcance_vision:
		return -1

	var ax = abs(diff.x)
	var ay = abs(diff.y)


	if ax <= margen_alineacion and ay >= ax:
		return Direccion.ABAJO if diff.y > 0 else Direccion.ARRIBA


	if ay <= margen_alineacion:
		return Direccion.DERECHA if diff.x > 0 else Direccion.IZQUIERDA

	return -1


func apuntar_pecho(direccion: int):
	match direccion:
		Direccion.ABAJO:
			pecho.rotation_degrees = 90
		Direccion.ARRIBA:
			pecho.rotation_degrees = -90
		Direccion.DERECHA:
			pecho.rotation_degrees = 0
		Direccion.IZQUIERDA:
			pecho.rotation_degrees = 180

func perseguir_jugador():
	var diff = posicion_objetivo() - pecho.global_position
	var mov = Vector2.ZERO

	if abs(diff.x) < abs(diff.y):
		if abs(diff.x) > 4.0:
			mov.x = sign(diff.x)
		else:
			mov.y = sign(diff.y)
	else:
		if abs(diff.y) > 4.0:
			mov.y = sign(diff.y)
		else:
			mov.x = sign(diff.x)

	move_and_slide(mov * velocidad)

	if mov.x > 0:
		mirar_direccion(Direccion.DERECHA)
	elif mov.x < 0:
		mirar_direccion(Direccion.IZQUIERDA)
	elif mov.y < 0:
		mirar_direccion(Direccion.ARRIBA)
	elif mov.y > 0:
		mirar_direccion(Direccion.ABAJO)


func mirar_direccion(direccion: int):
	match direccion:
		Direccion.ABAJO:
			poner_animacion("IDLE_frente", false)
		Direccion.ARRIBA:
			poner_animacion("Espalda", false)
		Direccion.DERECHA:
			poner_animacion("Costado", false)
		Direccion.IZQUIERDA:
			poner_animacion("Costado", true)


func poner_animacion(nombre: String, espejado: bool):
	anim_sprite.flip_h = espejado
	if anim_sprite.animation != nombre:
		anim_sprite.play(nombre)



func iniciar_aviso(direccion: int):
	estado = Estado.AVISANDO
	tiempo_estado = tiempo_aviso
	apuntar_pecho(direccion)
	mirar_direccion(direccion)
	rayo.avisar()


func iniciar_disparo():
	estado = Estado.DISPARANDO
	tiempo_estado = tiempo_disparo
	rayo.disparar()


func terminar_ataque():
	rayo.detener_disparo()
	estado = Estado.PERSIGUIENDO
	cooldown_ataque = tiempo_espera



func recibir_danio(cantidad = 1):
	if estado == Estado.MURIENDO:
		return

	vida -= float(cantidad)
	barra_vida.value = vida

	modulate = Color(1, 0.45, 0.45, 1)
	tiempo_flash = 0.1

	if vida <= 0.0:
		morir()


func recibir_dano(cantidad ):
	recibir_danio(cantidad)



func morir():
	estado = Estado.MURIENDO
	rayo.detener_disparo()
	remove_from_group("Enemigo")
	$CollisionShape2D.set_deferred("disabled", true)
	barra_vida.visible = false
	nombre_boss.visible = false
	anim_sprite.stop()


	tween.interpolate_property(self, "modulate", Color(1, 0.45, 0.45, 1), Color(1, 0.45, 0.45, 0), 1.5, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.connect("tween_all_completed", self, "queue_free")
	tween.start()
