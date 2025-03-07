extends Object

class_name Pattern

const UiPattern = preload("res://ui_pattern.gd")

var coords : Array[Vector3i]
var mult : int
var lv : int
var exp : int
var max_exp : int
var ui : UiPattern = null

static func get_max_exp(_lv : int):
	return int(pow(1.5, _lv - 1) * 1000)

func reset():
	lv = 1
	exp = 0
	max_exp = get_max_exp(1)
	mult = 1

func match_with(board : Board, off : Vector2i) -> Array[Vector2i]:
	var ocoords : Array[Vector2i] = []
	if coords.size() < 2:
		return [] as Array[Vector2i]
	var base_c = board.offset_to_cube(off)
	for c in coords:
		ocoords.append(board.cube_to_offset(base_c + c))
	var colors = []
	for c in ocoords:
		var g = board.get_gem_at(c)
		if g:
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

func differ(board : Board, off : Vector2i, type : int, differences : int = 1) -> Array[Vector2i]:
	var ocoords : Array[Vector2i] = []
	if coords.size() < 2:
		return [] as Array[Vector2i]
	var base_c = board.offset_to_cube(off)
	for c in coords:
		ocoords.append(board.cube_to_offset(base_c + c))
	var colors = []
	for c in ocoords:
		var g = board.get_gem_at(c)
		if g:
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
		if lv > old_lv:
			var ctrl = Control.new()
			var lb = Label.new()
			lb.text = "LV +1\nMult +%d" % (mult - old_mult)
			lb.modulate.a = 0.2
			ctrl.add_child(lb)
			ui.add_child(ctrl)
			ctrl.position = ui.get_rect().size * 0.5
			lb.set_anchors_and_offsets_preset(Control.PRESET_CENTER, Control.PRESET_MODE_KEEP_SIZE)
			var tween = Game.get_tree().create_tween()
			tween.tween_property(lb, "modulate:a", 1.0, 0.3)
			tween.tween_interval(1.0)
			tween.tween_callback(lb.queue_free)

func _init() -> void:
	reset()
