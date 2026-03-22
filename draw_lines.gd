extends Node2D

func _draw() -> void:
	for l in Painting.lines:
		draw_line(Board.get_pos(l.first), Board.get_pos(l.second), Color.WHITE, 10.0)
