extends Control

@onready var cate_frame : Control = $Category
@onready var cate_label : Label = $Category/MarginContainer/Label
@onready var content : Control = $Content
@onready var buy_button = $Buy

const gem_ui = preload("res://ui_gem.tscn")
const pattern_ui = preload("res://ui_pattern.tscn")
const relic_ui = preload("res://ui_relic.tscn")

var cate : String
var object
var original_price : int
var price : int
var quantity : int

func setup(_cate : String, _object, _price : int, _quantity : int = 1):
	cate = _cate
	object = _object
	original_price = _price
	quantity = _quantity

func refresh_price():
	if Game.modifiers["half_price_i"] > 0:
		price = int(original_price * 0.5)
	else:
		price = original_price
	if price > original_price:
		buy_button.text.text = "[color=ORANGE_RED]%d[/color][img=16]res://images/coin.png[/img]" % price
	elif price < original_price:
		buy_button.text.text = "[color=LAWN_GREEN]%d[/color][img=16]res://images/coin.png[/img]" % price
	else:
		buy_button.text.text = "[color=WHITE]%d[/color][img=16]res://images/coin.png[/img]" % price

func buy():
	if Game.coins < price:
		Game.status_bar_ui.coins_text.hint()
		return false
	if cate == "relic" && Game.relics.size() >= 5:
		SSound.se_error.play()
		Game.banner_ui.show_tip(tr("wr_relics_count_limit") % Game.MaxRelics, "", 1.0)
		return false
	
	buy_button.disabled = true
	SSound.se_coin.play()
	Game.coins -= price
	
	var tween = Game.get_tree().create_tween()
	if cate == "gem":
		var ui = gem_ui.instantiate()
		ui.update(object)
		ui.position = self.global_position
		ui.scale = Vector2(2.0, 2.0)
		Game.game_ui.add_child(ui)
		
		tween.tween_property(ui, "scale", Vector2(1.0, 1.0), 0.4)
		tween.parallel()
		SAnimation.cubic_curve_to(tween, ui, Game.status_bar_ui.bag_button.get_global_rect().get_center(), Vector2(0.1, 0.2), Vector2(0.9, 0.2), 0.4)
		tween.tween_callback(func():
			var original = object as Gem
			for i in quantity:
				var gem = Gem.new()
				Game.copy_gem(original, gem)
				Game.add_gem(gem)
			Game.sort_gems()
			ui.queue_free()
		)
	elif cate == "relic":
		var img = AnimatedSprite2D.new()
		img.sprite_frames = Relic.relic_frames
		img.frame = object.image_id
		img.position = self.global_position
		img.scale = Vector2(2.0, 2.0)
		Game.game_ui.add_child(img)
		
		SAnimation.cubic_curve_to(tween, img, Game.relics_bar_ui.get_pos(-1), Vector2(0.1, 0.2), Vector2(0.9, 0.2), 0.4)
		tween.tween_callback(func():
			Game.add_relic(object)
			img.queue_free()
		)
	tween.tween_callback(func():
		Game.save_to_file()
		self.queue_free()
	)
	
	self.hide()
	
	return true

func _ready() -> void:
	if cate != "":
		#cate_frame.show()
		#cate_label.text = cate
		if cate == "gem":
			var ctrl = Control.new()
			ctrl.custom_minimum_size = Vector2(64, 64)
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
	buy_button.button.pressed.connect(func():
		buy()
	)
	refresh_price()
