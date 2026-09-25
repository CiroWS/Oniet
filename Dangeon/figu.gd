extends Node2D

func _ready():
	var a=Global.figus
	if a==1:
		$AnimatedSprite.play("fig1")
	elif a==2:
		$AnimatedSprite.play("fig2")
	elif a==3:
		$AnimatedSprite.play("fig3")
	elif a==4:
		$AnimatedSprite.play("fig4")
	elif a==5:
		$AnimatedSprite.play("fig5")

func _on_Area2D_body_entered(body):
	if body.is_in_group("player"):
		Global.figus+=1
		queue_free()
		get_tree().change_scene("res://Dangeon/congratulation.tscn")
