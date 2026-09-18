extends Node2D

func _on_puertas_body_shape_entered(body_rid: RID, body: Node, body_shape_index: int, local_shape_index: int) -> void:
	if body.is_in_group("player"):
		var colision_node = $puertas.get_child(local_shape_index)
		
		# Al ENTRAR encendemos ambas plantas para que el jugador vea el cambio fluido
		match colision_node.name:
			"colision1", "colision2", "colision3", "colision4", "colision5":
				$planta_baja.visible = true
				$planta_media.visible = true
			"colision6":
				$planta_baja.visible = true
				$planta_alta.visible = true

func _on_puertas_body_shape_exited(body_rid: RID, body: Node, body_shape_index: int, local_shape_index: int) -> void:
	if body.is_in_group("player"):
		var colision_node = $puertas.get_child(local_shape_index)
		
		# Al SALIR comprobamos hacia qué lado de la puerta salió el jugador en el eje Y
		match colision_node.name:
			"colision1", "colision2", "colision3":
				if body.global_position.y < colision_node.global_position.y:
					# Saló por ARRIBA (pasó a la planta media)
					$planta_baja.visible = false
					$planta_media.visible = true
					$Player.collision_layer=2
					$Player.collision_mask=2
				else:
					# Salió por ABAJO (se regresó o bajó a la planta baja)
					$planta_baja.visible = true
					$planta_media.visible = false
					$Player.collision_layer=1
					$Player.collision_mask=1
			"colision4", "colision5":
				if body.global_position.x < colision_node.global_position.x:
					# Saló por ARRIBA (pasó a la planta media)
					$planta_baja.visible = false
					$planta_media.visible = true
					$Player.collision_layer=2
					$Player.collision_mask=2
				else:
					# Salió por ABAJO (se regresó o bajó a la planta baja)
					$planta_baja.visible = true
					$planta_media.visible = false
					$Player.collision_layer=1
					$Player.collision_mask=1
			"colision6":
				if body.global_position.y < colision_node.global_position.y:
					# Saló por ARRIBA (pasó a la planta media)
					$planta_baja.visible = false
					$planta_alta.visible = true
					$Player.collision_layer=4
					$Player.collision_mask=4
				else:
					# Salió por ABAJO (se regresó o bajó a la planta baja)
					$planta_baja.visible = true
					$planta_alta.visible = false
					$Player.collision_layer=1
					$Player.collision_mask=1
