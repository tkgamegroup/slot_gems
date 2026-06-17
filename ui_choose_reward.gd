extends Control

@export var panel : PanelContainer
@export var reward_list : Control
@export var buttons_list : Control
@export var hide_button : Button
@export var reroll_button : Button
@export var skip_button : Button

var rewards : Array
var callback : Callable

func choose(idx : int):
	SSound.se_click.play()
	G.screen_shake_strength = 8.0
	buttons_list.hide()
	callback.call(rewards, idx)
	callback = Callable()
	exit()

func enter(_rewards : Array, _callback : Callable, tween : Tween = null):
	rewards = _rewards
	callback = _callback
	
	self.self_modulate.a = 0.0
	
	for n in reward_list.get_children():
		reward_list.remove_child(n)
		n.queue_free()
	for i in rewards.size():
		var r = rewards[i]
		var ui = G.reward_pb.instantiate()
		ui.setup(r.cate, r.object, r.quantity)
		ui.gui_input.connect(func(event : InputEvent):
			if event is InputEventMouseButton:
				if event.pressed && event.button_index == MOUSE_BUTTON_LEFT:
					choose(i)
		)
		reward_list.add_child(ui)
	
	if !tween:
		tween = G.create_game_tween()
	tween.tween_callback(func():
		self.show()
		panel.show()
		buttons_list.show()
	)
	tween.tween_property(self, "self_modulate:a", 1.0, 0.3)

func exit(tween : Tween = null):
	panel.hide()
	self.self_modulate.a = 1.0
	if !tween:
		tween = G.create_game_tween()
	tween.tween_property(self, "self_modulate:a", 0.0, 0.3)
	tween.tween_callback(func():
		self.hide()
	)

func _ready() -> void:
	hide_button.pressed.connect(func():
		SSound.se_click.play()
		G.screen_shake_strength = 8.0
	)
	reroll_button.pressed.connect(func():
		SSound.se_click.play()
		G.screen_shake_strength = 8.0
	)
	skip_button.pressed.connect(func():
		SSound.se_click.play()
		G.screen_shake_strength = 8.0
	)
