extends KinematicBody2D

# Referencias a los nodos hijos (pasando por CanvasLayer)
onready var balloon = $Balloon
onready var panel = $CanvasLayer/Panel
onready var text_label = $CanvasLayer/Panel/VBoxContainer/TextLabel
onready var input_box = $CanvasLayer/Panel/VBoxContainer/InputBox

# Secuencia de frases iniciales
var dialog_lines = [
	"No me molestes niño",
	"¿ Que es lo que quieres ?",
	"Con que quieres recuperar tus figuritas",
	"Primero debes contestar mi pregunta",
	"¿ Cual es la capital de Tavulu ?"
]

# Respuestas que se aceptan como correctas
const RESPUESTAS_CORRECTAS = ["funafuti"]

# Estados posibles del diálogo
enum Estado {INACTIVO, HABLANDO, ESPERANDO_RESPUESTA, RESUELTO}

var estado = Estado.INACTIVO
var current_line = 0
var player_in_area = false
var player_ref = null


func _ready():
	panel.hide()
	input_box.hide()
	$AnimatedSprite.play("idle")
	if balloon:
		balloon.hide()


func _input(event):
	if event.is_action_pressed("esc"):
		player_in_area = false
		cerrar_dialogo()


func _process(_delta):
	if balloon:
		balloon.visible = player_in_area and estado == Estado.INACTIVO

	if not player_in_area:
		return

	if estado == Estado.ESPERANDO_RESPUESTA:
		return

	if Input.is_action_just_pressed("ui_accept"):
		$dialogo.play()
		match estado:
			Estado.INACTIVO:
				Global.emit_signal("nopausa", true)
				start_dialog()
			Estado.HABLANDO:
				Global.emit_signal("nopausa", true)
				advance_dialog()
			Estado.RESUELTO:
				Global.emit_signal("nopausa", true)
				text_label.text = "No tengo nada mas que decir, debes ir a 7°C"

	if estado != Estado.INACTIVO and Input.is_action_just_pressed("ui_cancel"):
		cerrar_dialogo()


func start_dialog():
	estado = Estado.HABLANDO
	current_line = 0
	panel.show()
	show_line()
	_bloquear_jugador(true)


func advance_dialog():
	current_line += 1
	if current_line < dialog_lines.size():
		show_line()
	else:
		estado = Estado.ESPERANDO_RESPUESTA
		input_box.show()
		input_box.text = ""
		input_box.grab_focus()


func show_line():
	text_label.text = dialog_lines[current_line]


func _on_Area2D_body_entered(body):
	if body.is_in_group("Jugador"):
		player_in_area = true
		player_ref = body


func _on_Area2D_body_exited(body):
	if body.is_in_group("Jugador"):
		player_in_area = false
		cerrar_dialogo()


func cerrar_dialogo():
	panel.hide()
	input_box.hide()
	input_box.text = ""
	if input_box.has_focus():
		input_box.release_focus()
	_bloquear_jugador(false)
	if estado != Estado.RESUELTO:
		estado = Estado.INACTIVO
	current_line = 0
	Global.emit_signal("nopausa", false)


func _on_InputBox_text_entered(new_text):
	if estado != Estado.ESPERANDO_RESPUESTA:
		return

	var answer = new_text.strip_edges().to_lower()

	if answer in RESPUESTAS_CORRECTAS:
		text_label.text = "Vete, lo que necesitas esta en 7°C"
		input_box.hide()
		input_box.release_focus()
		estado = Estado.RESUELTO
		_bloquear_jugador(false)
		Global.resolver_acertijo(4)
	else:
		text_label.text = "Incorrecto. ¡Inténtalo de nuevo!"
		input_box.text = ""
		input_box.grab_focus()


func _bloquear_jugador(bloqueado: bool):
	if player_ref and player_ref.has_method("set_dialog_active"):
		player_ref.set_dialog_active(bloqueado)
