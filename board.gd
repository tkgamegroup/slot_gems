extends Object

class_name Board

enum ActiveReason
{
	Pattern,
	Item,
	RcAction
}

enum AuraEvent
{
	Enter,
	Exit
}

var cx : int
var cy : int
var cx_mult : int
var cells : Array[Cell]
var central_coord = Vector2i(26, 10)

const cell_pb = preload("res://ui_cell.tscn")
const roll_speed : Curve = preload("res://roll_speed.tres")
const particles_pb = preload("res://particles.tscn")
const active_item_pb = preload("res://active_item.tscn")

var num_tasks : int
var show_coords : bool = false

var active_items : Array[Triple] = []
var active_serial : int = 0
var eliminated_items : Dictionary[String, int] = {}
var skill_effects : Array[Pair]
var auras : Array[Item]

signal rolling_finished
signal matching_finished

# odd-q vertical layout shoves odd columns down
# even-q vertical layout shoves even columns down

static func cube_to_oddq(c : Vector3i):
	var col = c.x
	var row = c.y + (c.x - (c.x & 1)) / 2
	return Vector2i(col, row)

static func oddq_to_cube(hex : Vector2i):
	var q = hex.x
	var r = hex.y - (hex.x - (hex.x & 1)) / 2
	return Vector3i(q, r, -q-r)

static func cube_to_evenq(c : Vector3i):
	var col = c.x
	var row = c.y + (c.x + (c.x & 1)) / 2
	return Vector2i(col, row)

static func evenq_to_cube(hex : Vector2i):
	var q = hex.x
	var r = hex.y - (hex.x + (hex.x & 1)) / 2
	return Vector3i(q, r, -q-r)

static func offset_to_cube(c : Vector2i):
	return oddq_to_cube(c) if (Game.board_size % 2 == 0) else evenq_to_cube(c)

static func cube_to_offset(c : Vector3i):
	return cube_to_oddq(c) if (Game.board_size % 2 == 0) else cube_to_evenq(c)
	
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

func is_valid(c : Vector2i):
	return c.x >= 0 && c.x < cx && c.y >= 0 && c.y < cy

func cell_at(c : Vector2i):
	if !is_valid(c):
		return null
	return cells[c.y * cx + c.x]

func get_gem_at(c : Vector2i):
	if !is_valid(c):
		return null
	return cells[c.y * cx + c.x].gem

func set_gem_at(c : Vector2i, g : Gem):
	if !is_valid(c):
		return
	var cell = cells[c.y * cx + c.x]
	var og = cell.gem
	if og:
		for a in auras:
			a.on_aura.call(AuraEvent.Exit, og)
		Game.release_gem(og)
	cell.gem = g
	if g:
		for a in auras:
			a.on_aura.call(AuraEvent.Enter, g)
		g.coord = c
	Game.get_cell_ui(c).set_gem_image(g.type if g else 0, g.rune if g else 0)
	return og

func get_item_at(c : Vector2i):
	if !is_valid(c):
		return null
	return cells[c.y * cx + c.x].item

func set_item_at(c : Vector2i, i : Item):
	if !is_valid(c):
		return
	var cell = cells[c.y * cx + c.x]
	var oi = cell.item
	if oi:
		if oi.on_aura.is_valid():
			auras.erase(oi)
			for y in cy:
				for x in cx:
					oi.on_aura.call(AuraEvent.Exit, self, Vector2i(x, y))
		if !oi.active:
			Game.release_item(oi)
	if i:
		if i.on_quick.is_valid():
			i.on_quick.call(self, c)
			Game.release_item(i)
			return oi
		if i.on_place.is_valid():
			i.on_place.call(self, c)
		if i.on_aura.is_valid():
			auras.append(i)
			for y in cy:
				for x in cx:
					i.on_aura.call(AuraEvent.Enter, self, Vector2i(x, y))
	cell.item = i
	Game.get_cell_ui(c).set_item_image(i.image_id if i else 0)
	return oi

