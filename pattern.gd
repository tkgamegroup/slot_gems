extends Object

class_name Pattern

const UiPattern = preload("res://ui_pattern.gd")

var name : String
var coord_groups : Array[Array]
var recipes : Array
var price : int = 10
var mult : int = 1
var lv : int = 1
var exp : int = 0
var max_exp : int = get_max_exp(1)

var ui : UiPattern = null

static func get_max_exp(_lv : int):
	return int(pow(1.5, _lv - 1) * 50000)

func setup(n : String):
	name = n
	if name == "\\":
		coord_groups.append([Vector3i(0, 0, 0), Vector3i(1, 0, -1), Vector3i(2, 0, -2), Vector3i(3, 0, -3)])
		recipes.append([Gem.ColorAny])
	elif name == "|":
		coord_groups.append([Vector3i(0, 0, 0), Vector3i(0, 1, -1), Vector3i(0, 2, -2), Vector3i(0, 3, -3)])
		recipes.append([Gem.ColorAny])
	elif name == "/":
		coord_groups.append([Vector3i(0, 0, 0), Vector3i(1, -1, 0), Vector3i(2, -2, 0), Vector3i(3, -3, 0)])
		recipes.append([Gem.ColorAny])
	elif name == "Y":
		coord_groups.append([Vector3i(0, 0, 0), Vector3i(1, 0, -1), Vector3i(1, 1, -2), Vector3i(2, -1, -1)])
		recipes.append([Gem.ColorAny])
	elif name == "C":
		coord_groups.append([Vector3i(1, -1, 0), Vector3i(0, 0, 0), Vector3i(0, 1, -1), Vector3i(1, 1, -2)])
		recipes.append([Gem.ColorAny])
	elif name == "O":
		coord_groups.append([Vector3i(1, -1, 0), Vector3i(0, 0, 0), Vector3i(0, 1, -1), Vector3i(1, 1, -2), Vector3i(2, -1, -1), Vector3i(2, 0, -2)])
		recipes.append([Gem.ColorAny])
	elif name == "√":
		coord_groups.append([Vector3i(0, 0, 0), Vector3i(0, 1, -1), Vector3i(1, 0, -1), Vector3i(2, -1, -1), Vector3i(3, -2, -1)])
		recipes.append([Gem.ColorAny])
	elif name == "X":
		coord_groups.append([Vector3i(0, 0, 0), Vector3i(1, 0, -1), Vector3i(2, 0, -2), Vector3i(2, -1, -1), Vector3i(0, 1, -1)])
		recipes.append([Gem.ColorAny])
	elif name == "Island":
		coord_groups.append([Vector3i(1, -1, 0)])
		coord_groups.append([Vector3i(0, 0, 0), Vector3i(1, 0, -1), Vector3i(2, -1, -1)])
		recipes.append([Gem.RunePalm, Gem.RuneWaves])

func match_with(off : Vector2i, check_color : int = Gem.None, check_rune : int = Gem.None):
	var base_c = Board.offset_to_cube(off)
	var matcheds : Array[Vector2i] = []
	var mismatcheds : Array[Vector2i] = []
	var checkeds : Array[Vector2i] = []
	for r in recipes:
		for i in coord_groups.size():
			var group = coord_groups[i]
			var coords = []
			var colors = []
			var runes = []
			for c in group:
				var oc = Board.format_coord(Board.cube_to_offset(base_c + c))
				var cell = Board.get_cell(oc)
				if !cell || cell.frozen:
					return [] as Array[Vector2i]
				var g = Board.get_gem_at(oc)
				if !g:
					return [] as Array[Vector2i]
				coords.append(oc)
				colors.append(g.type)
				runes.append(g.rune)
			var val = r[i]
			if val >= Gem.ColorRed && val <= Gem.ColorAny:
				for j in coords.size():
					var v = colors[j]
					if val == Gem.ColorAny && v != Gem.ColorWild:
						val = v
					if v == val || v == Gem.ColorWild:
						matcheds.append(coords[j])
					else:
						mismatcheds.append(coords[j])
						if check_color == val || check_color == Gem.ColorWild:
							checkeds.append(coords[j])
			elif val >= Gem.RuneWaves && val <= Gem.RuneAny:
				for j in coords.size():
					var v = runes[j]
					if val == Gem.RuneAny && v != Gem.RuneOmni:
						val = v
					if v == val || v == Gem.RuneOmni:
						matcheds.append(coords[j])
					else:
						mismatcheds.append(coords[j])
						if check_rune == val || check_rune == Gem.RuneOmni:
							checkeds.append(coords[j])
	if check_color != Gem.None || check_rune != Gem.None:
		if mismatcheds.size() == 1 && !checkeds.is_empty():
			return checkeds
		return [] as Array[Vector2i]
	if mismatcheds.is_empty():
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
	var old_mult = mult
	exp += v
	while exp >= max_exp:
		lv += 1
		mult += 1
		exp -= max_exp
		max_exp = get_max_exp(lv)
	if ui:
		ui.exp_bar.max_value = max_exp
		ui.exp_bar.value = exp
		ui.tilemap.position = Vector2(0, -5)
		var tween = Game.get_tree().create_tween()
		tween.tween_property(ui.tilemap, "position", Vector2(0, 0), 0.2)
		if lv > old_lv:
			var ctrl = Control.new()
			var lb = Label.new()
			lb.text = "LV +1\nMult +%d" % (mult - old_mult)
			lb.modulate.a = 0.2
			ctrl.add_child(lb)
			ui.add_child(ctrl)
			ctrl.position = ui.get_rect().size * 0.5
			lb.set_anchors_and_offsets_preset(Control.PRESET_CENTER, Control.PRESET_MODE_KEEP_SIZE)
			var tween2 = Game.get_tree().create_tween()
			tween2.tween_property(lb, "modulate:a", 1.0, 0.3)
			tween2.tween_interval(1.0)
			tween2.tween_callback(lb.queue_free)

func get_tooltip():
	var ret : Array[Pair] = []
	var content = ""
	for i in recipes.size():
		var r = recipes[i]
		if recipes.size() > 1:
			content += "\nRecipe %d:\n" % i
		else:
			content += "\nRecipe:\n"
		for j in r.size():
			var v = r[j]
			content += "%s - " % char(ord('A') + j)
			if v >= Gem.ColorRed && v <= Gem.ColorAny:
				content += "%s\n" % Gem.type_display_name(v)
			elif v >= Gem.RuneWaves && v <= Gem.RuneAny:
				content += "%s\n" % Gem.rune_display_name(v)
			else:
				content += "%s\n" % tr("gem_unknow")
	ret.append(Pair.new(tr("pattern_name_" + name), content))
	return ret
