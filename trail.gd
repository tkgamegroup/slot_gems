extends Node

@onready var trail = $Line2D
@onready var timer = $Timer

func _ready() -> void:
	timer.timeout.connect(func():
		var pts = trail.points
		if pts.size() > 10:
			pts.remove_at(0)
		pts.append(get_parent().global_position)
		trail.points = pts
	)
