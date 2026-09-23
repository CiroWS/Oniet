extends KinematicBody2D

export (String) var type_enemy
var player
var perseguir = false
var danioenemy = 35
var esta_atacando = false
var vida_enemy = 100
var regresando = false
var posicion_original = Vector2.ZERO
var ya_golpeo = false  # evita que un mismo ataque pegue más de una vez
var muriendo = false
export (float) var cooldown_ataque = 1.0  # tiempo extra de espera entre un ataque y el siguiente

func _ready():
	perseguir = false
	posicion_original = global_position

	$BarraVida.value = vida_enemy
	player = get_parent().get_node("Player")
	match type_enemy:
		"Chico":
			$AnimatedSprite.play("Idle")
func _physics_process(delta):
	if not esta_atacando:
		aim()
	check_player()


func aim():
	$RayCast2D.cast_to = to_local(player.global_position + Vector2(0, 15))


func check_player():
	if esta_atacando:
		return

	if $RayCast2D.get_collider() == player and perseguir:
		regresando = false
		var distancia = global_position.distance_to(player.global_position)

		if distancia < 25:
			atacar()
		else:
			var dir = (player.global_position - global_position).normalized()
			var velocity = dir * 140

			if dir.x < 0:
				$AnimatedSprite.flip_h = true
				$Position2D.scale.x = 1
			else:
				$AnimatedSprite.flip_h = false
				$Position2D.scale.x = -1

			$AnimatedSprite.play("Idle")
			move_and_slide(velocity)

	elif regresando:
		var distancia_a_casa = global_position.distance_to(posicion_original)

		if distancia_a_casa < 5:
			regresando = false
			$AnimatedSprite.play("Idle")
		else:
			var dir = (posicion_original - global_position).normalized()
			var velocity = dir * 120

			if dir.x < 0:
				$AnimatedSprite.flip_h = true
				$Position2D.scale.x = 1
			else:
				$AnimatedSprite.flip_h = false
				$Position2D.scale.x = -1

			$AnimatedSprite.play("Idle")
			move_and_slide(velocity)


func _on_aggro_body_entered(body):
	if body.is_in_group("Jugador"):
		perseguir = true
		$AnimatedSprite.play("Idle")


func _on_aggro_body_exited(body):
	if body.is_in_group("Jugador"):
		perseguir = false
		regresando = true


func _on_AtaqueEnemigo_area_entered(area):
	if ya_golpeo:
		return
	if area.name == "HurtBox":
		ya_golpeo = true
		var victima = area.get_parent()
		victima.recibir_danio(danioenemy)
		$Position2D/AtaqueEnemigo/EnemigoAtaque.set_deferred("disabled", true)

func atacar():
	if esta_atacando:
		return
	esta_atacando = true
	ya_golpeo = false
	$AnimatedSprite.play("Ataque")
	yield(get_tree().create_timer(0.4), "timeout")
	$Position2D/AtaqueEnemigo/EnemigoAtaque.set_deferred("disabled", false)
	yield(get_tree().create_timer(0.3), "timeout")
	$Position2D/AtaqueEnemigo/EnemigoAtaque.set_deferred("disabled", true)
	# cooldown propio del enemigo antes de poder volver a atacar
	yield(get_tree().create_timer(cooldown_ataque), "timeout")
	esta_atacando = false

func death():
	if muriendo:
		return
	muriendo = true
	esta_atacando = true
	perseguir = false
	$CollisionShape2D.set_deferred("disabled", true)
	$HurtArea/HurtColision.set_deferred("disabled", true)
	$RayCast2D.enabled = false
	$AnimatedSprite.play("Dead")
	yield($AnimatedSprite, "animation_finished")
	$Timer.start()

func recibir_danio(restar):
	if muriendo:
		return  # ya está muriendo, ignorar golpes extra
	vida_enemy -= restar
	$BarraVida.value = vida_enemy
	if vida_enemy <= 0:
		death()


func _on_Timer_timeout():
	queue_free()
