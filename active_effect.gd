extends Object

class_name ActiveEffect

var host
var type : int
var coord : Vector2i
var effect_index : int
var sp : AnimatedSprite2D

func process(b : Board, tween : Tween):
	host.on_active.call(b, coord, effect_index, tween, sp)
