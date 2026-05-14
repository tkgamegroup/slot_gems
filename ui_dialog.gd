extends Control

@export var panel : PanelContainer
@export var title : Label
@export var content : Label
@export var button1 : Button
@export var button2 : Button

var action1 : Callable
var action2 : Callable

func do_nothing():
	exit()

func open(_title : String, _content : String, buttons_num : int = 1, button1_action : Callable = do_nothing, button2_action : Callable = do_nothing):
	title.text = _title
	content.text = _content
	action1 = button1_action
	action2 = button2_action
	
	if buttons_num == 1:
		button1.text = "OK"
		button1.show()
		button2.hide()
	elif buttons_num == 2:
		button1.text = "Yes"
		button1.show()
		button2.text = "No"
		button2.show()
	
	self.self_modulate.a = 0.0
	self.show()
	panel.show()
	
	var tween = G.create_tween()
	tween.tween_property(self, "self_modulate:a", 1.0, 0.3)

func exit():
	panel.hide()
	self.self_modulate.a = 1.0
	var tween = G.create_tween()
	tween.tween_property(self, "self_modulate:a", 0.0, 0.3)
	tween.tween_callback(func():
		self.hide()
	)

func _ready() -> void:
	button1.pressed.connect(func():
		exit()
		if action1.is_valid():
			action1.call()
		action1 = do_nothing
	)
	button2.pressed.connect(func():
		exit()
		if action2.is_valid():
			action2.call()
		action2 = do_nothing
	)
