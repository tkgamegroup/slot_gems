extends Control

const reward_pb = preload("res://ui_reward.tscn")

@onready var panel : PanelContainer = $PanelContainer
@onready var reward_list : Control = $PanelContainer/VBoxContainer/HBoxContainer
@onready var buttons_list : Control = $PanelContainer/VBoxContainer/HBoxContainer2
@onready var hide_button : Button = $PanelContainer/VBoxContainer/HBoxContainer2/Button
@onready var reroll_button : Button = $PanelContainer/VBoxContainer/HBoxContainer2/Button2
@onready var skip_button : Button = $PanelContainer/VBoxContainer/HBoxContainer2/Button3

var callback : Callable

func choose(idx : int):
	SSound.se_click.play()
	App.screen_shake_strength = 8.0
	buttons_list.hide()
	var tween = App.game_tweens.create_tween()
	var n = reward_list.get_child_count()
	for i in n:
		if i != idx:
			var ui : Control = reward_list.get_child(i)
			ui.mouse_filter = Control.MOUSE_FILTER_IGNORE
			tween.parallel().tween_property(ui, "position", ui.position + Vector2(0, 1000), 0.2)
	var ui : Control = reward_list.get_child(idx)
	ui.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var img : Sprite2D = ui.icon_img
	tween.tween_callback(func():
		img.reparent(self)
	)
	tween.tween_property(ui, "modulate:a", 0, 0.2)
	tween.parallel().tween_property(img, "position", ui.get_rect().get_center(), 0.3)
	tween.tween_callback(func():
		img.queue_free()
		exit()
	)
	callback.call(idx, tween, img)

func enter(rewards : Array, _callback : Callable):
	callback = _callback
	
	self.self_modulate.a = 0.0
	self.show()
	panel.show()
	
	var tween = App.game_tweens.create_tween()
	tween.tween_property(self, "self_modulate:a", 1.0, 0.3)
	
	buttons_list.show()
	for n in reward_list.get_children():
		reward_list.remove_child(n)
		n.queue_free()
	for i in rewards.size():
		var r = rewards[i]
		var ui = reward_pb.instantiate()
		ui.setup(r)
		ui.gui_input.connect(func(event : InputEvent):
			if event is InputEventMouseButton:
				if event.pressed && event.button_index == MOUSE_BUTTON_LEFT:
					choose(i)
		)
		reward_list.add_child(ui)

func exit():
	panel.hide()
	self.self_modulate.a = 1.0
	var tween = App.game_tweens.create_tween()
	tween.tween_property(self, "self_modulate:a", 0.0, 0.3)
	tween.tween_callback(func():
		self.hide()
	)

func _ready() -> void:
	hide_button.pressed.connect(func():
		SSound.se_click.play()
		App.screen_shake_strength = 8.0
	)
	reroll_button.pressed.connect(func():
		SSound.se_click.play()
		App.screen_shake_strength = 8.0
	)
	skip_button.pressed.connect(func():
		SSound.se_click.play()
		App.screen_shake_strength = 8.0
	)
