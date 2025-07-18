extends Node

enum ActiveReason
{
	Pattern,
	Item,
	Relic,
	Burning,
	RcAction,
	Duplicate
}

enum PlaceReason
{
	None,
	FromHand,
	FromBag
}

var cx : int
var cy : int
const cx_mult : int = 3
var cells : Array[Cell]
var curr_min_gem_num : int
var next_min_gem_num : int

const roll_speed : Curve = preload("res://roll_speed.tres")
const particles_pb = preload("res://particles.tscn")
const active_effect_pb = preload("res://ui_active_effect.tscn")
const black_bg = preload("res://images/black_bg.png")
const trail_pb = preload("res://trail.tscn")

var num_tasks : int
var show_coords : bool = false

var active_effects : Array[ActiveEffect] = []
var active_serial : int = 0
var event_listeners : Array[Hook]

signal rolling_finished
signal filling_finished
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

func offset_distance(a : Vector2i, b : Vector2i):
	return cube_distance(offset_to_cube(a), offset_to_cube(b))

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
		ret.append(format_coord(cube_to_offset(cc)))
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
	if r == 0:
		ret.append(c)
		return ret
	for cc in cube_ring(offset_to_cube(c), r):
		ret.append(format_coord(cube_to_offset(cc)))
	return ret

func get_pos(c : Vector2i):
	return Game.board_ui.get_pos(Game.board_ui.ui_coord(c))

func is_valid(c : Vector2i):
	return c.x >= 0 && c.x < cx && c.y >= 0 && c.y < cy

func format_coord(c : Vector2i):
	if is_valid(c):
		return c
	if Game.modifiers["board_upper_lower_connected_i"] > 0:
		if c.y < 0:
			c.y = Board.cy + c.y
		if c.y >= Board.cy:
			c.y = c.y - Board.cy
	return c

func get_cell(c : Vector2i):
	c = format_coord(c)
	if !is_valid(c):
		return null
	return cells[c.y * cx + c.x]

func get_gem_at(c : Vector2i):
	c = format_coord(c)
	if !is_valid(c):
		return null
	return cells[c.y * cx + c.x].gem

func set_gem_at(c : Vector2i, g : Gem):
	c = format_coord(c)
	if !is_valid(c):
		return null
	var cell = cells[c.y * cx + c.x]
	var og = cell.gem
	if og:
		for h in event_listeners:
			h.host.on_event.call(Event.GemLeft, null, og)
		Game.release_gem(og)
	cell.gem = g
	if g:
		g.coord = c
		for h in event_listeners:
			h.host.on_event.call(Event.GemEntered, null, g)
	else:
		cell.pinned = false
		cell.frozen = false
	Game.board_ui.update_cell(c)
	return og

func get_item_at(c : Vector2i):
	c = format_coord(c)
	if !is_valid(c):
		return null
	return cells[c.y * cx + c.x].item

func set_item_at(c : Vector2i, i : Item, r : int = PlaceReason.None):
	c = format_coord(c)
	if !is_valid(c):
		return
	var cell = cells[c.y * cx + c.x]
	var oi = cell.item
	if oi:
		for h in event_listeners:
			h.host.on_event.call(Event.ItemLeft, null, oi)
		SMath.remove_if(event_listeners, func(h : Hook):
			return h.host == oi
		)
		Game.release_item(oi)
	if i:
		i.coord = c
		if i.on_place.is_valid():
			i.on_place.call(c, r)
		if i.on_event.is_valid():
			var h = Hook.new(-1, i, HostType.Item, false)
			event_listeners.append(h)
		for h in event_listeners:
			h.host.on_event.call(Event.ItemEntered, null, i)
	cell.item = i
	Game.board_ui.update_cell(c)
	return oi

func place_item(c : Vector2i, i : Item, reason : int = PlaceReason.FromHand):
	c = format_coord(c)
	if !is_valid(c):
		return false
	var g = get_gem_at(c)
	if !g:
		return false
	var oi = get_item_at(c)
	if i.on_quick.is_valid():
		if i.on_quick.call(c):
			Game.release_item(i)
			return true
	elif oi && oi.mountable == i.category && !oi.mounted:
		if oi.on_mount.is_valid():
			if !oi.on_mount.call(i):
				return true
		oi.mounted = i
		Game.board_ui.update_cell(c)
		return true
	else:
		set_item_at(c, i, reason)
		return true
	return false

