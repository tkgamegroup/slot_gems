extends Node

const Ui = preload("res://ui_tooltips.gd")
const constellation_pb = preload("res://ui_constellation.tscn")
const tooltip_pb = preload("res://tooltip.tscn")

var ui : Ui = null

var showing : bool = false
var alpha : float = 0.0
var node = null
var dir : int = 0

func reset():
	for n in ui.absoulte.get_children():
		ui.absoulte.remove_child(n)
		n.queue_free()
	for n in ui.list1.get_children():
		ui.list1.remove_child(n)
		n.queue_free()
	for n in ui.list2.get_children():
		ui.list2.remove_child(n)
		n.queue_free()
	ui.show_more.hide()
	ui.list2.hide()

func show(_node, _dir : int, contents : Array[Pair]):
	showing = true
	node = _node
	dir = _dir
	
	reset()
	
	var words = []
	var referenced_gems = []
	var referenced_constellations = []
	for c in contents:
		var item = tooltip_pb.instantiate()
		item.title = SUtils.format_text(c.first, false, false, words, referenced_gems, referenced_constellations)
		item.content = SUtils.format_text(c.second, true, false, words, referenced_gems, referenced_constellations)
		ui.list1.add_child(item)
	for n in referenced_gems:
		var g = Gem.new()
		g.setup(n)
		for c in g.get_tooltip():
			var item = tooltip_pb.instantiate()
			item.title = SUtils.format_text(c.first, false, false, words)
			item.content = SUtils.format_text(c.second, true, false, words)
			ui.list1.add_child(item)
	for n in referenced_constellations:
		var const_pb = constellation_pb.instantiate()
		const_pb.setup(n)
		ui.absoulte.add_child(const_pb)
	for w in words:
		var msg = w + "_desc"
		var desc = tr(msg)
		if desc != msg:
			var item = tooltip_pb.instantiate()
			item.title = w
			item.content = desc
			ui.list2.add_child(item)
			ui.show_more.show()

func close():
	showing = false
	node = null

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.keycode == KEY_ALT:
			if event.is_pressed():
				ui.list2.show()
			elif event.is_released():
				ui.list2.hide()
				ui.size_flags_changed.emit()
		if event.is_pressed():
			if event.keycode == KEY_UP:
				ui.panel.scroll_vertical -= 40
			elif event.keycode == KEY_DOWN:
				ui.panel.scroll_vertical += 40
	elif event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				ui.panel.scroll_vertical -= 40
			elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				ui.panel.scroll_vertical += 40

func _process(delta: float) -> void:
	if showing:
		ui.panel.size = ui.container.size.min(Vector2(400, 450))
		if node:
			var rect : Rect2 = node.get_global_rect()
			match dir:
				0: 
					ui.offset.position = Vector2(rect.end.x + 20, rect.position.y)
				1: 
					ui.offset.position = Vector2(rect.end.x + 20, rect.end.y)
				2: 
					ui.offset.position = Vector2(rect.position.x - 20, rect.end.y)
				3: 
					ui.offset.position = Vector2(rect.position.x - 20, rect.position.y)
	
		match dir:
			0: 
				ui.panel.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT, Control.PRESET_MODE_KEEP_SIZE)
			1: 
				ui.panel.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_LEFT, Control.PRESET_MODE_KEEP_SIZE)
			2: 
				ui.panel.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT, Control.PRESET_MODE_KEEP_SIZE)
			3: 
				ui.panel.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT, Control.PRESET_MODE_KEEP_SIZE)
		if alpha < 1.0:
			alpha += delta * 10.0
			alpha = min(1.0, alpha)
			ui.panel.modulate.a = alpha
	else:
		if alpha > 0.0:
			alpha -= delta * 10.0
			alpha = max(0.0, alpha)
			ui.panel.modulate.a = alpha
			if alpha == 0.0:
				reset()
