extends PanelContainer

const pattern_pb = preload("res://ui_pattern.tscn")

@onready var list : Control = $MarginContainer/VBoxContainer/PanelContainer/MarginContainer/List
@onready var number_text : Label = $MarginContainer/VBoxContainer/HBoxContainer/Label2

const item_w = 52
const item_h = 72
const gap = 16

var dragging : Control = null
var drag_pos : Vector2

var float_island = FloatIsland.new()

func release_dragging():
	if dragging:
		dragging.z_index = 0
		dragging = null

func add_ui(p : Pattern):
	var ui = pattern_pb.instantiate()
	ui.setup(p)
	list.add_child(ui)
	p.ui = ui
	var n = list.get_child_count()
	list.custom_minimum_size = Vector2(item_w, item_h * n + (n - 1) * gap)
	ui.gui_input.connect(func(event : InputEvent):
		if event is InputEventMouseButton:
			if event.pressed && event.button_index == MOUSE_BUTTON_LEFT:
				STooltip.close()
				dragging = ui
				drag_pos = event.position
				ui.z_index = 1
	)
	number_text.text = "(%d/%d)" % [list.get_child_count(), 4]

func clear():
	if list:
		for n in list.get_children():
			n.queue_free()
			list.remove_child(n)
		list.custom_minimum_size = Vector2(item_w, 0)
		number_text.text = "(%d/%d)" % [list.get_child_count(), 4]

func _ready() -> void:
	list.custom_minimum_size = Vector2(item_w, 0)
	
	float_island.setup(self, 2.0, 0.1, 0.2)

func _process(delta: float) -> void:
	var n = list.get_child_count()
	if n > 0:
		var y_off = 0
		for i in n:
			var ui = list.get_child(i)
			if ui != dragging:
				ui.position = lerp(ui.position, Vector2(0, y_off), 0.2)
			y_off += item_h + gap
		if dragging:
			var h = item_h * n + (n - 1) * gap
			var oidx = dragging.get_index()
			var nidx = -1
			var y = clamp(get_local_mouse_position().y - drag_pos.y, -20, h - item_h + 20) 
			dragging.position.y = y
			for i in n:
				var c = item_h * i + ((i - 1) * gap if i > 0 else 0) + item_h * 0.5
				if y >= c - 20.0 && y < c + 20.0:
					nidx = i
					break
			if nidx != -1 && nidx != oidx:
				var t = Game.patterns[oidx]
				Game.patterns[oidx] = Game.patterns[nidx]
				Game.patterns[nidx] = t
				list.move_child(dragging, nidx)
	
	float_island.update(delta)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.is_pressed():
			release_dragging()
		if event.is_released():
			if event.button_index == MOUSE_BUTTON_LEFT:
				release_dragging()
