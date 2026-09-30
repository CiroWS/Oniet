extends KinematicBody2D
# GOLEMCITO
# Mezcla del Enemigo_Peque (aggro + raycast + volver a casa) y del Golem (piedra + ataque a distancia).
# Ataque 1: se acerca y te pega cuerpo a cuerpo.
# Ataque 2: se para y te dispara una Bala desde la mano.

# ---------- Ajustes (se pueden cambiar desde el Inspector) ----------
export (int) var vida_max = 250
export (float) var velocidad = 85.0
export (float) var velocidad_regreso = 110.0

# Golpe cuerpo a cuerpo
export (int) var danio_melee = 20
export (float) var rango_melee = 40.0        # a esta distancia empieza a pegar
export (float) var cooldown_melee = 1.0

# Disparo
export (PackedScene) var escena_bala          # si queda vacio, carga res://Dangeon/Bala.tscn
export (int) var danio_bala = 8
export (float) var velocidad_bala = 180.0     # OJO: la Bala trae 20 por defecto y es lentisima
export (float) var rango_disparo_min = 80.0   # mas cerca que esto prefiere pegarte
export (float) var rango_disparo_max = 260.0
export (float) var cooldown_disparo = 3.0

# Lo que guarda en Global al morir (igual que el peque, para que funcione tu sistema de drops)
export (String) var bicho_global = "peque"

# Punto del cuerpo del Player al que apunta (el mismo truco de +15 en Y del peque)
export (Vector2) var offset_objetivo = Vector2(0, 15)

# ---------- Constantes (coinciden con las animaciones a 10 fps, 6 frames) ----------
const MELEE_INICIO = 0.30      # frame 3: empieza a golpear
const MELEE_FIN = 0.50         # frame 5: termina la ventana de golpe
const MELEE_DURACION = 0.65
const DISPARO_MOMENTO = 0.30   # frame 3: sale la bala
const DISPARO_DURACION = 0.65
const DISTANCIA_PARADA = 26.0  # no se acerca mas que esto
const FRENTE_X = 14.0          # cuanto adelanta la caja de golpe
const FRENTE_Y = 4.0
const MANO_X = 18.0            # de donde sale la bala
const MANO_Y = 0.0

enum Estado { LIBRE, MELEE, DISPARO, MURIENDO }

var estado = Estado.LIBRE
var jugador = null
var vida = 0.0

var perseguir = false
var regresando = false
var posicion_original = Vector2.ZERO

var lado = 1                 # 1 = mira a la derecha, -1 = izquierda
var t_estado = 0.0
var cd_melee = 0.0
var cd_disparo = 1.0         # pequeña espera inicial antes del primer disparo
var ya_golpeo = false
var disparo_hecho = false
var t_flash = 0.0


func _ready():
	vida = vida_max
	posicion_original = global_position
	$BarraVida.max_value = vida_max
	$BarraVida.value = vida
	$Frente/AtaqueEnemigo/EnemigoAtaque.disabled = true
	if escena_bala == null:
		escena_bala = load("res://Dangeon/Bala.tscn")
	buscar_jugador()
	colocar_lado()
	$AnimatedSprite.play("Idle")


func buscar_jugador():
	var lista = get_tree().get_nodes_in_group("Jugador")
	if lista.size() > 0:
		jugador = lista[0]


func punto_objetivo() -> Vector2:
	return jugador.global_position + offset_objetivo


func _physics_process(delta):
	# parpadeo rojo al recibir daño
	if t_flash > 0.0:
		t_flash -= delta
		if t_flash <= 0.0 and estado != Estado.MURIENDO:
			$AnimatedSprite.modulate = Color(1, 1, 1, 1)

	if estado == Estado.MURIENDO:
		return

	if not is_instance_valid(jugador):
		jugador = null
		buscar_jugador()

	cd_melee = max(cd_melee - delta, 0.0)
	cd_disparo = max(cd_disparo - delta, 0.0)

	match estado:
		Estado.LIBRE:
			estado_libre()
		Estado.MELEE:
			estado_melee(delta)
		Estado.DISPARO:
			estado_disparo(delta)


# ---------------------------------------------------------------
#  MOVIMIENTO Y DECISION (como el peque)
# ---------------------------------------------------------------
func estado_libre():
	var ve_jugador = false
	if perseguir and jugador != null:
		ve_jugador = actualizar_rayo()

	if ve_jugador:
		regresando = false
		var dist = global_position.distance_to(jugador.global_position)
		mirar_hacia(jugador.global_position.x)

		if dist <= rango_melee and cd_melee <= 0.0:
			iniciar_melee()
		elif dist >= rango_disparo_min and dist <= rango_disparo_max and cd_disparo <= 0.0:
			iniciar_disparo()
		elif dist > DISTANCIA_PARADA:
			mover_hacia(jugador.global_position, velocidad)
		else:
			poner_anim("Idle")

	elif regresando:
		if global_position.distance_to(posicion_original) < 5.0:
			regresando = false
			poner_anim("Idle")
		else:
			mover_hacia(posicion_original, velocidad_regreso)
	else:
		poner_anim("Idle")


func actualizar_rayo() -> bool:
	var v = to_local(punto_objetivo())
	$RayCast2D.cast_to = v + v.normalized() * 10.0
	$RayCast2D.force_raycast_update()
	return $RayCast2D.get_collider() == jugador


