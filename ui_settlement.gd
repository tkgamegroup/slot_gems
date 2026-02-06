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
	
	clear()
	
	self.self_modulate.a = 0.0
	self.show()
	panel.modulate.a = 1.0
	panel.show()
	
	var tween = G.get_tree().create_tween()
	tween.tween_property(self, "self_modulate:a", 1.0, 0.3)
	
	rewards = 0
	button.modulate.a = 0.0
	button.disabled = true
	
	tween.tween_callback(func():
		particles.emitting = true
	)
	tween.tween_interval(0.2)
	tween.tween_callback(func():
		var ui_s = item_pb.instantiate()
		ui_s.name_str = tr("ui_settlement_round_rewards")
		ui_s.value_str = "%d[img]res://images/coin.png[/img]" % G.reward
		list.add_child(ui_s)
	)
	rewards += G.reward
	if G.swaps > 0:
		tween.tween_interval(0.2)
		tween.tween_callback(func():
			var ui_s = item_pb.instantiate()
			ui_s.name_str = tr("ui_settlement_swap_rewards")
			ui_s.value_str = "%d[img]res://images/coin.png[/img]" % G.swaps
			list.add_child(ui_s)
		)
		rewards += G.swaps
	if G.coins >= 10:
		tween.tween_interval(0.2)
		tween.tween_callback(func():
			var ui_s = item_pb.instantiate()
			ui_s.name_str = tr("ui_settlement_interest")
			ui_s.value_str = "%d[img]res://images/coin.png[/img]" % int(G.coins / 10)
			list.add_child(ui_s)
		)
		rewards += int(G.coins / 10)
	tween.tween_interval(0.2)
	tween.tween_callback(func():
		G.save_to_file()
		button.modulate.a = 1.0
		button.disabled = false
	)
	button_text.text = "%s[img]res://images/coin.png[/img]" % (tr("ui_settlement_cash_out") % rewards)

func exit(trans : bool = true):
	G.coins += rewards
	
	clear()
	
	if G.round % 3 == 0:
		if trans:
			panel.modulate.a = 1.0
			var tween = G.game_tweens.create_tween()
			tween.tween_property(panel, "modulate:a", 0.0, 0.3)
			tween.tween_callback(func():
				self.hide()
				G.upgrade_ui.enter()
			)
		else:
			self.hide()
	else:
		if trans:
			panel.hide()
			self.self_modulate.a = 1.0
			
			var tween = G.game_tweens.create_tween()
			tween.tween_property(self, "self_modulate:a", 0.0, 0.3)
			tween.tween_callback(func():
				self.hide()
			)
			Board.ui.exit(tween)
			G.shop_ui.enter(tween)
		else:
			self.hide()

func _ready() -> void:
	button.pressed.connect(func():
		SSound.se_coin.play()
		exit()
	)
	#button.mouse_entered.connect(SSound.se_select.play)
