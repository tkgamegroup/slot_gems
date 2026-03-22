extends Control

const UiGem = preload("res://ui_gem.gd")

@export var gem_ui : UiGem
@export var pinned : Sprite2D
@export var frozen : Sprite2D
@export var nullified : Node2D
@export var nullified_sp1 : AnimatedSprite2D
@export var nullified_sp2 : AnimatedSprite2D

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
