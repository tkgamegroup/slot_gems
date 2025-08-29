extends Control

@onready var gem_ui : Node2D = $Gem

var gem : Gem = null

func _ready() -> void:
	gem_ui.set_image(gem.type, gem.rune, gem.bound_item.image_id if gem.bound_item else 0)
	
	mouse_entered.connect(func():
		if Drag.ui != self:
			SSound.se_select.play()
			STooltip.show(gem.get_tooltip())
	)
	mouse_exited.connect(func():
		STooltip.close()
	)
