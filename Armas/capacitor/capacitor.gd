extends Node2D

export (int) var speed = 100
var direccion_recta: Vector2 = Vector2.ZERO

func _ready():
	$Sprite.play("capacitor")
	add_to_group("Capacitor")
	$Sprite.scale=Vector2(1.0,1.0)
	$Area2D/explosion.disabled=true
	$Area2D/capacitor.disabled=false

func _physics_process(delta):
	position += direccion_recta * speed * delta

func set_forward_direction(direccion: Vector2):
	direccion_recta = direccion.normalized()

func _on_Area2D_body_entered(body):
	if body.is_in_group("Enemigos"):
		if body.has_method("recibir_danio"):
			if $Area2D/capacitor.disabled==false:
				body.recibir_danio(25)
			else:
				body.recibir_danio(30)
		boom()

func boom():
	$Sprite.play("boom")
	speed = 0
	$Sprite.scale=Vector2(1.5,1.5)
	$Area2D/explosion.disabled=false
	$Area2D/capacitor.disabled=true
	


func _on_Sprite_animation_finished():
	if $Sprite.animation == "boom":
		queue_free()
