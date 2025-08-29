extends Control

@onready var list : Control = $VBoxContainer
@onready var sell_button : Button = $VBoxContainer/Sell
@onready var sell_text : Label = $VBoxContainer/Sell/HBoxContainer/Label

var sell_price : int
var pos : Vector2

signal on_sell

func open(_pos : Vector2, _sell_price : int):
	pos = _pos
	sell_price = _sell_price

func _ready() -> void:
	sell_text.text = tr("ui_sell") % sell_price
	list.position = pos
	sell_button.pressed.connect(func():
		self.queue_free()
		on_sell.emit()
	)
	self.gui_input.connect(func(event : InputEvent):
		if event is InputEventMouseButton:
			if event.pressed:
				self.queue_free()
	)
