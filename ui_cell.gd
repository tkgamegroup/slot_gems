extends Control

@export var gem_ui : G.UiGem
@export var pinned : Sprite2D
@export var frozen : Sprite2D
@export var nullified : Node2D
@export var nullified_sp1 : AnimatedSprite2D
@export var nullified_sp2 : AnimatedSprite2D
@export var floating : Node2D
@export var floating_bubbles : CPUParticles2D
@export var floating_animation : AnimationPlayer

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

func set_floating(v : bool):
	if v:
		floating.show()
		floating_bubbles.emitting = true
		floating_animation.play("default")
	else:
		floating.hide()
		floating_bubbles.emitting = false
		floating_animation.stop()

func _ready() -> void:
	pinned.position = Vector2(C.SPRITE_SZ * 0.5, C.SPRITE_SZ * 0.5)
	frozen.position = Vector2(C.SPRITE_SZ * 0.5, C.SPRITE_SZ * 0.5)
	nullified.position = Vector2(C.SPRITE_SZ * 0.5, C.SPRITE_SZ * 0.5)
