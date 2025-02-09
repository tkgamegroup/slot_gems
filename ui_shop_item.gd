extends Control

@onready var bg : Control = $BG
@onready var image : AnimatedSprite2D = $BG/AnimatedSprite2D
@onready var gold_text : Label = $Label

var image_id : int
var gold : int

func setup(_image_id : int, _gold : int):
	image_id = _image_id
	gold = _gold

func _ready() -> void:
	image.frame = image_id
	gold_text.text = "%dG" % gold
	
	mouse_entered.connect(func():
		Sounds.sfx_select.play()
		bg.position.y -= 10
	)
	mouse_exited.connect(func():
		bg.position.y += 10
	)
	
	bg.scale = Vector2(0.0, 0.0)
	gold_text.hide()
	var tween = Game.get_tree().create_tween()
	tween.tween_property(bg, "scale", Vector2(1.0, 1.0), 0.3)
	tween.tween_callback(gold_text.show)
