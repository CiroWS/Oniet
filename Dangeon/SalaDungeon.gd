extends Node2D

var EnemigoEscena = preload("res://Dangeon/Enemigo_Peque.tscn")

var horda_actual = 1
var hordas_totales = 5
var enemigos_vivos = 0

var enemigos_por_horda = {
	1: 10,
	2: 20,
	3: 25,
	4: 30,
	5: 35
}

onready var spawn_points = $SpawnPoints.get_children()
onready var texto_horda = $CanvasLayer/TextoHorda

func _ready():
	randomize()
	iniciar_horda(horda_actual)

func mostrar_cartel_horda(numero):
	texto_horda.text = "HORDA " + str(numero)
	texto_horda.visible = true
	# CORRECCIÓN: yield permite devolver el timer a la función principal
	yield(get_tree().create_timer(1.5), "timeout")
	texto_horda.visible = false

func iniciar_horda(numero_horda):
	yield(mostrar_cartel_horda(numero_horda), "completed")
	var cantidad = enemigos_por_horda[numero_horda]
	
	for i in range(cantidad):
		spawn_enemigo()
		yield(get_tree().create_timer(0.4), "timeout")

func spawn_enemigo():
	var nuevo_enemigo = EnemigoEscena.instance()
	
	if spawn_points.size() > 0:
		var punto_spawn = spawn_points[randi() % spawn_points.size()]
		nuevo_enemigo.global_position = punto_spawn.global_position
	else:
		nuevo_enemigo.global_position = Vector2(rand_range(100, 900), rand_range(100, 500))
	
	nuevo_enemigo.connect("tree_exited", self, "_on_enemigo_muerto")
	add_child(nuevo_enemigo)
	enemigos_vivos += 1

func _on_enemigo_muerto():
	enemigos_vivos -= 1
	if enemigos_vivos <= 0:
		siguiente_horda()

func siguiente_horda():
	if horda_actual < hordas_totales:
		horda_actual += 1
		yield(get_tree().create_timer(2.0), "timeout")
		iniciar_horda(horda_actual)
	else:
		texto_horda.text = "¡NIVEL COMPLETADO!"
		texto_horda.visible = true
