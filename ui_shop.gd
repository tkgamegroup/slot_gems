extends Control

const craft_slot_pb = preload("res://craft_slot.tscn")
const item_pb = preload("res://ui_shop_item.tscn")
const gem_ui = preload("res://ui_gem.tscn")

@onready var exit_button : Button = $HBoxContainer/VBoxContainer2/Button
@onready var list1 : Control = $HBoxContainer/VBoxContainer/HBoxContainer
@onready var list2 : Control = $HBoxContainer/VBoxContainer/HBoxContainer2
@onready var refresh_button : Control = $HBoxContainer/VBoxContainer2/ShopButton
@onready var expand_board_button : Control = $HBoxContainer/VBoxContainer2/ShopButton2

var expand_board_price : int = 15
var expand_board_price_increase : int = 10
var refresh_base_price : int = 3
var refresh_price : int
var refresh_increase : int = 1

func random_item(cands : Array, list):
	var indices = SMath.get_shuffled_indices(cands.size())
	for idx in indices:
		var found = false
		for i in list:
			if i.name == cands[idx]:
				found = true
				break
		if !found:
			return cands[idx]
	return null

func buy_expand_board():
	if expand_board_button.button.disabled || Game.coins < expand_board_price:
		return false
	
	SSound.se_coin.play()
	Game.coins -= expand_board_price
	
	expand_board_price += expand_board_price_increase
	expand_board_button.button.disabled = true
	
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
				Game.board_ui.update_cell(c)
	
	return true

func buy_randomly():
	buy_expand_board()
	if randi() % 2 < 1:
		var item = list1.get_child(randi() % 4)
		if item:
			return item.buy()
	else:
		var item = list2.get_child(randi() % 4)
		if item:
			return item.buy()
	return false

func refresh(tween : Tween = null):
	if !tween:
		tween = get_tree().create_tween()
	
	refresh_button.button.disabled = true
	
	var items_pool = ["Flag", "Bomb", "C4", "Color Palette", "Hot Dog", "Rainbow", "Magician", "Ruby", "Citrine", "Emerald", "Sapphire", "Tourmaline"]
	var relics_pool = ["ExplosionScience", "HighExplosives", "UniformBlasting", "SympatheticDetonation", "MobiusStrip", "Premeditation", "PentagramPower", "RedStone", "OrangeStone", "GreenStone", "BlueStone", "PinkStone"]
	var patterns_pool = ["\\", "I", "/", "Y", "C", "O", "√", "X"]
	
	for n in list1.get_children():
		list1.remove_child(n)
		n.queue_free()
	for n in list2.get_children():
		list2.remove_child(n)
		n.queue_free()
	
	for i in 3:
		tween.tween_interval(0.04)
		tween.tween_callback(func():
			var ui = item_pb.instantiate()
			var gem = Gem.new()
			var price = 0
			if randf() > 0.4:
				gem.type = randi() % Gem.Type.Count + 1
				gem.rune = randi() % Gem.Rune.Count + 1
				price = 1
			else:
				if randf() > 0.25:
					gem.type = randi() % Gem.Type.Count + 1
					gem.rune = randi() % Gem.Rune.Count + 1
					if randf() > 0.5:
						var bid = Buff.create(gem, Buff.Type.ValueModifier, {"target":"base_score","add":6}, Buff.Duration.Eternal)
						Buff.create(gem, Buff.Type.Enchant, {"type":"w_enchant_charming","bid":bid}, Buff.Duration.Eternal)
					else:
						var bid = Buff.create(gem, Buff.Type.ValueModifier, {"target":"mult","add":0.4}, Buff.Duration.Eternal)
						Buff.create(gem, Buff.Type.Enchant, {"type":"w_enchant_sharp","bid":bid}, Buff.Duration.Eternal)
					price = 2
				else:
					if randf() > 0.66:
						gem.type = Gem.Type.Colorless
						gem.rune = randi() % Gem.Rune.Count + 1
						gem.base_score = 30
						price = 4
					elif randf() > 0.5:
						gem.type = Gem.Type.Wild
						gem.rune = randi() % Gem.Rune.Count + 1
						price = 5
					else:
						gem.type = randi() % Gem.Type.Count + 1
						gem.rune = Gem.Rune.Omni
						price = 5
			ui.setup("gem", gem, price)
			list1.add_child(ui)
		)
	for i in 1:
		tween.tween_interval(0.04)
		tween.tween_callback(func():
			var name = random_item(relics_pool, Game.relics)
			if name:
				var ui = item_pb.instantiate()
				var relic = Relic.new()
				relic.setup(name)
				ui.setup("relic", relic, relic.price)
				list1.add_child(ui)
		)
	for i in 1:
		tween.tween_interval(0.04)
		tween.tween_callback(func():
			var ui = craft_slot_pb.instantiate()
			if randf() >= 0.0:
				if randf() >= 1.5:
					if randf() >= 0.5:
						ui.setup("w_enchant", "w_enchant_charming", 3, func(gem : Gem):
							var bid = Buff.create(gem, Buff.Type.ValueModifier, {"target":"base_score","add":6}, Buff.Duration.Eternal)
							Buff.create(gem, Buff.Type.Enchant, {"type":"w_enchant_charming","bid":bid}, Buff.Duration.Eternal)
						)
					else:
						ui.setup("w_enchant", "w_enchant_sharp", 3, func(gem : Gem):
							var bid = Buff.create(gem, Buff.Type.ValueModifier, {"target":"mult","add":0.4}, Buff.Duration.Eternal)
							Buff.create(gem, Buff.Type.Enchant, {"type":"w_enchant_sharp","bid":bid}, Buff.Duration.Eternal)
						)
				else:
					var item = Item.new()
					item.setup(items_pool.pick_random())
					ui.setup("w_socket", item, 5, func(gem : Gem):
						Game.add_item(item)
						gem.rune = Gem.Rune.None
						gem.bound_item = item
					)
			else:
				if randf() >= 0.25:
					if randf() >= 0.5:
						ui.setup("w_delete", "", 2, func(gem : Gem):
							Game.delete_gem(gem, ui.gem_ui, "craft_slot")
							return true
						)
					else:
						ui.setup("w_duplicate", "", 5, func(gem : Gem):
							Game.duplicate_gem(gem, ui.gem_ui, "craft_slot")
						)
				else:
					if randf() >= 0.5:
						ui.setup("w_enchant", "w_wild", 8, func(gem : Gem):
							gem.type = Gem.Type.Wild
						)
					else:
						ui.setup("w_enchant", "w_omni", 8, func(gem : Gem):
							gem.rune = Gem.Rune.Omni
						)
			list2.add_child(ui)
		)
	for i in 0:
		tween.tween_interval(0.04)
		tween.tween_callback(func():
			var name = random_item(patterns_pool, Game.patterns)
			if name:
				var ui = item_pb.instantiate()
				var pattern = Pattern.new()
				pattern.setup(name)
				ui.setup("pattern", pattern, pattern.price)
				list2.add_child(ui)
		)
	tween.tween_callback(func():
		refresh_button.button.disabled = false
	)
	return tween

