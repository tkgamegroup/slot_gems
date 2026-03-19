extends Control

@export var panel : PanelContainer
@export var tab_container : TabContainer
@export var language_select : OptionButton
@export var game_speed_select : OptionButton
@export var performance_mode_checkbox : CheckBox
@export var invincible_checkbox : CheckBox
@export var command_line : LineEdit
@export var monitor_select : OptionButton
@export var window_mode_select : OptionButton
@export var resolution_select : OptionButton
@export var video_apply_button : Button
@export var crt_checkbox : CheckBox
@export var se_volume_slider : HSlider
@export var music_volume_slider : HSlider
@export var close_button : Button

func enter(second : bool = false):
	STooltip.close()
	
	self.show()
	panel.show()
	tab_container.current_tab = 0
	
	G.game_tweens.process_mode = Node.PROCESS_MODE_DISABLED
	
	var tween = G.create_tween()
	tween.tween_property(panel, "position:y", panel.position.y, 0.5).from(panel.position.y + 100).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	if !second:
		self.self_modulate.a = 0.0
		tween.parallel().tween_property(self, "self_modulate:a", 1.0, 0.3)
	else:
		self.self_modulate.a = 1.0

func exit():
	if G.game_ui.visible:
		SSound.music_more_clear()
	
	panel.hide()
	self.self_modulate.a = 1.0
	var tween = G.create_tween()
	tween.tween_property(self, "self_modulate:a", 0.0, 0.3)
	tween.tween_callback(func():
		self.hide()
		G.game_tweens.process_mode = Node.PROCESS_MODE_INHERIT
	)

func tab_changed(tab : int):
	if tab == 0:
		var locale = TranslationServer.get_locale()
		if locale.begins_with("en"):
			language_select.selected = 0
		elif locale.begins_with("zh"):
			language_select.selected = 1
		game_speed_select.selected = 0
		if G.base_speed > 0.5:
			game_speed_select.selected = 1
		elif G.base_speed > 1.0:
			game_speed_select.selected = 2
		elif G.base_speed > 2.0:
			game_speed_select.selected = 3
		performance_mode_checkbox.set_pressed_no_signal(G.performance_mode)
		invincible_checkbox.set_pressed_no_signal(G.invincible)
	elif tab == 1:
		var monitor_count = DisplayServer.get_screen_count()
		monitor_select.clear()
		for i in monitor_count:
			monitor_select.add_item("%d" % (i + 1))
		monitor_select.selected = DisplayServer.window_get_current_screen()
		var window_mode = DisplayServer.window_get_mode()
		window_mode_select.selected = 0
		if window_mode == DisplayServer.WindowMode.WINDOW_MODE_EXCLUSIVE_FULLSCREEN:
			window_mode_select.selected = 1
		elif window_mode == DisplayServer.WindowMode.WINDOW_MODE_FULLSCREEN:
			window_mode_select.selected = 2
		video_apply_button.disabled = true
	elif tab == 2:
		crt_checkbox.set_pressed_no_signal(G.crt_mode)
	elif tab == 3:
		se_volume_slider.value = db_to_linear(AudioServer.get_bus_volume_db(SSound.se_bus_index))
		music_volume_slider.value = db_to_linear(AudioServer.get_bus_volume_db(SSound.music_bus_index))

func lang_changed():
	tab_container.set_tab_title(0, tr("ui_options_game"))
	tab_container.set_tab_title(1, tr("ui_options_video"))
	tab_container.set_tab_title(2, tr("ui_options_graphics"))
	tab_container.set_tab_title(3, tr("ui_options_audio"))

func set_window_mode(mode : int):
	if mode == 0:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		var screen_size = DisplayServer.screen_get_size()
		DisplayServer.window_set_size(screen_size * 0.5)
		DisplayServer.window_set_position(screen_size * 0.25)
	elif mode == 1:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

func load_config():
	var config = ConfigFile.new()
	if config.load("user://config.ini") == OK:
		var lang = config.get_value("", "lang", "unknown")
		if lang != "unknown":
			G.set_lang(lang)
		match config.get_value("", "game_speed", 1):
			0: G.speed = 0.5
			1: G.speed = 1.0
			2: G.speed = 2.0
			3: G.speed = 4.0
		G.performance_mode = config.get_value("", "performance_mode", false)
		G.invincible = config.get_value("", "invincible", false)
		DisplayServer.window_set_current_screen(config.get_value("", "monitor", 0))
		set_window_mode(config.get_value("", "window_mode", 1))
		G.crt_mode = config.get_value("", "crt", true)
		AudioServer.set_bus_volume_db(SSound.se_bus_index, linear_to_db(config.get_value("", "se_volumn", 100)))
		AudioServer.set_bus_volume_db(SSound.music_bus_index, linear_to_db(config.get_value("", "music_volumn", 100)))