func get_state_at(c : Vector2i):
	c = format_coord(c)
	if !is_valid(c):
		return 0
	var idx = c.y * cx + c.x
	return cells[idx].state

func set_state_at(c : Vector2i, s : int, extra : Dictionary = {}):
	c = format_coord(c)
	if !is_valid(c):
		return
	var idx = c.y * cx + c.x
	if cells[idx].state == s:
		return false
	cells[idx].state = s
	Game.board_ui.update_cell(c)
	'''
	if extra.has("pos"):
		var tween = Game.get_tree().create_tween()
		ui.burn.global_position = extra.pos
		tween.tween_property(ui.burn, "position", Vector2(0, 0), 0.15)
	'''
	return true

func filter(cb : Callable) -> Array[Vector2i]:
	var ret : Array[Vector2i] = []
	for y in cy:
		for x in cx:
			var c = Vector2i(x, y)
			if cb.call(get_gem_at(c), get_item_at(c)):
				ret.append(c)
	return ret

func find_item(name : String):
	for y in cy:
		for x in cx:
			var c = Vector2i(x, y)
			var i = get_item_at(c)
			if i && i.name == name:
				return c
	return Vector2i(-1, -1)

func find_item_backwards(name : String, include_active_effects : bool = false):
	for y in range(cy - 1, -1, -1):
		for x in range(cx - 1, -1, -1):
			var c = Vector2i(x, y)
			var i = get_item_at(c)
			if i && i.name == name:
				return c
	return Vector2i(-1, -1)

func get_active_effects_at(c : Vector2i):
	var ret = []
	for ae in active_effects:
		if ae.coord == c:
			ret.append(ae)
	return ret

func gem_score_at(c : Vector2i):
	var g = get_gem_at(c)
	if !g:
		return 0
	return g.get_base_score() + g.bonus_score

func pin(c : Vector2i):
	c = format_coord(c)
	if !is_valid(c):
		return false
	var idx = c.y * cx + c.x
	var cell = cells[idx]
	if cell.pinned || cell.frozen:
		return false
	if get_gem_at(c):
		cell.pinned = true
		Game.board_ui.update_cell(c)
		return true

func unpin(c : Vector2i):
	c = format_coord(c)
	if !is_valid(c):
		return false
	var idx = c.y * cx + c.x
	cells[idx].pinned = false
	Game.board_ui.update_cell(c)

func freeze(c : Vector2i):
	c = format_coord(c)
	if !is_valid(c):
		return false
	var idx = c.y * cx + c.x
	var cell = cells[idx]
	if cell.frozen:
		return false
	if get_gem_at(c):
		cell.frozen = true
		Game.board_ui.update_cell(c)
		return true

func unfreeze(c : Vector2i):
	c = format_coord(c)
	if !is_valid(c):
		return
	var idx = c.y * cx + c.x
	cells[idx].frozen = false
	Game.board_ui.update_cell(c)

func eliminate(_coords : Array[Vector2i], tween : Tween, reason : ActiveReason, source = null):
	var coords = []
	var ptcs = []
	for c in _coords:
		if is_valid(c) && !get_cell(c).frozen:
			coords.append(c)
	for c in coords:
		var i = get_item_at(c)
		if i:
			if i.on_eliminate.is_valid():
				i.on_eliminate.call(c, reason, source, tween)
			set_item_at(c, null)
		SMath.remove_if(get_cell(c).event_listeners, func(h : Hook):
			if h.event == Event.Eliminated:
				h.host.on_event.call(Event.Eliminated, tween, c)
				return h.once
			return false
		)
	if !event_listeners.is_empty():
		var d = {"reason":reason,"coords":coords}
		for h in event_listeners:
			if h.event == Event.Eliminated:
				h.host.on_event.call(Event.Eliminated, tween, d)
	tween.tween_interval(0.02)
	tween.tween_callback(func():
		for i in coords.size():
			var c = coords[i]
			if get_state_at(c) != Cell.State.Burning:
				set_state_at(c, Cell.State.Consumed)
	)

