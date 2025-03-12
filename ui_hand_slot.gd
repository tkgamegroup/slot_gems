extends Control

@onready var trade : Sprite2D = $Trade
@onready var sp : AnimatedSprite2D = $SP

var item : Item = null

func _ready() -> void:
	sp.frame = item.image_id
	mouse_entered.connect(func():
		if Game.hand.dragging != self:
			SSound.sfx_select.play()
			STooltip.show(item.get_tooltip())
	)
	mouse_exited.connect(func():
		STooltip.close()
	)
