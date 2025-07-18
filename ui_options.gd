extends Control

@onready var panel : PanelContainer = $PanelContainer
@onready var language_select : OptionButton = $PanelContainer/VBoxContainer/GridContainer/OptionButton
@onready var se_volume_slider : HSlider = $PanelContainer/VBoxContainer/GridContainer/HSlider
@onready var music_volume_slider : HSlider = $PanelContainer/VBoxContainer/GridContainer/HSlider2
@onready var fullscreen_checkbox : CheckBox = $PanelContainer/VBoxContainer/GridContainer/CheckBox
@onready var game_speed_select : OptionButton = $PanelContainer/VBoxContainer/GridContainer/OptionButton2
@onready var crt_checkbox : CheckBox = $PanelContainer/VBoxContainer/GridContainer/CheckBox2
@onready var performance_mode_checkbox : CheckBox = $PanelContainer/VBoxContainer/GridContainer/CheckBox3
@onready var invincible_checkbox : CheckBox = $PanelContainer/VBoxContainer/GridContainer/CheckBox4
@onready var close_button : Button = $PanelContainer/VBoxContainer/Button
@onready var command_line : LineEdit = $PanelContainer/VBoxContainer/GridContainer/LineEdit

func enter(trans = true):
	STooltip.close()
	if trans:
		self.self_modulate.a = 0.0
		var tween = get_tree().create_tween()
		tween.tween_property(self, "self_modulate:a", 1.0, 0.3)
	else:
		self.self_modulate.a = 1.0
	
	var locale = TranslationServer.get_locale()
	if locale.begins_with("en"):
		language_select.selected = 0
	elif locale.begins_with("zh"):
		language_select.selected = 1
	se_volume_slider.value = db_to_linear(AudioServer.get_bus_volume_db(SSound.se_bus_index))
	music_volume_slider.value = db_to_linear(AudioServer.get_bus_volume_db(SSound.music_bus_index))
	crt_checkbox.set_pressed_no_signal(Game.crt_mode)
	performance_mode_checkbox.set_pressed_no_signal(Game.performance_mode)
	invincible_checkbox.set_pressed_no_signal(Game.invincible)
	fullscreen_checkbox.set_pressed_no_signal(DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN)
	if Game.base_speed > 0.4 && Game.base_speed < 0.6:
		game_speed_select.selected = 0
	elif Game.base_speed > 0.9 && Game.base_speed < 1.1:
		game_speed_select.selected = 1
	elif Game.base_speed > 1.9 && Game.base_speed < 2.1:
		game_speed_select.selected = 2
	elif Game.base_speed > 3.9 && Game.base_speed < 4.1:
		game_speed_select.selected = 3
	
	self.show()
	panel.show()

func exit():
	if Game.game_ui.visible:
		SSound.music_clear()
	
	panel.hide()
	self.self_modulate.a = 1.0
	var tween = get_tree().create_tween()
	tween.tween_property(self, "self_modulate:a", 0.0, 0.3)
	tween.tween_callback(func():
		self.hide()
	)

func _ready() -> void:
	language_select.item_selected.connect(func(idx):
		match idx:
			0: TranslationServer.set_locale("en")
			1: TranslationServer.set_locale("zh")
		Game.level = Game.level
		Game.target_score = Game.target_score
	)
	se_volume_slider.value_changed.connect(func(v):
		AudioServer.set_bus_volume_db(SSound.se_bus_index, linear_to_db(v))
	)
	music_volume_slider.value_changed.connect(func(v):
		AudioServer.set_bus_volume_db(SSound.music_bus_index, linear_to_db(v))
	)
	fullscreen_checkbox.toggled.connect(func(v):
		SSound.se_click.play()
		if v:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	)
	game_speed_select.item_selected.connect(func(idx):
		match idx:
			0: Game.base_speed = 0.5
			1: Game.base_speed = 1.0
			2: Game.base_speed = 2.0
			3: Game.base_speed = 4.0
		Game.speed = 1.0 / Game.base_speed
	)
	crt_checkbox.toggled.connect(func(v):
		SSound.se_click.play()
		Game.crt_mode = v
	)
	performance_mode_checkbox.toggled.connect(func(v):
		SSound.se_click.play()
		Game.performance_mode = v
	)
	invincible_checkbox.toggled.connect(func(v):
		SSound.se_click.play()
		Game.invincible = v
	)
	close_button.pressed.connect(func():
		SSound.se_click.play()
		exit()
	)
	#close_button.mouse_entered.connect(SSound.se_select.play)
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
			elif cmd == "win":
				Game.win()
			elif cmd == "lose":
				Game.lose()
			elif cmd == "shop":
				Game.shop_ui.enter()
			elif cmd == "gold":
				Game.coins += int(tokens[1])
			elif cmd == "ai":
				var num = 1
				var tt = tokens[1]
				if tt.is_valid_int():
					num = int(tt)
					tt = tokens[2]
				for j in num:
					var i = Item.new()
					i.setup(tt)
					Game.add_item(i)
			elif cmd == "ar":
				var r = Relic.new()
				r.setup(tokens[1])
				Game.add_relic(r)
			elif cmd == "test":
				var mode = 0
				var level_count = 1
				var task_count = 1
				var saving = ""
				var additional_items = []
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
					elif t == "-s":
						saving = tokens[i + 1]
						i += 1
					elif t == "-ai":
						var num = 1
						var tt = tokens[i + 1]
						i += 1
						if tt.is_valid_int():
							num = int(tt)
							tt = tokens[i + 1]
							i += 1
						for j in num:
							additional_items.append(tt)
					elif t == "-ap":
						var num = 1
						var tt = tokens[i + 1]
						i += 1
						if tt.is_valid_int():
							num = int(tt)
							tt = tokens[i + 1]
							i += 1
						for j in num:
							additional_patterns.append(tt)
					elif t == "-ar":
						var num = 1
						var tt = tokens[i + 1]
						i += 1
						if tt.is_valid_int():
							num = int(tt)
							tt = tokens[i + 1]
							i += 1
						for j in num:
							additional_relics.append(tt)
					elif t == "-es":
						enable_shopping = true
				STest.start_test(mode, level_count, task_count, "", saving, additional_items, additional_patterns, additional_relics, true, enable_shopping)
		command_line.clear()
	)
