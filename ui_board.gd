extends Control

const central_coord = Vector2i(26, 12)

const UiCell = preload("res://ui_cell.gd")
const cell_pb = preload("res://ui_cell.tscn")
const outline_pb = preload("res://ui_outline.tscn")

@onready var panel : Panel = $Panel
@onready var tilemap : TileMapLayer = $TileMapLayer
@onready var outlines_root : Node2D = $Outlines
@onready var underlay : Node2D = $Underlay
@onready var cells_root : Node2D = $Cells
@onready var overlay : Node2D = $Overlay
@onready var hover_ui : Sprite2D = $Hover

func game_coord(c : Vector2i):
	return c + Vector2i(Board.cx / 2, Board.cy / 2) - central_coord

func ui_coord(c : Vector2i):
	return c - Vector2i(Board.cx / 2, Board.cy / 2) + central_coord

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
	ui.set_duplicant(false)
	var g = Board.get_gem_at(c)
	if g:
		ui.set_gem_image(g.type, g.rune)
		var i = Board.get_item_at(c)
		if i:
			ui.set_item_image(i.image_id, i.mounted.image_id if i.mounted else 0)
			ui.set_duplicant(i.duplicant)
		else:
			ui.set_item_image(0, 0)
	else:
		ui.set_gem_image(0, 0)
		ui.set_item_image(0, 0)
	if cell.state == Cell.State.Normal:
		ui.gem_ui.position = Vector2(0, 0)
		ui.gem_ui.scale = Vector2(1, 1)
		ui.modulate = Color(1.0, 1.0, 1.0, 1.0)
	elif cell.state == Cell.State.Consumed:
		ui.modulate = Color(1.3, 1.3, 1.3, 1.0)
	ui.burn.visible = cell.state == Cell.State.Burning
	ui.pinned.visible = cell.pinned
	ui.frozen.visible = cell.frozen

func clear():
	for n in outlines_root.get_children():
		n.queue_free()
		outlines_root.remove_child(n)
	for n in cells_root.get_children():
		n.queue_free()
		cells_root.remove_child(n)

func add_cell(c : Vector2i):
	var outline = outline_pb.instantiate()
	outline.position = get_pos(c)
	outlines_root.add_child(outline)
	
	var cell = cell_pb.instantiate()
	cell.position = get_pos(c)
	cells_root.add_child(cell)

func enter(tween : Tween = null, trans : bool = true):
	tilemap.clear()
	for y in Board.cy:
		for x in Board.cx:
			tilemap.set_cell(ui_coord(Vector2i(x, y)), 1, Vector2i(0, 0))
	var rect = tilemap.get_used_rect()
	panel.position = tilemap.map_to_local(rect.position) - Vector2(16, 16) - Vector2(8, 32)
	panel.size = tilemap.map_to_local(rect.end) - panel.position
	if Game.board_size % 2 == 0:
		panel.position.y += 16
	
	if trans:
		if !tween:
			tween = get_tree().create_tween()
		tween.tween_callback(func():
			self.scale = Vector2(1.0, 0.0)
			self.show()
		)
		tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.3).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUART)
	else:
		self.scale = Vector2(1.0, 1.0)
		self.show()
	return tween

func exit(tween : Tween = null, trans : bool = true):
	if trans:
		if !tween:
			tween = get_tree().create_tween()
		tween.tween_property(self, "scale", Vector2(1.0, 0.0), 0.3).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUART)
		tween.tween_callback(func():
			self.hide()
		)
	else:
		self.hide()
	return tween

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if Board && self.visible:
			var c = hover_coord()
			var cc = c + Vector2i(Board.cx / 2, Board.cy / 2) - central_coord
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
			var coord = extra["coord"]
			var g1 = payload as Gem
			if Game.swaps > 0:
				Game.swaps -= 1
				var g2 = Board.get_gem_at(coord)
				Hand.swap(coord, g1)
				Game.action_stack.append(Pair.new(coord, g2))
				Game.control_ui.undo_button.show()
				return true
			else:
				Game.control_ui.swaps_text.hint()
		return false
	)
