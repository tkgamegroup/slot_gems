extends Control

@onready var cate_lb = $VBoxContainer/Category
@onready var content : Control = $VBoxContainer/Content
@onready var buy_button = $VBoxContainer/Buy
@onready var price_lb = $VBoxContainer/Price

const gem_ui = preload("res://ui_gem.tscn")
const relic_ui = preload("res://ui_relic.tscn")
const pattern_ui = preload("res://ui_pattern.tscn")

var cate : String
var object
var original_price : int
var price : int
var quantity : int
var no_button : bool
var selected : bool = false

var disabled : bool = false:
	set(v):
		disabled = v
		if v:
			buy_button.disabled = true
		else:
			buy_button.disabled = false

func select():
	if !selected:
		selected = true
		self.self_modulate.a = 1.0

func deselect():
	if selected:
		selected = false
		self.self_modulate.a = 0.0

func setup(_cate : String, _object, _price : int, _quantity : int = 1, _no_button : bool = false):
	cate = _cate
	object = _object
	original_price = _price
	quantity = _quantity
	no_button = _no_button

func refresh_price():
	if G.modifiers["half_price_i"] > 0:
		price = int(original_price * 0.5)
	else:
		price = original_price
	if original_price < 0:
		price = -price
	var color = "WHITE"
	if original_price > 0:
		if price > original_price:
			color = "ORANGE_RED"
		elif price < original_price:
			color = "LAWN_GREEN"
	var text = "[img]res://images/coin.png[/img][color=%s]%d[/color]" % [color, price]
	if original_price < 0:
		text = tr("ui_shop_item_return") + text
	if no_button:
		price_lb.text = text
	else:
		buy_button.text.text = text

func buy(tween : Tween = null):
	if G.coins < price:
		G.status_bar_ui.coins_text.hint()
		return false
	if cate == "relic" && G.relics.size() >= 5:
		SSound.se_error.play()
		G.banner_ui.show_tip(tr("wr_relics_count_limit") % G.MaxRelics, "", 1.0)
		return false
	if cate == "upgrade_board":
		if G.gems.size() < Board.next_min_gem_num:
			SSound.se_error.play()
			G.banner_ui.show_tip(tr("ui_upgrade_board_insufficient_quantity_title"), tr("ui_upgrade_board_insufficient_quantity_content") % Board.next_min_gem_num, 1.0)
			return false
	
	if !tween:
		tween = G.game_tweens.create_tween()
	tween.tween_callback(func():
		self.hide()
		G.shop_ui.disabled = true
		
		if price != 0:
			SSound.se_coin.play()
			if original_price > 0:
				G.coins -= price
			else:
				G.coins += price
	)
	if cate == "gem":
		var ui = content.get_child(0)
		tween.tween_callback(func():
			ui.reparent(G.game_overlay)
			ui.position = self.global_position
		)
		
		tween.tween_property(ui, "global_position", self.global_position - Vector2(0.0, 100.0), 0.4).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
		var to_bag = true
		if quantity == 1:
			for s in G.shop_ui.staging_slots:
				if s.slot.gem == null:
					s.slot.disabled = false
					SAnimation.quadratic_curve_to(tween, ui, s.global_position + Vector2(6, 6), Vector2(0.5, 0.2), 0.4)
					tween.tween_property(ui, "global_position", s.global_position, 0.5)
					tween.tween_callback(func():
						var gem = object as Gem
						G.add_gem(gem)
						ui.queue_free()
						
						G.take_out_gem_from_bag(gem)
						s.slot.load_gem(gem)
					)
					to_bag = false
					break
		if to_bag:
			tween.tween_property(ui, "scale", Vector2(0.7, 0.7), 0.4)
			tween.parallel()
			SAnimation.quadratic_curve_to(tween, ui, G.status_bar_ui.bag_button.global_position, Vector2(0.5, 0.2), 0.4)
			tween.tween_callback(func():
				var original = object as Gem
				for i in quantity:
					var gem = Gem.new()
					G.copy_gem(original, gem)
					G.add_gem(gem)
				G.sort_gems()
				ui.queue_free()
			)
	elif cate == "relic":
		G.add_relic(object)
		var ui = G.relics_bar_ui.get_ui(-1)
		ui.hide()
		tween.tween_callback(func():
			ui.show()
			ui.elastic = 0.0
			ui.global_position = self.global_position
		)
		tween.tween_property(ui, "elastic", 1.0, 0.4)
	elif cate == "pattern":
		G.add_pattern(object)
		var ui = G.patterns_bar_ui.get_ui(-1)
		ui.hide()
		tween.tween_callback(func():
			ui.show()
			ui.elastic = 0.0
			ui.global_position = self.global_position
		)
		tween.tween_property(ui, "elastic", 1.0, 0.4)
	elif cate == "upgrade_board":
		var new_size = G.board_size + 1
		tween.tween_callback(func():
			G.board_size = new_size
		)
		Board.resize(new_size, tween)
		tween.tween_interval(1.5)
	elif cate == "increase_swaps":
		tween.tween_callback(func():
			G.swaps_per_round += 1
			if G.swaps < G.swaps_per_round:
				G.swaps = G.swaps_per_round
		)
		tween.tween_interval(0.5)
	elif cate == "increase_hand_size":
		tween.tween_callback(func():
			G.max_hand_grabs += 1
			if Hand.grabs.size() < G.max_hand_grabs:
				for i in (G.max_hand_grabs - Hand.grabs.size()):
					Hand.draw()
		)
		tween.tween_interval(0.5)
	tween.tween_callback(func():
		G.shop_ui.disabled = false
		G.save_to_file()
		self.queue_free()
	)
	
	return true

