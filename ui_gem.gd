extends Node2D

@onready var bg_sp : AnimatedSprite2D = $BG
@onready var rune_sp : AnimatedSprite2D = $Rune
@onready var image_sp : AnimatedSprite2D = $Image

var type : int
var rune : int
var image_id : int

func set_image(_type : int, _rune : int, _image_id : int):
	type = _type
	rune = _rune
	image_id = _image_id
	if image_sp:
		bg_sp.frame = type
		if type == Gem.Type.Blue || type == Gem.Type.Orange || type == Gem.Type.Green:
			rune_sp.modulate = Color(0.0, 0.0, 0.0, 1.0)
		else:
			rune_sp.modulate = Color(1.0, 1.0, 1.0, 1.0)
		rune_sp.frame = rune
		image_sp.frame = image_id if image_id > 5 else 0

func _ready() -> void:
	set_image(type, rune, image_id)
