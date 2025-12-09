extends Control

const shop_item_pb = preload("res://ui_shop_item.tscn")
const craft_slot_pb = preload("res://craft_slot.tscn")
const gem_ui = preload("res://ui_gem.tscn")

@onready var list1 : Control = $SubViewport/Panel/HBoxContainer/VBoxContainer/HBoxContainer
@onready var list2 : Control = $SubViewport/Panel/HBoxContainer/VBoxContainer/HBoxContainer2
@onready var refresh_button : Control = $SubViewport/Panel/HBoxContainer/VBoxContainer2/RichButton
@onready var exit_button : Button = $SubViewport/Panel/HBoxContainer/VBoxContainer2/Button

const expand_board_base_price : int = 15
var expand_board_price : int
const expand_board_price_increase : int = 10
var refresh_base_price : int = 3
var refresh_price : int
const refresh_price_increase : int = 1
var delete_price : int
const delete_price_increase : int = 1

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

const items_pool = ["Flag", "Bomb", "C4", "Rainbow", "Ruby", "Heliodor", "Emerald", "Sapphire", "Amethyst"]
const relics_pool = ["ExplosionScience", "HighExplosives", "MobiusStrip", "Premeditation", "PentagramPower", "PaintingOfRed", "PaintingOfOrange", "PaintingOfGreen", "PaintingOfBlue", "PaintingOfMagenta", "PaintingOfWave", "PaintingOfPalm", "PaintingOfStarfish", "HalfPriceCoupon"]

func refresh(tween : Tween = null):
	if !tween:
		tween = App.game_tweens.create_tween()
	
	App.control_ui.play_button.disabled = true
	Hand.ui.disabled = true
	refresh_button.disabled = true
	
	clear()
	
	for i in 3:
		tween.tween_interval(0.04)
		tween.tween_callback(func():
			var ui = shop_item_pb.instantiate()
			var gem = Gem.new()
			var price = 0
			var quantity = 1
			if App.shop_rng.randf() > 0.2:
				if App.shop_rng.randf() > 0.5:
					gem.type = App.shop_rng.randi() % Gem.ColorCount + Gem.ColorFirst
					gem.rune = App.shop_rng.randi() % Gem.RuneCount + Gem.RuneFirst
					if App.shop_rng.randf() > 0.5:
						price = 1
						quantity = 5
					else:
						price = 0
						quantity = 1
				else:
					if App.shop_rng.randf() > 0.7:
						gem.type = App.shop_rng.randi() % Gem.ColorCount + Gem.ColorFirst
						gem.rune = App.shop_rng.randi() % Gem.RuneCount + Gem.RuneFirst
						if App.shop_rng.randf() > 0.5:
							App.enchant_gem(gem, "w_enchant_charming")
						else:
							App.enchant_gem(gem, "w_enchant_sharp")
						price = 2
					else:
						gem.setup(SMath.pick_random(items_pool, App.shop_rng))
						price = 2
			else:
				if App.shop_rng.randf() > 0.5:
					gem.type = Gem.ColorWild
					gem.rune = App.shop_rng.randi() % Gem.RuneCount + Gem.RuneFirst
					price = 5
				else:
					gem.type = App.shop_rng.randi() % Gem.ColorCount + Gem.ColorFirst
					gem.rune = Gem.RuneOmni
					price = 5
			ui.setup("gem", gem, price, quantity)
			list1.add_child(ui)
		)
	var relics_pool2 = []
	var explode_ability = false
	for g in App.gems:
		if g.category == "Bomb":
			explode_ability = true
			break
	for n in relics_pool:
		var has = false
		if !explode_ability:
			if n == "ExplosionScience" || n == "HighExplosives":
				continue
		for r in App.relics:
			if r.name == n:
				has = true
				break
		if !has:
			relics_pool2.append(n)
	for i in min(2, relics_pool2.size()):
		tween.tween_interval(0.04)
		tween.tween_callback(func():
			var ui = shop_item_pb.instantiate()
			var relic = Relic.new()
			relic.setup(SMath.pick_and_remove(relics_pool2, App.shop_rng))
			ui.setup("relic", relic, relic.price)
			list1.add_child(ui)
		)
	for i in 3:
		tween.tween_interval(0.04)
		tween.tween_callback(func():
			var ui = craft_slot_pb.instantiate()
			if App.shop_rng.randf() >= 0.4:
				if App.shop_rng.randf() >= 0.5:
					ui.setup("w_enchant", "w_enchant_charming", 1)
				else:
					ui.setup("w_enchant", "w_enchant_sharp", 1)
			else:
				if App.shop_rng.randf() >= 0.1:
					if App.shop_rng.randf() >= 0.5:
						ui.setup("w_delete", "", delete_price)
					else:
						ui.setup("w_duplicate", "", 4)
				else:
					if App.shop_rng.randf() >= 0.5:
						ui.setup("w_enchant", "w_wild", 6)
					else:
						ui.setup("w_enchant", "w_omni", 6)
			list2.add_child(ui)
		)
	tween.tween_callback(func():
		Hand.ui.disabled = false
		refresh_button.disabled = false
		App.save_to_file()
	)
	return tween

