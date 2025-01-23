extends Object

class_name Board

enum Gem
{
	None,
	Red,
	Yellow,
	Green,
	Blue,
	Purple
}

enum ActiveReason
{
	Pattern,
	Item,
	RcAction
}

var cx : int
var cy : int
var cells : Array[Cell]
var central_coord = Vector2i(26, 10)

const cell_pb = preload("res://ui_cell.tscn")
const roll_speed : Curve = preload("res://roll_speed.tres")
const particles_pb = preload("res://particles.tscn")

var num_tasks : int
var show_coords : bool = false

var gem_scores = [1, 1, 1, 1, 1]
var active_items : Array[Item] = []
var touched_items : Dictionary[String, int] = {}

signal processed_finished

func gem_col(v : int) -> Color:
	match v:
		0: return Color(0, 0, 0, 0)
		Gem.Red: return Color(123.0 / 255.0, 0.0 / 255.0, 0.0 / 255.0)
		Gem.Yellow: return Color(211.0 / 255.0, 205.0 / 255.0, 70.0 / 255.0)
		Gem.Green: return Color(32.0 / 255.0, 163.0 / 255.0, 5.0 / 255.0)
		Gem.Blue: return Color(5.0 / 255.0, 87.0 / 255.0, 163.0 / 255.0)
		Gem.Purple: return Color(115.0 / 255.0, 5.0 / 255.0, 163.0 / 255.0)
	return Color.WHITE

func offset_to_cube(c : Vector2i):
	var x = c.x
	var y = c.y - (c.x - (c.x & 1)) / 2
	var z = -x - y
	return Vector3i(x, y, z)

func cube_to_offset(c : Vector3i):
	var x = c.x
	var y = c.y + (c.x - (c.x & 1)) / 2
	return Vector2i(x, y)
	
func cube_distance(a : Vector3i, b : Vector3i):
	return (abs(a.x - b.x) + abs(a.y - b.y) + abs(a.z - b.z)) / 2

func cube_lerp(a : Vector3i, b : Vector3i, v : float):
	return Vector3i(round(lerp(a.x, b.x, v)), round(lerp(a.y, b.y, v)), round(lerp(a.z, b.z, v)))

func draw_line(a : Vector3i, b : Vector3i):
	var n = cube_distance(a, b)
	var res = []
	for i in n:
		res.append(cube_lerp(a, b, float(i) / n))
	return res

static var cube_dirs = [Vector3i(1,0,-1),Vector3i(1,-1,0),Vector3i(0,-1,1),Vector3i(-1,0,1),Vector3i(-1,1,0),Vector3i(0,1,-1)]

func cube_dir(d : int):
	return cube_dirs[d]

func cube_neighbors(c : Vector3i) -> Array[Vector3i]:
	var ret : Array[Vector3i] = []
	for d in cube_dirs:
		ret.append(c + d)
	return ret

func offset_neighbors(c : Vector2i) -> Array[Vector2i]:
	var ret : Array[Vector2i] = []
	for cc in cube_neighbors(offset_to_cube(c)):
		ret.append(cube_to_offset(cc))
	return ret

func cube_ring(c : Vector3i, r : int) -> Array[Vector3i]:
	var ret : Array[Vector3i] = []
	var cc = c + cube_dir(4) * r
	for i in 6:
		for j in r:
			ret.append(cc)
			cc = cc + cube_dir(i)
	return ret

func offset_ring(c : Vector2i, r : int) -> Array[Vector2i]:
	var ret : Array[Vector2i] = []
	for cc in cube_ring(offset_to_cube(c), r):
		ret.append(cube_to_offset(cc))
	return ret

func get_pos(c : Vector2i):
	return Game.tilemap.map_to_local(Vector2i(c.x - cx / 2, c.y - cy / 2) + central_coord)

func cell_at(c : Vector2i):
	if c.x < 0 || c.x >= cx || c.y < 0 || c.y >= cy:
		return null
	return cells[c.y * cx + c.x]

func get_gem_at(c : Vector2i):
	if c.x < 0 || c.x >= cx || c.y < 0 || c.y >= cy:
		return 0
	return cells[c.y * cx + c.x].gem

