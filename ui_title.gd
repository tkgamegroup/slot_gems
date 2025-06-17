extends Control

@onready var title_txt : Label = $Label
@onready var continue_button : Button = $Button1
@onready var new_game_button : Button = $Button2
@onready var collections_button : Button = $Button3
@onready var options_button : Button = $Button4
@onready var quit_button : Button = $Button5
@onready var version_text : Label = $Version

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
		SSound.se_click.play()
	)
	continue_button.mouse_entered.connect(SSound.se_select.play)
	continue_button.pressed.connect(func():
		SSound.se_click.play()
		var tween = Game.get_tree().create_tween()
		Game.begin_transition(tween)
		exit(tween)
		tween.tween_callback(func():
			Game.start_game("1")
		)
		Game.end_transition(tween)
	)
	new_game_button.pressed.connect(func():
		SSound.se_click.play()
		var tween = Game.get_tree().create_tween()
		Game.begin_transition(tween)
		exit(tween)
		tween.tween_callback(func():
			Game.start_game()
		)
		Game.end_transition(tween)
	)
	new_game_button.mouse_entered.connect(SSound.se_select.play)
	collections_button.pressed.connect(func():
		SSound.se_click.play()
		Game.collections_ui.enter()
	)
	collections_button.mouse_entered.connect(SSound.se_select.play)
	options_button.pressed.connect(func():
		SSound.se_click.play()
		Game.options_ui.enter()
	)
	options_button.mouse_entered.connect(SSound.se_select.play)
	quit_button.pressed.connect(func():
		get_tree().quit()
	)
	quit_button.mouse_entered.connect(SSound.se_select.play)
	
	version_text.text = "V%d.%02d.%03d" % [Game.version_major, Game.version_minor, Game.version_patch]
