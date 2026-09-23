extends CanvasLayer

onready var panel = $Panel
onready var texto_label = $Panel/TextoDialogo
onready var campo_respuesta = $Panel/CampoRespuesta
onready var boton_enviar = $Panel/BotonEnviar
onready var boton_siguiente = $Panel/BotonSiguiente

var lineas_dialogo: Array = [
	"¡Buenas!",
	"¿Qué haces a esta hora fuera del curso?",
	"Si lo que quieres es encontrar tus figuritas deberás resolver el siguiente acertijo:\n\nEn una granja escolar hay gallinas y conejos. En total se cuentan 20 cabezas y 56 patas. Si planteas un sistema de ecuaciones para saber cuántos animales de cada tipo hay, ¿cuántos conejos hay exactamente en la granja?"
]

var indice_linea: int = 0

func _ready():
	panel.hide()

func abrir():
	indice_linea = 0
	panel.show()
	mostrar_linea()

func cerrar():
	panel.hide()

func mostrar_linea():
	texto_label.text = lineas_dialogo[indice_linea]
	
	# Si llegamos a la línea del acertijo (la última de la lista)
	if indice_linea == lineas_dialogo.size() - 1:
		boton_siguiente.hide()
		campo_respuesta.show()
		boton_enviar.show()
		campo_respuesta.clear()
		campo_respuesta.grab_focus() # Pone el cursor en la caja de texto
	else:
		boton_siguiente.show()
		campo_respuesta.hide()
		boton_enviar.hide()

# Señal de BotonSiguiente
func _on_BotonSiguiente_pressed():
	if indice_linea < lineas_dialogo.size() - 1:
		indice_linea += 1
		mostrar_linea()

# Señal de BotonEnviar y al dar Enter en CampoRespuesta
func _on_BotonEnviar_pressed():
	_evaluar_respuesta()

func _on_CampoRespuesta_text_entered(_new_text):
	_evaluar_respuesta()

func _evaluar_respuesta():
	var entrada = campo_respuesta.text.strip_edges().to_lower()
	
	# Si la respuesta contiene "8"
	if "8" in entrada:
		texto_label.text = "Lo que buscas está en 5°B"
		campo_respuesta.hide()
		boton_enviar.hide()
		boton_siguiente.hide()
	else:
		texto_label.text = "Incorrecto. Inténtalo de nuevo:\n\n¿Cuántos conejos hay exactamente en la granja?"
		campo_respuesta.clear()
