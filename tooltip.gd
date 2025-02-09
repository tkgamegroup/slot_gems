extends Node

@onready var ui : Control = $/root/Main/UI/Tooltip
@onready var title_text : Label = $/root/Main/UI/Tooltip/VBoxContainer/Title
@onready var content_text : Label = $/root/Main/UI/Tooltip/VBoxContainer/Content

var tween : Tween = null

func show(title : String, content : String):
	ui.show()
	ui.position = get_viewport().get_mouse_position() + Vector2(30, 20)
	ui.modulate.a = 0.0
	if tween:
		tween.kill()
		tween = null
	tween = Game.get_tree().create_tween()
	tween.tween_interval(0.05)
	tween.tween_property(ui, "modulate:a", 1.0, 0.2)
	tween.parallel().tween_method(func(t):
		title_text.text = title.substr(0, title.length() * t)
		content_text.text = content.substr(0, content.length() * t)
	, 0.0, 1.0, 0.2)
	tween.tween_callback(func():
		tween = null
	)

func close():
	if tween:
		tween.kill()
		tween = null
	ui.hide()
	title_text.text = ""
	content_text.text = ""
