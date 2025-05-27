extends Node

func fade_in(n, tween : Tween, s0 : float, s1 : float, duration : float):
	if !tween:
		tween = Game.get_tree().create_tween()
	n.scale = Vector2(s0, s0)
	n.modulate.a = 0.0
	if s0 != s1:
		tween.tween_property(n, "scale", Vector2(s1, s1), duration).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
		tween.parallel()
	tween.tween_property(n, "modulate:a", 1.0, duration).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	return tween

func fade_out(n, tween : Tween, s0 : float, s1 : float, duration : float):
	if !tween:
		tween = Game.get_tree().create_tween()
	n.scale = Vector2(s0, s0)
	n.modulate.a = 1.0
	if s0 != s1:
		tween.tween_property(n, "scale", Vector2(s1, s1), duration).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
		tween.parallel()
	tween.tween_property(n, "modulate:a", 0.0, duration).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	return tween

func move_to(tween : Tween, target, p : Vector2, duration : float):
	if !tween:
		tween = Game.get_tree().create_tween()
	tween.tween_property(target, "global_position", p, duration)
	return tween

func quadratic_curve_to(tween : Tween, target, p2 : Vector2, ctrl1_t : float, ctrl1_o : Vector2, duration : float):
	if !tween:
		tween = Game.get_tree().create_tween()
	var d = {}
	d.p2 = p2
	tween.tween_callback(func():
		d.p0 = target.global_position
		d.p1 = lerp(d.p0, d.p2, ctrl1_t) + ctrl1_o
	)
	tween.parallel().tween_method(func(t):
		target.global_position = SMath.quadratic_bezier(d.p0, d.p1, d.p2, t)
	, 0.0, 1.0, duration)
	return tween

func cubic_curve_to(tween : Tween, target, p3 : Vector2, ctrl1_t : float, ctrl1_o : Vector2, ctrl2_t : float, ctrl2_o : Vector2, duration : float):
	if !tween:
		tween = Game.get_tree().create_tween()
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
	return tween

func jump(tween : Tween, target, height : float, duration : float, cb : Callable = Callable()):
	if !tween:
		tween = Game.get_tree().create_tween()
	var parent = target.get_parent()
	tween.tween_property(target, "scale", Vector2(1.0, 0.9), duration * 0.2).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tween.tween_property(target, "scale", Vector2(1.0, 1.1), duration * 0.5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(target, "position", target.position + Vector2(0, height), duration * 0.5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	if cb.is_valid():
		tween.tween_callback(cb)
	tween.tween_property(target, "scale", Vector2(1.0, 1.0), duration * 0.3).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(target, "position", target.position, duration * 0.3).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	return tween
