extends Control

const settlement_ui = preload("res://ui_settlement.tscn")

@onready var title : RichTextLabel = $PanelContainer/VBoxContainer/Label
@onready var continue_button : Button = $PanelContainer/VBoxContainer/Button
@onready var settlement_list : VBoxContainer = $PanelContainer/VBoxContainer/VBoxContainer
@onready var particles = $PanelContainer/CPUParticles2D
var rewards_count = 0
var coins = 0

func enter():
	SSound.sfx_level_clear.play()
	STooltip.close()
	self.self_modulate.a = 0.0
	var tween = get_tree().create_tween()
	tween.tween_property(self, "self_modulate:a", 1.0, 0.3)
	
	coins = 0
	for n in settlement_list.get_children():
		settlement_list.remove_child(n)
		n.queue_free()
	continue_button.disabled = true
	continue_button.hide()
	title.text = "[popup span=12.0 dura=1.2]Level Clear![/popup]"
	particles.emitting = true
	
	tween.tween_callback(func():
		var ui_s = settlement_ui.instantiate()
		ui_s.name_str = "Level Rewards"
		ui_s.value_str = "5[img]res://images/coin.png[/img]"
		settlement_list.add_child(ui_s)
	)
	coins += 5
	tween.tween_interval(0.3)
	tween.tween_callback(func():
		var ui_s = settlement_ui.instantiate()
		ui_s.name_str = "Rolls"
		ui_s.value_str = "%d[img]res://images/coin.png[/img]" % Game.rolls
		settlement_list.add_child(ui_s)
	)
	coins += Game.rolls
	tween.tween_interval(0.2)
	tween.tween_callback(func():
		rewards_count += 1
		var reward_btn = Button.new()
		reward_btn.text = " "
		var txt = RichTextLabel.new()
		txt.bbcode_enabled = true
		txt.fit_content = true
		txt.autowrap_mode = TextServer.AUTOWRAP_OFF
		txt.text = "Take %d[img]res://images/coin.png[/img]" % coins
		txt.mouse_filter = Control.MOUSE_FILTER_IGNORE
		reward_btn.add_child(txt)
		reward_btn.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
		settlement_list.add_child(reward_btn)
		txt.set_anchors_and_offsets_preset(Control.PRESET_CENTER, Control.PRESET_MODE_KEEP_SIZE)
		reward_btn.pressed.connect(func():
			SSound.sfx_coin.play()
			reward_btn.get_parent().remove_child(reward_btn)
			reward_btn.queue_free()
			rewards_count -= 1
			exit()
		)
	)
	
	"""
	tween.tween_interval(0.5)
	tween.tween_callback(func():
		rewards_count += 1
		var reward_btn = Button.new()
		reward_btn.text = "Select a Reward"
		reward_btn.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
		settlement_list.add_child(reward_btn)
		settlement_list.move_child(reward_btn, settlement_list.get_child_count() - 2)
		reward_btn.pressed.connect(func():
			reward_btn.get_parent().remove_child(reward_btn)
			reward_btn.queue_free()
			rewards_count -= 1
			if rewards_count == 0:
				continue_button.disabled = false
			
			var rewards = []
			
			var r1 = {}
			r1.icon = "res://images/add_gems.png"
			r1.title = "Add Gems"
			r1.description = "Add 5 gems with 4 base score. You can choose what color to add."
			rewards.append(r1)
			
			var r2 = {}
			r2.icon = "res://images/trash_bin.png"
			r2.title = "Remove Gems"
			r2.description = "Remove up to 5 basic gems. You can choose what color to remove."
			rewards.append(r2)
			
			Game.choose_reward_ui.enter(rewards, func(idx : int, tween : Tween, img : Sprite2D):
				if idx == 0:
					tween.tween_callback(func():
					)
				elif idx == 1:
					tween.tween_callback(func():
					)
			)
		)
	)
	tween.tween_interval(0.3)
	tween.tween_callback(func():
		continue_button.show()
	)
	"""
	
	self.show()

func exit():
	self.hide()
	
	Game.coins += coins
	
	for t in get_tree().get_processed_tweens():
		t.kill()
	Game.control_ui.exit()
	Game.shop_ui.enter()

func _ready() -> void:
	continue_button.pressed.connect(func():
		SSound.sfx_click.play()
		exit()
	)
	#continue_button.mouse_entered.connect(SSound.sfx_select.play)
