extends Control

@onready var tilemap : TileMapLayer = $TileMapLayer
@onready var panel : Panel = $SubViewport/Panel
@onready var outlines_root : Node2D = $SubViewport/Outlines
@onready var underlay : Node2D = $SubViewport/Underlay
@onready var cells_root : Node2D = $SubViewport/Cells
@onready var entangled_lines : Node2D = $SubViewport/EntangledLines
@onready var overlay : Node2D = $SubViewport/Overlay
@onready var hover_ui : Sprite2D = $Hover

const UiCell = preload("res://ui_cell.gd")
const UiHandSlot = preload("res://ui_hand_slot.gd")
const cell_pb = preload("res://ui_cell.tscn")
const outline_pb = preload("res://ui_outline.tscn")
const entangled_line_pb = preload("res://entangled_line.tscn")

func game_coord(c : Vector2i):
	return c + Vector2i(Board.cx, Board.cy) / 2 - C.BOARD_CENTER

func ui_coord(c : Vector2i):
	return c - Vector2i(Board.cx, Board.cy) / 2 + C.BOARD_CENTER

func hover_coord(to_game_coord : bool = false):
	var c = tilemap.local_to_map(tilemap.get_local_mouse_position()) 
	if to_game_coord:
		c = game_coord(c)
	return c

func get_pos(c : Vector2i):
	return tilemap.map_to_local(c)

func get_cell(c : Vector2i) -> UiCell:
	return cells_root.get_child(c.y * Board.cx + c.x)

func update_cell(c : Vector2i):
	var cell = Board.get_cell(c)
	var ui = get_cell(c)
	ui.gem_ui.reset()
	ui.gem_ui.angle = Vector2(0.0, 0.0)
	var g = Board.get_gem_at(c)
	if g:
		if cell.in_mist:
			ui.gem_ui.reset(Gem.Unknow, Gem.None)
		else:
			ui.gem_ui.update(g)
	else:
		ui.gem_ui.reset()
	if cell.state == Cell.State.Normal:
		ui.gem_ui.position = Vector2(0, 0)
		ui.gem_ui.scale = Vector2(1, 1)
		ui.modulate = Color(1.0, 1.0, 1.0, 1.0)
	elif cell.state == Cell.State.Consumed:
		ui.modulate = Color(1.3, 1.3, 1.3, 1.0)
	ui.pinned.visible = cell.pinned
	ui.frozen.visible = cell.frozen
	ui.set_nullified(cell.nullified)

func clear():
	for n in outlines_root.get_children():
		outlines_root.remove_child(n)
		n.queue_free()
	for n in cells_root.get_children():
		cells_root.remove_child(n)
		n.queue_free()

func add_cell(c : Vector2i):
	var pos = get_pos(c) - Vector2(C.BOARD_TILE_SZ, C.BOARD_TILE_SZ) * 0.5
	
	var outline = outline_pb.instantiate()
	outline.position = pos
	outlines_root.add_child(outline)
	
	var cell = cell_pb.instantiate()
	cell.position = pos
	cells_root.add_child(cell)

func get_panel_rect(even : bool, border : bool = true):
	tilemap.clear()
	for y in Board.cy:
		for x in Board.cx:
			tilemap.set_cell(ui_coord(Vector2i(x, y)), 1, Vector2i(0, 0))
	var used = tilemap.get_used_rect()
	var p = tilemap.map_to_local(used.position) - Vector2(C.BOARD_TILE_SZ * 0.5, C.BOARD_TILE_SZ * 1.0)
	var s = tilemap.map_to_local(used.end) - p - Vector2(C.BOARD_TILE_SZ * 0.25, C.BOARD_TILE_SZ * 0.5)
	if border:
		p -= Vector2(C.BOARD_TILE_SZ * 0.25, C.BOARD_TILE_SZ * 0.5)
		s += Vector2(C.BOARD_TILE_SZ * 0.5, C.BOARD_TILE_SZ * 1.0)
	if even:
		p.y += C.BOARD_TILE_SZ * 0.5
	return Rect2(p, s)

func enter(tween : Tween = null, trans : bool = true):
	var r = get_panel_rect(G.board_size % 2 == 0)
	panel.position = r.position
	panel.size = r.size
	
	if trans:
		if !tween:
			tween = G.game_tweens.create_tween()
		tween.tween_callback(func():
			self.material.set_shader_parameter("x_rot", -90.0)
			self.show()
		)
		tween.tween_property(self.material, "shader_parameter/x_rot", 0.0, 0.5).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
	else:
		self.material.set_shader_parameter("x_rot", 0.0)
		self.show()
	return tween

func exit(tween : Tween):
	tween.tween_property(self.material, "shader_parameter/x_rot", 90.0, 0.5).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
	tween.tween_callback(func():
		self.hide()
	)
	return tween

func show_entangled_lines():
	var old_nodes = []
	for n in Board.ui.entangled_lines.get_children():
		old_nodes.append(n)
	for eg in G.entangled_groups:
		var num = eg.gems.size()
		for i in num - 1:
			for j in range(i + 1, num):
				var g1 = eg.gems[i]
				var g2 = eg.gems[j]
				if g1.coord.x != -1 && g1.coord.y != -1 && g2.coord.x != -1 && g2.coord.y != -1:
					var already_has = false
					for n in old_nodes:
						if n.coord1 == g1.coord && n.coord2 == g2.coord:
							old_nodes.erase(n)
							already_has = true
							break
					if !already_has:
						var line = entangled_line_pb.instantiate()
						line.setup(g1.coord, g2.coord)
						Board.ui.entangled_lines.add_child(line)
	for n in old_nodes:
		n.disappear()

func hide_entangled_lines():
	for n in Board.ui.entangled_lines.get_children():
		Board.ui.entangled_lines.remove_child(n)
		n.disappear()

func find_entangled_line(g1 : Gem, g2 : Gem):
	for n in Board.ui.entangled_lines.get_children():
		if (n.coord1 == g1.coord && n.coord2 == g2.coord) || (n.coord2 == g1.coord && n.coord1 == g2.coord):
			return n
	return null

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if Board && self.visible:
			var c = hover_coord()
			var cc = c + Vector2i(Board.cx / 2, Board.cy / 2) - C.BOARD_CENTER
			if Board.is_valid(cc):
				hover_ui.show()
				hover_ui.position = get_pos(c)
			else:
				hover_ui.hide()

func _ready() -> void:
	self.pivot_offset = get_viewport_rect().size * 0.5
	Drag.add_target("gem", self, func(payload, ev : String, extra : Dictionary):
		if ev == "peek":
			pass
		elif ev == "peek_exited":
			pass
		else:
			if G.swaps > 0:
				var slot1 = payload as UiHandSlot
				var coord = extra["coord"]
				var g2 = Board.get_gem_at(coord)
				if Board.get_cell(coord).in_mist:
					SSound.se_error.play()
					G.banner_ui.show_tip(tr("wr_ban_swapping_in_mist"), "", 1.0)
					return false
				'''
				var i = Board.get_item_at(coord)
				if i && (i.name == "SinLust" || i.name == "SinGluttony" || i.name == "SinGreed" || i.name == "SinWrath" || i.name == "SinEnvy"):
					SSound.se_error.play()
					G.banner_ui.show_tip(tr("wr_ban_swapping_sin"), "", 1.0)
					return false
				'''
				G.swaps -= 1
				
				G.swap_hand_and_board(slot1, coord)
				G.action_stack.append(Pair.new(coord, g2))
				G.control_ui.undo_button.disabled = false
				return true
			else:
				G.control_ui.swaps_text.hint()
		return false
	)
