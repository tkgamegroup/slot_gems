extends Control

@onready var panel : PanelContainer = $PanelContainer
@onready var resume_button : Button = $PanelContainer/VBoxContainer/Button
@onready var options_button : Button = $PanelContainer/VBoxContainer/Button2
@onready var main_menu_button : Button = $PanelContainer/VBoxContainer/Button3
@onready var quit_to_desktop_button : Button = $PanelContainer/VBoxContainer/Button4
@onready var auto_place_items_button : Button = $PanelContainer/VBoxContainer/Button5
@onready var win_button : Button = $PanelContainer/VBoxContainer/HBoxContainer/Button6
@onready var lose_button : Button = $PanelContainer/VBoxContainer/HBoxContainer/Button7
@onready var test_button : Button = $PanelContainer/VBoxContainer/Button6

func enter():
	SSound.music_less_clear()
	STooltip.close()
	
	self.self_modulate.a = 0.0
	self.show()
	panel.show()
	
	G.game_tweens.process_mode = Node.PROCESS_MODE_DISABLED
	
	var tween = G.create_tween()
	tween.tween_property(self, "self_modulate:a", 1.0, 0.3)

func exit(trans = true):
	if trans:
		panel.hide()
		self.self_modulate.a = 1.0
		var tween = G.create_tween()
		tween.tween_property(self, "self_modulate:a", 0.0, 0.3)
		tween.tween_callback(func():
			self.hide()
			G.game_tweens.process_mode = Node.PROCESS_MODE_INHERIT
		)
	else:
		self.hide()
		G.game_tweens.process_mode = Node.PROCESS_MODE_INHERIT
	
func _ready() -> void:
	resume_button.pressed.connect(func():
		SSound.music_more_clear()
		SSound.se_click.play()
		G.screen_shake_strength = 8.0
		exit()
	)
	options_button.pressed.connect(func():
		SSound.se_click.play()
		G.screen_shake_strength = 8.0
		exit(false)
		G.options_ui.enter(true)
	)
	main_menu_button.pressed.connect(func():
		SSound.se_click.play()
		G.screen_shake_strength = 8.0
		G.save_to_file()
		G.exit_game()
		exit()
		
		var tween = G.create_tween()
		G.begin_transition(tween)
		tween.tween_callback(func():
			G.title_ui.enter()
		)
		G.end_transition(tween)
	)
	quit_to_desktop_button.pressed.connect(func():
		G.save_to_file()
		get_tree().quit()
	)
	auto_place_items_button.pressed.connect(func():
		SSound.music_more_clear()
		SSound.se_click.play()
		G.screen_shake_strength = 8.0
		exit()
		#STest.auto_place_items()
	)
	win_button.pressed.connect(func():
		SSound.music_more_clear()
		SSound.se_click.play()
		G.screen_shake_strength = 8.0
		exit()
		G.win()
	)
	lose_button.pressed.connect(func():
		SSound.music_more_clear()
		SSound.se_click.play()
		G.screen_shake_strength = 8.0
		exit()
		G.game_over_mark = "not_reach_score"
		G.lose()
	)
	test_button.pressed.connect(func():
		SSound.se_click.play()
		G.screen_shake_strength = 8.0
		exit(false)
		G.test_ui.enter()
	)
