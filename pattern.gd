extends RefCounted

class_name Pattern

const object_type : int = C.ObjectType.Pattern

var name : String
var coord_groups : Array[Array]
var recipes : Array
var price : int = 10
var mult : float = 1.0
var lv : int = 1
var exp : int = 0
var max_exp : int = get_max_exp(1)

var ui : G.UiPattern = null

static func get_max_exp(_lv : int):
	return int(pow(1.5, _lv - 1) * 50000)

func setup(n : String):
	name = n
	if name == "\\":
		coord_groups.append([Vector3i(0, 0, 0), Vector3i(1, 0, -1), Vector3i(2, 0, -2), Vector3i(3, 0, -3)])
		recipes.append([Gem.ColorAny])
	elif name == "|":
		mult = 1.5
		coord_groups.append([Vector3i(0, 0, 0), Vector3i(0, 1, -1), Vector3i(0, 2, -2), Vector3i(0, 3, -3)])
		recipes.append([Gem.ColorAny])
	elif name == "/":
		coord_groups.append([Vector3i(0, 0, 0), Vector3i(1, -1, 0), Vector3i(2, -2, 0), Vector3i(3, -3, 0)])
		recipes.append([Gem.ColorAny])
	elif name == "O":
		mult = 2.0
		coord_groups.append([Vector3i(1, -1, 0), Vector3i(0, 0, 0), Vector3i(0, 1, -1), Vector3i(1, 1, -2), Vector3i(2, -1, -1), Vector3i(2, 0, -2)])
		recipes.append([Gem.RuneAny])
	elif name == "√":
		coord_groups.append([Vector3i(0, 0, 0), Vector3i(0, 1, -1), Vector3i(1, 0, -1), Vector3i(2, -1, -1), Vector3i(3, -2, -1)])
		recipes.append([Gem.RuneAny])
	elif name == "X":
		coord_groups.append([Vector3i(0, 0, 0), Vector3i(1, 0, -1), Vector3i(2, 0, -2), Vector3i(2, -1, -1), Vector3i(0, 1, -1)])
		recipes.append([Gem.RuneAny])
	elif name == "Y":
		coord_groups.append([Vector3i(0, 0, 0), Vector3i(1, 0, -1), Vector3i(1, 1, -2), Vector3i(2, -1, -1)])
		recipes.append([Gem.RuneAny])
	elif name == "C":
		coord_groups.append([Vector3i(1, -1, 0), Vector3i(0, 0, 0), Vector3i(0, 1, -1), Vector3i(1, 1, -2)])
		recipes.append([Gem.RuneAny])
	elif name == "Island":
		coord_groups.append([Vector3i(1, -1, 0)])
		coord_groups.append([Vector3i(0, 0, 0), Vector3i(1, 0, -1), Vector3i(2, -1, -1)])
		recipes.append([Gem.RuneCircle, Gem.RuneWave])

func all_coords() -> Array[Vector3i]:
	var ret : Array[Vector3i] = []
	for g in coord_groups:
		for c in g:
			ret.append(c)
	return ret

func contains_coord(off : Vector2i, coord : Vector2i) -> bool:
	var c_off = Board.offset_to_cube(off)
	var cc = Board.offset_to_cube(coord)
	for c in all_coords():
		if cc == c_off + c:
			return true
	return false

