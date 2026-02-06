extends Line2D

var p0 : Vector2
var p1 : Vector2
var span : float
var duration : float

func setup(_p0 : Vector2, _p1 : Vector2, _span : float, _duration : float, _width = 8.0):
	p0 = _p0
	p1 = _p1
	span = _span
	duration = _duration
	width = _width

func _ready() -> void:
	set_point_position(0, p0)
	set_point_position(1, p0)
	var tween = G.game_tweens.create_tween()
	var tt = duration * (1.0 + span)
	tween.tween_method(func(t : float):
		if t < duration:
			set_point_position(1, lerp(p0, p1, t / duration))
		if t > duration * span:
			set_point_position(0, lerp(p0, p1, (t - duration * span) / duration))
	, 0.0, tt, tt)
	tween.tween_callback(queue_free)
