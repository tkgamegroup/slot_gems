class_name Painting

static var lines : Array[Pair]

static func color_distance(c1 : Color, c2 : Color):
	return (c1.r - c2.r) * (c1.r - c2.r) + (c1.g - c2.g) * (c1.g - c2.g) + (c1.b - c2.b) * (c1.b - c2.b)

static func closest_color(col : Color):
	var min_diff = 1000000.0
	var ret : int = Gem.None
	for i in Gem.ColorCount:
		var type = Gem.ColorFirst + i
		var dis = color_distance(Gem.type_color(type), col)
		if dis < min_diff:
			min_diff = dis
			ret = type
	return ret

static func save_to_file(name : String):
	if !DirAccess.dir_exists_absolute("res://paintings"):
		DirAccess.make_dir_absolute("res://paintings")
	var file = ConfigFile.new()
	var colors_data = {}
	var lines_data = []
	var center = Board.offset_to_cube(Vector2i(Board.cx / 2, Board.cy / 2))
	for y in Board.cy:
		for x in Board.cx:
			var oc = Vector2i(x, y)
			var cc = Board.offset_to_cube(oc)
			var g = Board.get_gem_at(oc)
			cc = cc - center
			var type = Gem.None
			if g && g.name == "":
				type = g.type
			colors_data.get_or_add(type, []).append(cc)
	for l in lines:
		lines_data.append([Board.offset_to_cube(l.first) - center, Board.offset_to_cube(l.second) - center])
	file.set_value("", "colors", colors_data)
	file.set_value("", "lines", lines_data)
	file.save("res://paintings/%s.txt" % name)

static func load_from_file(name : String):
	var ret = {}
	var file = ConfigFile.new()
	if file.load("res://paintings/%s.txt" % name) == OK:
		ret["colors"] = file.get_value("", "colors", {})
		ret["lines"] = file.get_value("", "lines", {})
	return ret

static func set_board_to_image(name : String):
	var tex = load("res://images/relics/%s.png" % name)
	var img = tex.get_image() as Image
	var img_cx = img.get_width()
	var img_cy = img.get_height()
	var img_data = img.get_data()
	var cx = Board.cx
	var cy = Board.cy
	var rect = Board.ui.get_panel_rect(G.board_size % 2 == 0, false)
	var tween = G.create_game_tween()
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
			var sub = G.create_game_tween()
			sub.tween_interval(delay)
			Board.effect_change_color(c, type, Gem.None, sub)
			tween.tween_subtween(sub)
			tween.parallel()
			delay += 0.01

static func add_line(a : Vector2i, b : Vector2i):
	for l in lines:
		if (l.first == a && l.second == b) || l.first == b && l.second == a:
			return
	lines.append(Pair.new(a, b))
	Board.ui.draw_lines.queue_redraw()

static func remove_line(a : Vector2i, b : Vector2i):
	for l in lines:
		if (l.first == a && l.second == b) || l.first == b && l.second == a:
			lines.erase(l)
	Board.ui.draw_lines.queue_redraw()

static func clear_lines():
	lines.clear()
	Board.ui.draw_lines.queue_redraw()
