extends Control

const UiGem = preload("res://ui_gem.gd")

@onready var title_lb : RichTextLabel = $RichTextLabel
@onready var slot : Control = $Control
@onready var gem_ui : UiGem = $Control/UiGem
@onready var img_open : TextureRect = $Control/Open
@onready var img_close : TextureRect = $Control/Close
@onready var particles1 : CPUParticles2D = $Control/CPUParticles2D
@onready var particles2 : CPUParticles2D = $Control/CPUParticles2D2
@onready var button : Button = $Button

var gem : Gem = null
var title : String
var tooltip : Pair
var button_text : String
var cost : int = 0
var callback : Callable

func load_gem(_gem : Gem):
	gem = _gem
	img_open.hide()
	img_close.show()
	gem_ui.set_image(gem.type, gem.rune, gem.bound_item.image_id if gem.bound_item else 0)
	button.disabled = false

func unload_gem():
	if gem:
		Hand.get_gem_from(gem, slot.get_global_rect().get_center())
		img_open.show()
		img_close.hide()
		gem_ui.set_image(0, 0, 0)
		button.disabled = true
		gem = null

func setup(_title : String, tt_title : String, tt_content : String, _button_text : String, _cost : int, cb : Callable):
	title = _title
	tooltip = Pair.new(tt_title, tt_content)
	button_text = _button_text
	cost = _cost
	callback = cb

func _ready() -> void:
	title_lb.text = title
	title_lb.mouse_entered.connect(func():
		SSound.se_select.play()
		STooltip.show([tooltip])
	)
	title_lb.mouse_exited.connect(func():
		STooltip.close()
	)
	button.text = "%s %dG" % [button_text, cost]
	Drag.add_target("gem", slot, func(payload, ev : String, extra : Dictionary):
		if ev == "peek":
			img_open.modulate = Color(0.7, 0.7, 0.7, 1.0)
			img_close.modulate = Color(0.7, 0.7, 0.7, 1.0)
		elif ev == "peek_exited":
			img_open.modulate = Color(1.0, 1.0, 1.0, 1.0)
			img_close.modulate = Color(1.0, 1.0, 1.0, 1.0)
		else:
			if gem:
				unload_gem()
			load_gem(payload)
			return true
		return false
	)
	slot.gui_input.connect(func(event : InputEvent):
		if event is InputEventMouseButton:
			if event.pressed && event.button_index == MOUSE_BUTTON_RIGHT:
				SSound.se_drag_item.play()
				unload_gem()
	)
	slot.mouse_entered.connect(func():
		if gem:
			SSound.se_select.play()
			STooltip.show(gem.get_tooltip())
	)
	slot.mouse_exited.connect(func():
		STooltip.close()
	)
	button.pressed.connect(func():
		if gem && Game.coins >= cost:
			button.disabled = true
			Game.coins -= cost
			SSound.se_coin.play()
			particles1.emitting = true
			var tween = get_tree().create_tween()
			tween.tween_interval(0.7)
			tween.tween_callback(func():
				particles2.emitting = true
			)
			tween.tween_interval(0.4)
			tween.tween_callback(func():
				callback.call(gem)
				unload_gem()
			)
			tween.tween_property(self, "modulate:a", 0.0, 0.3)
			tween.tween_callback(func():
				self.queue_free()
			)
	)

func _exit_tree() -> void:
	if gem:
		unload_gem()
	Drag.remove_target(slot)
