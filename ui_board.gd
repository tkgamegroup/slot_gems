extends Node2D

var central_coord = Vector2i(26, 11)

const cell_pb = preload("res://ui_cell.tscn")
const outline_pb = preload("res://ui_outline.tscn")

@onready var panel : Panel = $Panel
@onready var tilemap : TileMapLayer = $TileMapLayer
@onready var outlines_root : Node2D = $Outlines
@onready var underlay : Node2D = $Underlay
@onready var cells_root : Node2D = $Cells
@onready var overlay : Node2D = $Overlay
@onready var hover_ui : Sprite2D = $Hover
@onready var drag_ui : AnimatedSprite2D = $Drag

signal drag_dropped
var dragging_cell : Vector2i

func game_coord(c : Vector2i):
	return c + Vector2i(Board.cx / 2, Board.cy / 2) - central_coord

func ui_coord(c : Vector2i):
	return c - Vector2i(Board.cx / 2, Board.cy / 2) + central_coord

func hover_coord(to_game_coord : bool = false):
	var c = tilemap.local_to_map(tilemap.get_local_mouse_position()) 
	if to_game_coord:
		c = game_coord(c)
	return c

func start_drag(c : Vector2i):
	dragging_cell = c
	drag_ui.frame = Board.get_gem_at(c).type
	drag_ui.position = tilemap.get_local_mouse_position()
	drag_ui.show()

func release_dragging():
	dragging_cell = Vector2i(-1, -1)
	drag_ui.hide()

func get_pos(c : Vector2i):
	return tilemap.map_to_local(c)

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

func enter():
	self.show()
	for y in Board.cy:
		for x in Board.cx:
			tilemap.set_cell(ui_coord(Vector2i(x, y)), 1, Vector2i(0, 0))
	var rect = tilemap.get_used_rect()
	panel.position = tilemap.map_to_local(rect.position) - Vector2(16, 16) - Vector2(8, 32)
	panel.size = tilemap.map_to_local(rect.end) - panel.position

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == MOUSE_BUTTON_RIGHT:
				release_dragging()
		if event.is_released():
			if event.button_index == MOUSE_BUTTON_LEFT:
				if Board:
					if dragging_cell.x != -1 && dragging_cell.y != -1:
						var c = hover_coord()
						c = c + Vector2i(Board.cx / 2, Board.cy / 2) - central_coord
						if (dragging_cell.x != c.x || dragging_cell.y != c.y):
							drag_dropped.emit(dragging_cell, c)
				release_dragging()
	elif event is InputEventMouseMotion:
		if Board && self.visible:
			var c = hover_coord()
			var cc = c + Vector2i(Board.cx / 2, Board.cy / 2) - central_coord
			if Board.is_valid(cc):
				hover_ui.show()
				hover_ui.position = get_pos(c)
			else:
				hover_ui.hide()
			if drag_ui.visible:
				drag_ui.position = event.position

var float_island = FloatIsland.new()

func _process(delta: float) -> void:
	float_island.update(cells_root, 2.0, delta)
