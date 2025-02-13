extends Object

class_name Board

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

var task_name : String
var num_tasks : int
var show_coords : bool = false

var unused_gems : Array[Gem] = []
var active_gems : Array[Gem] = []
var active_serial : int = 0
var eliminated_gems : Dictionary[String, int] = {}
var skill_effects : Array[Pair]

signal processed_finished

static func offset_to_cube(c : Vector2i):
	var x = c.x
	var y = c.y - (c.x - (c.x & 1)) / 2
	var z = -x - y
	return Vector3i(x, y, z)

static func cube_to_offset(c : Vector3i):
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
		return null
	return cells[c.y * cx + c.x].gem

func set_gem_at(c : Vector2i, g : Gem):
	if c.x < 0 || c.x >= cx || c.y < 0 || c.y >= cy:
		return
	var cell = cells[c.y * cx + c.x]
	var og = cell.gem
	if og:
		og.coord = Vector2i(-1, -1)
		unused_gems.append(og)
	cell.gem = g
	if g:
		g.coord = c
	set_state_at(c, Cell.State.Normal)
	var ui = Game.get_cell_ui(c)
	if g:
		ui.gem.set_image(g.type, g.rune, g.image_id)
	else:
		ui.gem.set_image(0, 0, 0)
	return og

func gem_score_at(c : Vector2i):
	var g = get_gem_at(c)
	if !g:
		return 0
	return g.get_base_score()

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
	cells[idx].state = s
	var ui = Game.get_cell_ui(c)
	if s == Cell.State.Consumed:
		ui.modulate = Color(1.3, 1.3, 1.3, 1.0)
	elif s == Cell.State.Burning:
		Sounds.sfx_start_buring.play()
		ui.burn.show()
	else:
		ui.modulate = Color(1.0, 1.0, 1.0, 1.0)
		ui.pin.hide()
		ui.burn.hide()
	return true

func pin(c : Vector2i):
	if c.x < 0 || c.x >= cx || c.y < 0 || c.y >= cy:
		return false
	var idx = c.y * cx + c.x
	var cell = cells[idx]
	if cell.pined:
		return false
	var ui = Game.get_cell_ui(c)
	if get_gem_at(c):
		ui.pin.show()
		cell.pined = true
		return true

func unpin(c : Vector2i):
	if c.x < 0 || c.x >= cx || c.y < 0 || c.y >= cy:
		return
	var idx = c.y * cx + c.x
	var ui = Game.get_cell_ui(c)
	ui.pin.hide()
	cells[idx].pined = false

func pick_gem():
	var idx = randi_range(0, unused_gems.size() - 1)
	var g = unused_gems[idx]
	unused_gems.remove_at(idx)
	return g

func eliminate(_coords : Array[Vector2i], tween : Tween, reason : ActiveReason, source = null):
	var coords = []
	var uis = []
	var ptcs = []
	for c in _coords:
		if c.x >= 0 && c.x < cx && c.y >= 0 && c.y < cy:
			coords.append(c)
			uis.append(Game.get_cell_ui(c))
			ptcs.append(particles_pb.instantiate())
			var g = get_gem_at(c)
			if g:
				if eliminated_gems.has(g.name):
					eliminated_gems[g.name] += 1
				else:
					eliminated_gems[g.name] = 1
	tween.tween_callback(func():
		for i in coords.size():
			var c = coords[i]
			var g = get_gem_at(c)
			var ui = uis[i]
			var ptc = ptcs[i]
			ui.gem.bg_sp.scale = Vector2(1.5, 1.5)
			ui.gem.z_index = 1
			ptc.position = get_pos(c)
			ptc.emitting = true
			ptc.color = Gem.color(g.type)
			Game.overlay.add_child(ptc)
			activate(g, reason, source)
	)
	tween.tween_method(func(t):
		for ui in uis:
			ui.gem.bg_sp.scale = Vector2(t, t)
	, 1.5, 1.0, 0.3 * Game.animation_speed)
	tween.tween_callback(func():
		for i in coords.size():
			var c = coords[i]
			uis[i].gem.z_index = 0
			ptcs[i].queue_free()
			if !cell_at(c).pined:
				set_state_at(c, Cell.State.Consumed)
	)

func activate(gem : Gem, reason : ActiveReason, source = null):
	if !gem.active:
		if gem.on_active.is_valid():
			gem.active = true
			Sounds.sfx_brush.play()
			gem.on_active.call(self, reason, source)
		elif gem.on_process.is_valid():
			Sounds.sfx_brush.play()
			gem.active = true
			active_gems.append(gem)
			active_serial += 1
			var ui = Game.get_cell_ui(gem.coord)
			ui.set_active(true)

