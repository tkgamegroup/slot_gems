extends Control

@onready var gem_ui : Node2D = $Gem
@onready var action : Sprite2D = $Action

var gem : Gem = null

var selected : bool = false

func _ready() -> void:
	gem_ui.set_image(gem.type, gem.rune)
	
	mouse_entered.connect(func():
		if Game.hand_ui.dragging != self:
			SSound.sfx_select.play()
			STooltip.show(gem.get_tooltip())
	)
	mouse_exited.connect(func():
		STooltip.close()
	)
