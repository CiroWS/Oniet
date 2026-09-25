extends KinematicBody2D

# Referencias a los nodos hijos
onready var balloon = $Balloon
onready var text_label = $Panel/VBoxContainer/TextLabel
onready var input_box = $Panel/VBoxContainer/InputBox

# Secuencia de frases iniciales
var dialog_lines = [
	"¡ Buen Día !",
	"Estas no son horas de recreo ¿ que te trae por aquí ?",
	"Con que estas buscando tu colección de figuritas",
	"Si las quieres recuperar debes decirme algo simple",
	"Las dos magnitudes que se usan para ubicar un punto exacto sobre la superficie terrestre?"
	
]

# Respuestas que se aceptan como correctas
const RESPUESTAS_CORRECTAS = ["Latitud y Longitud","Longitud y Latitud","longitud y latitud","latitud y longitud"]

# Estados posibles del diálogo (reemplaza a las banderas sueltas)
enum Estado {INACTIVO, HABLANDO, ESPERANDO_RESPUESTA, RESUELTO}

var estado = Estado.INACTIVO
var current_line = 0
var player_in_area = false
var player_ref = null


func _ready():
	$Panel.hide()
	input_box.hide()
	$AnimatedSprite.play("idle")
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
				Global.emit_signal("nopausa", true)
				start_dialog()
			Estado.HABLANDO:
				advance_dialog()
			Estado.RESUELTO:
				text_label.text = "Debes ir a 2°A"

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
	Global.emit_signal("nopausa", false)


# Señal conectada del LineEdit (text_entered) -> Se activa al pulsar Enter
func _on_InputBox_text_entered(new_text):
	if estado != Estado.ESPERANDO_RESPUESTA:
		return

	var answer = new_text.strip_edges().to_lower()

	if answer in RESPUESTAS_CORRECTAS:
		text_label.text = "¡ Perfecto ! Rápido, ve a 2°A"
		input_box.hide()
		input_box.release_focus()
		estado = Estado.RESUELTO
		_bloquear_jugador(false) 
		Global.resolver_acertijo(3) # ya puede moverse aunque siga leyendo el mensaje
	else:
		text_label.text = "Incorrecto. ¡Inténtalo de nuevo!"
		input_box.text = ""
		input_box.grab_focus()


func _bloquear_jugador(bloqueado: bool):
	if player_ref and player_ref.has_method("set_dialog_active"):
		player_ref.set_dialog_active(bloqueado)
