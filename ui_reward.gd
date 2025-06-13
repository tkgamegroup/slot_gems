extends Control

@onready var bg : Control = $BG
@onready var icon_img : Sprite2D = $BG/Icon
@onready var title_txt : Label = $BG/Label
@onready var desc_txt : Label = $BG/Label2
@onready var cate_txt : Label = $BG/Label3

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
