extends KinematicBody2D

# Referencias a los nodos hijos
onready var balloon = $Balloon
onready var text_label = $Panel/VBoxContainer/TextLabel
onready var input_box = $Panel/VBoxContainer/InputBox

# Secuencia de frases iniciales
var dialog_lines = [
	"¡ Buenas !",
	"¿Que haces a esta hora fuera del curso ?",
	"Si lo que quieres es encontrar tus figuritas deberas resolver el siguiente acertijo :",
	"En una granja escolar hay gallinas y conejos. En total se cuentan 20 cabezas y 56 patas.",
	"Si planteas un sistema de ecuaciones para saber cuántos animales de cada tipo hay,",
	"¿cuantos conejos hay exactamente en la granja?"
]

# Respuestas que se aceptan como correctas
const RESPUESTAS_CORRECTAS = ["8", "8 conejos", "8 conejos."]

# Estados posibles del diálogo (reemplaza a las banderas sueltas)
enum Estado {INACTIVO, HABLANDO, ESPERANDO_RESPUESTA, RESUELTO}

var estado = Estado.INACTIVO
var current_line = 0
var player_in_area = false
var player_ref = null


func _ready():
	$Panel.hide()
	input_box.hide()
	$AnimatedSprite.play("default")
	if balloon:
		balloon.hide()


func _process(_delta):
	if balloon:
		balloon.visible = player_in_area and estado == Estado.INACTIVO

	if not player_in_area:
		return

	# Mientras el jugador está escribiendo la respuesta, el InputBox
	# maneja todo (señal text_entered). Acá no hacemos nada con Espacio.
	if estado == Estado.ESPERANDO_RESPUESTA:
		return

	if Input.is_action_just_pressed("ui_accept"):
		match estado:
			Estado.INACTIVO:
				start_dialog()
			Estado.HABLANDO:
				advance_dialog()
			Estado.RESUELTO:
				text_label.text = "Ya tienes lo que necesitas, anda a 5°B."

	# Esc cierra el diálogo en cualquier momento
	if estado != Estado.INACTIVO and Input.is_action_just_pressed("ui_cancel"):
		cerrar_dialogo()


func start_dialog():
	estado = Estado.HABLANDO
	current_line = 0
	$Panel.show()
	show_line()
	_bloquear_jugador(true)


func advance_dialog():
	current_line += 1
	if current_line < dialog_lines.size():
		show_line()
	else:
		# Llego al final de las frases, mostramos la caja de texto
		estado = Estado.ESPERANDO_RESPUESTA
		input_box.show()
		input_box.text = ""
		input_box.grab_focus()


func show_line():
	text_label.text = dialog_lines[current_line]


# Señal conectada del Area2D (body_entered)
func _on_Area2D_body_entered(body):
	if body.is_in_group("Jugador"):
		player_in_area = true
		player_ref = body


# Señal conectada del Area2D (body_exited)
func _on_Area2D_body_exited(body):
	if body.is_in_group("Jugador"):
		player_in_area = false
		cerrar_dialogo()


func cerrar_dialogo():
	$Panel.hide()
	input_box.hide()
	input_box.text = ""
	if input_box.has_focus():
		input_box.release_focus()
	_bloquear_jugador(false)
	# Si ya resolvió el acertijo, mantenemos ese estado para la próxima vez
	if estado != Estado.RESUELTO:
		estado = Estado.INACTIVO
	current_line = 0


# Señal conectada del LineEdit (text_entered) -> Se activa al pulsar Enter
func _on_InputBox_text_entered(new_text):
	if estado != Estado.ESPERANDO_RESPUESTA:
		return

	var answer = new_text.strip_edges().to_lower()

	if answer in RESPUESTAS_CORRECTAS:
		text_label.text = "¡ Excelente ! Lo que buscas esta en 5°B"
		input_box.hide()
		input_box.release_focus()
		estado = Estado.RESUELTO
		_bloquear_jugador(false)
		Global.resolver_acertijo(1)  # ya puede moverse aunque siga leyendo el mensaje
	else:
		text_label.text = "Incorrecto. ¡Inténtalo de nuevo!"
		input_box.text = ""
		input_box.grab_focus()


func _bloquear_jugador(bloqueado: bool):
	if player_ref and player_ref.has_method("set_dialog_active"):
		player_ref.set_dialog_active(bloqueado)
