extends Control

const ShopButton = preload("res://shop_button.gd")

@onready var cate_frame : Control = $Category
@onready var cate_label : Label = $Category/MarginContainer/Label
@onready var content : Control = $Content
@onready var button : ShopButton = $ShopButton

const gem_ui = preload("res://ui_gem.tscn")
const item_ui = preload("res://ui_item.tscn")
const pattern_ui = preload("res://ui_pattern.tscn")
const relic_ui = preload("res://ui_relic.tscn")

var cate : String
var object
var price : int

func setup(_cate : String, _object, _price : int):
	cate = _cate
	object = _object
	price = _price

func buy():
	if Game.coins < price:
		Game.status_bar_ui.coins_text.hint()
		return false
	
	button.button.disabled = true
	SSound.se_coin.play()
	Game.coins -= price
	
	if cate == "gem":
		var ui = gem_ui.instantiate()
		ui.set_image(object.type, object.rune, 0)
		ui.position = self.global_position
		ui.scale = Vector2(2.0, 2.0)
		Game.game_ui.add_child(ui)
		
		var tween = Game.get_tree().create_tween()
		tween.tween_property(ui, "scale", Vector2(1.0, 1.0), 0.4)
		tween.parallel()
		SAnimation.cubic_curve_to(tween, ui, Game.status_bar_ui.bag_button.get_global_rect().get_center(), Vector2(0.1, 0.2), Vector2(0.9, 0.2), 0.4)
		tween.tween_callback(func():
			Game.add_gem(object)
			ui.queue_free()
			self.queue_free()
		)
	elif cate == "relic":
		var img = AnimatedSprite2D.new()
		img.sprite_frames = Relic.relic_frames
		img.frame = object.image_id
		img.position = self.global_position
		img.scale = Vector2(2.0, 2.0)
		Game.game_ui.add_child(img)
		
		var tween = Game.get_tree().create_tween()
		SAnimation.cubic_curve_to(tween, img, Game.relics_bar_ui.get_pos(-1), Vector2(0.1, 0.2), Vector2(0.9, 0.2), 0.4)
		tween.tween_callback(func():
			Game.add_relic(object)
			img.queue_free()
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
			ui.set_image(object.type, object.rune)
			ui.scale = Vector2(2.0, 2.0)
			ctrl.add_child(ui)
			ctrl.mouse_entered.connect(func():
				SSound.se_select.play()
				STooltip.show(object.get_tooltip())
			)
			ctrl.mouse_exited.connect(func():
				STooltip.close()
			)
			content.add_child(ctrl)
			ui.position = Vector2(32, 32)
		elif cate == "item":
			var ui = item_ui.instantiate()
			ui.setup(object)
			ui.mouse_filter = Control.MOUSE_FILTER_PASS
			content.add_child(ui)
			ui.position = Vector2(16, 16)
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
			ui.position = Vector2(16, 16)
	button.price.text = "%d" % price
	button.button.pressed.connect(func():
		buy()
	)
