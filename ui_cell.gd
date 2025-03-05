extends Node2D

@onready var gem = $Gem
@onready var item : AnimatedSprite2D = $Item
@onready var burn : Sprite2D = $Burn
@onready var pin : Sprite2D = $Pin

func set_gem_image(gem_type : int, gem_rune : int):
	gem.set_image(gem_type, gem_rune)

func set_item_image(item_image : int):
	item.frame = item_image
	
