extends Control

@onready var gem_ui = $Gem

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
				if gem.type != Gem.None || gem.rune != Gem.None:
					preview.find_missing_ones(gem.type, gem.rune)
					preview.show()
	)
	mouse_exited.connect(func():
		STooltip.close()
		preview.clear()
	)
