extends Control

@onready var sp = $AnimatedSprite2D

var relic : Relic
var tt_dir : int = 0
var elastic : float = 1.0

func setup(_relic : Relic, _tt_dir : int = 0):
	relic = _relic
	tt_dir = _tt_dir

func _ready() -> void:
	sp.frame = relic.image_id
	self.mouse_entered.connect(func():
		SSound.se_select.play()
		STooltip.show(self, tt_dir, relic.get_tooltip())
	)
	self.mouse_exited.connect(func():
		STooltip.close()
	)
