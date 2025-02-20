extends Control

@onready var resume_button : Button = $VBoxContainer/Button
@onready var options_button : Button = $VBoxContainer/Button2
@onready var main_menu_button : Button = $VBoxContainer/Button3
@onready var test_avg_score_button : Button = $VBoxContainer/Button4

func enter():
	Tooltip.close()
	Game.blocker_ui.enter()
	self.show()

func exit():
	Game.blocker_ui.exit()
	self.hide()
	
func _ready() -> void:
	resume_button.pressed.connect(func():
		exit()
	)
	options_button.pressed.connect(func():
		exit()
		Game.options_ui.enter()
	)
	main_menu_button.pressed.connect(func():
		for t in get_tree().get_processed_tweens():
			t.kill()
		exit()
		Game.board.cleanup()
		Game.game_ui.hide()
		Game.game_root.hide()
		Game.status_bar.hide()
		Game.skills_bar.hide()
		Game.patterns_bar.hide()
		Game.title_ui.enter()
	)
	test_avg_score_button.pressed.connect(func():
		exit()
		Test.start_test_avg_score(100)
	)
