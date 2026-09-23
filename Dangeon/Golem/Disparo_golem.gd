extends Node2D

export (float) var longitud_maxima = 400.0
export (float) var velocidad_extension = 0.12 
export (int) var dano = 15

onready var animated_sprite = $AnimatedSprite
onready var ray_cast = $RayCast2D
onready var tween = $Tween

var alcance_actual: float = 0.0
var disparando: bool = false
var alto_frame_base: float = 0.0

func _ready():
	visible = false
	ray_cast.enabled = false
	

	if animated_sprite.frames and animated_sprite.frames.has_animation("default"):
		var textura_frame = animated_sprite.frames.get_frame("default", 0)
		if textura_frame:
			alto_frame_base = textura_frame.get_height()

func disparar():
	disparando = true
	visible = true
	ray_cast.enabled = true
	

	animated_sprite.play("default")
	

	tween.stop_all()
	tween.interpolate_property(
		self, 
		"alcance_actual", 
		0.0, 
		longitud_maxima, 
		velocidad_extension, 
		Tween.TRANS_QUAD, 
		Tween.EASE_OUT
	)
	tween.start()

func detener_disparo():
	disparando = false
	visible = false
	ray_cast.enabled = false
	animated_sprite.stop()

func _process(_delta):
	if not disparando:
		return
		


	ray_cast.cast_to = Vector2.RIGHT * alcance_actual
	ray_cast.force_raycast_update()
	
	var distancia_final = alcance_actual
	


	if ray_cast.is_colliding():
		var punto_impacto = to_local(ray_cast.get_collision_point())
		distancia_final = punto_impacto.x 
		
		var colisionador = ray_cast.get_collider()
		if colisionador.has_method("recibir_dano"):
			colisionador.recibir_dano(dano)
	

	if alto_frame_base > 0:
		animated_sprite.scale.y = distancia_final / alto_frame_base
