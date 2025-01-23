extends Control

@onready var sfx_volume_slider : HSlider = $VBoxContainer/GridContainer/HSlider
@onready var music_volume_slider : HSlider = $VBoxContainer/GridContainer/HSlider2
@onready var fullscreen_checkbox : CheckBox = $VBoxContainer/GridContainer/CheckBox
@onready var close_button : Button = $VBoxContainer/Button

func _ready() -> void:
	sfx_volume_slider.value_changed.connect(func(v):
		AudioServer.set_bus_volume_db(Game.sound.sfx_bus_index, linear_to_db(v))
	)
	sfx_volume_slider.value = db_to_linear(AudioServer.get_bus_volume_db(Game.sound.sfx_bus_index))
	music_volume_slider.value_changed.connect(func(v):
		AudioServer.set_bus_volume_db(Game.sound.music_bus_index, linear_to_db(v))
	)
	music_volume_slider.value = db_to_linear(AudioServer.get_bus_volume_db(Game.sound.music_bus_index))
	fullscreen_checkbox.toggled.connect(func(v):
		Game.sound.sfx_click.play()
		if v:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	)
	fullscreen_checkbox.set_pressed_no_signal(DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN) 
	close_button.pressed.connect(func():
		Game.sound.sfx_click.play()
		Game.ui_blocker.hide()
		self.hide()
	)
	close_button.mouse_entered.connect(Game.sound.sfx_select.play)
