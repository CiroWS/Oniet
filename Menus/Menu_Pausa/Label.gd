extends Label

var tiempo := 0.0

func _process(delta):
	tiempo += delta
	modulate.a = abs(sin(tiempo * 3))
