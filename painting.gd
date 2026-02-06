extends Object

class_name Painting

static func color_distance(c1 : Color, c2 : Color):
	return (c1.r - c2.r) * (c1.r - c2.r) + (c1.g - c2.g) * (c1.g - c2.g) + (c1.b - c2.b) * (c1.b - c2.b)

static func closest_color(col : Color):
	var min_diff = 1000000.0
	var ret = Gem.None
	for i in Gem.ColorCount:
		var type = Gem.ColorFirst + i
		var dis = color_distance(Gem.type_color(type), col)
		if dis < min_diff:
			min_diff = dis
			ret = type
	return ret

static func set_board_to_image(name : String):
	var tex = load("res://images/relics/painting_of_orange.png")
	var img = tex.get_image() as Image
	var img_cx = img.get_width()
	var img_cy = img.get_height()
	var img_data = img.get_data()
	var cx = Board.cx
	var cy = Board.cy
	var rect = Board.ui.get_panel_rect(G.board_size % 2 == 0, false)
	var tween = G.game_tweens.create_tween()
	var delay = 0.0
	for y in cy:
		for x in cx:
			var c = Vector2(x, y)
			var p = Board.get_pos(c)
			var coord = Vector2i(Vector2(img_cx, img_cy) * ((p - rect.position) / rect.size))
			var idx = (coord.y * img_cx + coord.x) * 4
			var r = img_data[idx + 0]
			var g = img_data[idx + 1]
			var b = img_data[idx + 2]
			var type = closest_color(Color(r / 255.0, g / 255.0, b / 255.0))
			var sub = G.game_tweens.create_tween()
			sub.tween_interval(delay)
			Board.effect_change_color(c, type, Gem.None, sub)
			tween.tween_subtween(sub)
			tween.parallel()
			delay += 0.01
