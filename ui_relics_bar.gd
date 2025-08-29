extends PanelContainer

@onready var list : Control = $MarginContainer/VBoxContainer/PanelContainer/MarginContainer/List
@onready var number_text : Label = $MarginContainer/VBoxContainer/HBoxContainer/Label2

const relic_pb = preload("res://ui_relic.tscn")
const ctx_menu_pb = preload("res://ui_context_menu.tscn")
const item_w = 104
const item_h = 64
const gap = 8

var dragging : Control = null
var drag_pos : Vector2

var float_island = FloatIsland.new()

func release_dragging():
	if dragging:
		dragging.z_index = 0
		dragging = null

func add_ui(r : Relic):
	var ui = relic_pb.instantiate()
	ui.setup(r)
	list.add_child(ui)
	r.ui = ui
	var n = list.get_child_count()
	list.custom_minimum_size = Vector2(item_w, item_h * n + (n - 1) * gap)
	ui.gui_input.connect(func(event : InputEvent):
		if event is InputEventMouseButton:
			if event.pressed:
				if event.button_index == MOUSE_BUTTON_LEFT:
					STooltip.close()
					dragging = ui
					drag_pos = event.position
					ui.z_index = 1
				elif event.button_index == MOUSE_BUTTON_RIGHT:
					var menu = ctx_menu_pb.instantiate()
					menu.open(event.global_position, int(r.price / 2))
					Game.root_ui.add_child(menu)
					menu.on_sell.connect(func():
						Game.coins += menu.sell_price
						Game.remove_relic(r)
					)
	)
	number_text.text = "(%d/%d)" % [list.get_child_count(), Game.MaxRelics]

func remove_ui(r : Relic):
	list.remove_child(r.ui)
	r.ui.queue_free()

func clear():
	if list:
		for n in list.get_children():
			n.queue_free()
			list.remove_child(n)
		list.custom_minimum_size = Vector2(item_w, 0)
		number_text.text = "(%d/%d)" % [list.get_child_count(), Game.MaxRelics]

func get_pos(idx : int):
	if idx == -1:
		idx = list.get_child_count()
	return list.global_position + Vector2(0, (item_h + gap) * idx)

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
				ui.position = lerp(ui.position, Vector2(20, y_off), 0.2)
			y_off += item_h + gap
		if dragging:
			var h = item_h * n + (n - 1) * gap
			var oidx = dragging.get_index()
			var nidx = -1
			var y = clamp(list.get_local_mouse_position().y - drag_pos.y, -20, h - item_h + 20)
			dragging.position.y = y
			for i in n:
				var c = item_h * i + ((i - 1) * gap if i > 0 else 0) + item_h * 0.5
				if y >= c - item_h * 0.5 && y < c + item_h * 0.5:
					nidx = i
					break
			if nidx != -1 && nidx != oidx:
				var t = Game.relics[oidx]
				Game.relics[oidx] = Game.relics[nidx]
				Game.relics[nidx] = t
				list.move_child(dragging, nidx)
	
	float_island.update(delta)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.is_pressed():
			release_dragging()
		if event.is_released():
			if event.button_index == MOUSE_BUTTON_LEFT:
				release_dragging()
