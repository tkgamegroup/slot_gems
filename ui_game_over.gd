extends Control

@onready var max_roll_text : Label = $VBoxContainer/GridContainer/Label2
@onready var rolls_text : Label = $VBoxContainer/GridContainer/Label4
@onready var level_text : Label = $VBoxContainer/GridContainer/Label6
@onready var seed_text : Label = $VBoxContainer/GridContainer/Label8
@onready var new_run : Button = $VBoxContainer/Button
@onready var main_menu_button : Button = $VBoxContainer/Button2

func enter():
	Game.ui_blocker.show()
	self.show()
	max_roll_text.text = "%d" % Game.history.max_roll
	rolls_text.text = "%d" % Game.history.rolls
	level_text.text = "%d" % Game.level
	seed_text.text = ""
	var tween = get_tree().create_tween()
	var sb : StyleBoxFlat = Game.ui_blocker.get_theme_stylebox("panel")
	tween.tween_property(sb, "bg_color", Color(1.0, 0.2, 0.2, 0.5), 0.5)
	
func _ready() -> void:
	new_run.pressed.connect(func():
		Game.sound.sfx_click.play()
		for t in get_tree().get_processed_tweens():
			t.kill()
		Game.ui_blocker.hide()
		var sb : StyleBoxFlat = Game.ui_blocker.get_theme_stylebox("panel")
		sb.bg_color = Color(0.0, 0.0, 0.0, 80.0 / 255.0)
		self.hide()
		Game.start_new_game()
	)
	new_run.mouse_entered.connect(Game.sound.sfx_select.play)
	main_menu_button.pressed.connect(func():
		Game.sound.sfx_click.play()
		for t in get_tree().get_processed_tweens():
			t.kill()
		Game.ui_blocker.hide()
		var sb : StyleBoxFlat = Game.ui_blocker.get_theme_stylebox("panel")
		sb.bg_color = Color(0.0, 0.0, 0.0, 80.0 / 255.0)
		self.hide()
		Game.board.cleanup()
		Game.game_ui.hide()
		Game.game_root.hide()
		Game.title_ui.enter()
	)
	main_menu_button.mouse_entered.connect(Game.sound.sfx_select.play)