func enter(tween : Tween = null, do_refresh : bool = true):
	if !tween:
		tween = get_tree().create_tween()
	
	tween.tween_property(Game.status_bar_ui.level_text, "modulate:a", 0.0, 0.3)
	tween.parallel().tween_property(Game.status_bar_ui.level_target, "modulate:a", 0.0, 0.3)
	tween.tween_callback(func():
		Game.status_bar_ui.level_text.text = tr("ui_shop_title")
		Game.status_bar_ui.level_target.text = "[wave amp=10.0 freq=-1.0]%s[/wave]" % tr("ui_shop_target")
		
		self.scale = Vector2(1.0, 0.0)
		self.show()
	)
	tween.tween_property(Game.status_bar_ui.level_text, "modulate:a", 1.0, 0.3)
	tween.parallel().tween_property(Game.status_bar_ui.level_target, "modulate:a", 1.0, 0.3)
	tween.parallel().tween_property(self, "scale", Vector2(1.0, 1.0), 0.3).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUART)
	
	expand_board_button.price.text = "%d" % expand_board_price
	expand_board_button.button.disabled = !(Game.board_size < 6)
	
	refresh_price = refresh_base_price
	refresh_button.price.text = "%d" % refresh_price
	
	if do_refresh:
		refresh(tween)
	
	return tween

func exit(tween : Tween = null):
	if !tween:
		tween = get_tree().create_tween()
	tween.tween_property(self, "scale", Vector2(1.0, 0.0), 0.3).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUART)
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
	if Game.stage == Game.Stage.LevelOver:
		Game.board_ui.enter(tween, true)
		Game.new_level(tween)
	return tween

func _ready() -> void:
	self.pivot_offset = self.size * 0.5
	
	exit_button.pressed.connect(func():
		SSound.se_click.play()
		exit()
	)
	#exit_button.mouse_entered.connect(SSound.se_select.play)
	expand_board_button.button.pressed.connect(func():
		buy_expand_board()
	)
	refresh_button.button.pressed.connect(func():
		if Game.coins < refresh_price:
			return
		SSound.se_coin.play()
		Game.coins -= refresh_price
		
		refresh_price += refresh_increase
		refresh_button.price.text = "%d" % refresh_price
		
		refresh()
	)
