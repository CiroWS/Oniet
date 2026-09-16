extends Node2D

export (int) var speed = 300
var direccion_recta: Vector2 = Vector2.ZERO

func _ready():
	add_to_group("Cremona")

func _physics_process(delta):
	if has_node("Sprite"):
		$Sprite.rotation_degrees += 5
	position += direccion_recta * speed * delta

func set_forward_direction(direccion: Vector2):
	direccion_recta = direccion.normalized()

func _on_VisibilityNotifier2D_screen_exited():
	queue_free()

func _on_Area2D_body_entered(body):
	if body.is_in_group("Enemigos"):
		if body.has_method("recibir_danio"):
			body.recibir_danio(50)
		queue_free()



