extends Control

const UiSlot = preload("res://ui_gem_slot.gd")

@onready var title_txt : RichTextLabel = $Title
@onready var slot1 : UiSlot = $HBoxContainer/Slot1
@onready var slot2 : UiSlot = $HBoxContainer/Slot2
@onready var button = $MarginContainer/Button

var price : int = 0

var disabled : bool = false:
	set(v):
		disabled = v
		if v:
			button.disabled = true
		else:
			if slot1.gem && slot2.gem:
				button.disabled = false
		slot1.disabled = v
		slot2.disabled = v

func setup(_price : int):
	price = _price

func _ready() -> void:
	title_txt.text = "[url=%s]%s[/url]" % ["w_enchant_entangle", tr("w_enchant_entangle")]
	button.disabled = true
	button.text.text = "[img]res://images/coin.png[/img]%d" % price
	slot1.on_load.connect(func(gem : Gem):
		if slot2.gem:
			button.disabled = false
	)
	slot1.on_unload.connect(func(gem : Gem):
		var ui = Hand.add_gem(gem)
		ui.global_position = slot1.get_global_rect().get_center()
		button.disabled = true
	)
	slot2.on_load.connect(func(gem : Gem):
		if slot1.gem:
			button.disabled = false
	)
	slot2.on_unload.connect(func(gem : Gem):
		var ui = Hand.add_gem(gem)
		ui.global_position = slot2.get_global_rect().get_center()
		button.disabled = true
	)
	button.button.pressed.connect(func():
		if !slot1.gem || !slot2.gem:
			return
		if G.coins < price:
			G.status_bar_ui.coins_text.hint()
			return
		
		G.shop_ui.disabled = true
		G.coins -= price
		SSound.se_coin.play()
		
		var tween = G.game_tweens.create_tween()
		tween.tween_interval(0.2)
		tween.tween_callback(func():
			slot1.particles1.emitting = true
			slot2.particles1.emitting = true
		)
		tween.tween_interval(0.7)
		tween.tween_callback(func():
			SSound.se_enchant.play()
			slot1.particles2.emitting = true
			slot2.particles2.emitting = true
		)
		tween.tween_interval(0.4)
		tween.tween_callback(func():
			G.entangle_gems(slot1.gem, slot2.gem)
		)
		tween.tween_callback(func():
			slot1.unload_gem()
			slot2.unload_gem()
		)
		tween.tween_property(self, "modulate:a", 0.0, 0.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)
		tween.tween_callback(func():
			G.shop_ui.disabled = false
			G.save_to_file()
			self.queue_free()
		)
	)