func activate(host, type : int, effect_index : int, c : Vector2i, reason : ActiveReason, source = null):
	var sp : AnimatedSprite2D = null
	if type == HostType.Item:
		var item : Item = host
		if !(item.on_active.is_valid() || (item.mounted && item.mounted.on_active.is_valid())):
			return
		sp = active_effect_pb.instantiate()
		sp.sprite_frames = Item.item_frames
		sp.frame = item.image_id
		sp.position = get_pos(c)
		sp.z_index = 4
		Game.board_ui.cells_root.add_child(sp)
	elif type == HostType.Relic:
		var relic : Relic = host
		if !relic.on_active.is_valid():
			return
		sp = active_effect_pb.instantiate()
		sp.global_position = relic.ui.get_global_rect().get_center()
		sp.z_index = 4
		Game.game_ui.add_child(sp)
	var ae = ActiveEffect.new()
	ae.host = host
	ae.type = type
	ae.effect_index = effect_index
	ae.coord = c
	ae.sp = sp
	active_effects.append(ae)
	active_serial += 1
	for h in event_listeners:
		h.host.on_event.call(Event.ItemActivated, null, ae)

func process_active_effect(ae : ActiveEffect):
	var tween = Game.get_tree().create_tween()
	if ae.type == HostType.Item:
		var item : Item = ae.host
		if item.mounted && item.mounted.on_active.is_valid():
			item.mounted.on_active.call(ae.effect_index, ae.coord, tween, ae.sp)
		if item.on_active.is_valid():
			item.on_active.call(ae.effect_index, ae.coord, tween, ae.sp)
	elif ae.type == HostType.Relic:
		var relic : Relic = ae.host
		if relic.on_active.is_valid():
			relic.on_active.call(ae.effect_index, ae.coord, tween)
	tween.tween_callback(func():
		active_effects.remove_at(0)
		ae.sp.queue_free()
		clear_consumed()
	)
	tween.tween_interval(0.4 * Game.speed)
	tween.tween_callback(func():
		fill_blanks()
	)

func item_moved(item : Item, tween : Tween, from : Vector2i, to : Vector2i):
	for h in event_listeners:
		h.host.on_event.call(Event.ItemMoved, tween, {"item":item,"from":from,"to":to})

func clear():
	for y in cy:
		for x in cx:
			var c = Vector2i(x, y)
			set_item_at(c, null)
			set_gem_at(c, null)
	cells.clear()
	Game.board_ui.clear()
	cx = 0
	cy = 0

func add_cell(c : Vector2i):
	var cell = Cell.new()
	cell.coord = c
	cells.append(cell)
	Game.board_ui.add_cell(Game.board_ui.ui_coord(c))
	return cell

func update_gem_quantity_limit():
	curr_min_gem_num = (cx * cy) + 10
	next_min_gem_num = (cx + 6) * (cy + 2) + 20
	Game.status_bar_ui.gem_count_limit_text.text = "%d/%d" % [next_min_gem_num, curr_min_gem_num]

func setup(_hf_cy : int):
	clear()
	
	cy = _hf_cy * 2
	cx = cy * cx_mult
	for y in cy:
		for x in cx:
			add_cell(Vector2i(x, y))
	update_gem_quantity_limit()

func resize(_hf_cy : int):
	var old_cells = cells.duplicate()
	var old_cx = cx
	var old_cy = cy
	cy = _hf_cy * 2
	cx = cy * cx_mult
	var offset = Vector2i((cx - old_cx) / 2, (cy - old_cy) / 2)
	for cell in old_cells:
		cell.coord = cell.coord + offset
	cells.clear()
	Game.board_ui.clear()
	for y in cy:
		for x in cx:
			var c = Vector2i(x, y)
			var added = false
			for cell in old_cells:
				if cell.coord == c:
					cells.append(cell)
					added = true
					break
			if !added:
				add_cell(c)
			else:
				Game.board_ui.add_cell(Game.board_ui.ui_coord(c))
	update_gem_quantity_limit()

func skip_above_unmovables(c : Vector2i) -> Vector2i:
	var cc = c - Vector2i(0, 1)
	while true:
		if cc.y < 0:
			return cc
		if !get_cell(cc).is_unmovable():
			return cc
		cc.y -= 1
	return Vector2i(-1, -1)

func step_down_cell(c : Vector2i):
	var cc = skip_above_unmovables(c)
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

func roll_step():
	var tween = Game.get_tree().create_tween()
	tween.tween_interval(0.03)
	tween.tween_callback(func():
		var filled = false
		for x in cx:
			for y in cy:
				var c = Vector2i(x, cy - y - 1)
				if !get_gem_at(c):
					step_down_cell(c)
					filled = true
		if filled:
			roll_step()
		else:
			rolling_finished.emit()
	)