func set_gem_at(c : Vector2i, v : int):
	if c.x < 0 || c.x >= cx || c.y < 0 || c.y >= cy:
		return
	cells[c.y * cx + c.x].gem = v
	var ui = Game.get_cell_ui(c)
	ui.frame = v

func gem_score_at(c : Vector2i):
	var g = get_gem_at(c)
	if g == 0:
		return 0
	return gem_scores[g - 1]

func get_gem_state_at(c : Vector2i):
	if c.x < 0 || c.x >= cx || c.y < 0 || c.y >= cy:
		return 0
	return cells[c.y * cx + c.x].gem_state

func set_gem_state_at(c : Vector2i, s : int):
	if c.x < 0 || c.x >= cx || c.y < 0 || c.y >= cy:
		return
	cells[c.y * cx + c.x].gem_state = s
	var ui = Game.get_cell_ui(c)
	if s == Cell.GemState.Normal:
		ui.modulate = Color(1.0, 1.0, 1.0, 1.0)
		ui.burn.hide()
	elif s == Cell.GemState.Consumed:
		ui.modulate = Color(0.7, 0.7, 0.7, 1.0)
	elif s == Cell.GemState.Burning:
		Game.sound.sfx_start_buring.play()
		ui.burn.show()

func get_state_at(c : Vector2i):
	if c.x < 0 || c.x >= cx || c.y < 0 || c.y >= cy:
		return 0
	var idx = c.y * cx + c.x
	return cells[idx].state

func set_state_at(c : Vector2i, s : int):
	if c.x < 0 || c.x >= cx || c.y < 0 || c.y >= cy:
		return
	var idx = c.y * cx + c.x
	if cells[idx].state == s:
		return false
	if s == Cell.State.Pined:
		if get_gem_at(c) == 0:
			return false
	cells[idx].state = s
	var ui = Game.get_cell_ui(c)
	if s == Cell.State.Pined:
		ui.pin.show()
	else:
		ui.pin.hide()
	return true

func get_item_at(c : Vector2i) -> Item:
	if c.x < 0 || c.x >= cx || c.y < 0 || c.y >= cy:
		return null
	return cells[c.y * cx + c.x].item

func set_item_at(c : Vector2i, item : Item):
	if c.x < 0 || c.x >= cx || c.y < 0 || c.y >= cy:
		return 0
	cells[c.y * cx + c.x].item = item
	var ui = Game.get_cell_ui(c)
	if item:
		item.coord = c
		ui.item.texture = load(item.image_path)
		ui.item.show()
	else:
		ui.item.texture = null
		ui.item.hide()

func eliminate(c : Vector2i, reason : ActiveReason, source = null):
	if c.x < 0 || c.x >= cx || c.y < 0 || c.y >= cy:
		return null
	var ptc = particles_pb.instantiate()
	ptc.position = get_pos(c)
	ptc.emitting = true
	ptc.color = gem_col(get_gem_at(c))
	Game.overlay.add_child(ptc)
	var ui = Game.get_cell_ui(c)
	ui.scale = Vector2(1.5, 1.5)
	ui.z_index = 1
	var item = get_item_at(c)
	if item:
		activate_item(item, reason, source)
	var tween = Game.get_tree().create_tween()
	tween.tween_property(ui, "scale", Vector2(1, 1), 0.5 * Game.animation_speed)
	tween.tween_callback(func():
		ptc.queue_free()
		ui.z_index = 0
		if get_state_at(c) != Cell.State.Pined:
			set_gem_state_at(c, Cell.GemState.Consumed)
	)
	return tween

func activate_item(item : Item, reason : ActiveReason, source = null):
	if !item.active:
		Game.sound.sfx_brush.play()
		item.active = true
		if item.on_active.is_valid():
			item.on_active.call(self, reason, source)
		if !item.on_process.is_valid():
			set_item_at(item.coord, null)
		else:
			active_items.append(item)
			var ui = Game.get_cell_ui(item.coord)
			ui.active.show()
		if touched_items.has(item.name):
			touched_items[item.name] += 1
		else:
			touched_items[item.name] = 1