func save_config():
	var config = ConfigFile.new()
	var locale = TranslationServer.get_locale()
	if locale.begins_with("en"):
		config.set_value("", "lang", "en")
	elif locale.begins_with("zh"):
		config.set_value("", "lang", "zh")
	else:
		config.set_value("", "lang", "unknown")
	if G.base_speed > 2.0:
		config.set_value("", "game_speed", 3)
	elif G.base_speed > 1.0:
		config.set_value("", "game_speed", 2)
	elif G.base_speed > 0.5:
		config.set_value("", "game_speed", 1)
	else:
		config.set_value("", "game_speed", 0)
	config.set_value("", "performance_mode", G.performance_mode)
	config.set_value("", "invincible", G.invincible)
	config.set_value("", "monitor", DisplayServer.window_get_current_screen())
	var window_mode = DisplayServer.window_get_mode()
	if window_mode == DisplayServer.WindowMode.WINDOW_MODE_EXCLUSIVE_FULLSCREEN:
		config.set_value("", "window_mode", 1)
	elif window_mode == DisplayServer.WindowMode.WINDOW_MODE_FULLSCREEN:
		config.set_value("", "window_mode", 2)
	else:
		config.set_value("", "window_mode", 0)
	config.set_value("", "crt", G.crt_mode)
	config.set_value("", "se_volumn", db_to_linear(AudioServer.get_bus_volume_db(SSound.se_bus_index)))
	config.set_value("", "music_volumn", db_to_linear(AudioServer.get_bus_volume_db(SSound.music_bus_index)))
	config.save("user://config.ini")

func _ready() -> void:
	load_config()
	
	tab_changed(0)
	tab_container.tab_changed.connect(func(tab : int):
		SSound.se_click.play()
		G.screen_shake_strength = 8.0
		tab_changed(tab)
	)
	lang_changed()
	language_select.item_selected.connect(func(idx):
		SSound.se_click.play()
		G.screen_shake_strength = 8.0
		match idx:
			0: G.set_lang("en")
			1: G.set_lang("zh")
		save_config()
	)
	se_volume_slider.value_changed.connect(func(v):
		AudioServer.set_bus_volume_db(SSound.se_bus_index, linear_to_db(v))
		save_config()
	)
	music_volume_slider.value_changed.connect(func(v):
		AudioServer.set_bus_volume_db(SSound.music_bus_index, linear_to_db(v))
		save_config()
	)
	video_apply_button.pressed.connect(func():
		DisplayServer.window_set_current_screen(monitor_select.selected)
		set_window_mode(window_mode_select.selected)
		save_config()
	)
	monitor_select.item_selected.connect(func(idx):
		SSound.se_click.play()
		G.screen_shake_strength = 8.0
		video_apply_button.disabled = false
	)
	window_mode_select.item_selected.connect(func(idx):
		SSound.se_click.play()
		G.screen_shake_strength = 8.0
		video_apply_button.disabled = false
	)
	game_speed_select.item_selected.connect(func(idx):
		SSound.se_click.play()
		G.screen_shake_strength = 8.0
		match idx:
			0: G.base_speed = 0.5
			1: G.base_speed = 1.0
			2: G.base_speed = 2.0
			3: G.base_speed = 4.0
		G.speed = 1.0 / G.base_speed
		save_config()
	)
	crt_checkbox.toggled.connect(func(v : bool):
		SSound.se_click.play()
		G.screen_shake_strength = 8.0
		G.crt_mode = v
		save_config()
	)
	performance_mode_checkbox.toggled.connect(func(v : bool):
		SSound.se_click.play()
		G.screen_shake_strength = 8.0
		G.performance_mode = v
		save_config()
	)
	invincible_checkbox.toggled.connect(func(v : bool):
		SSound.se_click.play()
		G.screen_shake_strength = 8.0
		G.invincible = v
		save_config()
	)
	close_button.pressed.connect(func():
		SSound.se_click.play()
		G.screen_shake_strength = 8.0
		exit()
	)
	#close_button.mouse_entered.connect(SSound.se_select.play)
	command_line.text_submitted.connect(func(cl : String):
		exit()
		G.process_command_line(cl)
		command_line.clear()
	)
