extends Control

@onready var title_txt : Label = $Label
@onready var continue_button : Button = $Button1
@onready var new_game_button : Button = $Button2
@onready var collections_button : Button = $Button3
@onready var options_button : Button = $Button4
@onready var quit_button : Button = $Button5

func exit(tween : Tween = null) -> Tween:
	if !tween:
		tween = get_tree().create_tween()
	tween.tween_callback(func():
		self.hide()
	)
	return tween

func enter():
	self.show()
	var tween = get_tree().create_tween()
	return tween

func _ready() -> void:
	continue_button.pressed.connect(func():
		SSound.sfx_click.play()
	)
	continue_button.mouse_entered.connect(SSound.sfx_select.play)
	continue_button.pressed.connect(func():
		SSound.sfx_click.play()
		var tween = Game.blocker_ui.enter(0.5, 1.0)
		exit(tween)
		tween.tween_callback(func():
			Game.start_new_game("1")
			Game.blocker_ui.exit(0.3)
		)
	)
	new_game_button.pressed.connect(func():
		SSound.sfx_click.play()
		var tween = Game.blocker_ui.enter(0.5, 1.0)
		exit(tween)
		tween.tween_callback(func():
			Game.start_new_game()
			Game.blocker_ui.exit(0.3)
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
