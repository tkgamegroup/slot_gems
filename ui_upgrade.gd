extends Control

@export var panel : Control
@export var list : Control
@export var button : Button

var selected = null

func setup_item_listener(ui : Control):
	ui.gui_input.connect(func(event : InputEvent):
		if event is InputEventMouseButton:
			if event.pressed:
				if event.button_index == MOUSE_BUTTON_LEFT:
					for n in list.get_children():
						n.deselect()
					ui.select()
					selected = ui
	)

func clear():
	for n in list.get_children():
		list.remove_child(n)
		n.queue_free()

func enter():
	STooltip.close()
	
	self.show()
	panel.modulate.a = 0.0
	panel.show()
	button.disabled = true
	
	G.stage = G.Stage.Upgrade
	
	var tween = G.create_game_tween()
	tween.tween_property(panel, "modulate:a", 1.0, 0.3)
	
	tween.tween_interval(0.04)
	tween.tween_callback(func():
		var ui = G.shop_item_pb.instantiate()
		ui.setup("upgrade_board", null, 15, 1, true)
		list.add_child(ui)
		setup_item_listener(ui)
	)
	tween.tween_interval(0.04)
	tween.tween_callback(func():
		var ui = G.shop_item_pb.instantiate()
		ui.setup("increase_swaps", null, 5, 1, true)
		list.add_child(ui)
		setup_item_listener(ui)
	)
	tween.tween_interval(0.04)
	tween.tween_callback(func():
		var ui = G.shop_item_pb.instantiate()
		ui.setup("increase_hand_size", null, 0, 1, true)
		list.add_child(ui)
		setup_item_listener(ui)
	)
	tween.tween_interval(0.04)
	tween.tween_callback(func():
		var ui = G.shop_item_pb.instantiate()
		ui.setup("nothing", null, -2, 1, true)
		list.add_child(ui)
		setup_item_listener(ui)
	)
	tween.tween_interval(0.04)
	tween.tween_callback(func():
		G.save_to_file()
		button.disabled = false
	)

func exit(trans : bool = true):
	if trans:
		var tween = G.create_game_tween()
		tween.tween_callback(func():
			panel.hide()
			self.self_modulate.a = 1.0
		)
		tween.tween_property(self, "self_modulate:a", 0.0, 0.3)
		tween.tween_callback(func():
			self.hide()
		)
		if selected:
			if !selected.buy(tween):
				tween.kill()
				tween = null
		if tween:
			tween.tween_callback(func():
				clear()
			)
			Board.ui.exit(tween)
			G.shop_ui.enter(tween)
	else:
		clear()
		self.hide()

func load_from_data(data : Dictionary):
	clear()
	var list_data = data["upgrade_list"]
	for item in list_data:
		var ui = G.shop_item_pb.instantiate()
		var cate = item["cate"]
		if cate == "pattern":
			var object = item["object"]
			var p = Pattern.new()
			p.setup(object["name"])
			ui.setup("pattern", p, item["price"], 1, true)
		else:
			ui.setup(cate, null, item["price"], 1, true)
		setup_item_listener(ui)
		list.add_child(ui)

func save_to_data(data : Dictionary):
	var list_data = []
	for n in list.get_children():
		var ui = n as G.UiShopItem
		var item = {}
		item["cate"] = ui.cate
		if ui.cate == "pattern":
			var p = ui.object as Pattern
			var object = {}
			object["name"] = p.name
			item["object"] = object
		item["price"] = ui.price
		list_data.append(item)
	data["upgrade_list"] = list_data

func _ready() -> void:
	button.pressed.connect(func():
		SSound.se_click.play()
		
		exit()
	)
