extends Control

@export var bg : Control
@export var content : Control
@export var name_txt : Label
@export var quantity_txt : Label

var cate : String
var object
var quantity : int

func setup(_cate : String, _object, _quantity : int = 1):
	cate = _cate
	object = _object
	quantity = _quantity

func _ready() -> void:
	var name = ""
	if cate == "gem":
		var ctrl = Control.new()
		ctrl.custom_minimum_size = Vector2(C.SPRITE_SZ, C.SPRITE_SZ)
		ctrl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var ui = G.gem_ui_pb.instantiate()
		ui.update(object)
		ctrl.add_child(ui)
		self.mouse_entered.connect(func():
			STooltip.show(self, 0, object.get_tooltip())
		)
		self.mouse_exited.connect(func():
			STooltip.close()
		)
		content.add_child(ctrl)
		name = object.get_tooltip_title()
	
	quantity_txt.text = "X%d" % quantity
	name_txt.text = name
	
	self.mouse_entered.connect(func():
		SSound.se_select.play()
		bg.show()
	)
	self.mouse_exited.connect(func():
		bg.hide()
	)
