extends Control

const ui_slot = preload("res://ui_hand_slot.tscn")
const UiSlot = preload("res://ui_hand_slot.gd")

var dragging : UiSlot = null
var disabled : bool = false:
	set(v):
		disabled = v
		if disabled:
			modulate = Color(0.7, 0.7, 0.7, 1.0)
			release_dragging()
		else:
			modulate = Color(1.0, 1.0, 1.0, 1.0)

signal rolling_finished

func is_empty():
	return get_child_count() == 0

func get_item_count():
	return get_child_count()

func get_item(idx : int) -> UiSlot:
	if idx >= 0 && idx < get_child_count():
		return get_child(idx)
	return null

func release_dragging():
	if dragging:
		dragging.z_index = 0
		dragging.trade.hide()
		dragging = null

func draw():
	if Game.unused_items.is_empty():
		return
	var item : Item = Game.get_item()
	var ui = ui_slot.instantiate()
	ui.item = item
	item.coord = Vector2i(get_item_count(), -1)
	self.add_child(ui)
	ui.gui_input.connect(func(event : InputEvent):
		if event is InputEventMouseButton:
			if event.pressed && event.button_index == MOUSE_BUTTON_LEFT:
				if !disabled:
					STooltip.close()
					dragging = ui
					ui.z_index = 10
	)
	return ui

func discard(use_animation : bool = false):
	for n in get_children():
		Game.release_item(n.item)
		if use_animation:
			var tween = get_tree().create_tween()
			tween.tween_property(n, "position", n.position + Vector2(0, 100), 0.2)
			tween.tween_callback(n.queue_free)
		else:
			n.queue_free()
			remove_child(n)

func use_item(ui : UiSlot, c : Vector2i):
	if Game.board.is_valid(c):
		var g = Game.board.get_gem_at(c)
		var i = Game.board.get_item_at(c)
		if g && (!i || ui.item.on_quick.is_valid()):
			Game.board.set_item_at(c, ui.item, Board.PlaceReason.FromHand)
			ui.queue_free()
			return true
	return false

func roll():
	discard(true)
	var tween = get_tree().create_tween()
	for i in min(8, Game.unused_items.size()):
		tween.tween_interval(0.15)
		tween.tween_callback(func():
			var ui = draw()
			if ui:
				ui.position.y = 50
		)
	tween.tween_callback(func():
		rolling_finished.emit()
	)

func cleanup():
	discard()
	Game.unused_items.clear()
	for i in Game.items:
		Game.unused_items.append(i)

func setup():
	cleanup()
	
	disabled = true

func _process(delta: float) -> void:
	var n = get_child_count()
	if n == 0:
		return
	var gap = 8
	var w = 32 * n + gap * (n - 1)
	var x_off = 0
	for i in n:
		var ui = get_item(i)
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
					if dragging.trade.visible:
						Game.release_item(dragging.item)
						dragging.queue_free()
						dragging = null
						draw()
					elif Game.board:
						var c = Game.tilemap.local_to_map(Game.tilemap.get_local_mouse_position())
						c -= Game.board.central_coord - Vector2i(Game.board.cx / 2, Game.board.cy / 2)
						if use_item(dragging, c):
							dragging = null
				release_dragging()
