extends KinematicBody2D


signal jugador_detectado
signal jugador_atrapado

enum Estado { PATRULLA, PAUSA, SOSPECHA, BUSCANDO, ATRAPADO }

export(float) var velocidad = 45.0            # px/seg al patrullar
export(float) var alcance_vision = 450.0      # distancia maxima de vision (px globales)
export(float) var angulo_vision = 70.0        # apertura TOTAL del cono (grados)
export(float) var tiempo_deteccion = 0.9      # seg de mirarte para atraparte (de lejos es mas lento)
export(float) var tiempo_busqueda = 2.5       # seg que te busca despues de perderte
export(float) var pausa_cada_min = 6.0        # cada cuanto se frena a mirar alrededor
export(float) var pausa_cada_max = 14.0
export(float) var pausa_duracion_min = 2.0
export(float) var pausa_duracion_max = 4.0
export(int, LAYERS_2D_PHYSICS) var capa_piso = 1   # capa de fisica del piso donde patrulla
export(String, FILE, "*.tscn") var escena_castigo = "res://Profesores/cinematica de regaño.tscn"

var path_follow: PathFollow2D = null          # lo asigna mapa.gd antes de add_child
var estado = Estado.PATRULLA
var facing := Vector2.DOWN                    # direccion cardinal (para el sprite)
var mirada := Vector2.DOWN                    # direccion exacta del cono de vision
var alerta := 0.0                             # 0..1 (1 = te atrapo)

var _ang_mirada := 0.0
var _mirada_objetivo := Vector2.DOWN
var _sentido := 1
var _curva: Curve2D = null
var _largo := 0.0
var _cerrado := false
var _jugador = null
var _ultima_pos_vista := Vector2.ZERO
var _distancia := 0.0
var _t_estado := 0.0
var _t_mirada := 0.0
var _t_proxima_pausa := 0.0
var _lado := 1
var _atrapado := false

onready var sprite = $personaje
onready var luz = $Light2D
var etiqueta: Label


func _ready():
	add_to_group("profesor")
	_crear_etiqueta()
	_t_proxima_pausa = rand_range(pausa_cada_min, pausa_cada_max)
	if path_follow:
		var path = path_follow.get_parent()
		_curva = path.curve
		_largo = _curva.get_baked_length()
		var n = _curva.get_point_count()
		_cerrado = _curva.get_point_position(0).distance_to(_curva.get_point_position(n - 1)) < 8.0
		path_follow.rotate = false            # el profe NUNCA rota, solo cambia de animacion
		path_follow.loop = _cerrado           # si no es circuito cerrado va y vuelve (ida y vuelta)
		path_follow.offset = rand_range(0.0, _largo)
		global_position = path_follow.global_position
		_sentido = 1 if randf() > 0.5 else -1
		var d = _direccion_camino()
		if d != Vector2.ZERO:
			_mirar_hacia(d)
	_ang_mirada = mirada.angle()
	_actualizar_sprite(false)


func _crear_etiqueta():
	etiqueta = Label.new()
	etiqueta.text = "?"
	etiqueta.rect_position = Vector2(-4, -44)
	etiqueta.visible = false
	add_child(etiqueta)


