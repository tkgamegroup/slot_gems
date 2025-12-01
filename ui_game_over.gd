extends Control

@onready var panel : PanelContainer = $PanelContainer
@onready var desc_text : Label = $PanelContainer/VBoxContainer/Label2
@onready var max_matching_score_text : Label = $PanelContainer/VBoxContainer/GridContainer/Label2
@onready var rolls_text : Label = $PanelContainer/VBoxContainer/GridContainer/Label4
@onready var round_text : Label = $PanelContainer/VBoxContainer/GridContainer/Label6
@onready var seed_text : Label = $PanelContainer/VBoxContainer/GridContainer/Label8
@onready var new_run : Button = $PanelContainer/VBoxContainer/VBoxContainer/Button
@onready var main_menu_button : Button = $PanelContainer/VBoxContainer/VBoxContainer/Button2

func enter():
	STooltip.close()
	
	self.self_modulate.a = 0.0
	self.show()
	panel.show()
	
	var tween = App.game_tweens.create_tween()
	tween.tween_property(self, "self_modulate:a", 1.0, 0.3)
	
	desc_text.text = tr("game_over_" + App.game_over_mark)
	App.game_over_mark = ""
	max_matching_score_text.text = "%d" % App.history.max_matching_score
	rolls_text.text = "%d" % App.history.rolls
	round_text.text = "%d" % App.round
	seed_text.text = "%X" % App.game_rng.seed

func exit():
	panel.hide()
	self.self_modulate.a = 1.0
	var tween = App.game_tweens.create_tween()
	tween.tween_property(self, "self_modulate:a", 0.0, 0.3)
	tween.tween_callback(func():
		self.hide()
	)

func _ready() -> void:
	new_run.pressed.connect(func():
		SSound.se_click.play()
		App.screen_shake_strength = 8.0
		App.exit_game()
		exit()
		
		var tween = App.game_tweens.create_tween()
		App.begin_transition(tween)
		tween.tween_callback(func():
			App.start_game()
		)
		App.end_transition(tween)
	)
	#new_run.mouse_entered.connect(SSound.se_select.play)
	main_menu_button.pressed.connect(func():
		SSound.se_click.play()
		App.screen_shake_strength = 8.0
		App.exit_game()
		exit()
		
		var tween = App.game_tweens.create_tween()
		App.begin_transition(tween)
		tween.tween_callback(func():
			App.title_ui.enter()
		)
		App.end_transition(tween)
	)
	#main_menu_button.mouse_entered.connect(SSound.se_select.play)
