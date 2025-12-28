extends Control

const UiCell = preload("res://ui_cell.gd")
const UiHandSlot = preload("res://ui_hand_slot.gd")
const cell_pb = preload("res://ui_cell.tscn")
const outline_pb = preload("res://ui_outline.tscn")

@onready var tilemap : TileMapLayer = $TileMapLayer
@onready var panel : Panel = $SubViewport/Panel
@onready var outlines_root : Node2D = $SubViewport/Outlines
@onready var underlay : Node2D = $SubViewport/Underlay
@onready var cells_root : Node2D = $SubViewport/Cells
@onready var overlay : Node2D = $SubViewport/Overlay
@onready var hover_ui : Sprite2D = $Hover

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
	var r = get_panel_rect(App.board_size % 2 == 0)
	panel.position = r.position
	panel.size = r.size
	
	if trans:
		if !tween:
			tween = App.game_tweens.create_tween()
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
			if App.swaps > 0:
				var slot1 = payload as UiHandSlot
				var coord = extra["coord"]
				var g2 = Board.get_gem_at(coord)
				if Board.get_cell(coord).in_mist:
					SSound.se_error.play()
					App.banner_ui.show_tip(tr("wr_ban_swapping_in_mist"), "", 1.0)
					return false
				'''
				var i = Board.get_item_at(coord)
				if i && (i.name == "SinLust" || i.name == "SinGluttony" || i.name == "SinGreed" || i.name == "SinWrath" || i.name == "SinEnvy"):
					SSound.se_error.play()
					App.banner_ui.show_tip(tr("wr_ban_swapping_sin"), "", 1.0)
					return false
				'''
				App.swaps -= 1
				
				App.swap_hand_and_board(slot1, coord)
				App.action_stack.append(Pair.new(coord, g2))
				App.control_ui.undo_button.disabled = false
				return true
			else:
				App.control_ui.swaps_text.hint()
		return false
	)