func get_state_at(c : Vector2i):
	if !is_valid(c):
		return 0
	var idx = c.y * cx + c.x
	return cells[idx].state

func set_state_at(c : Vector2i, s : int):
	if !is_valid(c):
		return
	var idx = c.y * cx + c.x
	if cells[idx].state == s:
		return false
	cells[idx].state = s
	var ui = Game.get_cell_ui(c)
	if s == Cell.State.Normal:
		ui.gem.position = Vector2(0, 0)
		ui.gem.scale = Vector2(1, 1)
		ui.modulate = Color(1.0, 1.0, 1.0, 1.0)
		ui.pin.hide()
		ui.burn.hide()
	elif s == Cell.State.Consumed:
		ui.modulate = Color(1.3, 1.3, 1.3, 1.0)
	elif s == Cell.State.Burning:
		SSound.sfx_start_buring.play()
		ui.burn.show()
	return true

func find(cb : Callable) -> Array[Vector2i]:
	var ret : Array[Vector2i] = []
	for y in cy:
		for x in cx:
			var c = Vector2i(x, y)
			if cb.call(get_gem_at(c), get_item_at(c)):
				ret.append(c)
	return ret

func gem_score_at(c : Vector2i):
	var g = get_gem_at(c)
	if !g:
		return 0
	return g.get_base_score() + g.bonus_score

func pin(c : Vector2i):
	if !is_valid(c):
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
	if !is_valid(c):
		return
	var idx = c.y * cx + c.x
	var ui = Game.get_cell_ui(c)
	ui.pin.hide()
	cells[idx].pined = false

func eliminate(_coords : Array[Vector2i], tween : Tween, reason : ActiveReason, source = null):
	var coords = []
	var uis = []
	var ptcs = []
	for c in _coords:
		if c.x >= 0 && c.x < cx && c.y >= 0 && c.y < cy:
			coords.append(c)
			uis.append(Game.get_cell_ui(c))
			ptcs.append(particles_pb.instantiate())
			var i = get_item_at(c)
			if i:
				if eliminated_items.has(i.name):
					eliminated_items[i.name] += 1
				else:
					eliminated_items[i.name] = 1
	tween.tween_callback(func():
		for idx in coords.size():
			var c = coords[idx]
			var g = get_gem_at(c)
			var i = get_item_at(c)
			var ui = uis[idx]
			var ptc = ptcs[idx]
			ui.gem.bg_sp.scale = Vector2(1.5, 1.5)
			ui.gem.z_index = 1
			ptc.position = get_pos(c)
			ptc.emitting = true
			ptc.color = Gem.type_color(g.type)
			Game.overlay.add_child(ptc)
			if i:
				var do_activate = true
				if i.on_eliminate.is_valid():
					do_activate = i.on_eliminate.call(self, c, reason, source)
				if do_activate:
					activate(i, c, reason, source)
				set_item_at(c, null)
	)
	tween.tween_method(func(t):
		for ui in uis:
			ui.gem.bg_sp.scale = Vector2(t, t)
	, 1.5, 1.0, max(0.4 * Game.animation_speed, 0.1))
	tween.tween_callback(func():
		for i in coords.size():
			var c = coords[i]
			uis[i].gem.z_index = 0
			ptcs[i].queue_free()
			if !cell_at(c).pined:
				set_state_at(c, Cell.State.Consumed)
	)

func activate(item : Item, coord : Vector2i, reason : ActiveReason, source = null):
	if !item.active:
		if item.on_process.is_valid():
			item.active = true
			var sp = active_item_pb.instantiate()
			sp.frame = item.image_id
			sp.position = get_pos(coord)
			sp.z_index = 2
			Game.cells_root.add_child(sp)
			active_items.append(Triple.new(item, coord, sp))
			active_serial += 1

