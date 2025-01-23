extends Control

@onready var name_text = $Label
@onready var bar_text = $Label2
@onready var value_text = $Label3

var name_str : String
var value_str : String

const bar_str = ".................................................................."

func _ready() -> void:
	name_text.text = name_str
	value_text.text = value_str
	
	var tween = get_tree().create_tween()
	tween.tween_method(func(t):
		bar_text.text = bar_str.substr(0, int(bar_str.length() * t))
	, 0.0, 1.0, 0.5)
	tween.tween_callback(func():
		value_text.show()
	)
