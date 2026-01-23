extends Node2D

@onready var line = $Line2D

var coord1 : Vector2i
var coord2 : Vector2i

func appear():
	var tween = App.game_tweens.create_tween()
	tween.tween_property(line.material, "shader_parameter/alpha", 1.0, 0.3)

func disappear():
	var tween = App.game_tweens.create_tween()
	tween.tween_property(line.material, "shader_parameter/alpha", 0.0, 0.3)
	tween.tween_callback(queue_free)

func flash():
	pass

func setup(_coord1 : Vector2i, _coord2 : Vector2i):
	coord1 = _coord1
	coord2 = _coord2

func _ready() -> void:
	line.clear_points()
	line.add_point(Board.get_pos(coord1))
	line.add_point(Board.get_pos(coord2))
	appear()
