extends KinematicBody2D

# Asigna la ruta a tu nodo DialogoUI si está en el nivel o instancia la UI
export(NodePath) var ui_dialogo_path
onready var ui_dialogo = get_node_or_null(ui_dialogo_path)

var jugador_cerca: bool = false
var dialogo_abierto: bool = false

func _process(_delta):
	# Si el jugador está en el área y presiona Enter/Espacio/Aceptar
	if jugador_cerca and Input.is_action_just_pressed("ui_accept"):
		if not dialogo_abierto:
			dialogo_abierto = true
			if ui_dialogo:
				ui_dialogo.abrir()

# Señales de Area2D
func _on_Area2D_body_entered(body):
	if body.is_in_group("Jugador"):
		jugador_cerca = true

func _on_Area2D_body_exited(body):
	if body.is_in_group("Jugador"):
		jugador_cerca = false
		dialogo_abierto = false
		if ui_dialogo:
			ui_dialogo.cerrar()