# ---------------------------------------------------------------
#  LOOP PRINCIPAL
# ---------------------------------------------------------------
func _physics_process(delta):
	if _atrapado:
		return

	_buscar_jugador()
	var ve = _ve_al_jugador()
	var dificultad = _dificultad()

	match estado:
		Estado.PATRULLA:
			_decaer_alerta(delta)
			_mover(delta, dificultad)
			_t_proxima_pausa -= delta
			if ve:
				_iniciar_sospecha()
			elif _t_proxima_pausa <= 0.0:
				_iniciar_pausa()

		Estado.PAUSA:
			_decaer_alerta(delta)
			_t_estado -= delta
			_t_mirada -= delta
			if _t_mirada <= 0.0:          # gira la cabeza izquierda / derecha
				_lado = -_lado
				_mirar_hacia(Vector2(_lado, 0))
				_t_mirada = rand_range(0.7, 1.2)
			if ve:
				_iniciar_sospecha()
			elif _t_estado <= 0.0:
				_volver_a_patrullar()

		Estado.SOSPECHA:
			if ve:
				_mirar_hacia(_ultima_pos_vista - global_position)
				# de cerca te caza mas rapido
				var cerca = 1.0 - clamp(_distancia / alcance_vision, 0.0, 1.0)
				var ritmo = (1.0 / max(tiempo_deteccion, 0.1)) * (1.0 + 1.5 * cerca) * dificultad
				alerta = min(alerta + ritmo * delta, 1.0)
				if alerta >= 1.0:
					_atrapar()
			else:
				estado = Estado.BUSCANDO
				_t_estado = tiempo_busqueda
				_t_mirada = 1.0

		Estado.BUSCANDO:
			_decaer_alerta(delta, 0.3)
			_t_estado -= delta
			_t_mirada -= delta
			if _t_mirada <= 0.0:          # revisa a los costados
				_lado = -_lado
				_mirar_hacia(Vector2(_lado, 0))
				_t_mirada = 0.8
			if ve:
				_iniciar_sospecha()
			elif _t_estado <= 0.0:
				_volver_a_patrullar()

	_actualizar_luz(delta)
	_actualizar_etiqueta()
	update()


# ---------------------------------------------------------------
#  MOVIMIENTO POR PATH
# ---------------------------------------------------------------
func _mover(delta, dificultad):
	if path_follow == null:
		_actualizar_sprite(false)
		return

	path_follow.offset += velocidad * dificultad * delta * _sentido

	if not _cerrado:
		path_follow.offset = clamp(path_follow.offset, 0.0, _largo)
		if path_follow.offset >= _largo - 0.5 and _sentido == 1:
			_sentido = -1
			_iniciar_pausa()              # llega al final del recorrido y mira alrededor
		elif path_follow.offset <= 0.5 and _sentido == -1:
			_sentido = 1
			_iniciar_pausa()

	global_position = path_follow.global_position

	var d = _direccion_camino()
	if d != Vector2.ZERO:
		_mirar_hacia(d)
	_actualizar_sprite(true)


# Tangente del camino hacia donde va a avanzar (mas estable que restar posiciones)
func _direccion_camino() -> Vector2:
	if path_follow == null or _curva == null or _largo <= 0.0:
		return Vector2.ZERO
	var o1 = path_follow.offset
	var o2 = o1 + _sentido * 8.0
	if _cerrado:
		o1 = fposmod(o1, _largo)
		o2 = fposmod(o2, _largo)
	else:
		o2 = clamp(o2, 0.0, _largo)
	var d = _curva.interpolate_baked(o2) - _curva.interpolate_baked(o1)
	d = path_follow.get_parent().global_transform.basis_xform(d)
	return d.normalized() if d.length() > 0.001 else Vector2.ZERO


# ---------------------------------------------------------------
#  DIRECCION + ANIMACION
# ---------------------------------------------------------------
func _mirar_hacia(v: Vector2):
	if v == Vector2.ZERO:
		return
	_mirada_objetivo = v.normalized()
	facing = _a_cardinal(v)


# 4 direcciones con histeresis para que no parpadee en las diagonales
func _a_cardinal(v: Vector2) -> Vector2:
	if abs(v.x) > abs(v.y) * 1.15:
		return Vector2.RIGHT if v.x > 0.0 else Vector2.LEFT
	if abs(v.y) > abs(v.x) * 1.15:
		return Vector2.DOWN if v.y > 0.0 else Vector2.UP
	return facing


func _actualizar_sprite(caminando: bool):
	var anim = "Adelante"
	var invertir = false
	if facing == Vector2.LEFT:
		anim = "Costado"            # el sprite original mira a la izquierda
	elif facing == Vector2.RIGHT:
		anim = "Costado"
		invertir = true             # derecha = mismo sprite espejado por codigo
	elif facing == Vector2.UP:
		anim = "Espalda"
	sprite.flip_h = invertir

	if sprite.animation != anim:
		sprite.animation = anim
		sprite.frame = 0
	if caminando:
		if not sprite.playing:
			sprite.play(anim)
	else:
		if sprite.playing:
			sprite.stop()
		sprite.frame = 0


