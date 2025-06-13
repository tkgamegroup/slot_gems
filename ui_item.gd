extends Control

@onready var sp = $AnimatedSprite2D

var item : Item

func setup(_item : Item):
	item = _item

func _ready() -> void:
	sp.frame = item.image_id
	
	self.mouse_entered.connect(func():
		SSound.se_select.play()
		STooltip.show(item.get_tooltip())
	)
	self.mouse_exited.connect(func():
		STooltip.close()
	)
