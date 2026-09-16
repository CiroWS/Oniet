extends Node2D

var EnemigoEscena = preload("res://Dangeon/Enemigo_Chico.tscn")

var horda_actual = 1
var hordas_totales = 5
var enemigos_vivos = 0


# Configuración de enemigos a aparecer en cada una de las 5 hordas
var enemigos_por_horda = {
	1: 3,
	2: 6,
	3: 9,
	4: 12,
	5: 16
}

onready var spawn_points = $SpawnPoints.get_children()

func _ready():
	randomize()
	iniciar_horda(horda_actual)
	

func iniciar_horda(numero_horda):
	print("=== INICIANDO HORDA ", numero_horda, " ===")
	var cantidad = enemigos_por_horda[numero_horda]
	
	for i in range(cantidad):
		spawn_enemigo()
		# Pausa breve entre apariciones para que no salgan encimados
		yield(get_tree().create_timer(0.3), "timeout")

func spawn_enemigo():
	var nuevo_enemigo = EnemigoEscena.instance()
	
	# Elegir un Position2D al azar
	var punto_azar_x = randi() % 1024+1
	print(punto_azar_x)
	var punto_azar_y = randi() % 600+1
	nuevo_enemigo.position.x = punto_azar_x
	print(nuevo_enemigo.global_position.x)
	nuevo_enemigo.position.y = punto_azar_y
	
	# Detectar cuándo se elimina el nodo para descontar del contador
	nuevo_enemigo.connect("tree_exited", self, "_on_enemigo_muerto")
	
	add_child(nuevo_enemigo)
	enemigos_vivos += 1

func _on_enemigo_muerto():
	enemigos_vivos -= 1
	print("Enemigo eliminado. Quedan: ", enemigos_vivos)
	
	if enemigos_vivos <= 0:
		siguiente_horda()

func siguiente_horda():
	if horda_actual < hordas_totales:
		horda_actual += 1
		print("¡Horda superada! Preparando horda ", horda_actual)
		yield(get_tree().create_timer(3.0), "timeout")
		iniciar_horda(horda_actual)
	else:
		print("¡DESAFÍO COMPLETADO! Sobreviviste a las 5 hordas.")