func process_item(item : Item):
	var ui = Game.get_cell_ui(item.coord)
	ui.active.hide()
	Game.sound.sfx_vibra.play()
	var tween = Game.get_tree().create_tween()
	tween.tween_property(ui.item, "scale", Vector2(2.0, 2.0), 0.5).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	tween.parallel().tween_property(ui.item, "self_modulate:a", 0.0, 0.5).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	ui.item.z_index = 2
	if item.on_process.is_valid():
		item.on_process.call(self, tween)
	tween.tween_callback(func():
		item.active = false
		active_items.remove_at(0)
		set_item_at(item.coord, null)
		clear_consumed()
		fill_blanks()
	)

func cleanup():
	cells.clear()
	for n in Game.outlines_root.get_children():
		n.queue_free()
		Game.outlines_root.remove_child(n)
	for n in Game.cells_root.get_children():
		n.queue_free()
		Game.cells_root.remove_child(n)

func setup(_hf_cy : int, _cx_multipler : int):
	cleanup()
	
	cy = _hf_cy * 2
	cx = cy * _cx_multipler
	for y in cy:
		for x in cx:
			var idx = y * cx + x
			var c = Cell.new()
			c.index = idx
			cells.append(c)
	
	for y in cy:
		for x in cx:
			var gem_sp = cell_pb.instantiate()
			gem_sp.position = get_pos(Vector2i(x, y))
			Game.cells_root.add_child(gem_sp)
			if show_coords:
				var cube_c = offset_to_cube(Vector2i(x, y))
				var lb0 = Label.new()
				lb0.text = "%d" % cube_c.x
				lb0.add_theme_color_override("font_color", Color.RED)
				lb0.add_theme_font_size_override("font_size", 9)
				lb0.position = gem_sp.position + Vector2(-5, -15)
				Game.scene.add_child(lb0)
				var lb1 = Label.new()
				lb1.text = "%d" % cube_c.y
				lb1.add_theme_color_override("font_color", Color.GREEN)
				lb1.add_theme_font_size_override("font_size", 9)
				lb1.position = gem_sp.position + Vector2(3, 2)
				Game.scene.add_child(lb1)
				var lb2 = Label.new()
				lb2.text = "%d" % cube_c.z
				lb2.add_theme_color_override("font_color", Color.BLUE)
				lb2.add_theme_font_size_override("font_size", 9)
				lb2.position = gem_sp.position + Vector2(-10, 2)
				Game.scene.add_child(lb2)
	
	var updated = {}
	var pc = Game.tilemap.map_to_local(central_coord)
	var tween = Game.get_tree().create_tween()
	for i in _hf_cy + 1:
		for x in range(-i * _cx_multipler, i * _cx_multipler):
			for y in range(-i, i):
				var cc = Vector2i(x, y) + central_coord
				if updated.has(cc):
					continue
				updated[cc] = 1
				tween.tween_callback(func():
					var tween2 = Game.get_tree().create_tween()
					var p1 = Game.tilemap.map_to_local(cc)
					var p0 = p1 + (p1 - pc).normalized() * 500.0
					var outline_sp = Sprite2D.new()
					tween2.tween_callback(func():
						outline_sp.texture = load("res://images/outline.png")
						outline_sp.position = p0
						outline_sp.scale = Vector2(1.2, 1.2)
						outline_sp.modulate.a = 0
						Game.outlines_root.add_child(outline_sp)
						num_tasks += 1
					)
					tween2.tween_property(outline_sp, "position", p1, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
					tween2.parallel().tween_property(outline_sp, "scale", Vector2(1.0, 1.0), 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
					tween2.parallel().tween_property(outline_sp, "modulate:a", 1.0, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
					tween2.tween_callback(func():
						num_tasks -= 1
						if num_tasks == 0:
							Game.end_protect_controls()
					)
				)
		tween.tween_interval(0.1)

func skip_above_pineds(c : Vector2i) -> Vector2i:
	var cc = c - Vector2i(0, 1)
	while true:
		if cc.y < 0:
			return cc
		if get_state_at(cc) != Cell.State.Pined:
			return cc
		cc.y -= 1
	return Vector2i(-1, -1)

func roll():
	touched_items.clear()
	
	var list : Array[Pair] = []
	for y in cy:
		for x in cx:
			list.append(Pair.new(randi_range(1, 5), null))
			var cell = cell_at(Vector2i(x, y))
			cell.user_data = null
			if cell.state != Cell.State.Pined:
				cell.item = null
	var item_places = Math.get_shuffled_indices(list.size())
	var num_places = min(Game.items.size(), list.size())
	for i in num_places:
		var item = Item.new()
		item.setup(Game.items[i])
		list[item_places[i]].second = item
	
	var tween = Game.get_tree().create_tween()
	Game.combos = 0
	for x in cx:
		tween.tween_callback(func():
			var tween2 = Game.get_tree().create_tween()
			tween2.tween_callback(func():
				num_tasks += 1
			)
			for i in cy * 12:
				tween2.tween_callback(func():
					for y in cy:
						var c = Vector2i(x, cy - y - 1)
						if get_state_at(c) != Cell.State.Pined:
							var cc = skip_above_pineds(c)
							var cell1 = cell_at(c)
							if cell1.user_data:
								list.append(cell1.user_data)
							if cc.y < 0:
								var idx = randi_range(0, list.size() - 1)
								cell1.user_data = list[idx]
								list.remove_at(idx)
							else:
								var cell2 = cell_at(cc)
								cell1.user_data = cell2.user_data
								cell2.user_data = null
							var d = cell1.user_data
							if d:
								set_gem_at(c, d.first)
								set_item_at(c, d.second)
				)
				tween2.tween_interval(roll_speed.sample(float(i) / 100.0))
			tween2.tween_interval(0.01)
			tween2.tween_callback(func():
				num_tasks -= 1
				if num_tasks == 0:
					for yy in cy:
						for xx in cx:
							var item = get_item_at(Vector2i(xx, yy))
							if item && item.on_place.is_valid():
								item.on_place.call(self)
					search_patterns()
			)
		)
		tween.tween_interval(0.015)

func clear_consumed():
	var burned_cells = 0
	for y in cy:
		for x in cx:
			var c = Vector2i(x, y)
			var s = get_gem_state_at(c)
			if s == Cell.GemState.Consumed:
				set_gem_at(c, 0)
				set_gem_state_at(c, Cell.GemState.Normal)
			elif s == Cell.GemState.Burning:
				burned_cells += 1
				set_gem_at(c, 0)
				set_gem_state_at(c, Cell.GemState.Normal)
	if burned_cells > 0:
		Game.sound.sfx_end_buring.play()

func fill_blanks():
	var tween = Game.get_tree().create_tween()
	tween.tween_interval(0.1 * Game.animation_speed)
	tween.tween_callback(func():
		var filled = false
		for x in cx:
			for y in cy:
				var c = Vector2i(x, cy - y - 1)
				if get_state_at(c) != Cell.State.Pined && get_gem_at(c) == 0:
					var cc = skip_above_pineds(c)
					if cc.y < 0:
						set_gem_at(c, randi_range(1, 5))
					else:
						set_gem_at(c, get_gem_at(cc))
						set_gem_at(cc, 0)
					filled = true
		if filled:
			Game.sound.sfx_zap.play()
			fill_blanks()
		else:
			search_patterns()
	)

func search_patterns():
	var no_patterns = true
	var tween = Game.get_tree().create_tween()
	for y in cy:
		for x in cx:
			for p in Game.patterns:
				var res : Array = p.search(self, Vector2i(x, y))
				if !res.is_empty():
					no_patterns = false
					tween.tween_callback(func():
						var txt_pos = Vector2(0, 0)
						var score = 0
						for c in res:
							score += gem_score_at(c)
							txt_pos += get_pos(c)
							eliminate(c, ActiveReason.Pattern, p)
						Game.sound.sfx_tom.play()
						score *= p.mult
						
						Game.add_combo()
						Game.add_score(score, txt_pos / res.size())
					)
					tween.tween_interval(0.3 * Game.animation_speed)
	if no_patterns:
		tween.tween_interval(0.6 * Game.animation_speed)
		tween.tween_callback(func():
			if active_items.is_empty():
				processed_finished.emit()
				touched_items.clear()
			else:
				process_item(active_items[0])
		)
	else:
		tween.tween_interval(0.6 * Game.animation_speed)
		tween.tween_callback(func():
			clear_consumed()
			fill_blanks()
		)
	Game.animation_speed *= 0.9
	Game.animation_speed = max(0.05, Game.animation_speed)
