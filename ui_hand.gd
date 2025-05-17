extends Control

const ui_slot = preload("res://ui_hand_slot.tscn")
const UiSlot = preload("res://ui_hand_slot.gd")

@onready var list = $Control

var dragging : UiSlot = null
var disabled : bool = false:
	set(v):
		disabled = v
		if disabled:
			list.modulate = Color(0.7, 0.7, 0.7, 1.0)
			release_dragging()
		else:
			list.modulate = Color(1.0, 1.0, 1.0, 1.0)

func is_empty():
	return list.get_child_count() == 0

func get_ui_count():
	return list.get_child_count()

func get_ui(idx : int) -> UiSlot:
	if idx >= 0 && idx < list.get_child_count():
		return list.get_child(idx)
	return null

func release_dragging():
	if dragging:
		SSound.sfx_drop_item.play()
		dragging.z_index = 0
		dragging.action.hide()
		dragging = null

func add_ui(item : Item):
	var ui = ui_slot.instantiate()
	ui.item = item
	item.coord = Vector2i(get_ui_count(), -1)
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

func draw():
	if Game.bag_items.is_empty():
		return null
	if get_ui_count() >= 8:
		return null
	var item : Item = Game.get_item()
	var ui = add_ui(item)
	ui.position.y = 50
	return ui

func discard(use_animation : bool = false):
	for n in list.get_children():
		Game.release_item(n.item)
		if use_animation:
			var tween = get_tree().create_tween()
			tween.tween_property(n, "position", n.position + Vector2(0, 100), 0.2)
			tween.tween_callback(func():
				n.queue_free()
				list.remove_child(n)
			)
		else:
			n.queue_free()
			list.remove_child(n)

func place_item(ui : UiSlot, c : Vector2i):
	if Board.place_item(c, ui.item):
		ui.queue_free()
		list.remove_child(ui)
		return true
	return false

func cleanup():
	discard()
	Game.bag_items.clear()
	for i in Game.items:
		Game.bag_items.append(i)

func _process(delta: float) -> void:
	var n = list.get_child_count()
	if n == 0:
		return
	var gap = 8
	var w = 32 * n + gap * (n - 1)
	var x_off = 0
	for i in n:
		var ui = get_ui(i)
		if ui != dragging:
			ui.position = lerp(ui.position, Vector2(x_off, 0.0), 0.2)
			x_off += 32 + gap
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
							if place_item(dragging, c):
								SSound.sfx_drop_item.play()
								dragging = null
					if !on_board && dragging.action.visible:
						Game.release_item(dragging.item)
						dragging.queue_free()
						dragging = null
						draw()
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
