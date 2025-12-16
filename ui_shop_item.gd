extends Control

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
	if App.modifiers["half_price_i"] > 0:
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
	if App.coins < price:
		App.status_bar_ui.coins_text.hint()
		return false
	if cate == "relic" && App.relics.size() >= 5:
		SSound.se_error.play()
		App.banner_ui.show_tip(tr("wr_relics_count_limit") % App.MaxRelics, "", 1.0)
		return false
	if cate == "upgrade_board":
		if App.gems.size() < Board.next_min_gem_num:
			SSound.se_error.play()
			App.banner_ui.show_tip(tr("ui_upgrade_board_insufficient_quantity_title"), tr("ui_upgrade_board_insufficient_quantity_content") % Board.next_min_gem_num, 1.0)
			return false
	
	if !tween:
		tween = App.game_tweens.create_tween()
	tween.tween_callback(func():
		self.hide()
		buy_button.disabled = true
		
		if price != 0:
			SSound.se_coin.play()
			if original_price > 0:
				App.coins -= price
			else:
				App.coins += price
	)
	if cate == "gem":
		var ui = content.get_child(0)
		tween.tween_callback(func():
			ui.reparent(App.game_overlay)
			ui.position = self.global_position
		)
		
		tween.tween_property(ui, "global_position", self.global_position - Vector2(0.0, 100.0), 0.4).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
		tween.tween_property(ui, "scale", Vector2(0.5, 0.5), 0.4)
		tween.parallel()
		SAnimation.cubic_curve_to(tween, ui, App.status_bar_ui.bag_button.get_global_rect().get_center(), Vector2(0.1, 0.2), Vector2(0.9, 0.2), 0.5)
		tween.tween_callback(func():
			var original = object as Gem
			for i in quantity:
				var gem = Gem.new()
				App.copy_gem(original, gem)
				App.add_gem(gem)
			App.sort_gems()
			ui.queue_free()
		)
	elif cate == "relic":
		App.add_relic(object)
		var ui = App.relics_bar_ui.get_ui(-1)
		ui.hide()
		tween.tween_callback(func():
			ui.show()
			ui.elastic = 0.0
			ui.global_position = self.global_position
		)
		tween.tween_property(ui, "elastic", 1.0, 0.4)
	elif cate == "pattern":
		App.add_pattern(object)
		var ui = App.patterns_bar_ui.get_ui(-1)
		ui.hide()
		tween.tween_callback(func():
			ui.show()
			ui.elastic = 0.0
			ui.global_position = self.global_position
		)
		tween.tween_property(ui, "elastic", 1.0, 0.4)
	elif cate == "upgrade_board":
		tween.tween_callback(func():
			App.board_size += 1
		)
		Board.resize(App.board_size + 1, tween)
		tween.tween_interval(1.5)
	elif cate == "increase_swaps":
		tween.tween_callback(func():
			App.swaps_per_round += 1
			if App.swaps < App.swaps_per_round:
				App.swaps = App.swaps_per_round
		)
		tween.tween_interval(0.5)
	elif cate == "increase_hand_size":
		tween.tween_callback(func():
			App.max_hand_grabs += 1
		)
		tween.tween_interval(0.5)
	tween.tween_callback(func():
		self.queue_free()
		App.save_to_file()
	)
	
	return true

func _ready() -> void:
	if cate == "gem":
		var ctrl = Control.new()
		ctrl.custom_minimum_size = Vector2(C.SPRITE_SZ, C.SPRITE_SZ) + Vector2(16, 16)
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
			lb.position = Vector2(40, 40)
			lb.add_theme_color_override("font_shadow_color", Color.BLACK)
			lb.add_theme_color_override("font_outline_color", Color.BLACK)
			lb.add_theme_constant_override("shadow_offset_x", 2)
			lb.add_theme_constant_override("shadow_offset_y", 2)
			lb.add_theme_constant_override("outline_size", 1)
			ctrl.add_child(lb)
		ui.position = Vector2(8, 8)
	elif cate == "pattern":
		var ui = pattern_ui.instantiate()
		ui.setup(object, true)
		ui.mouse_filter = Control.MOUSE_FILTER_PASS
		content.add_child(ui)
	elif cate == "relic":
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
