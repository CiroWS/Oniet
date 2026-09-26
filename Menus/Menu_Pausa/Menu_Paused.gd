extends CanvasLayer

var flag = false
var cantina = false
var k = true

func _ready():
	Global.connect("nopausa", self, "a")

func a(k):
	if k==true:
		cantina= true
	if k==false:
		cantina= false

func _input(event):
	if event.is_action_pressed("esc"):
		# Si la cantina está abierta, no hacemos nada aquí ni consumimos el evento,
		# dejando que el script del MAPA maneje el cierre.
		if cantina:
			return
			
		if not flag:
			flag = true
			$Pausad.visible = true
			$BG.visible = true
			get_tree().paused = true
		elif flag:
			flag = false
			$Pausad.visible = false
			$BG.visible = false
			get_tree().paused = false


func _on_Cont_pressed():
	$Pausad.visible= false
	$BG.visible = false
	get_tree().paused = false


func _on_Sal_pressed():
	$BG.visible = false
	get_tree().paused = false
	get_tree().change_scene("res://Menus/Menu_principal/Menu_principal.tscn")


func _on_pausa_finished():
	$pausa.play()
