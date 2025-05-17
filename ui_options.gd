extends Control

@onready var sfx_volume_slider : HSlider = $VBoxContainer/GridContainer/HSlider
@onready var music_volume_slider : HSlider = $VBoxContainer/GridContainer/HSlider2
@onready var fullscreen_checkbox : CheckBox = $VBoxContainer/GridContainer/CheckBox
@onready var performance_mode_checkbox : CheckBox = $VBoxContainer/GridContainer/CheckBox2
@onready var invincible_checkbox : CheckBox = $VBoxContainer/GridContainer/CheckBox3
@onready var close_button : Button = $VBoxContainer/Button
@onready var command_line : LineEdit = $VBoxContainer/GridContainer/LineEdit

func enter():
	STooltip.close()
	Game.blocker_ui.enter()
	sfx_volume_slider.value = db_to_linear(AudioServer.get_bus_volume_db(SSound.sfx_bus_index))
	music_volume_slider.value = db_to_linear(AudioServer.get_bus_volume_db(SSound.music_bus_index))
	performance_mode_checkbox.set_pressed_no_signal(Game.performance_mode)
	invincible_checkbox.set_pressed_no_signal(Game.invincible)
	fullscreen_checkbox.set_pressed_no_signal(DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN)
	self.show()

func exit():
	Game.blocker_ui.exit()
	self.hide()
	
func _ready() -> void:
	sfx_volume_slider.value_changed.connect(func(v):
		AudioServer.set_bus_volume_db(SSound.sfx_bus_index, linear_to_db(v))
	)
	music_volume_slider.value_changed.connect(func(v):
		AudioServer.set_bus_volume_db(SSound.music_bus_index, linear_to_db(v))
	)
	fullscreen_checkbox.toggled.connect(func(v):
		SSound.sfx_click.play()
		if v:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	)
	performance_mode_checkbox.toggled.connect(func(v):
		SSound.sfx_click.play()
		Game.performance_mode = v
	)
	invincible_checkbox.toggled.connect(func(v):
		SSound.sfx_click.play()
		Game.invincible = v
	)
	close_button.pressed.connect(func():
		SSound.sfx_click.play()
		exit()
	)
	#close_button.mouse_entered.connect(SSound.sfx_select.play)
	command_line.text_submitted.connect(func(cl : String):
		exit()
		var tokens = []
		var lq = -1
		var rt = 0
		for i in cl.length():
			var ch = cl[i]
			if ch == "\"":
				if lq != -1:
					tokens.append(cl.substr(lq, i - lq))
					lq = -1
					rt = i + 1
				else:
					tokens.append_array(cl.substr(rt, i - rt).split(" ", false))
					lq = i + 1
			else:
				if i == cl.length() - 1:
					tokens.append_array(cl.substr(rt).split(" ", false))
		if !tokens.is_empty():
			var cmd = tokens[0]
			for i in tokens.size():
				var t = tokens[i]
				if t.length() >= 2 && t[0] == '"' && t[t.length() - 1] == '"':
					tokens[i] = t.substr(1, t.length() - 2)
			if cmd == "test_matching":
				var tokens2 = tokens[1].split(",")
				var coord = Vector2i(int(tokens2[0]), int(tokens2[1]))
				for p in Game.patterns:
					p.match_with(coord)
			elif cmd == "test":
				var mode = 0
				var level_count = 1
				var task_count = 1
				var additional_items = []
				var additional_skills = []
				var additional_patterns = []
				var additional_relics = []
				var enable_shopping = false
				for i in range(1, tokens.size()):
					var t = tokens[i]
					if t == "-m":
						mode = int(tokens[i + 1])
						i += 1
					elif t == "-l":
						level_count = int(tokens[i + 1])
						i += 1
					elif t == "-t":
						task_count = int(tokens[i + 1])
						i += 1
					elif t == "-ai":
						additional_items.append(tokens[i + 1])
						i += 1
					elif t == "-as":
						additional_skills.append(tokens[i + 1])
						i += 1
					elif t == "-ap":
						additional_patterns.append(tokens[i + 1])
						i += 1
					elif t == "-ar":
						additional_relics.append(tokens[i + 1])
						i += 1
					elif t == "-es":
						enable_shopping = true
				STest.start_test(mode, level_count, task_count, "", "", additional_items, additional_skills,additional_patterns, additional_relics, true, enable_shopping)
	)
