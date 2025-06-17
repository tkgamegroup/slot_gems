extends Control

@onready var text : Label = $Text
@onready var change : Label = $Panel/ChangeBG/Change
@onready var change_bg : ColorRect = $Panel/ChangeBG
@onready var change_panel : Control = $Panel

@export var font_size : int = 22

var value : int
var enable_change : bool = true

var tween : Tween = null

func set_value(v : int):
	if !enable_change:
		value = v
		text.text = "%d" % value
		return
	
	if tween:
		tween.custom_step(100.0)
		tween = null
	var d = v - value
	if d >= 0:
		change.text = "+%d" % d
		change_bg.color = Color(0.0, 0.496, 0.853)
	else:
		change.text = "%d" % d
		change_bg.color = Color(0.866, 0.083, 0.0)
	change.pivot_offset = change.size * 0.5
	change.scale = Vector2(0.0, 0.0)
	change_panel.show()
	value = v
	tween = get_tree().create_tween()
	tween.tween_property(text, "modulate:a", 0.0, 0.2).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUART)
	tween.parallel().tween_property(change_bg, "modulate:a", 1.0, 0.2).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUART)
	tween.parallel().tween_property(change, "scale", Vector2(1.0, 1.0), 0.1).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUART)
	tween.tween_interval(0.5)
	tween.tween_callback(func():
		text.text = "%d" % value
	)
	tween.tween_property(change_bg, "modulate:a", 0.0, 0.4).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUART)
	tween.parallel().tween_property(text, "modulate:a", 1.0, 0.4).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUART)
	tween.parallel().tween_property(change, "scale", Vector2(0.0, 0.0), 0.2).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUART)
	tween.tween_callback(func():
		change_panel.hide()
		tween = null
	)

func hint():
	var original_color = text.get_theme_color("font_color")
	var tween = get_tree().create_tween()
	tween.tween_method(func(v):
		text.add_theme_color_override("font_color", lerp(Color(0.866, 0.083, 0.0), original_color, v))
	, 0.0, 1.0, 0.5)
	tween.parallel()
	SAnimation.shake(tween, text, 5.0, 0.5)

func _ready() -> void:
	text.add_theme_font_size_override("font_size", font_size)
	change.add_theme_font_size_override("font_size", font_size)
	self.custom_minimum_size = Vector2(font_size * 1.6, font_size)
	self.size = self.custom_minimum_size
