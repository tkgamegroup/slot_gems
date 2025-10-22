extends Control

@onready var text = $RichTextLabel
@onready var button = $Button

func _ready() -> void:
	button.button_down.connect(func():
		text.position.y = 2
	)
	button.button_up.connect(func():
		text.position.y = 0
	)