func mover_hacia(destino: Vector2, vel: float):
	var dir = (destino - global_position).normalized()
	mirar_hacia(destino.x)
	poner_anim("Camina")
	move_and_slide(dir * vel)


func mirar_hacia(x_destino: float):
	var dx = x_destino - global_position.x
	if abs(dx) < 2.0:
		return
	var nuevo = 1 if dx > 0 else -1
	if nuevo != lado:
		lado = nuevo
		colocar_lado()


func colocar_lado():
	$AnimatedSprite.flip_h = (lado == -1)
	$Frente.position = Vector2(FRENTE_X * lado, FRENTE_Y)
	$Mano.position = Vector2(MANO_X * lado, MANO_Y)


func poner_anim(nombre: String):
	if $AnimatedSprite.animation != nombre:
		$AnimatedSprite.play(nombre)


func lanzar_anim(nombre: String):
	# reinicia la animacion desde el frame 0 (los ataques no hacen loop)
	$AnimatedSprite.animation = nombre
	$AnimatedSprite.frame = 0
	$AnimatedSprite.play(nombre)


func volver_a_libre():
	estado = Estado.LIBRE
	$Frente/AtaqueEnemigo/EnemigoAtaque.set_deferred("disabled", true)
	poner_anim("Idle")


# ---------------------------------------------------------------
#  ATAQUE 1: GOLPE CUERPO A CUERPO
# ---------------------------------------------------------------
func iniciar_melee():
	estado = Estado.MELEE
	t_estado = 0.0
	ya_golpeo = false
	lanzar_anim("Melee")


func estado_melee(delta):
	t_estado += delta
	var en_ventana = t_estado >= MELEE_INICIO and t_estado <= MELEE_FIN
	$Frente/AtaqueEnemigo/EnemigoAtaque.set_deferred("disabled", not en_ventana)

	if en_ventana and not ya_golpeo:
		buscar_golpe()

	if t_estado >= MELEE_DURACION:
		cd_melee = cooldown_melee
		volver_a_libre()


func buscar_golpe():
	var caja = $Frente/AtaqueEnemigo
	for a in caja.get_overlapping_areas():
		if a.name == "HurtBox":
			golpear(a.get_parent())
			return
	for b in caja.get_overlapping_bodies():
		if b.is_in_group("Jugador"):
			golpear(b)
			return


func golpear(victima):
	ya_golpeo = true
	if victima.has_method("recibir_danio"):
		victima.recibir_danio(danio_melee)


# ---------------------------------------------------------------
#  ATAQUE 2: DISPARO DESDE LA MANO
# ---------------------------------------------------------------
func iniciar_disparo():
	estado = Estado.DISPARO
	t_estado = 0.0
	disparo_hecho = false
	lanzar_anim("Disparo")


func estado_disparo(delta):
	t_estado += delta

	# mientras carga, sigue al jugador con la mirada
	if not disparo_hecho and jugador != null:
		mirar_hacia(jugador.global_position.x)

	if not disparo_hecho and t_estado >= DISPARO_MOMENTO:
		disparo_hecho = true
		disparar()

	if t_estado >= DISPARO_DURACION:
		cd_disparo = cooldown_disparo + rand_range(-0.5, 1.0)
		volver_a_libre()


func disparar():
	if escena_bala == null or jugador == null:
		return
	var origen = $Mano.global_position
	var dir = (punto_objetivo() - origen).normalized()

	var bala = escena_bala.instance()
	# se configura ANTES de add_child porque Bala.gd usa "direccion" en su _ready()
	bala.direccion = dir
	bala.origen = self
	bala.danio = danio_bala
	bala.velocidad = velocidad_bala
	get_parent().add_child(bala)
	bala.global_position = origen


# ---------------------------------------------------------------
#  AGGRO (señales del Area2D "aggro")
# ---------------------------------------------------------------
func _on_aggro_body_entered(body):
	if body.is_in_group("Jugador"):
		jugador = body
		perseguir = true
		regresando = false


func _on_aggro_body_exited(body):
	if body.is_in_group("Jugador"):
		perseguir = false
		regresando = true


# ---------------------------------------------------------------
#  VIDA
# ---------------------------------------------------------------
func recibir_danio(cantidad = 1):
	if estado == Estado.MURIENDO:
		return
	vida -= float(cantidad)
	$BarraVida.value = vida
	$AnimatedSprite.modulate = Color(1, 0.45, 0.45, 1)
	t_flash = 0.1
	if vida <= 0.0:
		morir()


func recibir_dano(cantidad = 1):   # por si algun arma usa este nombre (como el Golem)
	recibir_danio(cantidad)


func death():                      # mismo nombre que el peque
	morir()


func morir():
	if estado == Estado.MURIENDO:
		return
	estado = Estado.MURIENDO
	perseguir = false
	regresando = false
	Global.posicion = global_position
	Global.bicho = bicho_global

	$CollisionShape2D.set_deferred("disabled", true)
	$HurtArea/HurtColision.set_deferred("disabled", true)
	$Frente/AtaqueEnemigo/EnemigoAtaque.set_deferred("disabled", true)
	$aggro/CollisionShape2D.set_deferred("disabled", true)
	$RayCast2D.enabled = false
	$BarraVida.visible = false
	$AnimatedSprite.modulate = Color(1, 1, 1, 1)
	$AnimatedSprite.play("Dead")
	yield($AnimatedSprite, "animation_finished")
	yield(get_tree().create_timer(0.6), "timeout")
	queue_free()
