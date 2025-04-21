extends Control

@onready var resume_button : Button = $VBoxContainer/Button
@onready var options_button : Button = $VBoxContainer/Button2
@onready var main_menu_button : Button = $VBoxContainer/Button3
@onready var test_avg_score_button : Button = $VBoxContainer/Button4
@onready var auto_place_items_button : Button = $VBoxContainer/Button5
@onready var command_line : LineEdit = $VBoxContainer/LineEdit

func enter():
	STooltip.close()
	Game.blocker_ui.enter()
	Game.status_bar_ui.bag_button.disabled = true
	if Game.bag_viewer_ui.visible:
		Game.bag_viewer_ui.exit()
	self.show()

func exit():
	Game.blocker_ui.exit()
	Game.status_bar_ui.bag_button.disabled = false
	self.hide()
	
func _ready() -> void:
	resume_button.pressed.connect(func():
		SSound.sfx_click.play()
		exit()
	)
	options_button.pressed.connect(func():
		SSound.sfx_click.play()
		exit()
		Game.options_ui.enter()
	)
	main_menu_button.pressed.connect(func():
		SSound.sfx_click.play()
		for t in get_tree().get_processed_tweens():
			t.kill()
		exit()
		Board.cleanup()
		Game.control_ui.hide()
		Game.board_ui.hide()
		Game.game_ui.hide()
		Game.title_ui.enter()
	)
	test_avg_score_button.pressed.connect(func():
		SSound.sfx_click.play()
		STest.start_test(STest.TaskType.AvgScore, 1, 100)
		#STest.start_multiple_tests([{"type":STest.TaskType.AvgScore,"level_count":1,"tasks":100,"fn":"","setup":"res://game_setup1.ini"}])
	)
	auto_place_items_button.pressed.connect(func():
		SSound.sfx_click.play()
		exit()
		STest.auto_place_items()
	)
	command_line.text_submitted.connect(func(cl : String):
		var tks = cl.split(" ", false)
		if !tks.is_empty():
			var cmd = tks[0]
			if cmd == "test_matching":
				var coord = Vector2i(int(tks[1]), int(tks[2]))
				for p in Game.patterns:
					p.match_with(Board, coord)
	)
