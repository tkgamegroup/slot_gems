extends Control

@export var list1 : Control
@export var list2 : Control
@export var refresh_button : Control
@export var exit_button : Button
@export var staging_slot1 : G.UiStagingSlot
@export var staging_slot2 : G.UiStagingSlot
@export var staging_slot3 : G.UiStagingSlot
@onready var staging_slots = [staging_slot1, staging_slot2, staging_slot3]

const expand_board_base_price : int = 15
var expand_board_price : int
const expand_board_price_increase : int = 10
var refresh_base_price : int = 3
var refresh_price : int
const refresh_price_increase : int = 1
var delete_price : int
const delete_price_increase : int = 1

var disabled : bool = false:
	set(v):
		disabled = v
		if v:
			Hand.ui.disabled = true
			refresh_button.disabled = true
			exit_button.disabled = true
			for n in list1.get_children():
				n.disabled = true
			for n in list2.get_children():
				n.disabled = true
		else:
			Hand.ui.disabled = false
			refresh_button.disabled = false
			exit_button.disabled = false
			for n in list1.get_children():
				n.disabled = false
			for n in list2.get_children():
				n.disabled = false

func release_stagings():
	var has = false
	if Hand.grabs.size() > G.max_hand_grabs:
		for i in Hand.grabs.size() - G.max_hand_grabs:
			Hand.discard(Hand.grabs.size() - 1)
		has = true
	return has

func clear():
	for n in list1.get_children():
		list1.remove_child(n)
		n.queue_free()
	for n in list2.get_children():
		list2.remove_child(n)
		n.queue_free()

func refresh_prices():
	for n in list1.get_children():
		n.refresh_price()

func buy_randomly():
	if randi() % 2 < 1:
		var item = list1.get_child(randi() % list1.get_child_count())
		if item:
			return item.buy()
	else:
		var item = list2.get_child(randi() % list2.get_child_count())
		if item:
			return item.buy()
	return false

const items_pool = ["Ruby", "Heliodor", "Emerald", "Sapphire", "Amethyst", "Flag", "Coin", "Bomb", "C4", "Rainbow", "Orange", "IaiCut", "Lightning", "EnergyDrink", "Badge", "Magnet", "Volcano", "PolishingPowder"]
const relics_pool = ["PaintingOfRed", "PaintingOfOrange", "PaintingOfGreen", "PaintingOfBlue", "PaintingOfMagenta", "PaintingOfWave", "PaintingOfCircle", "PaintingOfStar", "Amplifier", "Recorder", "GhostAmmo", "Multicast", "MobiusStrip", "Premeditation", "PentagramPower", "HalfPriceCoupon"]

const patterns_pool = ["\\", "|", "/", "O", "√", "X", "Island"]

