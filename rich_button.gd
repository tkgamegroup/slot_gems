extends Control

@onready var text = $RichTextLabel
@onready var button = $Button

@export var disabled : bool = false:
	set(v):
		disabled = v
		button.disabled = v
		text.add_theme_color_override("default_color", Color(0.875, 0.875, 0.875, 0.5) if v else Color.WHITE)

func _ready() -> void:
	button.button_down.connect(func():
		text.position.y = 2
	)
	button.button_up.connect(func():
		text.position.y = 0
	)
