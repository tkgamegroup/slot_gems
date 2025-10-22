extends Control

@onready var sp = $AnimatedSprite2D

var relic : Relic

func setup(_relic : Relic):
	relic = _relic

func _ready() -> void:
	sp.frame = relic.image_id
	
	self.mouse_entered.connect(func():
		SSound.se_select.play()
		STooltip.show(self, 0, relic.get_tooltip())
	)
	self.mouse_exited.connect(func():
		STooltip.close()
	)