func refresh(tween : Tween = null):
	if !tween:
		tween = G.create_game_tween()
	
	self.disabled = true
	
	clear()
	
	var relics_pool2 = []
	var explode_ability = false
	for g in G.gems:
		if g.category == "Bomb":
			explode_ability = true
			break
	for n in relics_pool:
		var has = false
		if !explode_ability:
			if n == "":
				continue
		for r in G.relics:
			if r.name == n:
				has = true
				break
		if !has:
			relics_pool2.append(n)
	var patterns_pool2 = []
	for n in patterns_pool:
		var has = false
		for p in G.patterns:
			if p.name == n:
				has = true
				break
		if !has:
			patterns_pool2.append(n)
			
	for i in 3:
		tween.tween_interval(0.04)
		tween.tween_callback(func():
			var ui = G.shop_item_pb.instantiate()
			var gem = Gem.new()
			var price = 0
			var quantity = 1
			if G.shop_rng.randf() > 0.2:
				if G.shop_rng.randf() > 0.5:
					gem.type = G.shop_rng.randi() % Gem.ColorCount + Gem.ColorFirst
					gem.rune = G.shop_rng.randi() % Gem.RuneCount + Gem.RuneFirst
					if G.shop_rng.randf() > 0.5:
						price = 1
						quantity = 5
					else:
						price = 0
						quantity = 1
				else:
					if G.shop_rng.randf() > 0.7:
						gem.type = G.shop_rng.randi() % Gem.ColorCount + Gem.ColorFirst
						gem.rune = G.shop_rng.randi() % Gem.RuneCount + Gem.RuneFirst
						if G.shop_rng.randf() > 0.5:
							G.enchant_gem(gem, "w_enchant_charming")
						else:
							G.enchant_gem(gem, "w_enchant_sharp")
						price = 2
					else:
						gem.setup(SMath.pick_random(items_pool, G.shop_rng))
						price = 2
			else:
				if G.shop_rng.randf() > 0.5:
					gem.type = Gem.ColorWild
					gem.rune = G.shop_rng.randi() % Gem.RuneCount + Gem.RuneFirst
					price = 5
				else:
					gem.type = G.shop_rng.randi() % Gem.ColorCount + Gem.ColorFirst
					gem.rune = Gem.RuneOmni
					price = 5
			ui.setup("gem", gem, price, quantity)
			list1.add_child(ui)
		)
	for i in 2:
		if relics_pool2.is_empty() && patterns_pool2.is_empty():
			break
		if G.shop_rng.randf() > 0.3 && !relics_pool2.is_empty():
			tween.tween_interval(0.04)
			tween.tween_callback(func():
				var ui = G.shop_item_pb.instantiate()
				var relic = Relic.new()
				relic.setup(SMath.pick_and_remove(relics_pool2, G.shop_rng))
				ui.setup("relic", relic, relic.price)
				list1.add_child(ui)
			)
		elif !patterns_pool2.is_empty():
			tween.tween_interval(0.04)
			tween.tween_callback(func():
				var ui = G.shop_item_pb.instantiate()
				var pattern = Pattern.new()
				pattern.setup(SMath.pick_random(patterns_pool2, G.shop_rng))
				ui.setup("pattern", pattern, pattern.price)
				list1.add_child(ui)
			)
	var slots = 3
	for i in 3:
		if slots <= 0:
			break
		tween.tween_interval(0.04)
		if G.shop_rng.randf() >= 0.4:
			if slots >= 2 && G.shop_rng.randf() >= 0.9:
				tween.tween_callback(func():
					var ui = G.entangle_slots_pb.instantiate()
					ui.setup(3)
					list2.add_child(ui)
				)
				slots -= 2
			else:
				if G.shop_rng.randf() >= 0.5:
					tween.tween_callback(func():
						var ui = G.craft_slot_pb.instantiate()
						ui.setup("w_enchant", "w_enchant_charming", 2)
						list2.add_child(ui)
					)
					slots -= 1
				else:
					tween.tween_callback(func():
						var ui = G.craft_slot_pb.instantiate()
						ui.setup("w_enchant", "w_enchant_sharp", 2)
						list2.add_child(ui)
					)
					slots -= 1
		else:
			if G.shop_rng.randf() >= 0.3:
				if G.shop_rng.randf() >= 0.5:
					tween.tween_callback(func():
						var ui = G.craft_slot_pb.instantiate()
						ui.setup("w_delete", "", delete_price)
						list2.add_child(ui)
					)
					slots -= 1
				else:
					tween.tween_callback(func():
						var ui = G.craft_slot_pb.instantiate()
						ui.setup("w_duplicate", "", 4)
						list2.add_child(ui)
					)
					slots -= 1
			else:
				if G.shop_rng.randf() >= 0.5:
					tween.tween_callback(func():
						var ui = G.craft_slot_pb.instantiate()
						ui.setup("w_enchant", "w_wild", 6)
						list2.add_child(ui)
					)
					slots -= 1
				else:
					tween.tween_callback(func():
						var ui = G.craft_slot_pb.instantiate()
						ui.setup("w_enchant", "w_omni", 6)
						list2.add_child(ui)
					)
					slots -= 1
	tween.tween_callback(func():
		self.disabled = false
		G.save_to_file()
	)
	return tween

func enter(tween : Tween = null, do_refresh : bool = true):
	if !tween:
		tween = G.create_game_tween()
	
	self.disabled = true
	
	self.show()
	self.material.set_shader_parameter("x_rot", -90.0)
	
	G.control_ui.undo_button.disabled = true
	G.control_ui.shuffle_button.disabled = true
	G.control_ui.play_button.disabled = true
	G.control_ui.last_play.hide()
	for n in staging_slots:
		n.disabled = true
	G.stage = G.Stage.Shopping
	
	var sub1 = G.create_game_tween()
	var sub2 = G.create_game_tween()
	sub1.tween_property(self.material, "shader_parameter/x_rot", 0.0, 0.5).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
	sub2.parallel().tween_property(G.game_ui.status_bar.round_text, "modulate:a", 0.0, 0.3)
	sub2.parallel().tween_property(G.game_ui.status_bar.round_target, "modulate:a", 0.0, 0.3)
	sub2.tween_callback(func():
		G.score = 0
		G.game_ui.status_bar.round_text.text = tr("ui_shop_title")
		G.game_ui.status_bar.round_target.text = "[wave amp=10.0 freq=-1.0]%s[/wave]" % tr("ui_shop_target")
	)
	sub2.tween_property(G.game_ui.status_bar.round_text, "modulate:a", 1.0, 0.3)
	sub2.parallel().tween_property(G.game_ui.status_bar.round_target, "modulate:a", 1.0, 0.3)
	tween.tween_subtween(sub1)
	tween.parallel().tween_subtween(sub2)
	tween.parallel().tween_property(G.background.material, "shader_parameter/color", Color(0.71, 0.703, 0.504), 0.8)
	
	refresh_price = refresh_base_price
	refresh_button.text.text = "%s [img]res://images/coin.png[/img]%d" % [tr("ui_shop_refresh"), refresh_price]
	
	delete_price = 0
	
	if do_refresh:
		refresh(tween)
	tween.tween_callback(func():
		self.disabled = false
	)
	
	return tween

