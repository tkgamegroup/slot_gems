extends PanelContainer

@onready var title : Label = $VBoxContainer/Label
@onready var content : Label = $VBoxContainer/Label2
@onready var button1 : Button = $VBoxContainer/HBoxContainer/Button
@onready var button2 : Button = $VBoxContainer/HBoxContainer/Button2

var action1 : Callable
var action2 : Callable

func do_nothing():
	pass

func open(_title : String, _content : String, yes_action : Callable, no_action : Callable):
	title.text = _title
	content.text = _content
	action1 = yes_action
	action2 = no_action
	self.show()

func _ready() -> void:
	button1.pressed.connect(func():
		self.hide()
		if action1.is_valid():
			action1.call()
		action1 = do_nothing
	)
	button1.pressed.connect(func():
		self.hide()
		if action2.is_valid():
			action2.call()
		action2 = do_nothing
	)
