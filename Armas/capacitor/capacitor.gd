extends Node2D

export (int) var speed = 100
var direccion_recta: Vector2 = Vector2.ZERO
export (PackedScene) var BOOM


func _ready():
	$Sprite.play("capacitor")
	add_to_group("Capacitor")

func _physics_process(delta):
	position += direccion_recta * speed * delta

func set_forward_direction(direccion: Vector2):
	direccion_recta = direccion.normalized()

func _on_Area2D_body_entered(body):
	if body.is_in_group("Enemigos"):
		if body.has_method("recibir_danio"):
				body.recibir_danio(45)
		boom()

func boom():
	speed = 0
	var boom = BOOM.instance()
	boom.global_position=$Position2D.global_position
	get_tree().call_group("dun", "add_child", boom)
	queue_free()
	


func _on_Sprite_animation_finished():
	if $Sprite.animation == "boom":
		queue_free()