# ---------------------------------------------------------------
#  VISION (cono + linea de vista)
# ---------------------------------------------------------------
func _buscar_jugador():
	if _jugador == null or not is_instance_valid(_jugador):
		var l = get_tree().get_nodes_in_group("player")
		_jugador = l[0] if l.size() > 0 else null


func _ve_al_jugador() -> bool:
	if _jugador == null:
		return false
	# solo ve al jugador si esta en SU piso (planta baja / media / alta)
	if (_jugador.collision_layer & capa_piso) == 0:
		return false

	var al_jugador = _jugador.global_position - global_position
	_distancia = al_jugador.length()
	if _distancia > alcance_vision:
		return false

	# 1) CONO: el jugador tiene que estar adelante, dentro del angulo de vision
	if _distancia > 1.0:
		if abs(mirada.angle_to(al_jugador)) > deg2rad(angulo_vision * 0.5):
			return false              # de espaldas / de costado = no te ve

	# 2) LINEA DE VISTA: ninguna pared en el medio
	var espacio = get_world_2d().direct_space_state
	var r = espacio.intersect_ray(global_position, _jugador.global_position, [self], capa_piso)
	if r and r.collider != _jugador:
		return false

	_ultima_pos_vista = _jugador.global_position
	return true


# ---------------------------------------------------------------
#  ESTADOS
# ---------------------------------------------------------------
func _iniciar_sospecha():
	estado = Estado.SOSPECHA
	_actualizar_sprite(false)
	emit_signal("jugador_detectado")


func _iniciar_pausa():
	estado = Estado.PAUSA
	_t_estado = rand_range(pausa_duracion_min, pausa_duracion_max)
	_lado = 1 if randf() > 0.5 else -1
	_mirar_hacia(Vector2(_lado, 0))
	_t_mirada = rand_range(0.7, 1.2)
	_actualizar_sprite(false)


func _volver_a_patrullar():
	estado = Estado.PATRULLA
	_t_proxima_pausa = rand_range(pausa_cada_min, pausa_cada_max)
	var d = _direccion_camino()
	if d != Vector2.ZERO:
		_mirar_hacia(d)


func _decaer_alerta(delta, ritmo = 0.5):
	alerta = max(alerta - ritmo * delta, 0.0)


func _atrapar():
	if _atrapado:
		return
	_atrapado = true
	estado = Estado.ATRAPADO
	alerta = 1.0
	_actualizar_sprite(false)
	_actualizar_etiqueta()
	if is_instance_valid(_jugador):
		_jugador.set_physics_process(false)  
	emit_signal("jugador_atrapado")
	Global.sancion += 1
	if Global.sancion == 12:
		get_tree().change_scene("res://Menus/Menu_principal/Menu_principal.tscn")
		Global.armas = [true , false , false , false , false ]
		Global.sancion = 0 
		Global.moneda = 0 
		Global.Llamdos_de_atencion = 0 
		
		
	yield(get_tree().create_timer(0.7), "timeout")   
	get_tree().change_scene(escena_castigo)



func _dificultad() -> float:
	var s = Global.get("sancion")
	if s == null:
		s = 0
	return 1.0 + 0.1 * min(int(s), 5)


# ---------------------------------------------------------------
#  FEEDBACK VISUAL
# ---------------------------------------------------------------
func _actualizar_luz(delta):
	var dif = fposmod(_mirada_objetivo.angle() - _ang_mirada + PI, TAU) - PI
	_ang_mirada += dif * clamp(delta * 12.0, 0.0, 1.0)
	mirada = Vector2(cos(_ang_mirada), sin(_ang_mirada))
	luz.rotation = _ang_mirada
	# amarillo tranquilo -> rojo cuando te esta por atrapar
	luz.color = Color(1.0, lerp(0.85, 0.0, alerta), 0.0, lerp(0.30, 0.60, alerta))


func _actualizar_etiqueta():
	etiqueta.visible = alerta > 0.05
	etiqueta.text = "!" if alerta >= 1.0 else "?"
	etiqueta.modulate = Color(1.0, 1.0 - alerta, 0.0)


func _draw():
	if alerta > 0.02:
		draw_rect(Rect2(-12, -24, 24, 3), Color(0, 0, 0, 0.6))
		draw_rect(Rect2(-12, -24, 24.0 * alerta, 3), Color(1.0, 1.0 - alerta, 0.0))
