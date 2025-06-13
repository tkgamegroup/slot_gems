extends Node

@onready var trail = $Line2D
@onready var timer = $Timer

var width : float = 5.0
var color : Color = Color(1.0, 1.0, 1.0)

func setup(_width : float, _color : Color):
	width = _width
	color = _color

func _ready() -> void:
	trail.width = width
	trail.modulate = color
	
	timer.timeout.connect(func():
		var pts = trail.points
		if pts.size() > 10:
			pts.remove_at(0)
		pts.append(get_parent().global_position)
		trail.points = pts
	)
