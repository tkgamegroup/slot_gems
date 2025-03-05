extends Node

func fade_in(n : Node2D, tween : Tween, s0 : float = 2.0, s1 : float = 1.0):
	n.scale = Vector2(s0, s0)
	n.self_modulate.a = 0.0
	tween.tween_property(n, "scale", Vector2(s1, s1), 0.5).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	tween.parallel().tween_property(n, "self_modulate:a", 1.0, 0.5).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)

func fade_out(n : Node2D, tween : Tween, s0 : float = 1.0, s1 : float = 2.0):
	n.scale = Vector2(s0, s0)
	n.self_modulate.a = 1.0
	tween.tween_property(n, "scale", Vector2(s1, s1), 0.5).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	tween.parallel().tween_property(n, "self_modulate:a", 0.0, 0.5).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)

func quadratic_curve_to(tween : Tween, target, p2 : Vector2, ctrl1_t : float, ctrl1_o : Vector2, duration : float):
	var d = {}
	d.p2 = p2
	tween.tween_callback(func():
		d.p0 = target.global_position
		d.p1 = lerp(d.p0, d.p2, ctrl1_t) + ctrl1_o
	)
	tween.parallel().tween_method(func(t):
		target.global_position = SMath.quadratic_bezier(d.p0, d.p1, d.p2, t)
	, 0.0, 1.0, duration)

func cubic_curve_to(tween : Tween, target, p3 : Vector2, ctrl1_t : float, ctrl1_o : Vector2, ctrl2_t : float, ctrl2_o : Vector2, duration : float):
	var d = {}
	d.p3 = p3
	tween.tween_callback(func():
		d.p0 = target.global_position
		d.p1 = lerp(d.p0, d.p3, ctrl1_t) + ctrl1_o
		d.p2 = lerp(d.p0, d.p3, ctrl2_t) + ctrl2_o
	)
	tween.parallel().tween_method(func(t):
		target.global_position = SMath.cubic_bezier(d.p0, d.p1, d.p2, d.p3, t)
	, 0.0, 1.0, duration)
