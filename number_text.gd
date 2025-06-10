extends Control

@onready var text : Label = $Text
@onready var change : Label = $Change

var value : int

var tween : Tween = null

func set_value(v : int):
	if tween:
		tween.custom_step(100.0)
		tween = null
	var d = v - value
	if d >= 0:
		change.text = "+%d" % d
		change.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0))
	else:
		change.text = "%d" % d
		change.add_theme_color_override("font_color", Color(0.866, 0.083, 0.0))
	change.show()
	value = v
	tween = get_tree().create_tween()
	tween.tween_property(text, "modulate:a", 0.0, 0.2).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUART)
	tween.parallel().tween_property(change, "modulate:a", 1.0, 0.2).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUART)
	tween.tween_interval(0.5)
	tween.tween_callback(func():
		text.text = "%d" % value
	)
	tween.tween_property(change, "modulate:a", 0.0, 0.2).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUART)
	tween.parallel().tween_property(text, "modulate:a", 1.0, 0.2).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUART)
	tween.tween_callback(func():
		change.hide()
		tween = null
	)
