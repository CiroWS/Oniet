extends Node2D

export (PackedScene) var CANTINA

var cantina = null


var y_inicio_escalera: float = 0.0
var x_inicio_escalera: float = 0.0

func _on_puertas_body_shape_entered(body_rid: RID, body: Node, body_shape_index: int, local_shape_index: int) -> void:
	if body.is_in_group("player"):
		var colision_node = $puertas.get_child(local_shape_index)
		match colision_node.name:
			"colision1", "colision2", "colision3", "colision4", "colision5":
				y_inicio_escalera = body.global_position.y
				x_inicio_escalera = body.global_position.x
				$planta_baja.visible = true
				$planta_media.visible = true
			"colision6":
				y_inicio_escalera = body.global_position.y
				$planta_baja.visible = true
				$planta_alta.visible = true

func _on_puertas_body_shape_exited(body_rid: RID, body: Node, body_shape_index: int, local_shape_index: int) -> void:
	if body.is_in_group("player"):
		var colision_node = $puertas.get_child(local_shape_index)
		
		match colision_node.name:
			"colision1", "colision2", "colision3":
				if body.global_position.y < y_inicio_escalera:
					# PLANTA MEDIA
					$planta_baja.visible = false
					$planta_media.visible = true
					$planta_alta.visible = false
					$Player.collision_layer = 2
					$Player.collision_mask = 2
					$Node/Profe_2.visible=false
					
					$Player/Light2D.range_item_cull_mask = 3
					$Player/Light2D.shadow_item_cull_mask = 2
				else:
					# PLANTA BAJA
					$planta_baja.visible = true
					$planta_media.visible = false
					$planta_alta.visible = false
					$Player.collision_layer = 1
					$Player.collision_mask = 1
					$Node/Profe_2.visible=true
					$Player/Light2D.range_item_cull_mask = 1
					$Player/Light2D.shadow_item_cull_mask = 1

			"colision4", "colision5":
				if body.global_position.x < x_inicio_escalera:
					# PLANTA MEDIA
					$planta_baja.visible = false
					$planta_media.visible = true
					$planta_alta.visible = false
					$Player.collision_layer = 2
					$Player.collision_mask = 2
					$Node/Profe_1.visible = true
					$Player/Light2D.range_item_cull_mask = 3
					$Player/Light2D.shadow_item_cull_mask = 2
				else:
					# PLANTA BAJA
					$planta_baja.visible = true
					$planta_media.visible = false
					$planta_alta.visible = false
					$Player.collision_layer = 1
					$Player.collision_mask = 1
					$Node/Profe_1.visible = false
					$Player/Light2D.range_item_cull_mask = 1
					$Player/Light2D.shadow_item_cull_mask = 1

			"colision6":
				if body.global_position.y < y_inicio_escalera:
					# SUBIÓ A PLANTA ALTA
					$planta_baja.visible = false
					$planta_media.visible = false
					$planta_alta.visible = true
					
					$Player.collision_layer = 4
					$Player.collision_mask = 4
					
					$Player/Light2D.range_item_cull_mask = 5
					$Player/Light2D.shadow_item_cull_mask = 4
					$Node/Profe_1.visible = false
					$puertas/colision4.set_deferred("disabled", true)
					$puertas/colision5.set_deferred("disabled", true)
				else:
					# BAJÓ DE PLANTA ALTA A PLANTA BAJA
					$planta_baja.visible = true
					$planta_media.visible = false
					$planta_alta.visible = false
					
					$Player.collision_layer = 1
					$Player.collision_mask = 1
					
					$Player/Light2D.range_item_cull_mask = 1
					$Player/Light2D.shadow_item_cull_mask = 1
					
					$puertas/colision4.set_deferred("disabled", false)
					$puertas/colision5.set_deferred("disabled", false)


# Guardamos la Y inicial donde el jugador tocó la escalera


func _on_escaleras_body_shape_entered(body_rid: RID, body: Node, body_shape_index: int, local_shape_index: int) -> void:
	if body.is_in_group("player"):
		var colision_node = $escaleras.get_child(local_shape_index)
		match colision_node.name:
			"escalera1", "escalera2":
				# Guardamos la posición Y exacta del jugador al entrar
				y_inicio_escalera = body.global_position.y
				$planta_baja.visible = true
				$planta_alta.visible = true

func _on_escaleras_body_shape_exited(body_rid: RID, body: Node, body_shape_index: int, local_shape_index: int) -> void:
	if body.is_in_group("player"):
		var colision_node = $escaleras.get_child(local_shape_index)
		
		match colision_node.name:
			"escalera1", "escalera2":
				# Si la posición Y final es MENOR que al entrar, significa que se movió hacia ARRIBA
				if body.global_position.y < y_inicio_escalera:
					# SUBIÓ A PLANTA ALTA
					$planta_baja.visible = false
					$planta_media.visible = false
					$planta_alta.visible = true
					$Node/Profe_5.visible = true
					$Node/Profe_2.visible=false
					$Player.collision_layer = 4
					$Player.collision_mask = 4
					
					$Player/Light2D.range_item_cull_mask = 5
					$Player/Light2D.shadow_item_cull_mask = 4
				else:
					# BAJÓ DE PLANTA ALTA A PLANTA BAJA (se movió hacia abajo)
					$planta_baja.visible = true
					$planta_media.visible = false
					$planta_alta.visible = false
					$Node/Profe_5.visible = false
					$Player.collision_layer = 1
					$Player.collision_mask = 1
					$Node/Profe_2.visible=true
					$Player/Light2D.range_item_cull_mask = 1
					$Player/Light2D.shadow_item_cull_mask = 1


func _on_AudioStreamPlayer_finished():
	$musica_ambiente.play()

func _input(event):
	if event.is_action_pressed("esc") and $Player/Menu_paused.cantina==true:
		$Player/Menu_paused.cantina = false
		$Player.global_position=Vector2(-673, -897)
		$Player.speed=100
		cantina.queue_free()

func _on_puertacantina_body_entered(body):
	if body.is_in_group("player"):
		$Player/Menu_paused.cantina = true
		cantina = CANTINA.instance()
		add_child(cantina)
		$Player.speed=0
