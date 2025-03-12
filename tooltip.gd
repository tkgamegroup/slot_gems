extends Control

@onready var title_text : RichTextLabel = $VBoxContainer/Title
@onready var content_text : RichTextLabel = $VBoxContainer/Content

var title : String
var content : String

func _ready() -> void:
	title_text.text = title
	content_text.text = content
	self.modulate.a = 0.0
	var tween = Game.get_tree().create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.2)
	#tween.parallel().tween_method(func(t):
	#	content_text.text = content.substr(0, content.length() * t)
	#, 0.0, 1.0, 0.2)