func roll():
	for yy in cy:
		for xx in cx:
			var c = Vector2i(xx, yy)
			if !get_cell(c).is_unmovable():
				set_item_at(c, null)
				set_gem_at(c, null)
				get_cell(c).event_listeners.clear()
	
	roll_step()

func clear_consumed():
	var burning_cells = []
	for y in cy:
		for x in cx:
			var c = Vector2i(x, y)
			var s = get_state_at(c)
			if s == Cell.State.Consumed:
				if !Game.performance_mode:
					var g = get_gem_at(c)
					if g:
						var tex = Gem.gem_frames.get_frame_texture("default", g.type)
						SEffect.add_break_pieces(get_pos(c), Vector2(32, 32), tex, Game.board_ui.overlay)
				set_gem_at(c, null)
				set_state_at(c, Cell.State.Normal)
			elif s == Cell.State.Burning:
				burning_cells.append(c)
	if burning_cells.size() > 0:
		for c in burning_cells:
			Game.add_score(gem_score_at(c), get_pos(c), false)
			set_gem_at(c, null)
			set_state_at(c, Cell.State.Normal)
		SSound.se_end_buring.play()

func fill_blanks():
	var tween = Game.get_tree().create_tween()
	tween.tween_interval(max(0.1 * Game.speed, 0.05))
	
	if !Game.staging_scores.is_empty():
		var idx = 0
		Game.staging_scores.shuffle()
		for s in Game.staging_scores:
			var subtween = get_tree().create_tween()
			subtween.tween_interval(idx * 0.02)
			subtween.tween_callback(func():
				var trail = trail_pb.instantiate()
				trail.setup(5.0, Color(1.0, 1.0, 1.0, 0.5))
				s.first.add_child(trail)
			)
			subtween.tween_property(s.first, "scale", Vector2(1.0, 1.0), 0.5 * Game.speed)
			subtween.parallel()
			SAnimation.quadratic_curve_to(subtween, s.first, Game.calculator_bar_ui.base_score_text.get_global_rect().get_center(), Vector2(0.3 + randf() * 0.3, (0.1 + randf() * 0.1) * sign(randf() - 0.5)), 0.5 * Game.speed).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN)
			subtween.tween_callback(func():
				SSound.se_select.play()
				Game.base_score += s.second
			)
			subtween.tween_callback(s.first.queue_free)
			if idx > 0:
				tween.parallel()
			tween.tween_subtween(subtween)
			idx += 1
		Game.staging_scores.clear()
		tween.tween_interval(0.3)
	
	tween.tween_callback(func():
		var filled = false
		for x in cx:
			for y in cy:
				var c = Vector2i(x, cy - y - 1)
				if !get_gem_at(c):
					step_down_cell(c)
					filled = true
		if filled:
			SSound.se_zap.play()
			fill_blanks()
		else:
			filling_finished.emit()
	)

func on_combo():
	for h in event_listeners:
		h.host.on_event.call(Event.Combo, null, null)

func matching():
	var matched_num = 0
	var tween = Game.get_tree().create_tween()
	tween.tween_interval(0.4)
	
	for y in cy:
		for x in cx:
			for p in Game.patterns:
				var res : Array[Vector2i] = p.match_with(Vector2i(x, y))
				if !res.is_empty():
					var subtween = Game.get_tree().create_tween()
					subtween.tween_interval(matched_num * 0.2 * Game.speed)
					subtween.tween_callback(func():
						p.add_exp(1)
						
						var burning_cells = []
						for yy in cy:
							for xx in cx:
								var c = Vector2i(xx, yy)
								if get_state_at(c) == Cell.State.Burning:
									burning_cells.append(c)
						for c in burning_cells:
							var cands = []
							for cc in offset_neighbors(c):
								if get_state_at(cc) != Cell.State.Burning:
									cands.append(cc)
							var pos = get_pos(c)
							for cc in SMath.pick_n_random(cands, 1, Game.rng):
								set_state_at(cc, Cell.State.Burning, {"pos":pos})
						
						SSound.se_marimba_scale[matched_num % 8].play()
						Game.add_combo()
						for c in res:
							var g = get_gem_at(c)
							Game.add_score(gem_score_at(c) * p.mult, get_pos(c))
							if g.mult != 0.0:
								Game.score_mult += g.mult
					)
					matched_num += 1
					
					eliminate(res, subtween, ActiveReason.Pattern, p)
					
					if matched_num > 0:
						tween.parallel()
					tween.tween_subtween(subtween)
					
					Game.speed *= 0.98
					Game.speed = max(0.05, Game.speed)
	if matched_num == 0:
		tween.tween_interval(0.7 * Game.speed)
		tween.tween_callback(func():
			if active_effects.is_empty():
				matching_finished.emit()
				active_serial = 0
			else:
				process_active_effect(active_effects[0])
		)
	else:
		tween.tween_callback(clear_consumed)
		tween.tween_interval(0.4 * Game.speed)
		tween.tween_callback(fill_blanks)
	Game.speed *= 0.98
	Game.speed = max(0.05, Game.speed)

