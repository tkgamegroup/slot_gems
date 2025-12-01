extends Control

const item_pb = preload("res://ui_settlement_item.tscn")

@onready var panel : PanelContainer = $PanelContainer
@onready var button : Button = $PanelContainer/VBoxContainer/Button
@onready var button_text : RichTextLabel = $PanelContainer/VBoxContainer/Button/RichTextLabel
@onready var list : VBoxContainer = $PanelContainer/VBoxContainer/VBoxContainer
@onready var particles = $PanelContainer/CPUParticles2D

var rewards = 0

func clear():
	for n in list.get_children():
		list.remove_child(n)
		n.queue_free()

func enter():
	SSound.se_well_done.play()
	STooltip.close()
	
	self.self_modulate.a = 0.0
	self.show()
	panel.modulate.a = 1.0
	panel.show()
	
	var tween = App.game_tweens.create_tween()
	tween.tween_property(self, "self_modulate:a", 1.0, 0.3)
	
	rewards = 0
	button.disabled = true
	
	tween.tween_callback(func():
		particles.emitting = true
	)
	tween.tween_interval(0.2)
	tween.tween_callback(func():
		var ui_s = item_pb.instantiate()
		ui_s.name_str = tr("ui_settlement_round_rewards")
		ui_s.value_str = "%d[img]res://images/coin.png[/img]" % App.reward
		list.add_child(ui_s)
	)
	rewards += App.reward
	if App.swaps > 0:
		tween.tween_interval(0.2)
		tween.tween_callback(func():
			var ui_s = item_pb.instantiate()
			ui_s.name_str = tr("ui_settlement_swap_rewards")
			ui_s.value_str = "%d[img]res://images/coin.png[/img]" % App.swaps
			list.add_child(ui_s)
		)
		rewards += App.swaps
	if App.coins >= 10:
		tween.tween_interval(0.2)
		tween.tween_callback(func():
			var ui_s = item_pb.instantiate()
			ui_s.name_str = tr("ui_settlement_interest")
			ui_s.value_str = "%d[img]res://images/coin.png[/img]" % int(App.coins / 10)
			list.add_child(ui_s)
		)
		rewards += int(App.coins / 10)
	tween.tween_interval(0.2)
	tween.tween_callback(func():
		App.save_to_file()
		button.disabled = false
	)
	button_text.text = "%s[img]res://images/coin.png[/img]" % (tr("ui_settlement_cash_out") % rewards)

func exit(trans : bool = true):
	App.coins += rewards
	
	clear()
	
	if true:
		if trans:
			panel.modulate.a = 1.0
			var tween = App.game_tweens.create_tween()
			tween.tween_property(panel, "modulate:a", 0.0, 0.3)
			tween.tween_callback(func():
				clear()
				self.hide()
				App.upgrade_ui.enter()
			)
		else:
			clear()
			self.hide()
	else:
		if trans:
			panel.hide()
			self.self_modulate.a = 1.0
			
			var tween = App.game_tweens.create_tween()
			tween.tween_property(self, "self_modulate:a", 0.0, 0.3)
			tween.tween_callback(func():
				clear()
				self.hide()
			)
			Board.ui.exit(tween)
			App.shop_ui.enter(tween)
		else:
			clear()
			self.hide()

func _ready() -> void:
	button.pressed.connect(func():
		SSound.se_coin.play()
		exit()
	)
	#button.mouse_entered.connect(SSound.se_select.play)
