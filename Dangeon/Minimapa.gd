extends Control



const TAMANO = Vector2(200, 120)     
const MARGEN = 10                 
const SALA = Rect2(0, -9, 1028, 618)

var jugador = null
var enemigos = []

func _ready():
	mouse_filter = Control.MOUSE_FILTER_IGNORE  
	rect_size = TAMANO
	rect_position = Vector2(get_viewport_rect().size.x - TAMANO.x - MARGEN, 470)
	visible = Global.dungeon

func _process(_delta):
	visible = Global.dungeon
	if visible:
		update()

func _draw():
	draw_rect(Rect2(Vector2.ZERO, TAMANO), Color(0, 0, 0, 0.6))
	draw_rect(Rect2(Vector2.ZERO, TAMANO), Color(1, 1, 1, 0.8), false)

	for e in enemigos:
		if is_instance_valid(e) and e.is_inside_tree():
			var radio = 3
			if e.filename.find("Golem") != -1:
				radio = 6   # el jefe se ve mas grande
			draw_circle(_a_minimapa(e.global_position), radio, Color.red)

	if is_instance_valid(jugador):
		draw_circle(_a_minimapa(jugador.global_position), 3, Color.green)

func _a_minimapa(pos):
	var p = (pos - SALA.position) / SALA.size
	return Vector2(clamp(p.x, 0, 1), clamp(p.y, 0, 1)) * TAMANO
