extends Node2D

func _on_puertas_body_shape_entered(body_rid: RID, body: Node, body_shape_index: int, local_shape_index: int) -> void:
	if body.is_in_group("player"):
		# Obtenemos el CollisionShape2D correspondiente al índice tocado
		var colision_node = $puertas.get_child(local_shape_index)
		var nombre_colision = colision_node.name

		match nombre_colision:
			"colision1", "colision2", "colision3":
				if $planta_media.visible:
					$planta_baja.visible = true
					print("1")
				else:
					$planta_media.visible = true
					print("2")
			"colision4", "colision5":
				pass
			"colision6":
				pass

func _on_puertas_body_shape_exited(body_rid: RID, body: Node, body_shape_index: int, local_shape_index: int) -> void:
	if body.is_in_group("player"):
		var colision_node = $puertas.get_child(local_shape_index)
		var nombre_colision = colision_node.name

		match nombre_colision:
			"colision1", "colision2", "colision3":
				if $planta_media.visible:
					$planta_media.visible = false
					print("3")
				else:
					$planta_baja.visible = false
					print("4")
			"colision4", "colision5":
				pass
			"colision6":
				pass
