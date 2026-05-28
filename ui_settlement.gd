extends Control

@export var panel : PanelContainer
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
		ui_s.value_str = "%d[img]res://images/coin.png[/img]" % G.reward
		list.add_child(ui_s)
	)
	coin_rewards += G.reward
	if G.swaps > 0:
		tween.tween_interval(0.2)
		tween.tween_callback(func():
			var ui_s = G.settlement_item_pb.instantiate()
			ui_s.name_str = tr("ui_settlement_swap_rewards")
			ui_s.value_str = "%d[img]res://images/coin.png[/img]" % G.swaps
			list.add_child(ui_s)
		)
		coin_rewards += G.swaps
	if G.coins >= 10:
		tween.tween_interval(0.2)
		tween.tween_callback(func():
			var ui_s = G.settlement_item_pb.instantiate()
			ui_s.name_str = tr("ui_settlement_interest")
			ui_s.value_str = "%d[img]res://images/coin.png[/img]" % int(G.coins / 10)
			list.add_child(ui_s)
		)
		coin_rewards += int(G.coins / 10)
	tween.tween_interval(0.2)
	tween.tween_callback(func():
		G.save_to_file()
		button.modulate.a = 1.0
		button.disabled = false
	)
	button_text.text = "%s[img]res://images/coin.png[/img]" % (tr("ui_settlement_cash_out") % coin_rewards)

const items_pool = ["Ruby", "Heliodor", "Emerald", "Sapphire", "Amethyst", "Flag", "Bomb"]

func choose_reward(rewards : Array, idx : int):
	var tween = G.create_game_tween()
	if rewards[idx].cate == "gem":
		for i in rewards[idx].quantity:
			var gem = Gem.new()
			G.copy_gem(rewards[idx].object, gem)
			G.add_gem(gem)
			var sub = G.create_game_tween()
			sub.tween_interval(i * 0.1)
			var ui = G.create_gem_ui(gem, G.choose_reward_ui.reward_list.get_child(idx).content.get_global_rect().get_center())
			sub.tween_property(ui, "scale", Vector2(0.7, 0.7), 0.4)
			sub.parallel()
			SAnimation.quadratic_curve_to(sub, ui, G.game_ui.status_bar.bag_button.global_position, Vector2(0.5, 0.2), 0.4)
			sub.tween_callback(func():
				ui.queue_free()
			)
			if i > 0:
				tween.parallel()
			tween.tween_subtween(sub)
	tween.tween_callback(func():
		G.shop_ui.enter()
	)

func exit(trans : bool = true):
	G.coins += coin_rewards
	
	clear()
	
	if trans:
		panel.hide()
		self.self_modulate.a = 1.0
		
		var tween = G.create_game_tween()
		tween.tween_property(self, "self_modulate:a", 0.0, 0.3)
		tween.tween_callback(func():
			self.hide()
		)
		var rewards = []
		for i in 3:
			var g = Gem.new()
			g.setup(SMath.pick_random(items_pool))
			var r = {}
			r.cate = "gem"
			r.object = g
			r.quantity = 1
			rewards.append(r)
		G.choose_reward_ui.enter(rewards, choose_reward, tween)
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
		exit()
	)
	#button.mouse_entered.connect(SSound.se_select.play)