func exit(tween : Tween = null, trans : bool = true):
	if trans:
		disabled = true
		if !tween:
			tween = G.create_game_tween()
		if release_stagings():
			tween.tween_interval(0.4)
		tween.tween_property(self.material, "shader_parameter/x_rot", 90.0, 0.5).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
		tween.parallel().tween_property(G.background.material, "shader_parameter/color", Color(0.917, 0.921, 0.65), 0.8)
		tween.parallel().tween_property(G.game_ui.status_bar.round_text, "modulate:a", 0.0, 0.3)
		tween.parallel().tween_property(G.game_ui.status_bar.round_target, "modulate:a", 0.0, 0.3)
		tween.tween_callback(func():
			clear()
			self.hide()
			disabled = false
		)
		if !Board.ui.visible:
			Board.ui.enter(tween, true)
			G.next_round(tween)
	else:
		release_stagings()
		clear()
		self.hide()
	return tween

func load_from_data(data : Dictionary):
	refresh_price = int(data["shop_refresh_price"])
	expand_board_price = data["shop_expand_board_price"]
	clear()
	var list1_data = data["shop_list1"]
	for item in list1_data:
		var ui = G.shop_item_pb.instantiate()
		var cate = item["cate"]
		if cate == "gem":
			var object = item["object"]
			var g = Gem.new()
			g.type = object["type"]
			g.rune = object["rune"]
			g.base_score = int(object["base_score"])
			var buffs = object["buffs"]
			for buff in buffs:
				Buff.load_from_data(g, buff)
			ui.setup("gem", g, item["price"])
		elif cate == "relic":
			var object = item["object"]
			var r = Relic.new()
			r.setup(object["name"])
			ui.setup("relic", r, item["price"])
		list1.add_child(ui)
	var list2_data = data["shop_list2"]
	for slot in list2_data:
		var ui = G.craft_slot_pb.instantiate()
		ui.setup(slot["type"], slot["thing"], slot["price"])
		list2.add_child(ui)

func save_to_data(data : Dictionary):
	data["shop_refresh_price"] = refresh_price
	data["shop_expand_board_price"] = expand_board_price
	var list1_data = []
	for n in list1.get_children():
		var ui = n as G.UiShopItem
		var item = {}
		item["cate"] = ui.cate
		if ui.cate == "gem":
			var g = ui.object as Gem
			var object = {}
			object["type"] = g.type
			object["rune"] = g.rune
			object["base_score"] = g.base_score
			var buffs = []
			for b in g.buffs:
				var buff = {}
				Buff.save_to_data(b, buff)
				buffs.append(buff)
			object["buffs"] = buffs
			item["object"] = object
		elif ui.cate == "relic":
			var r = ui.object as Relic
			var object = {}
			object["name"] = r.name
			item["object"] = object
		item["price"] = ui.price
		list1_data.append(item)
	data["shop_list1"] = list1_data
	var list2_data = []
	for n in list2.get_children():
		if n is G.UiCraftSlot:
			var ui = n as G.UiCraftSlot
			var slot = {}
			slot["type"] = ui.type
			slot["thing"] = ui.thing
			slot["price"] = ui.price
			list2_data.append(slot)
		else:
			pass
	data["shop_list2"] = list2_data

func _ready() -> void:
	self.pivot_offset = self.size * 0.5
	
	exit_button.pressed.connect(func():
		SSound.se_click.play()
		G.screen_shake_strength = 8.0
		exit()
	)
	#exit_button.mouse_entered.connect(SSound.se_select.play)
	refresh_button.button.pressed.connect(func():
		if G.coins < refresh_price:
			G.game_ui.status_bar.coins_text.hint()
			return
		SSound.se_coin.play()
		G.coins -= refresh_price
		
		refresh_price += refresh_price_increase
		refresh_button.text.text = "%s %d[img]res://images/coin.png[/img]" % [tr("ui_shop_refresh"), refresh_price]
		
		refresh()
	)
