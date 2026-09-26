extends Node2D

export (int) var speed = 100
var direccion_recta: Vector2 = Vector2.ZERO

func set_forward_direction(direccion: Vector2):
	direccion_recta = direccion.normalized()

func _physics_process(delta):
	position += direccion_recta * speed * delta
	
func _process(delta):
	if $tijera.visible==true and $papel.visible==true and $piedra.visible==true:
		$tijera.global_position+=Vector2(0, -10)
		$papel.global_position+=Vector2(10, 10)
		$piedra.global_position+=Vector2(-10, 10)
	

func _on_Area2D_body_entered(body):
	if body.is_in_group("Enemigos"):
		if body.has_method("recibir_danio"):
			body.recibir_danio(60)
			$ataque.visible=false
			$tijera.visible=true
			$papel.visible=true
			$piedra.visible=true


func _on_secu_body_entered(body):
	if body.is_in_group("Enemigos"):
		if body.has_method("recibir_danio"):
			print("aia")
			body.recibir_danio(20)
			$tijera.visible=false
			$papel.visible=false
			$piedra.visible=false


func _on_VisibilityNotifier2D_screen_exited():
	queue_free()
