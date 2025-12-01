extends Control

@onready var title_txt : RichTextLabel = $MarginContainer2/Control/Text
@onready var title_txt_shadow : Label = $MarginContainer2/Control/Shadow
@onready var gems_root : Control = $Control
@onready var button_list : Control = $MarginContainer/PanelContainer
@onready var continue_button : Button = $MarginContainer/PanelContainer/HBoxContainer/Button1
@onready var new_game_button : Button = $MarginContainer/PanelContainer/HBoxContainer/Button2
@onready var collections_button : Button = $MarginContainer/PanelContainer/HBoxContainer/Button3
@onready var options_button : Button = $MarginContainer/PanelContainer/HBoxContainer/Button4
@onready var quit_button : Button = $MarginContainer/PanelContainer/HBoxContainer/Button5
@onready var version_text : Label = $Version

func exit(tween : Tween = null) -> Tween:
	if !tween:
		tween = App.create_tween()
	tween.tween_callback(func():
		self.hide()
	)
	return tween

func enter():
	self.show()
	var tween = App.create_tween()
	return tween

func _ready() -> void:
	continue_button.pressed.connect(func():
		SSound.se_click.play()
		App.screen_shake_strength = 8.0
	)
	continue_button.mouse_entered.connect(SSound.se_select.play)
	continue_button.pressed.connect(func():
		SSound.se_click.play()
		SSound.music_more_clear()
		App.screen_shake_strength = 8.0
		
		var tween = App.create_tween()
		App.begin_transition(tween)
		exit(tween)
		tween.tween_callback(func():
			App.start_game("1")
		)
		App.end_transition(tween)
	)
	new_game_button.pressed.connect(func():
		SSound.se_click.play()
		SSound.music_more_clear()
		App.screen_shake_strength = 8.0
		
		var tween = App.create_tween()
		App.begin_transition(tween)
		exit(tween)
		tween.tween_callback(func():
			App.start_game()
		)
		App.end_transition(tween)
	)
	new_game_button.mouse_entered.connect(SSound.se_select.play)
	collections_button.pressed.connect(func():
		SSound.se_click.play()
		App.screen_shake_strength = 8.0
		App.collections_ui.enter()
	)
	collections_button.mouse_entered.connect(SSound.se_select.play)
	options_button.pressed.connect(func():
		SSound.se_click.play()
		App.screen_shake_strength = 8.0
		App.options_ui.enter()
	)
	options_button.mouse_entered.connect(SSound.se_select.play)
	quit_button.pressed.connect(func():
		get_tree().quit()
	)
	quit_button.mouse_entered.connect(SSound.se_select.play)
	
	version_text.text = "V%d.%02d.%03d" % [App.version_major, App.version_minor, App.version_patch]
	
	const move_amount = 8.0
	var tween = App.create_tween()
	tween.tween_callback(func():
		title_txt.hide()
		title_txt_shadow.hide()
		button_list.hide()
	)
	tween.tween_property(gems_root, "position:y", 0, 2.0).from(300 * move_amount).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(App.background.material, "shader_parameter/offset:y", 0.0, 2.0).from(0.28 * move_amount).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_callback(func():
		title_txt.show()
		title_txt_shadow.show()
	)
	tween.tween_property(title_txt.material, "shader_parameter/dissolve", 1.0, 1.0).from(0.0)
	tween.parallel().tween_property(title_txt_shadow.material, "shader_parameter/dissolve", 1.0, 1.0).from(0.0)
	tween.tween_callback(func():
		button_list.show()
	)
	tween.tween_property(button_list, "position:y", 0.0, 0.5).from(100.0).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
