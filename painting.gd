extends Object

class_name Painting

static func set_board_to_painting(name : String):
	var tex = load("res://images/relics/painting_of_orange.png") as Texture2D
	var data = tex.get_image()
	var cx = data.get_width()
	var cy = data.get_height()
	pass
