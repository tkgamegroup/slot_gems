extends Object

class_name Pattern

const UiPattern = preload("res://ui_pattern.gd")

var name : String
var coords : Array[Vector3i]
var price : int
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
		coords.append(Vector3i(0, 0, 0))
		coords.append(Vector3i(1, 0, -1))
		coords.append(Vector3i(2, 0, -2))
		coords.append(Vector3i(3, 0, -3))
	elif name == "I":
		coords.append(Vector3i(0, 0, 0))
		coords.append(Vector3i(0, 1, -1))
		coords.append(Vector3i(0, 2, -2))
		coords.append(Vector3i(0, 3, -3))
	elif name == "/":
		coords.append(Vector3i(0, 0, 0))
		coords.append(Vector3i(1, -1, 0))
		coords.append(Vector3i(2, -2, 0))
		coords.append(Vector3i(3, -3, 0))
	elif name == "Y":
		coords.append(Vector3i(0, 0, 0))
		coords.append(Vector3i(1, 0, -1))
		coords.append(Vector3i(1, 1, -2))
		coords.append(Vector3i(2, -1, -1))
	elif name == "C":
		coords.append(Vector3i(1, -1, 0))
		coords.append(Vector3i(0, 0, 0))
		coords.append(Vector3i(0, 1, -1))
		coords.append(Vector3i(1, 1, -2))
	elif name == "O":
		coords.append(Vector3i(1, -1, 0))
		coords.append(Vector3i(0, 0, 0))
		coords.append(Vector3i(0, 1, -1))
		coords.append(Vector3i(1, 1, -2))
		coords.append(Vector3i(2, -1, -1))
		coords.append(Vector3i(2, 0, -2))
	elif name == "√":
		coords.append(Vector3i(0, 0, 0))
		coords.append(Vector3i(0, 1, -1))
		coords.append(Vector3i(1, 0, -1))
		coords.append(Vector3i(2, -1, -1))
		coords.append(Vector3i(3, -2, -1))
	elif name == "X":
		coords.append(Vector3i(0, 0, 0))
		coords.append(Vector3i(1, 0, -1))
		coords.append(Vector3i(2, 0, -2))
		coords.append(Vector3i(2, -1, -1))
		coords.append(Vector3i(0, 1, -1))

func match_with(off : Vector2i) -> Array[Vector2i]:
	var ocoords : Array[Vector2i] = []
	if coords.size() < 2:
		return [] as Array[Vector2i]
	var base_c = Board.offset_to_cube(off)
	for c in coords:
		ocoords.append(Board.format_coord(Board.cube_to_offset(base_c + c)))
	var colors = []
	for c in ocoords:
		var g = Board.get_gem_at(c)
		if g && !Board.cell_at(c).frozen:
			colors.append(g.type)
	if colors.size() < coords.size():
		return [] as Array[Vector2i]
	var first_v = Gem.Type.None
	for c in colors:
		if c != Gem.Type.Wild:
			first_v = c
			break
	if first_v == Gem.Type.None:
		return ocoords
	var all_same = true
	for c in colors:
		if !(c == Gem.Type.Wild || c == first_v):
			all_same = false
			break
	if all_same:
		return ocoords
	return [] as Array[Vector2i]

func get_ui_coords():
	var ret = []
	var y_min = 4
	var y_max = 0
	for c in coords:
		y_min = min(y_min, c.y)
		y_max = min(y_max, c.y)
	ret = coords.duplicate()
	if y_min < 0:
		for i in coords.size():
			ret[i].y += -y_min
			ret[i].z += y_min
	return ret

func differ(off : Vector2i, type : int, differences : int = 1) -> Array[Vector2i]:
	var ocoords : Array[Vector2i] = []
	if coords.size() < 2:
		return [] as Array[Vector2i]
	var base_c = Board.offset_to_cube(off)
	for c in coords:
		ocoords.append(Board.format_coord(Board.cube_to_offset(base_c + c)))
	var colors = []
	for c in ocoords:
		var g = Board.get_gem_at(c)
		if g && !Board.cell_at(c).frozen:
			colors.append(g.type)
	if colors.size() < coords.size():
		return [] as Array[Vector2i]
	var diff = 0
	var res : Array[Vector2i] = []
	for j in ocoords.size():
		var c = colors[j]
		if !(c == Gem.Type.Wild || c == type):
			res.append(ocoords[j])
			diff += 1
	if diff == differences:
		return res
	return [] as Array[Vector2i]

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
	ret.append(Pair.new(name, "LV: %d\nExp: %d/%d\nMult: %d" % [lv, exp, max_exp, mult]))
	return ret
