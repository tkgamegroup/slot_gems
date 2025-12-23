extends Control

@onready var panel : PanelContainer = $PanelContainer
@onready var resume_button : Button = $PanelContainer/VBoxContainer/Button
@onready var options_button : Button = $PanelContainer/VBoxContainer/Button2
@onready var main_menu_button : Button = $PanelContainer/VBoxContainer/Button3
@onready var quit_to_desktop_button : Button = $PanelContainer/VBoxContainer/Button4
@onready var auto_place_items_button : Button = $PanelContainer/VBoxContainer/Button5
@onready var win_button : Button = $PanelContainer/VBoxContainer/HBoxContainer/Button6
@onready var lose_button : Button = $PanelContainer/VBoxContainer/HBoxContainer/Button7

func enter():
	SSound.music_less_clear()
	STooltip.close()
	
	self.self_modulate.a = 0.0
	self.show()
	panel.show()
	
	App.game_tweens.process_mode = Node.PROCESS_MODE_DISABLED
	
	var tween = App.create_tween()
	tween.tween_property(self, "self_modulate:a", 1.0, 0.3)

func exit(trans = true):
	if trans:
		panel.hide()
		self.self_modulate.a = 1.0
		var tween = App.create_tween()
		tween.tween_property(self, "self_modulate:a", 0.0, 0.3)
		tween.tween_callback(func():
			self.hide()
			App.game_tweens.process_mode = Node.PROCESS_MODE_INHERIT
		)
	else:
		self.hide()
		App.game_tweens.process_mode = Node.PROCESS_MODE_INHERIT
	
func _ready() -> void:
	resume_button.pressed.connect(func():
		SSound.music_more_clear()
		SSound.se_click.play()
		App.screen_shake_strength = 8.0
		exit()
	)
	options_button.pressed.connect(func():
		SSound.se_click.play()
		App.screen_shake_strength = 8.0
		exit(false)
		App.options_ui.enter(true)
	)
	main_menu_button.pressed.connect(func():
		SSound.se_click.play()
		App.screen_shake_strength = 8.0
		App.exit_game()
		exit()
		
		var tween = App.create_tween()
		App.begin_transition(tween)
		tween.tween_callback(func():
			App.title_ui.enter()
		)
		App.end_transition(tween)
	)
	quit_to_desktop_button.pressed.connect(func():
		get_tree().quit()
	)
	auto_place_items_button.pressed.connect(func():
		SSound.music_more_clear()
		SSound.se_click.play()
		App.screen_shake_strength = 8.0
		exit()
		#STest.auto_place_items()
	)
	win_button.pressed.connect(func():
		SSound.music_more_clear()
		SSound.se_click.play()
		App.screen_shake_strength = 8.0
		exit()
		App.win()
	)
	lose_button.pressed.connect(func():
		SSound.music_more_clear()
		SSound.se_click.play()
		App.screen_shake_strength = 8.0
		exit()
		App.game_over_mark = "not_reach_score"
		App.lose()
	)
