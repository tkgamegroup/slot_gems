extends Control

@onready var base : Control = $Base
@onready var cate_frame : Control = $Base/Category
@onready var cate_label : Label = $Base/Category/MarginContainer/Label
@onready var content : Control = $Base/Content
@onready var image : AnimatedSprite2D = $Base/Content/SP
@onready var tilemap : TileMapLayer = $Base/Content/TileMapLayer
@onready var label : Label = $Base/Content/Text
@onready var coin_text : Label = $Base/Price/MarginContainer/HBoxContainer/Label

var cate : String
var object
var text : String
var coins : int
var callback : Callable

func setup(_cate : String, _object, _text : String, _coins : int, _callback : Callable):
	cate = _cate
	object = _object
	text = _text
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
			image.sprite_frames = Item.item_frames
			image.frame = object.image_id
		elif cate == "Relic":
			image.sprite_frames = Relic.relic_frames
			image.frame = object.image_id
		elif cate == "Skill":
			image.sprite_frames = Skill.skill_frames
			image.frame = object.image_id
		elif cate == "Pattern":
			var coords = object.get_ui_coords()
			tilemap.show()
			for c in coords:
				var cc = Board.cube_to_oddq(c)
				tilemap.set_cell(cc, 0, Vector2i(0, 0))
	label.text = text
	coin_text.text = "%dG" % coins
	
	gui_input.connect(func(event : InputEvent):
		if event is InputEventMouseButton:
			if event.pressed && event.button_index == MOUSE_BUTTON_LEFT:
				buy()
	)
	mouse_entered.connect(func():
		SSound.sfx_select.play()
		base.position.y -= 10
		STooltip.show(object.get_tooltip())
	)
	mouse_exited.connect(func():
		base.position.y += 10
		STooltip.close()
	)
