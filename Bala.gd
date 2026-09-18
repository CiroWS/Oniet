extends Area2D

export var velocidad := 20.0
var danio := 10
var direccion := Vector2.RIGHT


func _ready() -> void:
	rotation = direccion.angle()
	connect("body_entered", self, "_on_body_entered")
	connect("area_entered", self, "_on_area_entered")
	$VisibilityNotifier2D.connect("screen_exited", self, "_on_screen_exited")


func _physics_process(delta: float) -> void:
	position += direccion * velocidad


func _on_body_entered(body: Node) -> void:
	# Aplica daño al jugador si pertenece al grupo "Jugador"
	if body.is_in_group("Jugador") or body.has_method("recibir_danio"):
		if body.has_method("recibir_danio"):
			body.recibir_danio(danio)
		queue_free()


func _on_area_entered(area: Node) -> void:
	if area.is_in_group("Jugador") or area.has_method("recibir_danio"):
		if area.has_method("recibir_danio"):
			area.recibir_danio(danio)
		queue_free()


func _on_screen_exited() -> void:
	queue_free()
