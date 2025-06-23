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
var callback : Callable

func setup(_cate : String, _object, _price : int, _callback : Callable):
	cate = _cate
	object = _object
	price = _price
	callback = _callback

func buy():
	if Game.coins < price:
		Game.status_bar_ui.coins_text.hint()
		return false
	SSound.se_coin.play()
	Game.coins -= price
	callback.call()
	
	get_parent().remove_child(self)
	self.queue_free()
	return true

func _ready() -> void:
	if cate != "":
		#cate_frame.show()
		#cate_label.text = cate
		if cate == "Gem":
			var ctrl = Control.new()
			ctrl.custom_minimum_size = Vector2(32, 32)
			var ui = gem_ui.instantiate()
			ui.set_image(object.type, object.rune)
			ctrl.add_child(ui)
			ctrl.mouse_entered.connect(func():
				SSound.se_select.play()
				STooltip.show(object.get_tooltip())
			)
			ctrl.mouse_exited.connect(func():
				STooltip.close()
			)
			content.add_child(ctrl)
			ui.position = Vector2(16, 16)
		elif cate == "Item":
			var ui = item_ui.instantiate()
			ui.setup(object)
			ui.mouse_filter = Control.MOUSE_FILTER_PASS
			content.add_child(ui)
			ui.position = Vector2(16, 16)
		elif cate == "Pattern":
			var ui = pattern_ui.instantiate()
			ui.setup(object, true)
			ui.mouse_filter = Control.MOUSE_FILTER_PASS
			content.add_child(ui)
		elif cate == "Relic":
			var ui = relic_ui.instantiate()
			ui.setup(object)
			ui.mouse_filter = Control.MOUSE_FILTER_PASS
			content.add_child(ui)
			ui.position = Vector2(16, 16)
	button.price.text = "%d" % price
	button.button.pressed.connect(func():
		buy()
	)
