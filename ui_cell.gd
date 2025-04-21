extends Node2D

@onready var gem = $Gem
@onready var item : AnimatedSprite2D = $Item
@onready var item2 : AnimatedSprite2D = $Item2
@onready var burn : Sprite2D = $Burn
@onready var frozen : Sprite2D = $Frozen

func set_gem_image(gem_type : int, gem_rune : int):
	gem.set_image(gem_type, gem_rune)

func set_item_image(item_image : int, item2_image : int = 0):
	item.frame = item_image
	item2.frame = item2_image

func set_is_duplicant(v : bool):
	if v:
		item.self_modulate = Color(0.45, 0.624, 0.906, 1.0)
		item2.self_modulate = Color(0.45, 0.624, 0.906, 1.0)
	else:
		item.self_modulate = Color(1.0, 1.0, 1.0, 1.0)
		item.self_modulate = Color(1.0, 1.0, 1.0, 1.0)
