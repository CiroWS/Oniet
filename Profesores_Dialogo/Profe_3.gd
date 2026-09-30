extends KinematicBody2D

# Referencias a los nodos hijos (pasando por CanvasLayer)
onready var balloon = $Balloon
onready var panel = $CanvasLayer/Panel
onready var text_label = $CanvasLayer/Panel/VBoxContainer/TextLabel
onready var input_box = $CanvasLayer/Panel/VBoxContainer/InputBox

# Secuencia de frases iniciales
var dialog_lines = [
	"¡ Buen Dia !",
	"Estas no son horas de recreo ¿ que te trae por aqui ?",
	"Con que estas buscando tu coleccion de figuritas",
	"Si las quieres recuperar debes decirme algo simple",
	"Las dos magnitudes que se usan para ubicar un punto exacto sobre la superficie terrestre?"
]

# Respuestas que se aceptan como correctas (en minusculas y sin tildes)
const RESPUESTAS_CORRECTAS = ["latitud y longitud", "longitud y latitud"]

# Textos
const TEXTO_ACIERTO = "¡ Perfecto ! Rapido, ve a 2°A"
const TEXTO_RESUELTO = "Debes ir a 2°A"
const TEXTO_ERROR = "Incorrecto. ¡Intentalo de nuevo!"

# Estados posibles del diálogo
enum Estado {INACTIVO, HABLANDO, ESPERANDO_RESPUESTA, RESUELTO}

var estado = Estado.INACTIVO
var current_line = 0
var player_in_area = false
var player_ref = null

# Evita que el Enter con el que se envía la respuesta se cuente también
# como "avanzar diálogo" en ese mismo frame
var _ignorar_accept = false


func _ready():
	panel.hide()
	input_box.hide()
	$AnimatedSprite.play("idle")
	if balloon:
		balloon.hide()


func _process(_delta):
	if balloon:
		balloon.visible = player_in_area and estado == Estado.INACTIVO

	if _ignorar_accept:
		_ignorar_accept = false
		return

	if not player_in_area:
		return

	# Mientras escribe la respuesta, el InputBox maneja las acciones
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
				if panel.visible:
					# Ya leyó el mensaje de acierto: se cierra
					cerrar_dialogo()
				else:
					# Vuelve a hablar con el profe: solo muestra el mensaje final
					Global.emit_signal("nopausa", true)
					panel.show()
					text_label.text = TEXTO_RESUELTO
					_bloquear_jugador(true)


# Esc cierra el diálogo, pero NO saca al jugador del área
# (si no, habría que salir y volver a entrar para poder hablar de nuevo)
func _input(event):
	if panel.visible and (event.is_action_pressed("esc") or event.is_action_pressed("ui_cancel")):
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
		# Llegó al final de las frases, mostramos la caja de texto
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
		if panel.visible:
			cerrar_dialogo()


func cerrar_dialogo():
	panel.hide()
	input_box.hide()
	input_box.text = ""
	if input_box.has_focus():
		input_box.release_focus()
	_bloquear_jugador(false)

	# Si ya lo resolvió, se queda en RESUELTO (no repite el acertijo)
	if estado != Estado.RESUELTO:
		estado = Estado.INACTIVO
	current_line = 0
	Global.emit_signal("nopausa", false)


# Minusculas, sin tildes y sin punto final
func _normalizar(texto: String) -> String:
	var t = texto.strip_edges().to_lower()
	for par in [["á", "a"], ["é", "e"], ["í", "i"], ["ó", "o"], ["ú", "u"], ["ü", "u"]]:
		t = t.replace(par[0], par[1])
	if t.ends_with("."):
		t = t.substr(0, t.length() - 1)
	return t


# Señal conectada del LineEdit (text_entered) -> Se activa al pulsar Enter
func _on_InputBox_text_entered(new_text):
	if estado != Estado.ESPERANDO_RESPUESTA:
		return

	var answer = _normalizar(new_text)

	if answer in RESPUESTAS_CORRECTAS:
		_ignorar_accept = true
		text_label.text = TEXTO_ACIERTO
		input_box.hide()
		input_box.release_focus()
		estado = Estado.RESUELTO
		_bloquear_jugador(false)
		Global.resolver_acertijo(3)
	else:
		text_label.text = TEXTO_ERROR
		input_box.text = ""
		input_box.grab_focus()


func _bloquear_jugador(bloqueado: bool):
	if player_ref and player_ref.has_method("set_dialog_active"):
		player_ref.set_dialog_active(bloqueado)
