extends Control

const shop_item_pb = preload("res://ui_shop_item.tscn")

@onready var panel : Control = $PanelContainer
@onready var list : Control = $PanelContainer/VBoxContainer/HBoxContainer
@onready var button : Button = $PanelContainer/VBoxContainer/Button

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
	
	var tween = G.game_tweens.create_tween()
	tween.tween_property(panel, "modulate:a", 1.0, 0.3)
	
	tween.tween_interval(0.04)
	tween.tween_callback(func():
		var ui = shop_item_pb.instantiate()
		ui.setup("upgrade_board", null, 15, 1, true)
		list.add_child(ui)
		setup_item_listener(ui)
	)
	tween.tween_interval(0.04)
	tween.tween_callback(func():
		var ui = shop_item_pb.instantiate()
		ui.setup("increase_swaps", null, 5, 1, true)
		list.add_child(ui)
		setup_item_listener(ui)
	)
	tween.tween_interval(0.04)
	tween.tween_callback(func():
		var ui = shop_item_pb.instantiate()
		ui.setup("increase_hand_size", null, 0, 1, true)
		list.add_child(ui)
		setup_item_listener(ui)
	)
	tween.tween_interval(0.04)
	tween.tween_callback(func():
		var ui = shop_item_pb.instantiate()
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
		var tween = G.game_tweens.create_tween()
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

func _ready() -> void:
	button.pressed.connect(func():
		SSound.se_click.play()
		
		exit()
	)
