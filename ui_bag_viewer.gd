extends Control

@onready var title = $VBoxContainer/Label
@onready var gem_list = $VBoxContainer/ScrollContainer/VBoxContainer/List
@onready var item_list = $VBoxContainer/ScrollContainer/VBoxContainer/List2
@onready var comfirm_button = $VBoxContainer/HBoxContainer/Button2
@onready var close_button = $VBoxContainer/HBoxContainer/Button

const gem_ui = preload("res://ui_gem.tscn")

var selecteds = []
var select_num : int
var select_callback : Callable

func clear():
	for n in gem_list.get_children():
		n.queue_free()
		gem_list.remove_child(n)
	for n in item_list.get_children():
		n.queue_free()
		item_list.remove_child(n)

func enter(_select_num : int = 0, select_prompt : String = "", _select_callback : Callable = Callable()):
	clear()
	Game.blocker_ui.enter()
	self.show()
	if _select_num == 0:
		title.text = "Bag"
		comfirm_button.hide()
	else:
		title.text = "Bag (%s)" % select_prompt
		comfirm_button.show()
		comfirm_button.text = "Comfirm(0)"
		comfirm_button.disabled = false
		select_num = _select_num
		select_callback = _select_callback
	for g in Game.gems:
		var ctrl = Control.new()
		ctrl.custom_minimum_size = Vector2(32, 34)
		ctrl.mouse_entered.connect(func():
			SSound.sfx_select.play()
			STooltip.show(g.get_tooltip())
		)
		ctrl.mouse_exited.connect(func():
			STooltip.close()
		)
		var ui = gem_ui.instantiate()
		ui.position = Vector2(16, 16)
		ui.set_image(g.type, g.rune)
		ctrl.add_child(ui)
		if _select_num > 0:
			var bar = ColorRect.new()
			bar.position = Vector2(12, 32)
			bar.size = Vector2(8, 2)
			bar.color = Color(0.7, 0.7, 0.7, 1.0)
			bar.hide()
			ctrl.add_child(bar)
			ctrl.gui_input.connect(func(event : InputEvent):
				if event is InputEventMouseButton:
					if event.pressed && event.button_index == MOUSE_BUTTON_LEFT:
						if bar.visible:
							bar.visible = false
							selecteds.erase(g)
						elif selecteds.size() < select_num:
							bar.visible = true
							selecteds.append(g)
						comfirm_button.text = "Comfirm(%d)" % selecteds.size()
						comfirm_button.disabled = selecteds.is_empty()
			)
		gem_list.add_child(ctrl)
	for i in Game.items:
		var ctrl = Control.new()
		ctrl.custom_minimum_size = Vector2(32, 34)
		ctrl.mouse_entered.connect(func():
			SSound.sfx_select.play()
			STooltip.show(i.get_tooltip())
		)
		ctrl.mouse_exited.connect(func():
			STooltip.close()
		)
		var ui = AnimatedSprite2D.new()
		ui.position = Vector2(16, 16)
		ui.sprite_frames = Item.item_frames
		ui.frame = i.image_id
		ctrl.add_child(ui)
		item_list.add_child(ctrl)

func exit():
	Game.blocker_ui.exit()
	self.hide()

func _ready() -> void:
	close_button.pressed.connect(func():
		SSound.sfx_click.play()
		exit()
	)
	comfirm_button.pressed.connect(func():
		SSound.sfx_click.play()
		exit()
		select_callback.call(selecteds)
	)
