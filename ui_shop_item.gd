extends Control

@onready var base : Control = $Base
@onready var cate_frame : Control = $Base/Category
@onready var cate_label : Label = $Base/Category/MarginContainer/Label
@onready var content : Control = $Base/Content
@onready var coin_text : Label = $Base/Price/MarginContainer/HBoxContainer/Label

const item_ui = preload("res://ui_item.tscn")
const skill_ui = preload("res://ui_skill.tscn")
const pattern_ui = preload("res://ui_pattern.tscn")
const relic_ui = preload("res://ui_relic.tscn")

var cate : String
var object
var coins : int
var callback : Callable

func setup(_cate : String, _object, _coins : int, _callback : Callable):
	cate = _cate
	object = _object
	coins = _coins
	callback = _callback

func buy():
	if Game.coins < coins:
		return false
	SSound.sfx_coin.play()
	Game.coins -= coins
	callback.call()
	
	get_parent().remove_child(self)
	self.queue_free()
	return true

func _ready() -> void:
	if cate != "":
		cate_frame.show()
		cate_label.text = cate
		if cate == "Item":
			var ui = item_ui.instantiate()
			ui.setup(object)
			content.add_child(ui)
		elif cate == "Skill":
			var ui = skill_ui.instantiate()
			ui.setup(object)
			content.add_child(ui)
		elif cate == "Pattern":
			var ui = pattern_ui.instantiate()
			ui.setup(object, true)
			content.add_child(ui)
		elif cate == "Relic":
			var ui = relic_ui.instantiate()
			ui.setup(object)
			content.add_child(ui)
	coin_text.text = "%dG" % coins
	
	gui_input.connect(func(event : InputEvent):
		if event is InputEventMouseButton:
			if event.pressed && event.button_index == MOUSE_BUTTON_LEFT:
				buy()
	)
	mouse_entered.connect(func():
		SSound.sfx_select.play()
		base.position.y -= 5
	)
	mouse_exited.connect(func():
		base.position.y += 5
	)
