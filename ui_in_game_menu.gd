extends Control

@onready var panel : PanelContainer = $PanelContainer
@onready var resume_button : Button = $PanelContainer/VBoxContainer/Button
@onready var options_button : Button = $PanelContainer/VBoxContainer/Button2
@onready var main_menu_button : Button = $PanelContainer/VBoxContainer/Button3
@onready var tutorial_button : Button = $PanelContainer/VBoxContainer/Button4
@onready var auto_place_items_button : Button = $PanelContainer/VBoxContainer/Button5
@onready var win_button : Button = $PanelContainer/VBoxContainer/Button6
@onready var lose_button : Button = $PanelContainer/VBoxContainer/Button7

func enter():
	SSound.music_less_clear()
	STooltip.close()
	self.self_modulate.a = 0.0
	var tween = get_tree().create_tween()
	tween.tween_property(self, "self_modulate:a", 1.0, 0.3)
	
	self.show()
	panel.show()

func exit(trans = true):
	if trans:
		panel.hide()
		self.self_modulate.a = 1.0
		var tween = get_tree().create_tween()
		tween.tween_property(self, "self_modulate:a", 0.0, 0.3)
		tween.tween_callback(func():
			self.hide()
		)
	else:
		self.hide()
	
func _ready() -> void:
	resume_button.pressed.connect(func():
		SSound.music_clear()
		SSound.se_click.play()
		exit()
	)
	options_button.pressed.connect(func():
		exit(false)
		Game.options_ui.enter(false)
	)
	main_menu_button.pressed.connect(func():
		SSound.se_click.play()
		for t in get_tree().get_processed_tweens():
			t.custom_step(100.0)
		exit()
		
		var tween = Game.get_tree().create_tween()
		Game.begin_transition(tween)
		tween.tween_callback(func():
			if Game.board_ui.visible:
				Game.board_ui.exit(null, false)
			elif Game.shop_ui.visible:
				Game.shop_ui.exit(null, false)
			Game.control_ui.exit()
			Game.game_ui.hide()
			Game.title_ui.enter()
		)
		Game.end_transition(tween)
	)
	tutorial_button.pressed.connect(func():
		SSound.music_clear()
		SSound.se_click.play()
		exit()
		Game.tutorial_ui.show()
	)
	auto_place_items_button.pressed.connect(func():
		SSound.music_clear()
		SSound.se_click.play()
		exit()
		STest.auto_place_items()
	)
	win_button.pressed.connect(func():
		SSound.music_clear()
		SSound.se_click.play()
		exit()
		Game.win()
	)
	lose_button.pressed.connect(func():
		SSound.music_clear()
		SSound.se_click.play()
		exit()
		Game.lose()
	)
