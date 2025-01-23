extends Control

const ui_settlement = preload("res://ui_settlement.tscn")

@onready var title : RichTextLabel = $VBoxContainer/Label
@onready var continue_button : Button = $VBoxContainer/Button
@onready var settlement_list : VBoxContainer = $VBoxContainer
@onready var particles = $CPUParticles2D

func enter():
	Game.sound.sfx_level_clear.play()
	Game.ui_blocker.show()
	self.show()
	continue_button.hide()
	title.text = "[popup span=12.0 dura=1.2]Level Clear![/popup]"
	particles.emitting = true
	var tween = get_tree().create_tween()
	tween.tween_interval(0.6)
	tween.tween_callback(func():
		var ui_s = ui_settlement.instantiate()
		ui_s.name_str = "Level Rewards"
		ui_s.value_str = "5g"
		settlement_list.add_child(ui_s)
		settlement_list.move_child(ui_s, 1)
	)
	tween.tween_interval(0.5)
	tween.tween_interval(0.3)
	tween.tween_callback(func():
		continue_button.show()
	)

func _ready() -> void:
	continue_button.pressed.connect(func():
		Game.sound.sfx_click.play()
		for t in get_tree().get_processed_tweens():
			t.kill()
		Game.ui_blocker.hide()
		self.hide()
		Game.board.cleanup()
		Game.game_ui.hide()
		Game.game_root.hide()
		Game.shop_ui.show()
	)
	continue_button.mouse_entered.connect(Game.sound.sfx_select.play)
