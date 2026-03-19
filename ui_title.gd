extends Control

@export var title_txt : RichTextLabel
@export var title_txt_shadow : Label
@export var gems_root : Control
@export var button_list : Control
@export var continue_button : Button
@export var new_game_button : Button
@export var collections_button : Button
@export var options_button : Button
@export var quit_button : Button
@export var test_button : Button
@export var version_text : Label

func exit(tween : Tween = null) -> Tween:
	if !tween:
		tween = G.create_tween()
	tween.tween_callback(func():
		self.hide()
	)
	return tween

func enter():
	self.show()
	var tween = G.create_tween()
	return tween

func _ready() -> void:
	continue_button.pressed.connect(func():
		SSound.se_click.play()
		G.screen_shake_strength = 8.0
	)
	continue_button.mouse_entered.connect(SSound.se_select.play)
	continue_button.pressed.connect(func():
		SSound.se_click.play()
		SSound.music_more_clear()
		G.screen_shake_strength = 8.0
		
		var tween = G.create_tween()
		G.begin_transition(tween)
		exit(tween)
		tween.tween_callback(func():
			G.start_game("1")
		)
		G.end_transition(tween)
	)
	new_game_button.pressed.connect(func():
		SSound.se_click.play()
		SSound.music_more_clear()
		G.screen_shake_strength = 8.0
		
		var tween = G.create_tween()
		G.begin_transition(tween)
		exit(tween)
		tween.tween_callback(func():
			G.start_game()
		)
		G.end_transition(tween)
	)
	new_game_button.mouse_entered.connect(SSound.se_select.play)
	collections_button.pressed.connect(func():
		SSound.se_click.play()
		G.screen_shake_strength = 8.0
		G.collections_ui.enter()
	)
	collections_button.mouse_entered.connect(SSound.se_select.play)
	options_button.pressed.connect(func():
		SSound.se_click.play()
		G.screen_shake_strength = 8.0
		G.options_ui.enter()
	)
	options_button.mouse_entered.connect(SSound.se_select.play)
	quit_button.pressed.connect(func():
		get_tree().quit()
	)
	quit_button.mouse_entered.connect(SSound.se_select.play)
	test_button.pressed.connect(func():
		G.test_ui.show()
	)
	
	version_text.text = "V%d.%02d.%03d" % [G.version_major, G.version_minor, G.version_patch]
	
	const move_amount = 8.0
	var tween = G.create_tween()
	tween.tween_callback(func():
		title_txt.hide()
		title_txt_shadow.hide()
		button_list.hide()
	)
	tween.tween_property(gems_root, "position:y", 0, 1.4).from(300 * move_amount).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(G.background.material, "shader_parameter/offset:y", 0.0, 1.4).from(0.28 * move_amount).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_callback(func():
		title_txt.show()
		title_txt_shadow.show()
	)
	tween.tween_property(title_txt.material, "shader_parameter/dissolve", 1.0, 0.5).from(0.0)
	tween.parallel().tween_property(title_txt_shadow.material, "shader_parameter/dissolve", 1.0, 0.5).from(0.0)
	tween.tween_callback(func():
		button_list.show()
	)
	tween.tween_property(button_list, "position:y", 0.0, 0.3).from(100.0).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
