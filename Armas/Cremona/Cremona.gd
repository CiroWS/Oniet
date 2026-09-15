extends Node2D


var direccion_recta: Vector2 = Vector2.ZERO
export (int) var speed = 300
export (int) var rotacion = 15

var enemigo: Node2D = null
var velocidad: Vector2 = Vector2.ZERO

	
func _physics_process(delta):
	$Sprite.rotation_degrees+=1
	if is_instance_valid(enemigo):
		var velocidadactual = (enemigo.global_position - global_position).normalized() * speed
		velocidad = velocidad.linear_interpolate(velocidadactual, rotacion * delta)
		rotation = velocidad.angle()
	else:
			position += direccion_recta * speed * delta

func set_forward_direction(direccion: Vector2):
	enemigo = null
	direccion_recta = direccion.normalized()

func set_target_node(enemy: Node2D):
	enemigo = enemy
	var direccioninicial = (enemy.global_position - global_position).normalized()
	velocidad = direccioninicial * speed
	rotacion = velocidad.angle()
	
	

func _on_VisibilityNotifier2D_screen_exited():
	queue_free()
	

func _on_Area2D_body_entered(body):
	if body.is_in_group("Enemigo"):
		queue_free()


func _on_Desas_timeout():
	queue_free()
