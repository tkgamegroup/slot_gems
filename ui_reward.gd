extends Control

@export var bg : Control
@export var content : Control
@export var title_txt : Label

var cate : String
var object
var quantity : int

func setup(_cate : String, _object, _quantity : int = 1):
	cate = _cate
	object = _object
	quantity = _quantity

func _ready() -> void:
	var title = ""
	if cate == "gem":
		var ctrl = Control.new()
		ctrl.custom_minimum_size = Vector2(C.SPRITE_SZ, C.SPRITE_SZ)
		var ui = G.gem_ui_pb.instantiate()
		ui.update(object)
		ctrl.add_child(ui)
		ctrl.mouse_entered.connect(func():
			SSound.se_select.play()
			STooltip.show(ui, 0, object.get_tooltip())
		)
		ctrl.mouse_exited.connect(func():
			STooltip.close()
		)
		content.add_child(ctrl)
		title = "Get %s" % object.get_tooltip_title()
	
	if quantity > 1:
		title += " X%d" % quantity
	title_txt.text = title
	
	self.mouse_entered.connect(func():
		SSound.se_select.play()
		bg.show()
	)
	self.mouse_exited.connect(func():
		bg.hide()
	)
