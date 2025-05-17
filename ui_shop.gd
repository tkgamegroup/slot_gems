extends Control

const item_pb = preload("res://ui_shop_item.tscn")
const gem_ui = preload("res://ui_gem.tscn")

@onready var exit_button : Button = $PanelContainer/VBoxContainer2/Button
@onready var list1 : Control = $PanelContainer/VBoxContainer2/HBoxContainer3/VBoxContainer2/HBoxContainer
@onready var list2 : Control = $PanelContainer/VBoxContainer2/HBoxContainer3/VBoxContainer2/HBoxContainer2
@onready var refresh_button : Control = $PanelContainer/VBoxContainer2/HBoxContainer3/VBoxContainer/ShopButton
@onready var expand_board_button : Control = $PanelContainer/VBoxContainer2/HBoxContainer3/VBoxContainer/ShopButton2
@onready var add_gems_button  : Control = $PanelContainer/VBoxContainer2/HBoxContainer3/VBoxContainer/ShopButton3
@onready var remove_gems_button : Control = $PanelContainer/VBoxContainer2/HBoxContainer3/VBoxContainer/ShopButton4
@onready var remove_item_button : Control = $PanelContainer/VBoxContainer2/HBoxContainer3/VBoxContainer/ShopButton5

var expand_board_price : int = 15
var expand_board_increase : int = 10

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
	expand_board_price += expand_board_increase
	expand_board_button.button.disabled = true
	return true

func buy_randomly():
	if randf() < 0.5:
		return buy_expand_board()
	else:
		if randi() % 2 < 1:
			var item = list1.get_child(randi() % 4)
			if item:
				return item.buy()
		else:
			var item = list2.get_child(randi() % 4)
			if item:
				return item.buy()
	return false

func continue_game():
	self.hide()
	Game.new_level()

func enter():
	self.show()
	
	expand_board_button.price.text = "%d" % expand_board_price
	expand_board_button.button.disabled = false if Game.board_size < 6 else true
	
	var tween = get_tree().create_tween()
	
	var items_pool = ["Flag", "Bomb", "C4", "Chain Bomb", "Minefield", "Echo Stone", "Virus", "Lightning", "Color Palette", "Black Hole", "White Hole", "Dog", "Cat", "Rooster", "Rabbit", "Fox", "Eagle", "Mouse", "Elephant", "Hot Dog", "Iai Cut", "Rainbow", "Idol", "Magician", "Ruby", "Citrine", "Emerald", "Sapphire", "Tourmaline"]
	var relics_pool = ["Explosion Science", "High Explosives", "Uniform Blasting", "Sympathetic Detonation", "Blocked Lever", "Mobius Strip", "Premeditation", "Pentagram Power", "Red Stone", "Orange Stone", "Green Stone", "Blue Stone", "Pink Stone", "Rock Bottom"]
	var skills_pool = ["Xiao", "RoLL", "Mat.", "Qiang", "Jiang", "Huan", "Chou", "Jin", "Bao", "Fang", "Fen", "Xing"]
	var patterns_pool = ["\\", "I", "/", "Y", "C", "O", "√", "X"]
	
	for n in list1.get_children():
		list1.remove_child(n)
		n.queue_free()
	for n in list2.get_children():
		list2.remove_child(n)
		n.queue_free()
	
	for i in 4:
		tween.tween_interval(0.04)
		tween.tween_callback(func():
			var ui = item_pb.instantiate()
			var item = Item.new()
			item.setup(items_pool.pick_random())
			ui.setup("Item", item, "", item.price, func():
				var img = ui.image
				img.reparent(self)
				
				var tween2 = Game.get_tree().create_tween()
				tween2.tween_property(img, "scale", Vector2(1.0, 1.0), 0.3)
				tween2.parallel()
				SAnimation.cubic_curve_to(tween2, img, Game.status_bar_ui.bag_button.get_global_rect().get_center(), 0.1, Vector2(0, 150), 0.9, Vector2(0, 100), 0.4)
				tween2.tween_callback(func():
					Game.add_item(item)
					img.queue_free()
				)
			)
			list1.add_child(ui)
		)
	for i in 2:
		tween.tween_interval(0.04)
		tween.tween_callback(func():
			var name = random_item(relics_pool, Game.relics)
			if name:
				var ui = item_pb.instantiate()
				var relic = Relic.new()
				relic.setup(name)
				ui.setup("Relic", relic, "", relic.price, func():
					var img = ui.image
					img.reparent(self)
					
					var tween2 = Game.get_tree().create_tween()
					tween2.tween_property(img, "scale", Vector2(1.0, 1.0), 0.3)
					tween2.parallel()
					SAnimation.cubic_curve_to(tween2, img, Game.relics_bar_ui.get_global_rect().end, 0.1, Vector2(0, 150), 0.9, Vector2(0, 100), 0.4)
					tween2.tween_callback(func():
						Game.add_relic(relic)
						img.queue_free()
					)
				)
				list2.add_child(ui)
		)
	for i in 1:
		tween.tween_interval(0.04)
		tween.tween_callback(func():
			var name = random_item(skills_pool, Game.skills)
			if name:
				var ui = item_pb.instantiate()
				var skill = Skill.new()
				skill.setup(name)
				ui.setup("Skill", skill, "", skill.price, func():
					Game.add_skill(skill)
				)
				list2.add_child(ui)
		)
	for i in 1:
		tween.tween_interval(0.04)
		tween.tween_callback(func():
			var name = random_item(patterns_pool, Game.patterns)
			if name:
				var ui = item_pb.instantiate()
				var pattern = Pattern.new()
				pattern.setup(name)
				ui.setup("Pattern", pattern, "", pattern.price, func():
					Game.add_pattern(pattern)
				)
				list2.add_child(ui)
		)

