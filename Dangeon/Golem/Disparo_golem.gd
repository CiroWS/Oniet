extends Node2D



export (float) var longitud_maxima = 1200.0   
export (float) var velocidad_extension = 1500.0
export (float) var grosor = 44.0             
export (int) var dano = 25                    
export (float) var intervalo_dano = 0.30     

export (bool) var arte_vertical = true

onready var sprite = $AnimatedSprite
onready var hitbox = $Hitbox
onready var forma = $Hitbox/CollisionShape2D

var golem = null          
var alcance_actual: float = 0.0
var largo_total: float = 0.0  
var disparando: bool = false
var avisando: bool = false
var cooldown_dano: float = 0.0


var largo_base: float = 64.0  
var ancho_base: float = 32.0  


func _ready():
	visible = false
	hitbox.monitoring = false
	configurar_sprite()


func configurar_sprite():
	if sprite.frames and sprite.frames.has_animation("default"):
		var tex = sprite.frames.get_frame("default", 0)
		if tex:
			if arte_vertical:
				ancho_base = float(tex.get_width())
				largo_base = float(tex.get_height())
			else:
				largo_base = float(tex.get_width())
				ancho_base = float(tex.get_height())


	sprite.centered = false
	if arte_vertical:
		sprite.rotation_degrees = -90.0
		sprite.offset = Vector2(-ancho_base / 2.0, 0.0)
	else:
		sprite.rotation_degrees = 0.0
		sprite.offset = Vector2(0.0, -ancho_base / 2.0)



func avisar():
	largo_total = calcular_largo_hasta_pared()
	avisando = true
	disparando = false
	visible = true
	sprite.visible = false
	hitbox.set_deferred("monitoring", false)
	update()


func disparar():
	largo_total = calcular_largo_hasta_pared()
	avisando = false
	disparando = true
	alcance_actual = 0.0
	cooldown_dano = 0.0
	visible = true
	sprite.visible = true
	sprite.play("default")
	actualizar_visual()
	hitbox.set_deferred("monitoring", true)
	update()


func detener_disparo():
	avisando = false
	disparando = false
	visible = false
	sprite.stop()
	hitbox.set_deferred("monitoring", false)
	update()



func _physics_process(delta):
	if avisando:
		update() 

	if not disparando:
		return

	alcance_actual = min(alcance_actual + velocidad_extension * delta, largo_total)
	actualizar_visual()
	aplicar_dano(delta)


func actualizar_visual():
	var largo = max(alcance_actual, 1.0)

	if arte_vertical:
		sprite.scale = Vector2(grosor / ancho_base, largo / largo_base)
	else:
		sprite.scale = Vector2(largo / largo_base, grosor / ancho_base)


	forma.shape.extents = Vector2(largo / 2.0, grosor * 0.4)
	hitbox.position = Vector2(largo / 2.0, 0.0)


func aplicar_dano(delta):
	cooldown_dano -= delta
	if cooldown_dano > 0.0 or not hitbox.monitoring:
		return

	var golpeo = false
	for cuerpo in hitbox.get_overlapping_bodies():
		if cuerpo == golem:
			continue
		if not (cuerpo.is_in_group("Jugador") or cuerpo.is_in_group("player")):
			continue

		if cuerpo.has_method("recibir_danio"):
			cuerpo.recibir_danio(dano)
			golpeo = true
		elif cuerpo.has_method("recibir_dano"):
			cuerpo.recibir_dano(dano)
			golpeo = true

	if golpeo:
		cooldown_dano = intervalo_dano


func calcular_largo_hasta_pared() -> float:
	var espacio = get_world_2d().direct_space_state
	var desde = global_position
	var direccion = Vector2.RIGHT.rotated(global_rotation)
	var hasta = desde + direccion * longitud_maxima

	var excluidos = []
	if golem:
		excluidos.append(golem)

	for i in range(10):
		var r = espacio.intersect_ray(desde, hasta, excluidos)
		if r.empty():
			return longitud_maxima
		var col = r.collider
		if col is StaticBody2D or col is TileMap:
			return desde.distance_to(r.position)
		excluidos.append(col)

	return longitud_maxima

func _draw():
	if not avisando:
		return
	var alfa = 0.18 + 0.14 * sin(OS.get_ticks_msec() / 40.0)
	draw_rect(Rect2(0.0, -grosor * 0.4, largo_total, grosor * 0.8), Color(1, 0.1, 0.1, alfa))
	draw_line(Vector2.ZERO, Vector2(largo_total, 0.0), Color(1, 0.3, 0.3, 0.8), 2.0)