func effect_explode(cast_pos : Vector2, target_coord : Vector2i, range : int, power : int, tween : Tween = null, source = null):
	var outer_tween = (tween != null)
	if !tween:
		tween = get_tree().create_tween()
		Game.begin_busy()
	var target_pos = get_pos(target_coord)
	if cast_pos != target_pos:
		tween.tween_callback(func():
			SEffect.add_leading_line(cast_pos, target_pos, 0.3 * Game.speed)
		)
		tween.tween_interval(0.4 * Game.speed)
	var coords : Array[Vector2i] = []
	var r = range + Game.modifiers["explode_range_i"]
	var p = power + Game.modifiers["explode_power_i"]
	var fx_sz = Vector2(64.0, 64.0)
	if r < 1:
		fx_sz *= 0.5
	else:
		fx_sz *= r
	for i in r + 1:
		for c in offset_ring(target_coord, i):
			if is_valid(c):
				coords.append(c)
	tween.tween_callback(func():
		var pos = get_pos(target_coord)
		var sp_expl = SEffect.add_explosion(pos, fx_sz, 3, 0.5 * Game.speed)
		Game.board_ui.cells_root.add_child(sp_expl)
		var fx = SEffect.add_distortion(pos, fx_sz, 4, 0.5 * Game.speed)
		Game.board_ui.cells_root.add_child(fx)
	)
	tween.tween_interval(0.5 * Game.speed)
	tween.tween_callback(func():
		var data = {"source":source,"coord":target_coord,"range":range,"power":power}
		for h in event_listeners:
			h.host.on_event.call(Event.Exploded, null, data)
		
		Game.add_combo()
		for c in coords:
			Game.add_score(gem_score_at(c) + p, get_pos(c))
	)
	eliminate(coords, tween, ActiveReason.Item, self)
	if !outer_tween:
		tween.tween_callback(Game.end_busy)
	return coords

func effect_place_items_from_bag(items : Array, tween : Tween = null, source = null):
	var target_coords : Array[Vector2i]
	var outer_tween = true
	var sps = []
	if !tween:
		tween = get_tree().create_tween()
		Game.begin_busy()
		outer_tween = false
	tween.tween_callback(func():
		for i in items.size():
			if !items[i]:
				var cands = []
				for _i in Game.items:
					if _i.coord.x == -1 && _i.coord.y == -1 && !items.has(_i):
						cands.append(_i)
				if cands.is_empty():
					return
				items[i] = SMath.pick_random(cands, Game.rng)
			
			var places = filter(func(g : Gem, i : Item):
				return g && !i && get_active_effects_at(g.coord).is_empty()
			)
			if places.is_empty():
				target_coords.append(Vector2i(-1, -1))
				sps.append(null)
			else:
				target_coords.append(SMath.pick_random(places, Game.rng))
				
				var sp = AnimatedSprite2D.new()
				sp.position = Game.status_bar_ui.bag_button.get_global_rect().get_center()
				sp.sprite_frames = Item.item_frames
				sp.frame = items[i].image_id
				sp.z_index = 4
				Game.board_ui.cells_root.add_child(sp)
				sps.append(sp)
	)
	tween.tween_callback(func():
		var tween2 = Game.get_tree().create_tween()
		for i in target_coords.size():
			if sps[i] != null:
				tween2.parallel()
				SAnimation.cubic_curve_to(tween2, sps[i], get_pos(target_coords[i]), Vector2(0.1, 0.2), Vector2(0.9, 0.2), 0.7 * Game.speed)
	)
	tween.tween_interval(0.7 * Game.speed)
	tween.tween_callback(func():
		for i in items.size():
			if sps[i] != null:
				sps[i].queue_free()
				place_item(target_coords[i], items[i], PlaceReason.FromBag)
		if !outer_tween:
			Game.end_busy()
	)
