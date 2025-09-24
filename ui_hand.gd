extends Control

const slot_ui = preload("res://ui_hand_slot.tscn")
const UiSlot = preload("res://ui_hand_slot.gd")
const gem_ui = preload("res://ui_gem.tscn")
const trail_pb = preload("res://trail.tscn")

@onready var list = $Control
const item_w = 32
const item_h = 32
const gap = 4

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

func add_ui(gem : Gem, idx : int = -1):
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
					Drag.start("gem", ui.gem, ui, func(target):
						SSound.se_drop_item.play()
						if target:
							Hand.erase(ui.get_index(), false)
					)
	)
	return ui

func remove_ui(idx : int):
	var n = list.get_child(idx)
	n.queue_free()
	list.remove_child(n)

func fly_gem_from(gem : Gem, pos):
	var ui = gem_ui.instantiate()
	ui.update(gem)
	ui.global_position = pos
	var trail = trail_pb.instantiate()
	trail.setup(10.0, Gem.type_color(gem.type))
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

func get_pos(idx : int):
	return list.global_position + Vector2((item_w + gap) * idx + item_w * 0.5, item_h * 0.5)

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
	var drag_idx = -1
	var drag_on_hand = false
	if Drag.ui && Drag.ui.get_parent() == list:
		drag_idx = Drag.ui.get_index()
	var rect : Rect2 = list.get_global_rect()
	var mpos = get_global_mouse_position()
	if drag_idx != -1:
		if rect.has_point(mpos):
			drag_on_hand = true
	for i in n:
		var ui = get_ui(i)
		if ui != Drag.ui:
			ui.position = lerp(ui.position, Vector2(x_off, 0), 0.2)
		if !(i == drag_idx && !drag_on_hand):
			x_off += item_w + gap
	if drag_on_hand:
		var x = Drag.ui.get_rect().get_center().x
		var nidx = -1
		for i in n:
			var c = item_w * i + ((i - 1) * gap if i > 0 else 0) + item_w * 0.5
			if x >= c - item_w * 0.5 && x < c + item_w * 0.5:
				nidx = i
				break
		if nidx != -1 && nidx != drag_idx:
			var g1 = Hand.grabs[drag_idx]
			var g2 = Hand.grabs[nidx]
			Hand.grabs[drag_idx] = g2
			Hand.grabs[nidx] = g1
			g1.coord.x = nidx
			if g1.bound_item:
				g1.bound_item.coord.x = nidx
			g2.coord.x = drag_idx
			if g2.bound_item:
				g2.bound_item.coord.x = drag_idx
			list.move_child(Drag.ui, nidx)
