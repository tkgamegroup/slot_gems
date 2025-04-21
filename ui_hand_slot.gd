extends Control

@onready var sp : AnimatedSprite2D = $SP
@onready var action : Sprite2D = $Action

var item : Item = null

func _ready() -> void:
	sp.frame = item.image_id
	mouse_entered.connect(func():
		if Game.hand_ui.dragging != self:
			SSound.sfx_select.play()
			STooltip.show(item.get_tooltip())
	)
	mouse_exited.connect(func():
		STooltip.close()
	)
