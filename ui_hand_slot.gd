extends Control

@onready var gem_ui : Node2D = $Gem

var gem : Gem = null
var preview = MatchPreview.new()
var elastic : float = 1.0

func _ready() -> void:
	gem_ui.update(gem)
	
	mouse_entered.connect(func():
		if Drag.ui != self:
			SSound.se_select.play()
			STooltip.show(gem.get_tooltip())
			
			if !Hand.ui.disabled:
				preview.find_missing_ones(gem.type)
				preview.show()
	)
	mouse_exited.connect(func():
		STooltip.close()
		preview.clear()
	)
