extends Control

const slot_ui = preload("res://ui_hand_slot.tscn")
const UiSlot = preload("res://ui_hand_slot.gd")

@onready var list = $Control
const item_w = 48
const item_h = 48
const gap = 8

var disabled : bool = false:
	set(v):
		disabled = v
		if disabled:
			list.modulate = Color(0.7, 0.7, 0.7, 1.0)
		else:
			list.modulate = Color(1.0, 1.0, 1.0, 1.0)

func get_slot(idx : int) -> UiSlot:
	if idx >= 0 && idx < list.get_child_count():
		return list.get_child(idx)
	return null

func add_slot(gem : Gem, idx : int = -1) -> UiSlot:
	if idx == -1:
		idx = list.get_child_count()
	var ui = slot_ui.instantiate()
	ui.gem = gem
	list.add_child(ui)
	list.move_child(ui, idx)
	ui.gui_input.connect(func(event : InputEvent):
		if event is InputEventMouseButton:
			if event.pressed && event.button_index == MOUSE_BUTTON_LEFT:
				if !disabled:
					STooltip.close()
					SSound.se_drag_item.play()
					ui.rotation_degrees = 0.0
					Drag.start("gem", ui, ui, func(target, extra):
						if target && target != Board.ui:
							Hand.erase(ui.get_index(), false)
					)
	)
	return ui

func remove_slot(idx : int):
	var n = list.get_child(idx)
	n.queue_free()
	list.remove_child(n)

func get_pos(idx : int):
	return list.global_position + Vector2((item_w + gap) * idx + item_w * 0.5, item_h * 0.5)

'''
func place_item(ui : UiSlot, c : Vector2i):
	if Board.place_item(c, null): # TODO
		ui.queue_free()
		list.remove_child(ui)
		return true
	return false
'''

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
	var x_off = 0
	var drag_idx = -1
	var drag_on_hand = false
	if Drag.ui && Drag.ui.get_parent() == list:
		drag_idx = Drag.ui.get_index()
	var rect : Rect2 = list.get_global_rect()
	var mpos = get_global_mouse_position()
	if drag_idx != -1:
		if rect.has_point(mpos):
			drag_on_hand = true
	var tt = Time.get_ticks_usec() / 60000.0
	for i in n:
		var ui = get_slot(i)
		if ui != Drag.ui && ui.elastic > 0.0:
			var y = pow(sin(x_off * 0.03 + tt / 9.0), 2.0) * 3.0
			if ui.get_global_rect().has_point(mpos):
				y -= 5
			ui.position = lerp(ui.position, Vector2(x_off, y), 0.2 * ui.elastic)
			ui.rotation_degrees = (sin(x_off * 0.05 + tt / 20.0)) * 3.0
		if !(i == drag_idx && !drag_on_hand):
			x_off += item_w + gap
	if drag_on_hand:
		var x = Drag.ui.get_rect().get_center().x
		var new_idx = -1
		for i in n:
			var c = item_w * i + ((i - 1) * gap if i > 0 else 0) + item_w * 0.5
			if x >= c - item_w * 0.5 && x < c + item_w * 0.5:
				new_idx = i
				break
		if new_idx != -1 && new_idx != drag_idx:
			var g1 = Hand.grabs[drag_idx]
			var g2 = Hand.grabs[new_idx]
			Hand.grabs[drag_idx] = g2
			Hand.grabs[new_idx] = g1
			g1.coord.x = new_idx
			g2.coord.x = drag_idx
			list.move_child(Drag.ui, new_idx)
