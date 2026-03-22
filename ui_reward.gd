extends Control

@export var bg : Control
@export var icon_img : Sprite2D
@export var title_txt : Label
@export var desc_txt : Label
@export var cate_txt : Label

var data : Dictionary

func setup(_data : Dictionary):
	data = _data

func _ready() -> void:
	if !data.is_empty():
		icon_img.texture = load(data.icon)
		title_txt.text = data.title
		desc_txt.text = data.description
		cate_txt.text = ""
	
	mouse_entered.connect(func():
		SSound.se_select.play()
		bg.position.y = -20
	)
	mouse_exited.connect(func():
		bg.position.y = 0
	)
