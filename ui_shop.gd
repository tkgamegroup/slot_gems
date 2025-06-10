extends Control

const enchant_pb = preload("res://enchant_slot.tscn")
const item_pb = preload("res://ui_shop_item.tscn")
const gem_ui = preload("res://ui_gem.tscn")

@onready var exit_button : Button = $HBoxContainer/HBoxContainer/VBoxContainer2/Button
@onready var list1 : Control = $HBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer
@onready var list2 : Control = $HBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer2
@onready var refresh_button : Control = $HBoxContainer/HBoxContainer/VBoxContainer2/ShopButton
@onready var expand_board_button : Control = $HBoxContainer/HBoxContainer/VBoxContainer2/ShopButton2

var expand_board_price : int = 15
var expand_board_price_increase : int = 10

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
	
	SSound.sfx_coin.play()
	Game.coins -= expand_board_price
	
	Game.board_size += 1
	expand_board_price += expand_board_price_increase
	expand_board_button.button.disabled = true
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

func enter(tween : Tween = null):
	if !tween:
		tween = get_tree().create_tween()
	
	tween.tween_callback(func():
		self.scale = Vector2(1.0, 0.0)
		self.show()
	)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.3).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUART)
	
	expand_board_button.price.text = "%d" % expand_board_price
	expand_board_button.button.disabled = false if Game.board_size < 6 else true
	
	var items_pool = ["Flag", "Bomb", "C4", "Color Palette", "Hot Dog", "Rainbow", "Magician", "Ruby", "Citrine", "Emerald", "Sapphire", "Tourmaline"]
	var relics_pool = ["ExplosionScience", "HighExplosives", "UniformBlasting", "SympatheticDetonation", "BlockedLever", "MobiusStrip", "Premeditation", "PentagramPower", "RedStone", "OrangeStone", "GreenStone", "BlueStone", "PinkStone", "RockBottom"]
	var skills_pool = ["Xiao", "RoLL", "Mat.", "Qiang", "Se", "Huan", "Chou", "Jin", "Bao", "Fang", "Fen", "Xing"]
	var patterns_pool = ["\\", "I", "/", "Y", "C", "O", "√", "X"]
	
	for n in list1.get_children():
		list1.remove_child(n)
		n.queue_free()
	for n in list2.get_children():
		list2.remove_child(n)
		n.queue_free()
	
	for i in 1:
		tween.tween_interval(0.04)
		tween.tween_callback(func():
			var ui = enchant_pb.instantiate()
			ui.setup("Charming", "Charming", "+6 Base Score", "Enchant", 2, func(gem : Gem):
				gem.base_score += 6
			)
			list1.add_child(ui)
		)
	for i in 0:
		tween.tween_interval(0.04)
		tween.tween_callback(func():
			var ui = item_pb.instantiate()
			var item = Item.new()
			item.setup(items_pool.pick_random())
			ui.setup("Item", item, item.price, func():
				var img = ui.image
				img.reparent(self)
				
				var tween2 = Game.get_tree().create_tween()
				tween2.tween_property(img, "scale", Vector2(1.0, 1.0), 0.3)
				tween2.parallel()
				SAnimation.cubic_curve_to(tween2, img, Game.status_bar_ui.bag_button.get_global_rect().get_center(), Vector2(0.1, 0.2), Vector2(0.9, 0.2), 0.4)
				tween2.tween_callback(func():
					Game.add_item(item)
					img.queue_free()
				)
			)
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
				ui.setup("Relic", relic, relic.price, func():
					var img = ui.image
					img.reparent(self)
					
					var tween2 = Game.get_tree().create_tween()
					tween2.tween_property(img, "scale", Vector2(1.0, 1.0), 0.3)
					tween2.parallel()
					SAnimation.cubic_curve_to(tween2, img, Game.relics_bar_ui.get_global_rect().end, Vector2(0.1, 0.2), Vector2(0.9, 0.2), 0.4)
					tween2.tween_callback(func():
						Game.add_relic(relic)
						img.queue_free()
					)
				)
				list2.add_child(ui)
		)
	if randf() < 0.5:
		for i in 1:
			tween.tween_interval(0.04)
			tween.tween_callback(func():
				var name = random_item(skills_pool, Game.skills)
				if name:
					var ui = item_pb.instantiate()
					var skill = Skill.new()
					skill.setup(name)
					ui.setup("Skill", skill, skill.price, func():
						Game.add_skill(skill)
					)
					list2.add_child(ui)
			)
	else:
		for i in 1:
			tween.tween_interval(0.04)
			tween.tween_callback(func():
				var name = random_item(patterns_pool, Game.patterns)
				if name:
					var ui = item_pb.instantiate()
					var pattern = Pattern.new()
					pattern.setup(name)
					ui.setup("Pattern", pattern, pattern.price, func():
						Game.add_pattern(pattern)
					)
					list2.add_child(ui)
			)
	return tween

func exit(tween : Tween = null):
	if !tween:
		tween = get_tree().create_tween()
	tween.tween_property(self, "scale", Vector2(1.0, 0.0), 0.3).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUART)
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
		Game.new_level(tween)
	return tween

func _ready() -> void:
	self.pivot_offset = self.size * 0.5
	
	exit_button.pressed.connect(func():
		SSound.sfx_click.play()
		exit()
	)
	#exit_button.mouse_entered.connect(SSound.sfx_select.play)
	expand_board_button.button.pressed.connect(func():
		buy_expand_board()
	)