func process_active_item(t : Triple):
	var item = t.first
	var tween = Game.get_tree().create_tween()
	item.on_process.call(self, t.second, tween, t.third)
	tween.tween_callback(func():
		active_items.remove_at(0)
		item.active = false
		Game.release_item(item)
		t.third.queue_free()
		clear_consumed()
	)
	tween.tween_interval(0.4 * Game.animation_speed)
	tween.tween_callback(func():
		fill_blanks()
	)

func process_skill_effects():
	if skill_effects.is_empty():
		fill_blanks()
	else:
		SSound.sfx_bubble.play()
		var s = skill_effects[0]
		var skill : Skill = s.first
		var rune_coords = s.second
		var tween = Game.get_tree().create_tween()
		var coords = []
		for r in rune_coords:
			for c in rune_coords[r]:
				var pos = get_pos(c)
				coords.append(c)
		var rid = randi_range(0, coords.size() - 1)
		var target_coord = coords[rid]
		var g = Gem.new()
		g.setup(skill.spawn_gem.name)
		g.temporary = true
		tween.tween_callback(func():
			set_gem_at(target_coord, g)
		)
		tween.tween_interval(0.3)
		tween.tween_callback(func():
			skill_effects.remove_at(0)
			process_skill_effects()
		)

func cleanup():
	cells.clear()
	for y in cy:
		for x in cx:
			var c = Vector2i(x, y)
			set_gem_at(c, null)
	Game.unused_gems.clear()
	for g in Game.gems:
		Game.unused_gems.append(g)
	for n in Game.outlines_root.get_children():
		n.queue_free()
		Game.outlines_root.remove_child(n)
	for n in Game.cells_root.get_children():
		n.queue_free()
		Game.cells_root.remove_child(n)

