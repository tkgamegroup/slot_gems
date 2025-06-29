extends Control

const settlement_ui = preload("res://ui_settlement.tscn")

@onready var panel : PanelContainer = $PanelContainer
@onready var title : RichTextLabel = $PanelContainer/VBoxContainer/Label
@onready var button : Button = $PanelContainer/VBoxContainer/Button
@onready var button_text : RichTextLabel = $PanelContainer/VBoxContainer/Button/RichTextLabel
@onready var settlement_list : VBoxContainer = $PanelContainer/VBoxContainer/VBoxContainer
@onready var particles = $PanelContainer/CPUParticles2D
var coins = 0

func enter():
	SSound.se_well_done.play()
	STooltip.close()
	self.self_modulate.a = 0.0
	var tween = get_tree().create_tween()
	tween.tween_property(self, "self_modulate:a", 1.0, 0.3)
	
	coins = 0
	for n in settlement_list.get_children():
		settlement_list.remove_child(n)
		n.queue_free()
	button.modulate.a = 0.0
	button.disabled = true
	title.text = "[popup span=12.0 dura=1.2]%s[/popup]" % tr("ui_level_clear_title")
	particles.emitting = true
	
	tween.tween_callback(func():
		var ui_s = settlement_ui.instantiate()
		ui_s.name_str = tr("ui_level_clear_level_rewards")
		ui_s.value_str = "5[img]res://images/coin.png[/img]"
		settlement_list.add_child(ui_s)
	)
	coins += 5
	if Game.swaps > 0:
		tween.tween_interval(0.1)
		tween.tween_callback(func():
			var ui_s = settlement_ui.instantiate()
			ui_s.name_str = tr("ui_level_clear_swap_rewards")
			ui_s.value_str = "%d[img]res://images/coin.png[/img]" % Game.swaps
			settlement_list.add_child(ui_s)
		)
		coins += Game.swaps
	if Game.coins >= 10:
		tween.tween_interval(0.1)
		tween.tween_callback(func():
			var ui_s = settlement_ui.instantiate()
			ui_s.name_str = tr("ui_level_clear_interest")
			ui_s.value_str = "%d[img]res://images/coin.png[/img]" % int(Game.coins / 10)
			settlement_list.add_child(ui_s)
		)
		coins += int(Game.coins / 10)
	tween.tween_interval(0.1)
	tween.tween_callback(func():
		button.modulate.a = 1.0
		button.disabled = false
		button_text.text = "%s[img]res://images/coin.png[/img]" % (tr("ui_level_clear_button_text") % coins)
	)
	
	"""
	tween.tween_interval(0.5)
	tween.tween_callback(func():
		var reward_btn = Button.new()
		reward_btn.text = "Select a Reward"
		reward_btn.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
		settlement_list.add_child(reward_btn)
		settlement_list.move_child(reward_btn, settlement_list.get_child_count() - 2)
		reward_btn.pressed.connect(func():
			reward_btn.get_parent().remove_child(reward_btn)
			reward_btn.queue_free()
			button.disabled = false
			
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
	"""
	
	self.show()
	panel.show()

func exit():
	for t in get_tree().get_processed_tweens():
		t.custom_step(100.0)
	
	Game.coins += coins
	
	panel.hide()
	self.self_modulate.a = 1.0
	var tween = get_tree().create_tween()
	tween.tween_property(self, "self_modulate:a", 0.0, 0.3)
	tween.tween_callback(func():
		self.hide()
	)
	Game.board_ui.exit(tween)
	Game.shop_ui.enter(tween)
	return tween

func _ready() -> void:
	button.pressed.connect(func():
		SSound.se_coin.play()
		exit()
	)
	#button.mouse_entered.connect(SSound.se_select.play)
