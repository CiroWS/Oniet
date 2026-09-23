extends Area2D

export var velocidad := 20.0
var danio := 5
var direccion := Vector2.RIGHT
var origen: Node = null   # quién disparó esta bala (para ignorarlo)


func _ready() -> void:
	rotation = direccion.angle()
	connect("body_entered", self, "_on_body_entered")
	connect("area_entered", self, "_on_area_entered")
	$VisibilityNotifier2D.connect("screen_exited", self, "_on_screen_exited")


func _physics_process(delta: float) -> void:
	position += direccion * velocidad * delta


func _on_body_entered(body: Node) -> void:
	if body == origen:
		return
	if body.is_in_group("Jugador"):
		if body.has_method("recibir_danio"):
			body.recibir_danio(danio)
		queue_free()


func _on_area_entered(area: Node) -> void:
	if area == origen:
		return
	if area.is_in_group("Jugador"):
		if area.has_method("recibir_danio"):
			area.recibir_danio(danio)
		queue_free()


func _on_screen_exited() -> void:
	queue_free()
