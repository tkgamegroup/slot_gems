extends Control

const slot_ui = preload("res://ui_hand_slot.tscn")
const UiSlot = preload("res://ui_hand_slot.gd")
const gem_ui = preload("res://ui_gem.tscn")
const trail_pb = preload("res://trail.tscn")

@onready var list = $Control
const item_w = 32
const gap = 8

var disabled : bool = false:
	set(v):
		disabled = v
		if disabled:
			list.modulate = Color(0.7, 0.7, 0.7, 1.0)
		else:
			list.modulate = Color(1.0, 1.0, 1.0, 1.0)

func get_ui(idx : int) -> UiSlot:
	if idx >= 0 && idx < list.get_child_count():
		return list.get_child(idx)
	return null

func add_ui(gem : Gem):
	var ui = slot_ui.instantiate()
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
					Drag.start("gem", ui.gem, ui, func(target):
						SSound.sfx_drop_item.play()
						if target:
							ui.queue_free()
					)
	)
	return ui

func fly_gem_from(gem : Gem, pos):
	var ui = gem_ui.instantiate()
	ui.set_image(gem.type, gem.rune, gem.bound_item.image_id if gem.bound_item else 0)
	ui.global_position = pos
	var trail = trail_pb.instantiate()
	ui.add_child(trail)
	Game.game_ui.add_child(ui)
	var tween = get_tree().create_tween()
	var final_pos = end_pos()
	tween.tween_property(ui, "global_position", final_pos, 0.3)
	tween.tween_callback(func():
		ui.queue_free()
		var slot = add_ui(gem)
		slot.position = final_pos - list.global_position
	)
	return tween

func end_pos():
	return list.global_position + Vector2((item_w + gap) * list.get_child_count(), 0)

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
	var n = max(Game.max_hand_grabs, 5)
	custom_minimum_size = Vector2(item_w * n + gap * (n - 1), 50)

func _process(delta: float) -> void:
	var n = list.get_child_count()
	if n == 0:
		return
	var w = item_w * n + gap * (n - 1)
	var x_off = 0
	for i in n:
		var ui = get_ui(i)
		if ui != Drag.ui:
			var y = 0
			if ui.selected:
				y = -5
			ui.position = lerp(ui.position, Vector2(x_off, y), 0.2)
			x_off += item_w + gap
