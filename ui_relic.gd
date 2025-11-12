extends Control

@onready var sp = $AnimatedSprite2D

var relic : Relic

func setup(_relic : Relic):
	relic = _relic

func _ready() -> void:
	sp.frame = relic.image_id