func process_active_gem(g : Gem):
	var ui = Game.get_cell_ui(g.coord)
	Sounds.sfx_vibra.play()
	var tween = Game.get_tree().create_tween()
	Animations.fade_out(ui.gem.image, tween, ui.gem.image.scale.x, 1.5)
	if g.on_process.is_valid():
		g.on_process.call(self, tween)
	tween.tween_callback(func():
		g.active = false
		ui.set_active(false)
		active_gems.remove_at(0)
		set_gem_at(g.coord, null)
		ui.gem.image.scale = Vector2(1.0, 1.0)
		ui.gem.image.self_modulate.a = 1.0
		clear_consumed()
		fill_blanks()
	)

func process_skill_effect(s : Skill, rune_coords : Dictionary[int, Array]):
	var tween = Game.get_tree().create_tween()
	tween.tween_callback(func():
		skill_effects.remove_at(0)
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
		if !cell_at(cc).pined:
			var g = get_gem_at(cc)
			if !g || !g.active:
				return cc
		cc.y -= 1
	return Vector2i(-1, -1)

func roll():
	task_name = "roll"
	
	unused_gems.clear()
	for g in Game.gems:
		g.coord = Vector2i(-1, -1)
		unused_gems.append(g)
	for yy in cy:
		for xx in cx:
			var c = Vector2i(xx, yy)
			cell_at(c).gem = null
	
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
						if !cell_at(c).pined:
							var cc = skip_above_pineds(c)
							if cc.y < 0:
								set_gem_at(c, pick_gem())
							else:
								var og = set_gem_at(cc, null)
								if og:
									unused_gems.remove_at(unused_gems.size() - 1)
								set_gem_at(c, og)
				)
				tween2.tween_interval(roll_speed.sample(float(i) / 100.0))
			tween2.tween_interval(0.01)
			tween2.tween_callback(func():
				num_tasks -= 1
				if num_tasks == 0:
					for yy in cy:
						for xx in cx:
							var g = get_gem_at(Vector2i(xx, yy))
							if g && g.on_place.is_valid():
								g.on_place.call(self)
					search_patterns()
			)
		)
		tween.tween_interval(0.015)

func clear_consumed():
	var burned_cells = 0
	for y in cy:
		for x in cx:
			var c = Vector2i(x, y)
			var s = get_state_at(c)
			if s == Cell.State.Consumed || s == Cell.State.Burning:
				if s == Cell.State.Burning:
					burned_cells += 1
				var g = get_gem_at(c)
				if !(g.active && g.on_process.is_valid()):
					set_gem_at(c, null)
	if burned_cells > 0:
		Sounds.sfx_end_buring.play()

func fill_blanks():
	var tween = Game.get_tree().create_tween()
	tween.tween_interval(0.1 * Game.animation_speed)
	tween.tween_callback(func():
		var filled = false
		for x in cx:
			for y in cy:
				var c = Vector2i(x, cy - y - 1)
				if !cell_at(c).pined && !get_gem_at(c):
					var cc = skip_above_pineds(c)
					if cc.y < 0:
						set_gem_at(c, pick_gem())
					else:
						var og = set_gem_at(cc, null)
						if og:
							unused_gems.remove_at(unused_gems.size() - 1)
						set_gem_at(c, og)
					filled = true
		if filled:
			Sounds.sfx_zap.play()
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
				var res : Array[Vector2i] = p.search(self, Vector2i(x, y))
				if !res.is_empty():
					no_patterns = false
					tween.tween_callback(func():
						var txt_pos = Vector2(0, 0)
						var score = 0
						for c in res:
							score += gem_score_at(c)
							txt_pos += get_pos(c)
						Sounds.sfx_tom.play()
						score *= p.mult
						
						p.add_exp(1)
						Game.add_combo()
						Game.add_score(score, txt_pos / res.size())
					)
					for s in Game.skills:
						var rune_coords = s.check(res)
						if !rune_coords.is_empty():
							skill_effects.append(Pair.new(s, rune_coords))
					eliminate(res, tween, ActiveReason.Pattern, p)
					Game.animation_speed *= 0.98
					Game.animation_speed = max(0.05, Game.animation_speed)
	if no_patterns:
		tween.tween_interval(0.7)
		tween.tween_callback(func():
			if active_gems.is_empty():
				processed_finished.emit(task_name)
				task_name = ""
				active_gems.clear()
				active_serial = 0
				eliminated_gems.clear()
			else:
				process_active_gem(active_gems[0])
		)
	else:
		tween.tween_callback(func():
			clear_consumed()
			if skill_effects.is_empty():
				fill_blanks()
			else:
				var s = skill_effects[0]
				process_skill_effect(s.first, s.second)
		)
	Game.animation_speed *= 0.95
	Game.animation_speed = max(0.05, Game.animation_speed)
