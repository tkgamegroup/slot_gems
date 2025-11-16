extends Control

const craft_slot_pb = preload("res://craft_slot.tscn")
const shop_item_pb = preload("res://ui_shop_item.tscn")
const gem_ui = preload("res://ui_gem.tscn")

@onready var list1 : Control = $SubViewport/Panel/HBoxContainer/VBoxContainer/HBoxContainer
@onready var list2 : Control = $SubViewport/Panel/HBoxContainer/VBoxContainer/HBoxContainer2
@onready var refresh_button : Control = $SubViewport/Panel/HBoxContainer/VBoxContainer2/RichButton
@onready var expand_board_button : Control = $SubViewport/Panel/HBoxContainer/VBoxContainer2/RichButton2
@onready var exit_button : Button = $SubViewport/Panel/HBoxContainer/VBoxContainer2/Button

var expand_board_price : int = 15
var expand_board_price_increase : int = 10
var refresh_base_price : int = 3
var refresh_price : int
var refresh_price_increase : int = 1
var delete_price : int
var delete_price_increase : int = 1

func clear():
	for n in list1.get_children():
		list1.remove_child(n)
		n.queue_free()
	for n in list2.get_children():
		list2.remove_child(n)
		n.queue_free()

func buy_expand_board():
	if expand_board_button.disabled:
		return false
	if Game.gems.size() < Board.next_min_gem_num:
		SSound.se_error.play()
		Game.banner_ui.show_tip(tr("ui_shop_upgrade_insufficient_quantity_title"), tr("ui_shop_upgrade_insufficient_quantity_content") % Board.next_min_gem_num, 1.0)
		return false
	if Game.coins < expand_board_price:
		Game.status_bar_ui.coins_text.hint()
		return false
	
	SSound.se_coin.play()
	Game.coins -= expand_board_price
	
	expand_board_price += expand_board_price_increase
	expand_board_button.disabled = true
	
	Game.board_size += 1
	Board.resize(Game.board_size)
	for y in Board.cy:
		for x in Board.cx:
			var c = Vector2i(x, y)
			var g = Board.get_gem_at(c)
			if !g:
				g = Game.get_gem()
				Board.set_gem_at(c, g)
			else:
				Board.ui.update_cell(c)
	
	return true

func refresh_prices():
	for n in list1.get_children():
		n.refresh_price()

func buy_randomly():
	buy_expand_board()
	if randi() % 2 < 1:
		var item = list1.get_child(randi() % list1.get_child_count())
		if item:
			return item.buy()
	else:
		var item = list2.get_child(randi() % list2.get_child_count())
		if item:
			return item.buy()
	return false

const items_pool = ["Flag", "Bomb", "C4", "Rainbow", "Magician", "Ruby", "Citrine", "Emerald", "Sapphire", "Amethyst"]
const relics_pool = ["ExplosionScience", "HighExplosives", "MobiusStrip", "Premeditation", "PentagramPower", "PaintingOfRed", "PaintingOfOrange", "PaintingOfGreen", "PaintingOfBlue", "PaintingOfMagenta", "PaintingOfWave", "PaintingOfPalm", "PaintingOfStarfish", "HalfPriceCoupon"]
const patterns_pool = ["\\", "|", "/", "Y", "C", "O", "√", "X"]

func refresh(tween : Tween = null):
	if !tween:
		tween = get_tree().create_tween()
	
	Game.control_ui.play_button.disabled = true
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
			if Game.rng.randf() > 0.4:
				gem.type = Game.rng.randi() % Gem.ColorCount + Gem.ColorRed
				gem.rune = Game.rng.randi() % Gem.RuneCount + Gem.Runewave
				if Game.rng.randf() > 0.5:
					price = 1
					quantity = 5
				else:
					price = 0
					quantity = 1
			else:
				if Game.rng.randf() > 0.2:
					gem.type = Game.rng.randi() % Gem.ColorCount + Gem.ColorRed
					gem.rune = Game.rng.randi() % Gem.RuneCount + Gem.Runewave
					if Game.rng.randf() > 0.5:
						Game.enchant_gem(gem, "w_enchant_charming")
					else:
						Game.enchant_gem(gem, "w_enchant_sharp")
					price = 2
				else:
					if Game.rng.randf() > 0.5:
						gem.type = Gem.ColorWild
						gem.rune = Game.rng.randi() % Gem.RuneCount + Gem.Runewave
						price = 5
					else:
						gem.type = Game.rng.randi() % Gem.ColorCount + Gem.ColorRed
						gem.rune = Gem.RuneOmni
						price = 5
			ui.setup("gem", gem, price, quantity)
			list1.add_child(ui)
		)
	var relics_pool2 = []
	var boom_ability = false
	for g in Game.gems:
		if g.category == "Bomb":
			boom_ability = true
			break
	for n in relics_pool:
		var has = false
		if !boom_ability:
			if n == "ExplosionScience" || n == "HighExplosives":
				continue
		for r in Game.relics:
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
			relic.setup(SMath.pick_and_remove(relics_pool2, Game.rng))
			ui.setup("relic", relic, relic.price)
			list1.add_child(ui)
		)
	var patterns_pool2 = []
	for n in patterns_pool:
		var has = false
		for p in Game.patterns:
			if p.name == n:
				has = true
				break
		if !has:
			patterns_pool2.append(n)
	for i in 1:
		tween.tween_interval(0.04)
		tween.tween_callback(func():
			var ui = shop_item_pb.instantiate()
			var pattern = Pattern.new()
			pattern.setup(SMath.pick_random(patterns_pool2, Game.rng))
			ui.setup("pattern", pattern, pattern.price)
			list1.add_child(ui)
		)
	for i in 4:
		tween.tween_interval(0.04)
		tween.tween_callback(func():
			var ui = craft_slot_pb.instantiate()
			if Game.rng.randf() >= 0.4:
				if Game.rng.randf() >= 0.5:
					ui.setup("w_enchant", "w_enchant_charming", 1)
				else:
					ui.setup("w_enchant", "w_enchant_sharp", 1)
			else:
				if Game.rng.randf() >= 0.25:
					if Game.rng.randf() >= 0.5:
						ui.setup("w_delete", "", delete_price)
					else:
						ui.setup("w_duplicate", "", 4)
				else:
					if Game.rng.randf() >= 0.5:
						ui.setup("w_enchant", "w_wild", 6)
					else:
						ui.setup("w_enchant", "w_omni", 6)
			list2.add_child(ui)
		)
	tween.tween_callback(func():
		Hand.ui.disabled = false
		refresh_button.disabled = false
		Game.save_to_file()
	)
	return tween

