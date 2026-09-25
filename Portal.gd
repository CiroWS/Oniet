extends Area2D

export var profe_id: int = 1  # 1 a 5: a que profesor pertenece esta instancia del portal

func _ready():
	$CollisionShape2D.disabled = true
	$CollisionShape2D.visible = false
	$AnimatedSprite.visible = false

	if Global.acertijos_resueltos[profe_id - 1]:
		activar_portal(profe_id)
	else:
		Global.connect("acertijo_resuelto", self, "activar_portal")

func activar_portal(id: int):
	if id != profe_id:
		return
	$CollisionShape2D.disabled = false
	$CollisionShape2D.visible = true
	$AnimatedSprite.visible = true

func _on_Portal_body_entered(body):
	if body.is_in_group("player"):
		get_tree().change_scene("res://Dangeon/SalaDungeon.tscn")
