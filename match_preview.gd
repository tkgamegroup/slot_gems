extends RefCounted

class_name MatchPreview

var matchings : Array[Dictionary]
var lines : Array[Node2D]
var tween : Tween = null

func find_all_matchings():
	matchings.clear()
	for p in G.patterns:
		for y in Board.cy:
			for x in Board.cx:
				var c = Vector2i(x, y)
				var res : Array[Vector2i] = p.match_with(c)
				if !res.is_empty():
					matchings.append({"pattern":p,"coords":res})

func find_missing_ones(check_color : int, check_rune : int):
	matchings.clear()
	for p in G.patterns:
		for y in Board.cy:
			for x in Board.cx:
				var c = Vector2i(x, y)
				var res : Array[Vector2i] = p.match_with(c, check_color, check_rune)
				if !res.is_empty():
					var added = false
					for m in matchings:
						if m.coords[0] == res[0]:
							added = true
							break
					if !added:
						matchings.append({"pattern":p,"coords":res})

func show():
	for n in lines:
		Board.ui.overlay.remove_child(n)
		n.queue_free()
	lines.clear()
	if tween:
		tween.kill()
		tween = null
	tween = G.create_game_tween()
	var gs = []
	for m in matchings:
		for c in m.coords:
			var ok = false
			for g in gs:
				if g.is_empty():
					g.append(c)
					ok = true
					break
				for cc in g:
					if Board.offset_adjacents(cc, false).has(c):
						g.append(c)
						ok = true
						break
			if !ok:
				var g : Array[Vector2i] = []
				g.append(c)
				gs.append(g)
	var idx = 0
	var color = Color(0.0, 0.0, 0.0, 1.0)
	for g in gs:
		var pts = SMath.weld_lines(SUtils.get_cells_border(g), 8.0)
		var c = Vector2(0.0, 0.0)
		for pt in pts:
			c += pt
		c /= pts.size()
		for i in pts.size():
			pts[i] = pts[i] - c
		var l = G.dashed_line_pb.instantiate()
		l.default_color = color
		l.width = 3
		l.points = pts
		l.modulate.a = 0.0
		l.scale = Vector2(2.0, 2.0)
		l.position = c
		var subtween = G.create_game_tween()
		subtween.tween_interval(0.05 * idx)
		subtween.tween_property(l, "scale", Vector2(1.0, 1.0), 0.2)
		subtween.parallel().tween_property(l, "modulate:a", 1.0, 0.5)
		tween.parallel()
		tween.tween_subtween(subtween)
		lines.append(l)
		Board.ui.overlay.add_child(l)
		idx += 1
	tween.tween_callback(func():
		tween = null
	)

func clear():
	for n in lines:
		Board.ui.overlay.remove_child(n)
		n.queue_free()
	if tween:
		tween.kill()
		tween = null
	lines.clear()
