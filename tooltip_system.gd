extends Node

@onready var ui : Control = $/root/Main/SubViewportContainer/SubViewport/Canvas/Tooltips
@onready var panel : Control = $/root/Main/SubViewportContainer/SubViewport/Canvas/Tooltips/ScorllContainer
@onready var container : Control = $/root/Main/SubViewportContainer/SubViewport/Canvas/Tooltips/ScorllContainer/MarginContainer
@onready var list1 : Control = $/root/Main/SubViewportContainer/SubViewport/Canvas/Tooltips/ScorllContainer/MarginContainer/HBoxContainer/VBoxContainer
@onready var list2 : Control = $/root/Main/SubViewportContainer/SubViewport/Canvas/Tooltips/ScorllContainer/MarginContainer/HBoxContainer/VBoxContainer2
@onready var ui_show_more : Control = $/root/Main/SubViewportContainer/SubViewport/Canvas/Tooltips/ScorllContainer/MarginContainer/HBoxContainer/VBoxContainer/MarginContainer

const Tooltip = preload("res://tooltip.gd")
const tooltip_pb = preload("res://tooltip.tscn")

var showing : bool = false
var alpha : float = 0.0
var node = null
var dir : int = 0

func reset():
	for n in list1.get_children():
		if n != ui_show_more:
			list1.remove_child(n)
			n.queue_free()
	for n in list2.get_children():
		list2.remove_child(n)
		n.queue_free()
	ui_show_more.hide()
	list2.hide()

func show(_node, _dir : int, contents : Array[Pair]):
	showing = true
	node = _node
	dir = _dir
	
	for n in list1.get_children():
		if n != ui_show_more:
			list1.remove_child(n)
			n.queue_free()
	for n in list2.get_children():
		list2.remove_child(n)
		n.queue_free()
	ui_show_more.hide()
	list2.hide()
	
	var words = []
	var used_gems = []
	for c in contents:
		var ui = tooltip_pb.instantiate()
		ui.title = SUtils.format_text(c.first, false, false, words, used_gems)
		ui.content = SUtils.format_text(c.second, true, false, words, used_gems)
		list1.add_child(ui)
	for n in used_gems:
		var g = Gem.new()
		g.setup(n)
		for c in g.get_tooltip():
			var ui = tooltip_pb.instantiate()
			ui.title = SUtils.format_text(c.first, false, false, words)
			ui.content = SUtils.format_text(c.second, true, false, words)
			list1.add_child(ui)
	for w in words:
		var msg = w + "_desc"
		var desc = tr(msg)
		if desc != msg:
			var ui = tooltip_pb.instantiate()
			ui.title = w
			ui.content = desc
			list2.add_child(ui)
			ui_show_more.show()
	list1.move_child(ui_show_more, list1.get_child_count() - 1)

func close():
	showing = false
	node = null

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.keycode == KEY_ALT:
			if event.is_pressed():
				list2.show()
			elif event.is_released():
				list2.hide()
				ui.size_flags_changed.emit()
		if event.is_pressed():
			if event.keycode == KEY_UP:
				panel.scroll_vertical -= 40
			elif event.keycode == KEY_DOWN:
				panel.scroll_vertical += 40
	elif event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				panel.scroll_vertical -= 40
			elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				panel.scroll_vertical += 40

func _process(delta: float) -> void:
	if showing:
		panel.size = container.size.min(Vector2(400, 450))
		if node:
			var rect : Rect2 = node.get_global_rect()
			match dir:
				0: 
					ui.position = Vector2(rect.end.x + 20, rect.position.y)
				1: 
					ui.position = Vector2(rect.end.x + 20, rect.end.y)
				2: 
					ui.position = Vector2(rect.position.x - 20, rect.end.y)
				3: 
					ui.position = Vector2(rect.position.x - 20, rect.position.y)
	
		match dir:
			0: 
				panel.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT, Control.PRESET_MODE_KEEP_SIZE)
			1: 
				panel.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_LEFT, Control.PRESET_MODE_KEEP_SIZE)
			2: 
				panel.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT, Control.PRESET_MODE_KEEP_SIZE)
			3: 
				panel.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT, Control.PRESET_MODE_KEEP_SIZE)
		if alpha < 1.0:
			alpha += delta * 10.0
			alpha = min(1.0, alpha)
			panel.modulate.a = alpha
	else:
		if alpha > 0.0:
			alpha -= delta * 10.0
			alpha = max(0.0, alpha)
			panel.modulate.a = alpha
			if alpha == 0.0:
				reset()
