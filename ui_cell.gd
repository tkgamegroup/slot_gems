extends Node2D

@onready var gem_ui = $Gem
@onready var item_sp : AnimatedSprite2D = $Item
@onready var item2_2p : AnimatedSprite2D = $Item2
@onready var burn : Sprite2D = $Burn
@onready var pinned : Sprite2D = $Pinned
@onready var frozen : Sprite2D = $Frozen
@onready var nullified : Node2D = $Nullified
@onready var nullified_sp1 : AnimatedSprite2D = $Nullified/sp1
@onready var nullified_sp2 : AnimatedSprite2D = $Nullified/sp2

func set_gem_image(gem_type : int, gem_rune : int):
	gem_ui.set_image(gem_type, gem_rune)

func set_item_image(item_image : int, item2_image : int = 0):
	item_sp.frame = item_image
	item2_2p.frame = item2_image

func set_duplicant(v : bool):
	if v:
		item_sp.self_modulate = Color(0.45, 0.624, 0.906, 1.0)
		item2_2p.self_modulate = Color(0.45, 0.624, 0.906, 1.0)
	else:
		item_sp.self_modulate = Color(1.0, 1.0, 1.0, 1.0)
		item2_2p.self_modulate = Color(1.0, 1.0, 1.0, 1.0)

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
