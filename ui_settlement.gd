extends Control

@export var panel : PanelContainer
@export var title1 : Label
@export var title2 : Label
@export var button : Button
@export var button_text : RichTextLabel
@export var list : VBoxContainer
@export var particles : CPUParticles2D

var coin_rewards = 0

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
	title1.modulate.a = 1.0
	title1.show()
	title2.modulate.a = 1.0
	title2.hide()
	
	var tween = G.get_tree().create_tween()
	tween.tween_property(self, "self_modulate:a", 1.0, 0.3)
	
	coin_rewards = 0
	button.modulate.a = 0.0
	button.disabled = true
	
	tween.tween_callback(func():
		particles.emitting = true
	)
	tween.tween_interval(0.2)
	tween.tween_callback(func():
		var ui_s = G.settlement_item_pb.instantiate()
		ui_s.name_str = tr("ui_settlement_round_rewards")
		ui_s.value_str = "[img]res://images/coin.png[/img]%d" % G.reward
		list.add_child(ui_s)
	)
	coin_rewards += G.reward
	if G.swaps > 0:
		tween.tween_interval(0.2)
		tween.tween_callback(func():
			var ui_s = G.settlement_item_pb.instantiate()
			ui_s.name_str = tr("ui_settlement_swap_rewards")
			ui_s.value_str = "[img]res://images/coin.png[/img]%d" % G.swaps
			list.add_child(ui_s)
		)
		coin_rewards += G.swaps
	if G.coins >= 10:
		tween.tween_interval(0.2)
		tween.tween_callback(func():
			var ui_s = G.settlement_item_pb.instantiate()
			ui_s.name_str = tr("ui_settlement_interest")
			ui_s.value_str = "[img]res://images/coin.png[/img]%d" % int(G.coins / 10)
			list.add_child(ui_s)
		)
		coin_rewards += int(G.coins / 10)
	tween.tween_interval(0.2)
	tween.tween_callback(func():
		G.save_to_file()
		button.modulate.a = 1.0
		button.disabled = false
	)
	button_text.text = "%s [img]res://images/coin.png[/img]%d" % [tr("ui_settlement_receive"), coin_rewards]

func exit(tween : Tween = null, trans : bool = true):
	clear()
	
	if trans:
		panel.hide()
		self.self_modulate.a = 1.0
		if !tween:
			tween = G.create_game_tween()
		tween.tween_property(self, "self_modulate:a", 0.0, 0.3)
		tween.tween_callback(func():
			self.hide()
		)
	else:
		self.hide()

func load_from_data(data : Dictionary):
	clear()
	coin_rewards = int(data["settlement_coin_rewards"])
	button_text.text = "%s[img]res://images/coin.png[/img]" % (tr("ui_settlement_cash_out") % coin_rewards)
	button.disabled = false
	var list_data = data["settlement_list"]
	for item in list_data:
		var ui = G.settlement_item_pb.instantiate()
		ui.name_str = item["name"]
		ui.value_str = item["value"]
		list.add_child(ui)

func save_to_data(data : Dictionary):
	data["settlement_coin_rewards"] = coin_rewards
	var list_data = []
	for s in list.get_children():
		var item = {}
		item["name"] = s.name_str
		item["value"] = s.value_str
		list_data.append(item)
	data["settlement_list"] = list_data

func _ready() -> void:
	button.pressed.connect(func():
		SSound.se_coin.play()
		G.coins += coin_rewards
		
		button.hide()
		clear()
		
		var tween = G.create_game_tween()
		tween.tween_property(title1, "modulate:a", 0.0, 0.2)
		tween.tween_callback(func():
			title1.hide()
			title2.modulate.a = 0.0
			title2.show()
		)
		tween.tween_property(title2, "modulate:a", 1.0, 0.2)
		for i in 3:
			var g = Gem.new()
			g.setup(SMath.pick_random(Gem.items_pool))
			var n = 1
			var ui = G.reward_pb.instantiate()
			ui.setup("gem", g, n)
			ui.modulate.a = 0.0
			ui.gui_input.connect(func(event : InputEvent):
				if event is InputEventMouseButton:
					if event.pressed && event.button_index == MOUSE_BUTTON_LEFT:
						SSound.se_click.play()
						var tween2 = G.create_game_tween()
						tween2.tween_callback(func():
							exit()
						)
						for j in n:
							var gem = Gem.new()
							G.copy_gem(g, gem)
							G.add_gem(gem)
							var pos = G.game_ui.status_bar.bag_button.get_global_rect().get_center()
							pos -= Vector2(C.SPRITE_SZ, C.SPRITE_SZ) * 0.5
							var sp = G.create_gem_ui(g, pos + Vector2(0.0, 100.0))
							var sub = G.create_game_tween()
							sub.tween_interval(j * 0.1)
							sub.tween_property(sp.get_sp(), "modulate:a", 0.6, 0.4).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
							sub.parallel().tween_property(sp, "scale", Vector2(0.5, 0.5), 0.4)
							sub.tween_property(sp, "position", pos + Vector2(0.0, 20.0), 0.4).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
							sub.tween_callback(func():
								SSound.se_item_pickup.play()
								sp.queue_free()
							)
							if j > 0:
								tween2.parallel()
							tween2.tween_subtween(sub)
						tween2.tween_callback(func():
							G.shop_ui.enter()
						)
			)
			list.add_child(ui)
			tween.tween_property(ui, "modulate:a", 1.0, 0.2)
	)
	button.mouse_entered.connect(SSound.se_select.play)
