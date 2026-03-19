extends Control

@export var panel : PanelContainer
@export var desc_text : Label
@export var max_matching_score_text : Label
@export var round_text : Label
@export var seed_text : Label
@export var new_run : Button
@export var main_menu_button : Button

func enter():
	STooltip.close()
	
	self.self_modulate.a = 0.0
	self.show()
	panel.show()
	
	var tween = G.create_game_tween()
	tween.tween_property(self, "self_modulate:a", 1.0, 0.3)
	
	desc_text.text = tr("game_over_" + G.game_over_mark)
	G.game_over_mark = ""
	max_matching_score_text.text = "%d" % G.history.max_matching_score
	round_text.text = "%d" % G.current_round
	seed_text.text = "%X" % G.game_rng.seed

func exit(trans : bool = true):
	panel.hide()
	if trans:
		self.self_modulate.a = 1.0
		var tween = G.create_game_tween()
		tween.tween_property(self, "self_modulate:a", 0.0, 0.3)
		tween.tween_callback(func():
			self.hide()
		)
	else:
		self.hide()

func _ready() -> void:
	new_run.pressed.connect(func():
		SSound.se_click.play()
		G.screen_shake_strength = 8.0
		G.exit_game()
		exit()
		
		var tween = G.create_game_tween()
		G.begin_transition(tween)
		tween.tween_callback(func():
			G.start_game()
		)
		G.end_transition(tween)
	)
	#new_run.mouse_entered.connect(SSound.se_select.play)
	main_menu_button.pressed.connect(func():
		SSound.se_click.play()
		G.screen_shake_strength = 8.0
		G.exit_game()
		exit()
		
		var tween = G.create_game_tween()
		G.begin_transition(tween)
		tween.tween_callback(func():
			G.title_ui.enter()
		)
		G.end_transition(tween)
	)
	#main_menu_button.mouse_entered.connect(SSound.se_select.play)
