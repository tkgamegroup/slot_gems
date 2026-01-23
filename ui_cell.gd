extends Control

const UiGem = preload("res://ui_gem.gd")

@onready var gem_ui : UiGem = $Gem
@onready var pinned : Sprite2D = $Pinned
@onready var frozen : Sprite2D = $Frozen
@onready var nullified : Node2D = $Nullified
@onready var nullified_sp1 : AnimatedSprite2D = $Nullified/sp1
@onready var nullified_sp2 : AnimatedSprite2D = $Nullified/sp2

func set_nullified(v : bool):
	if v:
		nullified.show()
		nullified_sp1.play("default")
		nullified_sp1.frame = 2
		nullified_sp2.play("default")
		nullified_sp2.frame = 0
	else:
		nullified.hide()
		nullified_sp1.stop()
		nullified_sp2.stop()