func _ready() -> void:
	exit_button.pressed.connect(func():
		SSound.sfx_click.play()
		continue_game()
	)
	#exit_button.mouse_entered.connect(SSound.sfx_select.play)
	expand_board_button.button.pressed.connect(func():
		buy_expand_board()
	)
	add_gems_button.button.pressed.connect(func():
		if Game.coins < 2:
			return
		
		var arr = []
		for i in 5:
			var r = {}
			var name = Gem.type_name(i + 1)
			r.icon = Gem.type_img(i + 1)
			r.title = name + " x10"
			r.description = "Add 10 %s gems, the runes are random." % name
			arr.append(r)
		var tween = get_tree().create_tween()
		tween.tween_callback(func():
			Game.choose_reward_ui.enter(arr, func(idx : int, tween2 : Tween, img : Sprite2D):
				if idx != -1:
			
					SSound.sfx_coin.play()
					Game.coins -= 2
					
					tween2.tween_property(img, "scale", Vector2(1.0, 1.0), 0.3)
					tween2.parallel()
					SAnimation.cubic_curve_to(tween2, img, Game.status_bar_ui.bag_button.get_global_rect().get_center(), 0.1, Vector2(0, 150), 0.9, Vector2(0, 100), 0.4)
					tween2.tween_callback(func():
						for i in 10:
							var g = Gem.new()
							g.type = idx + 1
							g.rune = randi_range(1, Gem.Rune.Count)
							Game.add_gem(g)
						Game.sort_gems()
					)
			)
		)
	)
	remove_gems_button.button.pressed.connect(func():
		if Game.coins < 2:
			return
		
		Game.bag_viewer_ui.enter(8, "Select up to 8 gems to Remove", func(gems):
			if gems.is_empty():
				return
			
			SSound.sfx_coin.play()
			Game.coins -= 2
			
			Game.blocker_ui.enter()
			var bag_pos = Game.status_bar_ui.bag_button.get_global_rect().get_center()
			var base_pos = self.get_global_rect().get_center() + Vector2(-16 * (gems.size() - 1), 200)
			var uis = []
			for g in gems:
				var ui = gem_ui.instantiate()
				ui.set_image(g.type, g.rune)
				Game.blocker_ui.add_child(ui)
				ui.global_position = bag_pos
				ui.hide()
				uis.append(ui)
			var tween = get_tree().create_tween()
			for i in gems.size():
				tween.tween_interval(0.2)
				tween.tween_callback(func():
					var ui = uis[i]
					ui.show()
					SAnimation.cubic_curve_to(null, ui, base_pos + i * Vector2(32, 0), 0.1, Vector2(0, 100), 0.9, Vector2(0, 150), 0.4)
				)
			tween.tween_interval(1.0)
			tween.tween_callback(func():
				for ui in uis:
					ui.dissolve(0.5)
			)
			tween.tween_interval(0.5)
			tween.tween_callback(func():
				for ui in uis:
					ui.queue_free()
				for g in gems:
					Game.gems.erase(g)
				Game.blocker_ui.exit()
			)
		)
	)
