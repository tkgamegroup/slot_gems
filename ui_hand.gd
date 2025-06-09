extends Control

const ui_slot = preload("res://ui_hand_slot.tscn")
const UiSlot = preload("res://ui_hand_slot.gd")

@onready var list = $Control
const item_w = 32
const gap = 8

var dragging : UiSlot = null

func release_dragging():
	if dragging:
		SSound.sfx_drop_item.play()
		dragging.z_index = 0
		dragging.action.hide()
		dragging = null

var disabled : bool = false:
	set(v):
		disabled = v
		if disabled:
			list.modulate = Color(0.7, 0.7, 0.7, 1.0)
			release_dragging()
		else:
			list.modulate = Color(1.0, 1.0, 1.0, 1.0)

func get_ui(idx : int) -> UiSlot:
	if idx >= 0 && idx < list.get_child_count():
		return list.get_child(idx)
	return null

func add_ui(gem : Gem):
	var ui = ui_slot.instantiate()
	ui.gem = gem
	gem.coord = Vector2i(list.get_child_count(), -1)
	if gem.bound_item:
		gem.bound_item.coord = Vector2i(list.get_child_count(), -1)
	list.add_child(ui)
	ui.gui_input.connect(func(event : InputEvent):
		if event is InputEventMouseButton:
			if event.pressed && event.button_index == MOUSE_BUTTON_LEFT:
				if !disabled:
					STooltip.close()
					SSound.sfx_drag_item.play()
					dragging = ui
					ui.z_index = 10
	)
	return ui

func end_pos():
	var n = list.get_child_count()
	if n == 0:
		return list.global_position
	return list.global_position + Vector2(item_w * n + gap * n, 0)

func place_item(ui : UiSlot, c : Vector2i):
	if Board.place_item(c, null): # TODO
		ui.queue_free()
		list.remove_child(ui)
		return true
	return false

func clear():
	for n in list.get_children():
		n.queue_free()
		list.remove_child(n)

func _ready() -> void:
	custom_minimum_size = Vector2(item_w * Game.max_hand_grabs + gap * (Game.max_hand_grabs - 1), 50)

func _process(delta: float) -> void:
	var n = list.get_child_count()
	if n == 0:
		return
	var w = item_w * n + gap * (n - 1)
	var x_off = 0
	for i in n:
		var ui = get_ui(i)
		if ui != dragging:
			var y = 0
			if ui.selected:
				y = -5
			ui.position = lerp(ui.position, Vector2(x_off, y), 0.2)
			x_off += item_w + gap
	if dragging:
		dragging.global_position = get_global_mouse_position() - Vector2(16, 16)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == MOUSE_BUTTON_RIGHT:
				release_dragging()
		if event.is_released():
			if event.button_index == MOUSE_BUTTON_LEFT:
				if dragging && !disabled:
					var on_board = false
					if Board:
						var c = Game.board_ui.hover_coord(true)
						if Board.is_valid(c):
							on_board = true
							SSound.sfx_drop_item.play()
							var gem = dragging.gem
							dragging.queue_free()
							list.remove_child(dragging)
							dragging = null
							Hand.swap(c, gem)
					if !on_board && dragging.action.visible: #trade
						Game.release_gem(dragging.gem)
						dragging.queue_free()
						dragging = null
						Hand.draw()
				release_dragging()
	elif event is InputEventMouseMotion:
		if dragging && !disabled && Board:
			var c = Game.board_ui.hover_coord(true)
			if Board.is_valid(c):
				var i = Board.get_item_at(c)
				if i && i.mountable == dragging.item.category:
					dragging.action.show()
				else:
					dragging.action.hide()
