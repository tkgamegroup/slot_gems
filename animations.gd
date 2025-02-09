extends Node

func fade_in(n : Node2D, tween : Tween):
	n.scale = Vector2(2.0, 2.0)
	n.self_modulate.a = 0.0
	tween.tween_property(n, "scale", Vector2(1.0, 1.0), 0.5).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	tween.parallel().tween_property(n, "self_modulate:a", 1.0, 0.5).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)

func fade_out(n : Node2D, tween : Tween, s0 : float = 1.0, s1 : float = 2.0):
	n.scale = Vector2(s0, s0)
	n.self_modulate.a = 1.0
	tween.tween_property(n, "scale", Vector2(s1, s1), 0.5).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	tween.parallel().tween_property(n, "self_modulate:a", 0.0, 0.5).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
