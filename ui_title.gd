extends Control

@onready var title_txt : Label = $Label
@onready var new_game_button : Button = $Button
@onready var collections_button : Button = $Button2
@onready var options_button : Button = $Button3
@onready var quit_button : Button = $Button4

func exit() -> Tween:
	var tween = get_tree().create_tween()
	var p0 = title_txt.position
	var p1 = new_game_button.position
	var p2 = collections_button.position
	var p3 = options_button.position
	var p4 = quit_button.position
	tween.tween_property(title_txt, "position", title_txt.position - Vector2(0, 300), 0.3)
	tween.parallel().tween_property(new_game_button, "position", new_game_button.position + Vector2(0, 500), 0.3)
	tween.parallel().tween_property(collections_button, "position", collections_button.position + Vector2(0, 500), 0.3)
	tween.parallel().tween_property(options_button, "position", options_button.position + Vector2(0, 500), 0.3)
	tween.parallel().tween_property(quit_button, "position", quit_button.position + Vector2(0, 500), 0.3)
	tween.tween_callback(func():
		self.hide()
		title_txt.position = p0
		new_game_button.position = p1
		collections_button.position = p2
		options_button.position = p3
		quit_button.position = p4
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
	var p2 = collections_button.position
	collections_button.position = p2 + Vector2(0, 500)
	tween.parallel().tween_property(collections_button, "position", p2, 0.3)
	var p3 = options_button.position
	options_button.position = p3 + Vector2(0, 500)
	tween.parallel().tween_property(options_button, "position", p3, 0.3)
	var p4 = quit_button.position
	quit_button.position = p4 + Vector2(0, 500)
	tween.parallel().tween_property(quit_button, "position", p4, 0.3)

func _ready() -> void:
	new_game_button.pressed.connect(func():
		SSound.sfx_click.play()
		var tween = exit()
		tween.tween_callback(func():
			Game.start_new_game()
		)
	)
	new_game_button.mouse_entered.connect(SSound.sfx_select.play)
	collections_button.pressed.connect(func():
		SSound.sfx_click.play()
		
	)
	collections_button.mouse_entered.connect(SSound.sfx_select.play)
	options_button.pressed.connect(func():
		SSound.sfx_click.play()
		Game.options_ui.enter()
	)
	options_button.mouse_entered.connect(SSound.sfx_select.play)
	quit_button.pressed.connect(func():
		SSound.sfx_click.play()
		Game.blocker_ui.enter()
		var tween = get_tree().create_tween()
		tween.tween_interval(0.3)
		tween.tween_callback(func():
			get_tree().quit()
		)
	)
	quit_button.mouse_entered.connect(SSound.sfx_select.play)
