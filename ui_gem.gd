extends Node2D

@onready var bg_sp : AnimatedSprite2D = $BG
@onready var runes_sp : AnimatedSprite2D = $Runes
@onready var image_sp : AnimatedSprite2D = $Image

var type : int
var runes : int
var image_id : int

func set_image(_type : int, _runes : int, _image_id : int):
	type = _type
	runes = _runes
	image_id = _image_id
	if image_sp:
		bg_sp.frame = type
		runes_sp.frame = runes
		image_sp.frame = image_id if image_id > 5 else 0

func _ready() -> void:
	set_image(type, runes, image_id)
