extends Node2D

var EnemigoEscena = preload("res://Dangeon/Enemigo_Peque.tscn")
var TorretaEscena = preload("res://Dangeon/Torreta.tscn")
var GolemEscena = preload("res://Dangeon/Golem/Golem.tscn")

export (PackedScene) var MONEDA
export (PackedScene) var VIDA
export (PackedScene) var FIGURITA

var horda_actual = 5
var hordas_totales = 5
var enemigos_vivos = 0
var horda_generando = false 
var saliendo = false

var enemigos_por_horda = {
	1: 6,
	2: 15,
	3: 22,
	4: 30,
	5: 15
}

var torretas_pos : Array=[]


onready var spawn_points = $SpawnPoints.get_children()
onready var texto_horda = $CanvasLayer/TextoHorda
var spawn_queue = []  

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

	if numero_horda == hordas_totales:
			spawn_golem_boss()
	
	var cantidad = enemigos_por_horda[numero_horda]
	
# warning-ignore:unused_variable
	for i in range(cantidad):
		spawn_enemigo()
		yield(get_tree().create_timer(0.4), "timeout")

	horda_generando = false

	verificar_horda_completa()

func siguiente_punto_spawn():

	if spawn_queue.empty():
		spawn_queue = spawn_points.duplicate()
		spawn_queue.shuffle()
	return spawn_queue.pop_front()

func spawn_enemigo():
	var nuevo_enemigo = EnemigoEscena.instance()
	

	if spawn_points.size() > 0:
		var punto_spawn = siguiente_punto_spawn()

		var offset = Vector2(rand_range(-40, 40), rand_range(-40, 40))
		nuevo_enemigo.global_position = punto_spawn.global_position + offset
	else:
		nuevo_enemigo.global_position = Vector2(rand_range(100, 900), rand_range(100, 500))


	nuevo_enemigo.connect("tree_exited", self, "_on_enemigo_muerto")
	add_child(nuevo_enemigo)
	enemigos_vivos += 1
func spawn_golem_boss():
	var golem = GolemEscena.instance()
	

	if spawn_points.size() > 0:
		golem.global_position = spawn_points[0].global_position
	else:
		golem.global_position = Vector2(512, 300)
		
	golem.connect("tree_exited", self, "_on_enemigo_muerto")
	add_child(golem)
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
	if saliendo or not is_inside_tree():
		return
	enemigos_vivos -= 1
	verificar_horda_completa()
	if Global.bicho=="peque":
# warning-ignore:unused_variable
		for i in range(2):
			var moneda = MONEDA.instance()
			add_child(moneda)
			Global.posicion.x+=16.0
			moneda.global_position = Global.posicion
	elif Global.bicho=="golem":
		for i in range(50):
			var moneda = MONEDA.instance()
			add_child(moneda)
			if i<10:
				Global.posicion.x+=10.0
				Global.posicion.y-=10.0
			elif i<20:
				Global.posicion.y+=10.0
				Global.posicion.x+=10.0
			elif i<30:
				Global.posicion.x-=10.0
				Global.posicion.y+=10.0
			elif i<40:
				Global.posicion.x-=10.0
				Global.posicion.y-=10.0
			elif i<50:
				Global.posicion.x+=10.0
			moneda.global_position = Global.posicion
			if i==49:
				var figu = FIGURITA.instance()
				add_child(figu)
				figu.global_position = Global.posicion

func verificar_horda_completa():
	if saliendo or not is_inside_tree():
		return

	if not horda_generando and enemigos_vivos <= 0:
		siguiente_horda()

func siguiente_horda():
	if saliendo or not is_inside_tree():
		return

	if horda_actual < hordas_totales:
		horda_actual += 1
		yield(get_tree().create_timer(2.0), "timeout")
		iniciar_horda(horda_actual)
	else:
		texto_horda.text = "¡NIVEL COMPLETADO!"
		texto_horda.visible = true
		Global.vidajugador = 100
		yield(get_tree().create_timer(3.0), "timeout")
		get_tree().change_scene("res://mapa/mapa.tscn")
		



func _on_musica_pelea_finished():
	$musica_pelea.play()


func _on_generador_vida_timeout():
	var vida = VIDA.instance()
	add_child(vida)
	vida.global_position=Vector2(Global.random(15, 990), Global.random(15,590))
	$generador_vida.start()


func _on_Player_muerte():
	$gameover.play()
	$gm.visible = true
	yield(get_tree().create_timer(0.7), "timeout")
	get_tree().paused = true
	


func _on_Button_pressed():
	saliendo = true
	get_tree().paused = false
	get_tree().change_scene("res://Dangeon/SalaDungeon.tscn")


func _on_Button2_pressed():
	saliendo = true
	get_tree().paused = false
	get_tree().change_scene("res://mapa/mapa.tscn")
