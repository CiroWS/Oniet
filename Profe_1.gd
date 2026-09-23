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

var player_in_area = false
var current_line = 0
var is_dialog_active = false
var waiting_for_answer = false

func _ready():
	pass
	$Panel.hide()
	input_box.hide()

func _process(_delta):
	# Si estamos esperando que escriba la respuesta, no avanzamos con Espacio/Enter desde aquí
	if waiting_for_answer:
		return
		
	# Se activa con la tecla Espacio cuando el jugador está en el área
	if player_in_area and Input.is_action_just_pressed("ui_accept"):
		print("hablando")
		if not is_dialog_active:
			start_dialog()
		else:
			advance_dialog()




func start_dialog():
	is_dialog_active = true
	current_line = 0
	print("cuadro de dialogo")
	$Panel.show()
	show_line()

func advance_dialog():
	current_line += 1
	if current_line < dialog_lines.size():
		show_line()
	else:
		# Llego al final de las preguntas, mostramos la caja de texto
		waiting_for_answer = true
		input_box.show()
		input_box.text = ""
		input_box.grab_focus() # Pone el cursor directamente en la casilla

func show_line():
	text_label.text = dialog_lines[current_line]

# Señal conectada del Area2D (body_entered)
func _on_Area2D_body_entered(body):
	if body.is_in_group("Jugador"): # Asegúrate de asignar el grupo "player" a tu jugador
		player_in_area = true

# Señal conectada del Area2D (body_exited)
func _on_Area2D_body_exited(body):
	if body.is_in_group("Jugador"):
		player_in_area = false
		reset_dialog()
		$Panel.hide()

func reset_dialog():
	is_dialog_active = false
	waiting_for_answer = false
	current_line = 0
	
	

# Señal conectada del LineEdit (text_entered) -> Se activa al pulsar Enter
func _on_InputBox_text_entered(new_text):
	if not waiting_for_answer:
		return
		
	var answer = new_text.strip_edges().to_lower()
	
	if answer == "8" or answer == "8 conejos" or answer == "8 conejos.":
		text_label.text = "¡ Exelente ! Lo que buscas esta en 5°B"
		input_box.visible = false
		waiting_for_answer = false
		
	else:
		text_label.text = "Incorrecto. ¡Inténtalo de nuevo!"
		input_box.text = ""
