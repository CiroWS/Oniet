extends Area2D

export var velocidad = 300
export var danio = 25

var direccion = Vector2.ZERO

func set_forward_direction(dir: Vector2):
	direccion = dir
	# Opcional: orientar el sprite de la bala hacia donde viaja
	rotation = dir.angle()

func _process(delta):
	# Mueve la bala en la dirección fijada
	position += direccion * velocidad * delta

func _on_Cremona_body_entered(body):
	if body.is_in_group("Enemigo"):
		if body.has_method("recibir_danio"):
			body.recibir_danio(danio)
		queue_free()
	elif body is TileMap:
		queue_free()
