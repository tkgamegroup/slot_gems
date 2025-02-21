extends Control

const reward_pb = preload("res://ui_reward.tscn")

@onready var reward_list : Control = $VBoxContainer/HBoxContainer
@onready var buttons_list : Control = $VBoxContainer/HBoxContainer2
@onready var hide_button : Button = $VBoxContainer/HBoxContainer2/Button
@onready var reroll_button : Button = $VBoxContainer/HBoxContainer2/Button2
@onready var skip_button : Button = $VBoxContainer/HBoxContainer2/Button3

var callback : Callable

func choose(idx : int):
	Sounds.sfx_click.play()
	buttons_list.hide()
	var tween = Game.get_tree().create_tween()
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
	callback.call(idx, tween, img)
	callback = Callable.create(null, "")
	tween.tween_callback(img.queue_free)
	tween.tween_callback(func():
		exit()
	)

func enter(rewards : Array, _callback : Callable):
	callback = _callback
	Game.blocker_ui.enter()
	self.show()
	buttons_list.show()
	for n in reward_list.get_children():
		n.queue_free()
		reward_list.remove_child(n)
	for i in rewards.size():
		var r = rewards[i]
		var ui = reward_pb.instantiate()
		ui.setup(r)
		ui.gui_input.connect(func(event : InputEvent):
			if event is InputEventMouseButton:
				if event.pressed:
					choose(i)
		)
		reward_list.add_child(ui)

func exit():
	Game.blocker_ui.exit()
	self.hide()

func _ready() -> void:
	hide_button.pressed.connect(func():
		Sounds.sfx_click.play()
	)
	reroll_button.pressed.connect(func():
		Sounds.sfx_click.play()
	)
	skip_button.pressed.connect(func():
		Sounds.sfx_click.play()
	)
