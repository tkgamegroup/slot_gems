extends Control

@onready var panel : PanelContainer = $PanelContainer
@onready var desc_text : Label = $PanelContainer/VBoxContainer/Label2
@onready var max_matching_score_text : Label = $PanelContainer/VBoxContainer/GridContainer/Label2
@onready var rolls_text : Label = $PanelContainer/VBoxContainer/GridContainer/Label4
@onready var level_text : Label = $PanelContainer/VBoxContainer/GridContainer/Label6
@onready var seed_text : Label = $PanelContainer/VBoxContainer/GridContainer/Label8
@onready var new_run : Button = $PanelContainer/VBoxContainer/VBoxContainer/Button
@onready var main_menu_button : Button = $PanelContainer/VBoxContainer/VBoxContainer/Button2

func enter():
	STooltip.close()
	self.self_modulate.a = 0.0
	var tween = get_tree().create_tween()
	tween.tween_property(self, "self_modulate:a", 1.0, 0.3)
	
	desc_text.text = tr("game_over_" + Game.game_over_mark)
	Game.game_over_mark = ""
	max_matching_score_text.text = "%d" % Game.history.max_matching_score
	rolls_text.text = "%d" % Game.history.rolls
	level_text.text = "%d" % Game.level
	seed_text.text = ""
	
	self.show()
	panel.show()

func exit():
	panel.hide()
	self.self_modulate.a = 1.0
	var tween = get_tree().create_tween()
	tween.tween_property(self, "self_modulate:a", 0.0, 0.3)
	tween.tween_callback(func():
		self.hide()
	)

func _ready() -> void:
	new_run.pressed.connect(func():
		SSound.se_click.play()
		Game.screen_shake_strength = 8.0
		for t in get_tree().get_processed_tweens():
			t.custom_step(100.0)
		exit()
		Game.start_game()
	)
	#new_run.mouse_entered.connect(SSound.se_select.play)
	main_menu_button.pressed.connect(func():
		SSound.se_click.play()
		Game.screen_shake_strength = 8.0
		for t in get_tree().get_processed_tweens():
			t.custom_step(100.0)
		exit()
		
		var tween = get_tree().create_tween()
		tween.tween_callback(func():
			if Board.ui.visible:
				Board.ui.exit(null, false)
			elif Game.shop_ui.visible:
				Game.shop_ui.exit(null, false)
			Game.control_ui.exit()
			Game.game_ui.hide()
			Game.title_ui.enter()
		)
	)
	#main_menu_button.mouse_entered.connect(SSound.se_select.play)
