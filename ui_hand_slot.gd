extends Control

@export var gem_ui : G.UiGem

var gem : Gem = null
var preview = MatchPreview.new()
var elastic : float = 1.0

func _ready() -> void:
	self.custom_minimum_size = Vector2(C.SPRITE_SZ, C.SPRITE_SZ)
	self.pivot_offset = Vector2(C.SPRITE_SZ, C.SPRITE_SZ) * 0.5
	
	gem_ui.update(gem)
	
	mouse_entered.connect(func():
		if Drag.ui != self && elastic > 0.5:
			SSound.se_select.play()
			STooltip.show(self, 1, gem.get_tooltip())
			
			if !Hand.ui.disabled:
				preview.show()
	)
	mouse_exited.connect(func():
		STooltip.close()
		preview.clear()
	)
