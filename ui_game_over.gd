extends Control

@onready var max_matching_score_text : Label = $VBoxContainer/GridContainer/Label2
@onready var rolls_text : Label = $VBoxContainer/GridContainer/Label4
@onready var level_text : Label = $VBoxContainer/GridContainer/Label6
@onready var seed_text : Label = $VBoxContainer/GridContainer/Label8
@onready var new_run : Button = $VBoxContainer/Button
@onready var main_menu_button : Button = $VBoxContainer/Button2

func enter():
	STooltip.close()
	Game.blocker_ui.enter()
	self.show()
	max_matching_score_text.text = "%d" % Game.history.max_matching_score
	rolls_text.text = "%d" % Game.history.rolls
	level_text.text = "%d" % Game.level
	seed_text.text = ""
	var tween = get_tree().create_tween()
	var sb : StyleBoxFlat = Game.blocker_ui.get_theme_stylebox("panel")
	tween.tween_property(sb, "bg_color", Color(1.0, 0.2, 0.2, 0.5), 0.5)

func exit():
	Game.blocker_ui.exit()
	self.hide()

func _ready() -> void:
	new_run.pressed.connect(func():
		SSound.sfx_click.play()
		for t in get_tree().get_processed_tweens():
			t.kill()
		Game.blocker_ui.exit()
		var sb : StyleBoxFlat = Game.blocker_ui.get_theme_stylebox("panel")
		sb.bg_color = Color(0.0, 0.0, 0.0, 80.0 / 255.0)
		exit()
		Game.start_game()
	)
	#new_run.mouse_entered.connect(SSound.sfx_select.play)
	main_menu_button.pressed.connect(func():
		SSound.sfx_click.play()
		for t in get_tree().get_processed_tweens():
			t.kill()
		Game.blocker_ui.exit()
		var sb : StyleBoxFlat = Game.blocker_ui.get_theme_stylebox("panel")
		sb.bg_color = Color(0.0, 0.0, 0.0, 80.0 / 255.0)
		exit()
		var tween = Game.blocker_ui.enter(0.3, 1.0)
		tween.tween_callback(func():
			Game.control_ui.exit()
			Game.game_ui.hide()
			Game.title_ui.enter()
			Game.blocker_ui.exit(0.3)
		)
	)
	#main_menu_button.mouse_entered.connect(SSound.sfx_select.play)
