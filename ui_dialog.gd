extends Control

@onready var panel : PanelContainer = $PanelContainer
@onready var title : Label = $PanelContainer/VBoxContainer/Label
@onready var content : Label = $PanelContainer/VBoxContainer/Label2
@onready var button1 : Button = $PanelContainer/VBoxContainer/HBoxContainer/Button
@onready var button2 : Button = $PanelContainer/VBoxContainer/HBoxContainer/Button2

var action1 : Callable
var action2 : Callable

func do_nothing():
	pass

func open(_title : String, _content : String, yes_action : Callable, no_action : Callable):
	title.text = _title
	content.text = _content
	action1 = yes_action
	action2 = no_action
	
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
	button1.pressed.connect(func():
		exit()
		if action2.is_valid():
			action2.call()
		action2 = do_nothing
	)
