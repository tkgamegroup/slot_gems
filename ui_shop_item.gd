extends Control

@onready var bg : Control = $BG
@onready var image : AnimatedSprite2D = $BG/AnimatedSprite2D
@onready var coin_text : Label = $Label

var image_id : int
var coins : int

func setup(_image_id : int, _coins : int):
	image_id = _image_id
	coins = _coins

func _ready() -> void:
	image.frame = image_id
	coin_text.text = "%dG" % coins
	
	mouse_entered.connect(func():
		SSound.sfx_select.play()
		bg.position.y -= 10
	)
	mouse_exited.connect(func():
		bg.position.y += 10
	)
	
	bg.scale = Vector2(0.0, 0.0)
	coin_text.hide()
	var tween = Game.get_tree().create_tween()
	tween.tween_property(bg, "scale", Vector2(1.0, 1.0), 0.3)
	tween.tween_callback(coin_text.show)