func _ready() -> void:
	if cate == "gem":
		cate_lb.text = tr("gem")
		cate_lb.show()
		var ctrl = Control.new()
		ctrl.custom_minimum_size = Vector2(C.SPRITE_SZ, C.SPRITE_SZ)
		var ui = gem_ui.instantiate()
		ui.update(object)
		ctrl.add_child(ui)
		ctrl.mouse_entered.connect(func():
			SSound.se_select.play()
			STooltip.show(ui, 0, object.get_tooltip())
		)
		ctrl.mouse_exited.connect(func():
			STooltip.close()
		)
		content.add_child(ctrl)
		if quantity > 1:
			var lb = Label.new()
			lb.text = "x%d" % quantity
			lb.position = Vector2(40, 48)
			lb.add_theme_color_override("font_shadow_color", Color.BLACK)
			lb.add_theme_color_override("font_outline_color", Color.BLACK)
			lb.add_theme_constant_override("shadow_offset_x", 2)
			lb.add_theme_constant_override("shadow_offset_y", 2)
			lb.add_theme_constant_override("outline_size", 1)
			ctrl.add_child(lb)
	elif cate == "pattern":
		cate_lb.text = tr("pattern")
		cate_lb.show()
		var ui = pattern_ui.instantiate()
		ui.setup(object, true)
		ui.mouse_filter = Control.MOUSE_FILTER_PASS
		content.add_child(ui)
	elif cate == "relic":
		cate_lb.text = tr("relic")
		cate_lb.show()
		var ui = relic_ui.instantiate()
		ui.setup(object)
		ui.mouse_filter = Control.MOUSE_FILTER_PASS
		content.add_child(ui)
		ui.position = Vector2(8, 8)
	elif cate == "upgrade_board":
		var lb = Label.new()
		lb.text = tr("ui_upgrade_board")
		content.add_child(lb)
	elif cate == "increase_swaps":
		var lb = Label.new()
		lb.text = tr("ui_shop_item_increase_swaps")
		content.add_child(lb)
	elif cate == "increase_hand_size":
		var lb = Label.new()
		lb.text = tr("ui_shop_item_increase_hand_size")
		content.add_child(lb)
	elif cate == "nothing":
		var lb = Label.new()
		lb.text = tr("ui_shop_item_nothing")
		content.add_child(lb)
	if no_button:
		buy_button.hide()
		price_lb.show()
	else:
		buy_button.button.pressed.connect(func():
			buy()
		)
	refresh_price()