func enter(tween : Tween = null, do_refresh : bool = true):
	if !tween:
		tween = App.game_tweens.create_tween()
	
	self.show()
	self.material.set_shader_parameter("x_rot", -90.0)
	
	App.stage = App.Stage.Shopping
	
	var sub1 = App.game_tweens.create_tween()
	var sub2 = App.game_tweens.create_tween()
	sub1.tween_property(self.material, "shader_parameter/x_rot", 0.0, 0.5).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
	sub1.tween_callback(func():
		App.refresh_cluster_rounds()
	)
	sub2.parallel().tween_property(App.status_bar_ui.round_text, "modulate:a", 0.0, 0.3)
	sub2.parallel().tween_property(App.status_bar_ui.round_target, "modulate:a", 0.0, 0.3)
	sub2.tween_callback(func():
		App.score = 0
		App.status_bar_ui.round_text.text = tr("ui_shop_title")
		App.status_bar_ui.round_target.text = "[wave amp=10.0 freq=-1.0]%s[/wave]" % tr("ui_shop_target")
	)
	sub2.tween_property(App.status_bar_ui.round_text, "modulate:a", 1.0, 0.3)
	sub2.parallel().tween_property(App.status_bar_ui.round_target, "modulate:a", 1.0, 0.3)
	tween.tween_subtween(sub1)
	tween.parallel().tween_subtween(sub2)
	tween.parallel().tween_property(App.background.material, "shader_parameter/color", Color(0.71, 0.703, 0.504), 0.8)
	
	refresh_price = refresh_base_price
	refresh_button.text.text = "%s %d[img=16]res://images/coin.png[/img]" % [tr("ui_shop_refresh"), refresh_price]
	
	delete_price = 0
	
	if do_refresh:
		refresh(tween)
	
	return tween

func exit(tween : Tween = null, trans : bool = true):
	if trans:
		if !tween:
			tween = App.game_tweens.create_tween()
		tween.tween_property(self.material, "shader_parameter/x_rot", 90.0, 0.5).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
		tween.parallel().tween_property(App.background.material, "shader_parameter/color", Color(0.917, 0.921, 0.65), 0.8)
		tween.parallel().tween_property(App.status_bar_ui.round_text, "modulate:a", 0.0, 0.3)
		tween.parallel().tween_property(App.status_bar_ui.round_target, "modulate:a", 0.0, 0.3)
		tween.tween_callback(func():
			clear()
			self.hide()
		)
		if !Board.ui.visible:
			Board.ui.enter(tween, true)
			App.next_round(tween)
	else:
		clear()
		self.hide()
	return tween

func _ready() -> void:
	self.pivot_offset = self.size * 0.5
	
	exit_button.pressed.connect(func():
		SSound.se_click.play()
		App.screen_shake_strength = 8.0
		exit()
	)
	#exit_button.mouse_entered.connect(SSound.se_select.play)
	refresh_button.button.pressed.connect(func():
		if App.coins < refresh_price:
			App.status_bar_ui.coins_text.hint()
			return
		SSound.se_coin.play()
		App.coins -= refresh_price
		
		refresh_price += refresh_price_increase
		refresh_button.text.text = "%s %d[img=16]res://images/coin.png[/img]" % [tr("ui_shop_refresh"), refresh_price]
		
		refresh()
	)
