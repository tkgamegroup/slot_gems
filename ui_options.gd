extends Control

@onready var sfx_volume_slider : HSlider = $VBoxContainer/GridContainer/HSlider
@onready var music_volume_slider : HSlider = $VBoxContainer/GridContainer/HSlider2
@onready var fullscreen_checkbox : CheckBox = $VBoxContainer/GridContainer/CheckBox
@onready var close_button : Button = $VBoxContainer/Button

func enter():
	STooltip.close()
	Game.blocker_ui.enter()
	self.show()

func exit():
	Game.blocker_ui.exit()
	self.hide()
	
func _ready() -> void:
	sfx_volume_slider.value_changed.connect(func(v):
		AudioServer.set_bus_volume_db(SSound.sfx_bus_index, linear_to_db(v))
	)
	sfx_volume_slider.value = db_to_linear(AudioServer.get_bus_volume_db(SSound.sfx_bus_index))
	music_volume_slider.value_changed.connect(func(v):
		AudioServer.set_bus_volume_db(SSound.music_bus_index, linear_to_db(v))
	)
	music_volume_slider.value = db_to_linear(AudioServer.get_bus_volume_db(SSound.music_bus_index))
	fullscreen_checkbox.toggled.connect(func(v):
		SSound.sfx_click.play()
		if v:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	)
	fullscreen_checkbox.set_pressed_no_signal(DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN) 
	close_button.pressed.connect(func():
		SSound.sfx_click.play()
		exit()
	)
	#close_button.mouse_entered.connect(SSound.sfx_select.play)
