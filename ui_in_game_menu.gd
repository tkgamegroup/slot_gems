extends Control

@onready var resume_button : Button = $VBoxContainer/Button
@onready var options_button : Button = $VBoxContainer/Button2
@onready var main_menu_button : Button = $VBoxContainer/Button3

func _ready() -> void:
	resume_button.pressed.connect(func():
		Game.ui_blocker.hide()
		self.hide()
	)
	options_button.pressed.connect(func():
		self.hide()
		Game.options_ui.show()
	)
	main_menu_button.pressed.connect(func():
		for t in get_tree().get_processed_tweens():
			t.kill()
		Game.ui_blocker.hide()
		self.hide()
		Game.board.cleanup()
		Game.game_ui.hide()
		Game.game_root.hide()
		Game.status_bar.hide()
		Game.patterns_bar.hide()
		Game.title_ui.enter()
	)
