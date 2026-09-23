extends Node2D

var EnemigoEscena = preload("res://Dangeon/Enemigo_Peque.tscn")
var TorretaEscena = preload("res://Dangeon/Torreta.tscn")

var horda_actual = 1
var hordas_totales = 5
var enemigos_vivos = 0
var horda_generando = false  # true mientras todavía se están spawneando enemigos de la horda

var enemigos_por_horda = {
	1: 10,
	2: 20,
	3: 25,
	4: 30,
	5: 35
}

var torretas_pos : Array=[]


onready var spawn_points = $SpawnPoints.get_children()
onready var texto_horda = $CanvasLayer/TextoHorda
var spawn_queue = []  # cola de puntos de spawn "barajados" para no repetir seguido

func _ready():
	$musica_pelea.play()
	var contenedor_spawn = $SpawnPoints
	$Player/Light2D.visible=false
	$Player/Camera2D.limit_left = 0
	$Player/Camera2D.limit_top = 0
	$Player/Camera2D.limit_bottom = 600
	$Player/Camera2D.limit_right = 1024
	var nuevo_tamano = Vector2(1360, 768)
	OS.set_window_size(nuevo_tamano)
	OS.center_window()
	for i in contenedor_spawn.get_children():
		torretas_pos.append(i.position)
	randomize()
	iniciar_horda(horda_actual)
	

func mostrar_cartel_horda(numero):
	texto_horda.text = "HORDA " + str(numero)
	texto_horda.visible = true
	yield(get_tree().create_timer(1.5), "timeout")
	texto_horda.visible = false

func iniciar_horda(numero_horda):
	yield(mostrar_cartel_horda(numero_horda), "completed")
	spawn_torreta()
	horda_generando = true
	var cantidad = enemigos_por_horda[numero_horda]
	
	for i in range(cantidad):
		spawn_enemigo()
		yield(get_tree().create_timer(0.4), "timeout")

	horda_generando = false
	# Por si los primeros enemigos ya murieron mientras seguíamos spawneando
	verificar_horda_completa()

func siguiente_punto_spawn():
	# Barajamos todos los puntos y los vamos sacando de a uno.
	# Así, con 3 puntos, garantizamos que no se repita el mismo punto
	# dos veces seguidas (cosa que SÍ podía pasar con randi() puro).
	if spawn_queue.empty():
		spawn_queue = spawn_points.duplicate()
		spawn_queue.shuffle()
	return spawn_queue.pop_front()

func spawn_enemigo():
	var nuevo_enemigo = EnemigoEscena.instance()
	

	if spawn_points.size() > 0:
		var punto_spawn = siguiente_punto_spawn()
		# offset más grande para que se vean claramente separados
		var offset = Vector2(rand_range(-40, 40), rand_range(-40, 40))
		nuevo_enemigo.global_position = punto_spawn.global_position + offset
	else:
		nuevo_enemigo.global_position = Vector2(rand_range(100, 900), rand_range(100, 500))

	# antes decía "_on_enemigo_muerato" (typo), por eso nunca se restaban
	# los enemigos vivos y las hordas no avanzaban
	nuevo_enemigo.connect("tree_exited", self, "_on_enemigo_muerto")
	add_child(nuevo_enemigo)
	enemigos_vivos += 1

func spawn_torreta():
	var nueva_torreta = TorretaEscena.instance()

	if horda_actual == 1:
		var rng = randi()%len(torretas_pos)
		
		nueva_torreta.position = torretas_pos[rng]
		torretas_pos.remove(rng)
	elif horda_actual == 2:
		var rng = randi()%len(torretas_pos)
		
		nueva_torreta.position = torretas_pos[rng]
		torretas_pos.remove(rng)
	elif horda_actual == 3:
		var rng = randi()%len(torretas_pos)
		
		nueva_torreta.position = torretas_pos[rng]
		torretas_pos.remove(rng)
	elif horda_actual == 4:
		var rng = randi()%len(torretas_pos)
		
		nueva_torreta.position = torretas_pos[rng]
		torretas_pos.remove(rng)
	elif horda_actual == 5:
		var rng = randi()%len(torretas_pos)
		
		nueva_torreta.position = torretas_pos[rng]
		torretas_pos.remove(rng)
	add_child(nueva_torreta)
	
func _on_enemigo_muerto():
	enemigos_vivos -= 1
	verificar_horda_completa()

func verificar_horda_completa():
	# Solo avanzamos si ya terminamos de spawnear TODA la horda
	# y además no queda ningún enemigo vivo.
	if not horda_generando and enemigos_vivos <= 0:
		siguiente_horda()

func siguiente_horda():
	if horda_actual < hordas_totales:
		horda_actual += 1
		yield(get_tree().create_timer(2.0), "timeout")
		iniciar_horda(horda_actual)
	else:
		texto_horda.text = "¡NIVEL COMPLETADO!"
		texto_horda.visible = true



func _on_musica_pelea_finished():
	$musica_pelea.play()
