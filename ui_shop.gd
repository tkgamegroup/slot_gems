extends Control

@onready var title : Label = $Label
@onready var next_button : Button = $Button

func _ready() -> void:
	next_button.pressed.connect(func():
		Game.sound.sfx_click.play()
	)
	next_button.mouse_entered.connect(Game.sound.sfx_select.play)
