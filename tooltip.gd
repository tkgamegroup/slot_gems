extends Control

@onready var title_text : RichTextLabel = $VBoxContainer/Title
@onready var content_text : RichTextLabel = $VBoxContainer/Content

var title : String
var content : String

func _ready() -> void:
	if !title.is_empty():
		title_text.text = title
	else:
		title_text.hide()
	content_text.text = content
	title_text.visible_ratio = 0.0
	content_text.visible_ratio = 0.0
	var tween = G.create_tween()
	tween.tween_property(title_text, "visible_ratio", 1.0, 0.2)
	tween.parallel().tween_property(content_text, "visible_ratio", 1.0, 0.2)
	
