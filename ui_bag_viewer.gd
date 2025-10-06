extends Control

@onready var panel : PanelContainer = $PanelContainer
@onready var title = $PanelContainer/VBoxContainer/Label
@onready var legend1 = $PanelContainer/VBoxContainer/HBoxContainer2/HBoxContainer
@onready var legend2 = $PanelContainer/VBoxContainer/HBoxContainer2/HBoxContainer2
@onready var gem_list = $PanelContainer/VBoxContainer/ScrollContainer/VBoxContainer/List
@onready var item_list = $PanelContainer/VBoxContainer/ScrollContainer/VBoxContainer/List2
@onready var comfirm_button = $PanelContainer/VBoxContainer/HBoxContainer/Button2
@onready var close_button = $PanelContainer/VBoxContainer/HBoxContainer/Button

const gem_ui = preload("res://ui_gem.tscn")
const item_ui = preload("res://ui_item.tscn")

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

func create_bar():
	var bar = ColorRect.new()
	bar.position = Vector2(16, 48)
	bar.size = Vector2(16, 4)
	bar.color = Color(0.7, 0.7, 0.7, 1.0)
	bar.hide()
	return bar

func enter(select_category : String = "", _select_num : int = 0, select_prompt : String = "", _select_callback : Callable = Callable()):
	clear()
	self.self_modulate.a = 0.0
	var tween = get_tree().create_tween()
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
	for g in Game.gems:
		var ctrl = Control.new()
		ctrl.custom_minimum_size = Vector2(48, 52)
		ctrl.mouse_entered.connect(func():
			SSound.se_select.play()
			STooltip.show(g.get_tooltip())
		)
		ctrl.mouse_exited.connect(func():
			STooltip.close()
		)
		var ui = gem_ui.instantiate()
		ui.position = Vector2(24, 24)
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
	'''
	for i in Game.items:
		var ui = item_ui.instantiate()
		ui.custom_minimum_size = Vector2(32, 36)
		ui.setup(i)
		
		var bar = create_bar()
		ui.add_child(bar)
		if i.coord.x != -1 && i.coord.y != -1:
			bar.color = Color(0.9, 0.6, 0.3, 1.0)
			bar.show()
		elif i.coord.x != -1:
			bar.color = Color(0.5, 0.8, 0.6, 1.0)
			bar.show()
		item_list.add_child(ui)
	'''
	
	self.show()
	panel.show()

func exit():
	panel.hide()
	self.self_modulate.a = 1.0
	var tween = get_tree().create_tween()
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
		Game.screen_shake_strength = 8.0
		exit()
		select_callback.call(selecteds)
	)