func match_with(off : Vector2i, check_color : int = Gem.None, check_rune : int = Gem.None, external_board : Dictionary = {}):
	var c_off = Board.offset_to_cube(off)
	for recipe in recipes:
		var matcheds : Array[Vector2i] = []
		var mismatcheds : Array[Vector2i] = []
		var checkeds : Array[Vector2i] = []
		for i in coord_groups.size():
			var group = coord_groups[i]
			var coords = []
			var colors = []
			var runes = []
			for c in group:
				var oc = Board.format_coord(Board.cube_to_offset(c_off + c))
				var cell = Board.get_cell(oc)
				if !cell || cell.frozen > 0:
					return [] as Array[Vector2i]
				coords.append(oc)
				if external_board.is_empty():
					var g = Board.get_gem_at(oc)
					if !g || g.active:
						return [] as Array[Vector2i]
					colors.append(g.type)
					runes.append(g.rune)
				else:
					var item = external_board[oc]
					if !item:
						return [] as Array[Vector2i]
					colors.append(item.type)
					runes.append(item.rune)
			var val = recipe[i]
			if val >= Gem.ColorFirst && val <= Gem.ColorAny:
				if val >= Gem.ColorComboFirst && val <= Gem.ColorComboLast:
					var color_count : Array[int]
					color_count.resize(Gem.ColorCount)
					for c in colors:
						if (c >= Gem.ColorComboFirst && c <= Gem.ColorComboLast):
							for j in color_count.size():
								if Gem.color_combo_contains(c, Gem.ColorFirst + j):
									color_count[j] += 1
						elif c == Gem.ColorWild:
							for j in color_count.size():
								color_count[j] += 1
						elif c != Gem.None:
							color_count[c - Gem.ColorFirst] += 1
					var sorted_indices = SMath.index_sort_reverse(color_count)
					if val == Gem.ColorAny:
						val = Gem.ColorFirst + sorted_indices[0]
					else:
						for j in sorted_indices:
							if Gem.color_combo_contains(val, Gem.ColorFirst + j):
								val = Gem.ColorFirst + j
								break
				for j in coords.size():
					var v = colors[j]
					if v == val || v == Gem.ColorWild || Gem.color_combo_contains(v, val):
						matcheds.append(coords[j])
					else:
						mismatcheds.append(coords[j])
						if check_color == val || check_color == Gem.ColorWild || Gem.color_combo_contains(check_color, val):
							checkeds.append(coords[j])
			elif val >= Gem.RuneFirst && val <= Gem.RuneAny:
				if val >= Gem.RuneComboFirst && val <= Gem.RuneComboLast:
					var rune_count : Array[int]
					rune_count.resize(Gem.RuneCount)
					for r in runes:
						if (r >= Gem.RuneComboFirst && r <= Gem.RuneComboLast):
							for j in rune_count.size():
								if Gem.rune_combo_contains(r, Gem.RuneFirst + j):
									rune_count[j] += 1
						elif r == Gem.RuneOmni:
							for j in rune_count.size():
								rune_count[j] += 1
						elif r != Gem.None:
							rune_count[r - Gem.RuneFirst] += 1
					var sorted_indices = SMath.index_sort_reverse(rune_count)
					if val == Gem.RuneAny:
						val = Gem.RuneFirst + sorted_indices[0]
					else:
						for j in sorted_indices:
							if Gem.rune_combo_contains(val, Gem.RuneFirst + j):
								val = Gem.RuneFirst + j
								break
				for j in coords.size():
					var v = runes[j]
					if v == val || v == Gem.RuneOmni || Gem.rune_combo_contains(v, val):
						matcheds.append(coords[j])
					else:
						mismatcheds.append(coords[j])
						if check_rune == val || check_rune == Gem.RuneOmni || Gem.rune_combo_contains(check_rune, val):
							checkeds.append(coords[j])
		if check_color != Gem.None || check_rune != Gem.None:
			if mismatcheds.size() == 1 && !checkeds.is_empty():
				return checkeds
		elif mismatcheds.is_empty():
			return matcheds
	return [] as Array[Vector2i]

func get_ui_coords():
	var ret = coord_groups.duplicate(true)
	var y_min = 4
	var y_max = 0
	for g in coord_groups:
		for c in g:
			y_min = min(y_min, c.y)
			y_max = min(y_max, c.y)
	if y_min < 0:
		for g in ret:
			for i in g.size():
				g[i].y += -y_min
				g[i].z += y_min
	return ret

func add_exp(v : int):
	var old_lv = lv
	exp += v
	while exp >= max_exp:
		lv += 1
		exp -= max_exp
		max_exp = get_max_exp(lv)
	if ui:
		ui.exp_bar.max_value = max_exp
		ui.exp_bar.value = exp
		ui.tilemap.position = Vector2(0, -5)
		var tween = G.create_game_tween()
		tween.tween_property(ui.tilemap, "position", Vector2(0, 0), 0.2)
		if lv > old_lv:
			var ctrl = Control.new()
			var lb = Label.new()
			lb.text = "LV +1"
			lb.modulate.a = 0.2
			ctrl.add_child(lb)
			ui.add_child(ctrl)
			ctrl.position = ui.get_rect().size * 0.5
			lb.set_anchors_and_offsets_preset(Control.PRESET_CENTER, Control.PRESET_MODE_KEEP_SIZE)
			var tween2 = G.create_game_tween()
			tween2.tween_property(lb, "modulate:a", 1.0, 0.3)
			tween2.tween_interval(1.0)
			tween2.tween_callback(lb.queue_free)

func get_tooltip():
	var ret : Array[Pair] = []
	var content = ""
	for i in recipes.size():
		var r = recipes[i]
		if recipes.size() > 1:
			if !content.is_empty():
				content += "\n"
			content += "Recipe %d:\n" % i
		for j in r.size():
			var v = r[j]
			content += "%s - " % char(65 + j)
			if v >= Gem.ColorFirst && v <= Gem.ColorAny:
				content += "%s\n" % Gem.type_display_name(v)
			elif v >= Gem.RuneFirst && v <= Gem.RuneAny:
				content += "%s\n" % Gem.rune_display_name(v)
			else:
				content += "%s\n" % tr("gem_unknow")
	if mult != 1.0:
		content += "Mult: %.1f" % mult
	ret.append(Pair.new(tr("pattern_name_" + name), content))
	return ret
