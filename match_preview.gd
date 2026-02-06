extends Object

class_name MatchPreview

const line_pb = preload("res://dashed_line.tscn")

var matchings : Array[Array]
var rune_matchings : Array[int]
var lines : Array[Node2D]
var tween : Tween = null

func find_all_matchings():
	matchings.clear()
	for y in Board.cy:
		for x in Board.cx:
			for p in G.patterns:
				var res : Array[Vector2i] = p.match_with(Vector2i(x, y))
				if !res.is_empty():
					matchings.append(res)

func find_missing_ones(check_color : int, check_rune : int):
	matchings.clear()
	for y in Board.cy:
		for x in Board.cx:
			for p in G.patterns:
				var res : Array[Vector2i] = p.match_with(Vector2i(x, y), check_color, check_rune)
				if !res.is_empty():
					var added = false
					for m in matchings:
						if m[0] == res[0]:
							added = true
							break
					if !added:
						matchings.append(res)

func show():
	for n in lines:
		Board.ui.overlay.remove_child(n)
		n.queue_free()
	lines.clear()
	if tween:
		tween.kill()
		tween = null
	tween = G.game_tweens.create_tween()
	var idx = 0
	for res in matchings:
		var gs = []
		for c in res:
			var ok = false
			for g in gs:
				if g.is_empty():
					g.append(c)
					ok = true
					break
				for cc in g:
					if Board.offset_neighbors(cc, false).has(c):
						g.append(c)
						ok = true
						break
			if !ok:
				var g : Array[Vector2i] = []
				g.append(c)
				gs.append(g)
		for g in gs:
			var pts = SMath.weld_lines(SUtils.get_cells_border(g), 8.0)
			var c = Vector2(0.0, 0.0)
			for pt in pts:
				c += pt
			c /= pts.size()
			for i in pts.size():
				pts[i] = pts[i] - c
			var l = line_pb.instantiate()
			l.default_color = Color(0.0, 0.0, 0.0, 1.0)
			l.width = 3
			l.points = pts
			l.modulate.a = 0.0
			l.scale = Vector2(2.0, 2.0)
			l.position = c
			var subtween = G.game_tweens.create_tween()
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