func setup(_hf_cy : int, _cx_multipler : int):
	cleanup()
	
	cx_mult = _cx_multipler
	cy = _hf_cy * 2
	cx = cy * cx_mult
	for y in cy:
		for x in cx:
			var idx = y * cx + x
			var c = Cell.new()
			c.index = idx
			cells.append(c)
	
	for y in cy:
		for x in cx:
			var cell = cell_pb.instantiate()
			cell.position = get_pos(Vector2i(x, y))
			Game.cells_root.add_child(cell)
			if show_coords:
				var cube_c = offset_to_cube(Vector2i(x, y))
				var lb0 = Label.new()
				lb0.text = "%d" % cube_c.x
				lb0.add_theme_color_override("font_color", Color.RED)
				lb0.add_theme_font_size_override("font_size", 9)
				lb0.position = cell.position + Vector2(-5, -15)
				Game.overlay.add_child(lb0)
				var lb1 = Label.new()
				lb1.text = "%d" % cube_c.y
				lb1.add_theme_color_override("font_color", Color.GREEN)
				lb1.add_theme_font_size_override("font_size", 9)
				lb1.position = cell.position + Vector2(3, 2)
				Game.overlay.add_child(lb1)
				var lb2 = Label.new()
				lb2.text = "%d" % cube_c.z
				lb2.add_theme_color_override("font_color", Color.BLUE)
				lb2.add_theme_font_size_override("font_size", 9)
				lb2.position = cell.position + Vector2(-10, 2)
				Game.overlay.add_child(lb2)
	
	var updated = {}
	var pc = Game.tilemap.map_to_local(central_coord)
	var tween = Game.get_tree().create_tween()
	for i in _hf_cy + 1:
		for x in range(-i * cx_mult, i * cx_mult):
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
					outline_sp.texture = load("res://images/outline.png")
					outline_sp.position = p0
					outline_sp.scale = Vector2(1.2, 1.2)
					outline_sp.modulate.a = 0
					tween2.tween_callback(func():
						Game.outlines_root.add_child(outline_sp)
						num_tasks += 1
					)
					tween2.tween_property(outline_sp, "position", p1, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
					tween2.parallel().tween_property(outline_sp, "scale", Vector2(1.0, 1.0), 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
					tween2.parallel().tween_property(outline_sp, "modulate:a", 1.0, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
					tween2.tween_callback(func():
						num_tasks -= 1
						if num_tasks == 0:
							Game.game_ui.roll_button.disabled = false
					)
				)
		tween.tween_interval(0.1)

func skip_above_pineds(c : Vector2i) -> Vector2i:
	var cc = c - Vector2i(0, 1)
	while true:
		if cc.y < 0:
			return cc
		if !cell_at(cc).pined:
			return cc
		cc.y -= 1
	return Vector2i(-1, -1)

func step_down_cell(c : Vector2i):
	if !cell_at(c).pined:
		var cc = skip_above_pineds(c)
		if cc.y < 0:
			set_gem_at(c, Game.get_gem())
		else:
			var og = set_gem_at(cc, null)
			if og:
				og = Game.get_gem(og)
			var oi = set_item_at(cc, null)
			if oi:
				oi = Game.get_item(oi)
			set_gem_at(c, og)
			set_item_at(c, oi)

func roll():
	for yy in cy:
		for xx in cx:
			var c = Vector2i(xx, yy)
			if !cell_at(c).pined:
				set_gem_at(c, null)
	
	Game.combos = 0
	
	var tween = Game.get_tree().create_tween()
	for x in cx:
		tween.tween_callback(func():
			var tween2 = Game.get_tree().create_tween()
			tween2.tween_callback(func():
				num_tasks += 1
			)
			for i in cy * 6:
				tween2.tween_callback(func():
					for y in cy:
						var c = Vector2i(x, cy - y - 1)
						step_down_cell(c)
				)
				tween2.tween_interval(roll_speed.sample(float(i) / (cy * 6.0)))
			tween2.tween_interval(0.01)
			tween2.tween_callback(func():
				num_tasks -= 1
				if num_tasks == 0:
					rolling_finished.emit()
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
				set_gem_at(c, null)
				set_state_at(c, Cell.State.Normal)
	if burned_cells > 0:
		SSound.sfx_end_buring.play()

func fill_blanks():
	var tween = Game.get_tree().create_tween()
	tween.tween_interval(max(0.1 * Game.animation_speed, 0.05))
	tween.tween_callback(func():
		var filled = false
		for x in cx:
			for y in cy:
				var c = Vector2i(x, cy - y - 1)
				if !cell_at(c).pined && !get_gem_at(c):
					step_down_cell(c)
					filled = true
		if filled:
			SSound.sfx_zap.play()
			fill_blanks()
		else:
			matching()
	)

func matching():
	var no_patterns = true
	var used_runes = {}
	var tween = Game.get_tree().create_tween()
	for y in cy:
		for x in cx:
			for p in Game.patterns:
				var res : Array[Vector2i] = p.search(self, Vector2i(x, y))
				if !res.is_empty():
					no_patterns = false
					tween.tween_callback(func():
						var txt_pos = Vector2(0, 0)
						SSound.sfx_tom.play()
						
						p.add_exp(1)
						Game.add_combo()
						for c in res:
							Game.add_score(gem_score_at(c) * p.mult, get_pos(c))
					)
					var runes : Array[Vector2i] = []
					for c in res:
						if !used_runes.has(c):
							runes.append(c)
					for s in Game.skills:
						var rune_coords = s.check(runes)
						if !rune_coords.is_empty():
							skill_effects.append(Pair.new(s, rune_coords))
							for c in runes:
								used_runes[c] = 1
					eliminate(res, tween, ActiveReason.Pattern, p)
					Game.animation_speed *= 0.98
					Game.animation_speed = max(0.05, Game.animation_speed)
	if no_patterns:
		tween.tween_interval(0.7)
		tween.tween_callback(func():
			if active_items.is_empty():
				matching_finished.emit()
				active_serial = 0
				eliminated_items.clear()
			else:
				process_active_item(active_items[0])
		)
	else:
		tween.tween_callback(func():
			clear_consumed()
		)
		tween.tween_interval(0.4 * Game.animation_speed)
		tween.tween_callback(func():
			process_skill_effects()
		)
	Game.animation_speed *= 0.98
	Game.animation_speed = max(0.05, Game.animation_speed)
