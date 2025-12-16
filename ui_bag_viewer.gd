extends Control

@onready var panel : PanelContainer = $PanelContainer
@onready var title = $PanelContainer/VBoxContainer/Label
@onready var legend1 = $PanelContainer/VBoxContainer/HBoxContainer2/HBoxContainer
@onready var legend2 = $PanelContainer/VBoxContainer/HBoxContainer2/HBoxContainer2
@onready var gem_list = $PanelContainer/VBoxContainer/ScrollContainer/MarginContainer/VBoxContainer/List
@onready var item_list = $PanelContainer/VBoxContainer/ScrollContainer/MarginContainer/VBoxContainer/List2
@onready var comfirm_button = $PanelContainer/VBoxContainer/HBoxContainer/Button2
@onready var close_button = $PanelContainer/VBoxContainer/HBoxContainer/Button

const gem_ui = preload("res://ui_gem.tscn")

var selecteds = []
var select_num : int
var select_callback : Callable

func clear():
	for n in gem_list.get_children():
		gem_list.remove_child(n)
		n.queue_free()
	for n in item_list.get_children():
		item_list.remove_child(n)
		n.queue_free()

func create_bar():
	var bar = ColorRect.new()
	bar.size = Vector2(24, 4)
	bar.position = Vector2((C.SPRITE_SZ - bar.size.x) * 0.5, C.SPRITE_SZ)
	bar.color = Color(0.7, 0.7, 0.7, 1.0)
	bar.hide()
	return bar

func enter(select_category : String = "", _select_num : int = 0, select_prompt : String = "", _select_callback : Callable = Callable()):
	self.self_modulate.a = 0.0
	self.show()
	panel.show()
	
	var tween = App.create_tween()
	tween.tween_property(self, "self_modulate:a", 1.0, 0.3)
	
	if _select_num == 0:
		title.text = tr("ui_bag_viewer_title")
		legend1.show()
		legend2.hide()
		comfirm_button.hide()
	else:
		title.text = tr("ui_bag_viewer_title") + " " + select_prompt
		legend2.show()
		legend1.hide()
		comfirm_button.show()
		comfirm_button.text = "Comfirm(0)"
		comfirm_button.disabled = false
		select_num = _select_num
		select_callback = _select_callback
	for g in App.gems:
		var ctrl = Control.new()
		ctrl.custom_minimum_size = Vector2(C.SPRITE_SZ, C.SPRITE_SZ + 4)
		ctrl.mouse_entered.connect(func():
			SSound.se_select.play()
			STooltip.show(ctrl, 0, g.get_tooltip())
		)
		ctrl.mouse_exited.connect(func():
			STooltip.close()
		)
		var ui = gem_ui.instantiate()
		ui.update(g)
		ctrl.add_child(ui)
		var bar = create_bar()
		ctrl.add_child(bar)
		if _select_num > 0:
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
		else:
			if g.coord.x != -1 && g.coord.y != -1:
				bar.color = Color(0.9, 0.6, 0.3, 1.0)
				bar.show()
			elif g.coord.x != -1:
				bar.color = Color(0.5, 0.8, 0.6)
				bar.show()
		gem_list.add_child(ctrl)

func exit():
	panel.hide()
	clear()
	
	self.self_modulate.a = 1.0
	var tween = App.create_tween()
	tween.tween_property(self, "self_modulate:a", 0.0, 0.3)
	tween.tween_callback(func():
		self.hide()
	)

func _ready() -> void:
	close_button.pressed.connect(func():
		SSound.se_close_bag.play()
		exit()
	)
	comfirm_button.pressed.connect(func():
		SSound.se_click.play()
		App.screen_shake_strength = 8.0
		exit()
		select_callback.call(selecteds)
	)