func enter(tween : Tween = null, do_refresh : bool = true):
	if !tween:
		tween = get_tree().create_tween()
	
	self.show()
	self.material.set_shader_parameter("x_rot", -90.0)
	var sub1 = get_tree().create_tween()
	var sub2 = get_tree().create_tween()
	sub1.tween_property(self.material, "shader_parameter/x_rot", 0.0, 0.5)
	sub1.tween_callback(func():
		Game.refresh_cluster_levels()
	)
	sub2.parallel().tween_property(Game.status_bar_ui.level_text, "modulate:a", 0.0, 0.3)
	sub2.parallel().tween_property(Game.status_bar_ui.level_target, "modulate:a", 0.0, 0.3)
	sub2.tween_callback(func():
		Game.score = 0
		Game.status_bar_ui.level_text.text = tr("ui_shop_title")
		Game.status_bar_ui.level_target.text = "[wave amp=10.0 freq=-1.0]%s[/wave]" % tr("ui_shop_target")
	)
	sub2.tween_property(Game.status_bar_ui.level_text, "modulate:a", 1.0, 0.3)
	sub2.parallel().tween_property(Game.status_bar_ui.level_target, "modulate:a", 1.0, 0.3)
	tween.tween_subtween(sub1)
	tween.parallel().tween_subtween(sub2)
	tween.parallel().tween_property(Game.background.material, "shader_parameter/color", Color(0.71, 0.703, 0.504), 0.8)
	
	expand_board_button.disabled = !(Game.board_size < 6)
	expand_board_button.text.text = "%s %d[img=16]res://images/coin.png[/img]" % [tr("ui_shop_upgrade"), expand_board_price]
	
	refresh_price = refresh_base_price
	refresh_button.text.text = "%s %d[img=16]res://images/coin.png[/img]" % [tr("ui_shop_refresh"), refresh_price]
	
	delete_price = 0
	
	if do_refresh:
		refresh(tween)
	
	return tween

func exit(tween : Tween = null, trans : bool = true):
	if trans:
		if !tween:
			tween = get_tree().create_tween()
		tween.tween_property(self.material, "shader_parameter/x_rot", 90.0, 0.5)
		tween.parallel().tween_property(Game.background.material, "shader_parameter/color", Color(0.917, 0.921, 0.65), 0.8)
		tween.parallel().tween_property(Game.status_bar_ui.level_text, "modulate:a", 0.0, 0.3)
		tween.parallel().tween_property(Game.status_bar_ui.level_target, "modulate:a", 0.0, 0.3)
		tween.tween_callback(func():
			for n in list1.get_children():
				n.queue_free()
				list1.remove_child(n)
			for n in list2.get_children():
				n.queue_free()
				list2.remove_child(n)
			self.hide()
		)
		if !Board.ui.visible:
			Board.ui.enter(tween, true)
			Game.new_level(tween)
	else:
		self.hide()
	return tween

func _ready() -> void:
	self.pivot_offset = self.size * 0.5
	
	exit_button.pressed.connect(func():
		SSound.se_click.play()
		Game.screen_shake_strength = 8.0
		exit()
	)
	#exit_button.mouse_entered.connect(SSound.se_select.play)
	expand_board_button.button.pressed.connect(func():
		buy_expand_board()
	)
	refresh_button.button.pressed.connect(func():
		if Game.coins < refresh_price:
			Game.status_bar_ui.coins_text.hint()
			return
		SSound.se_coin.play()
		Game.coins -= refresh_price
		
		refresh_price += refresh_price_increase
		refresh_button.text.text = "%s %d[img=16]res://images/coin.png[/img]" % [tr("ui_shop_refresh"), refresh_price]
		
		refresh()
	)
