extends Control

const UiSlot = preload("res://ui_gem_slot.gd")

@onready var slot : UiSlot = $Slot

var disabled : bool = false:
	set(v):
		disabled = v
		slot.disabled = v

func _ready() -> void:
	slot.rc_to_unload = false
	slot.on_load.connect(func(gem : Gem):
		if slot.gem:
			var ui = Hand.add_gem(slot.gem)
			ui.global_position = self.get_global_rect().get_center()
			slot.gem = null
	)
	slot.on_unload.connect(func(gem : Gem):
		var ui = App.create_gem_ui(gem, slot.global_position)
		var tween = App.game_tweens.create_tween()
		SAnimation.quadratic_curve_to(tween, ui, App.status_bar_ui.bag_button.global_position, Vector2(0.5, 0.2), 0.5)
		tween.tween_callback(func():
			App.put_back_gem_to_bag(gem)
			App.sort_gems()
			ui.queue_free()
		)
	)
