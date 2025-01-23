extends Control

@onready var title_txt : Label = $Label
@onready var new_game_button : Button = $Button
@onready var options_button : Button = $Button3
@onready var quit_button : Button = $Button2

func exit() -> Tween:
	var tween = get_tree().create_tween()
	var p0 = title_txt.position
	var p1 = new_game_button.position
	var p2 = options_button.position
	var p3 = quit_button.position
	tween.tween_property(title_txt, "position", title_txt.position - Vector2(0, 300), 0.3)
	tween.parallel().tween_property(new_game_button, "position", new_game_button.position + Vector2(0, 500), 0.3)
	tween.parallel().tween_property(options_button, "position", options_button.position + Vector2(0, 500), 0.3)
	tween.parallel().tween_property(quit_button, "position", quit_button.position + Vector2(0, 500), 0.3)
	tween.tween_callback(func():
		self.hide()
		title_txt.position = p0
		new_game_button.position = p1
		options_button.position = p2
		quit_button.position = p3
	)
	return tween

func enter():
	self.show()
	var tween = get_tree().create_tween()
	var p0 = title_txt.position
	title_txt.position = p0  - Vector2(0, 300)
	tween.tween_property(title_txt, "position", p0, 0.3)
	var p1 = new_game_button.position
	new_game_button.position = p1 + Vector2(0, 500)
	tween.parallel().tween_property(new_game_button, "position", p1, 0.3)
	var p2 = options_button.position
	options_button.position = p2 + Vector2(0, 500)
	tween.parallel().tween_property(options_button, "position", p2, 0.3)
	var p3 = quit_button.position
	quit_button.position = p3 + Vector2(0, 500)
	tween.parallel().tween_property(quit_button, "position", p3, 0.3)

func _ready() -> void:
	new_game_button.pressed.connect(func():
		Game.sound.sfx_click.play()
		var tween = exit()
		tween.tween_callback(func():
			Game.sound.sfx_board_setup.play()
			Game.start_new_game()
		)
	)
	new_game_button.mouse_entered.connect(Game.sound.sfx_select.play)
	options_button.pressed.connect(func():
		Game.sound.sfx_click.play()
		Game.ui_blocker.show()
		Game.options_ui.show()
	)
	options_button.mouse_entered.connect(Game.sound.sfx_select.play)
	quit_button.pressed.connect(func():
		Game.sound.sfx_click.play()
		Game.ui_blocker.show()
		var tween = get_tree().create_tween()
		tween.tween_interval(0.3)
		tween.tween_callback(func():
			get_tree().quit()
		)
	)
	quit_button.mouse_entered.connect(Game.sound.sfx_select.play)
