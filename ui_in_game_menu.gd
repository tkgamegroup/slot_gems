extends Control

@onready var resume_button : Button = $VBoxContainer/Button
@onready var options_button : Button = $VBoxContainer/Button2
@onready var main_menu_button : Button = $VBoxContainer/Button3
@onready var auto_place_items_button : Button = $VBoxContainer/Button4

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
		var tween = Game.get_tree().create_tween()
		Game.begin_transition(tween)
		tween.tween_callback(func():
			Game.control_ui.exit()
			Game.game_ui.hide()
			Game.title_ui.enter()
		)
		Game.end_transition(tween)
	)
	auto_place_items_button.pressed.connect(func():
		SSound.sfx_click.play()
		exit()
		STest.auto_place_items()
	)
