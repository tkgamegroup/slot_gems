extends Panel

@onready var panel : Control = $PanelContainer
@onready var tab_container : TabContainer = $PanelContainer/VBoxContainer/TabContainer
@onready var prev_button : Button = $PanelContainer/VBoxContainer/HBoxContainer/Prev
@onready var next_button : Button = $PanelContainer/VBoxContainer/HBoxContainer/Next
@onready var elements_image : TextureRect = $Elements
@onready var close_button : Button = $PanelContainer/VBoxContainer/HBoxContainer/Button
@onready var pattern_list = $PanelContainer/VBoxContainer/TabContainer/VBoxContainer2/HBoxContainer

const ui_pattern_pb = preload("res://ui_pattern.tscn")

var view_idx : int = 0

func update_view():
	match view_idx:
		0: 
			tab_container.current_tab = 0
			elements_image.show()
		1: 
			tab_container.current_tab = 1
			elements_image.hide()
	prev_button.disabled = view_idx == 0
	next_button.disabled = view_idx == 1

func enter():
	STooltip.close()
	
	view_idx = 0
	update_view()
	
	self.show()
	self.modulate.a = 0.0
	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.3)
	
func exit():
	self.modulate.a = 1.0
	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	tween.tween_callback(func():
		self.hide()
	)

func _ready() -> void:
	var p1 = Pattern.new()
	p1.setup("\\")
	var pui1 = ui_pattern_pb.instantiate()
	pui1.setup(p1, true)
	pattern_list.add_child(pui1)
	var p2 = Pattern.new()
	p2.setup("|")
	var pui2 = ui_pattern_pb.instantiate()
	pui2.setup(p2, true)
	pattern_list.add_child(pui2)
	var p3 = Pattern.new()
	p3.setup("/")
	var pui3 = ui_pattern_pb.instantiate()
	pui3.setup(p3, true)
	pattern_list.add_child(pui3)
	var p4 = Pattern.new()
	p4.setup("Island")
	var pui4 = ui_pattern_pb.instantiate()
	pui4.setup(p4, true)
	pattern_list.add_child(pui4)
	prev_button.pressed.connect(func():
		if view_idx > 0:
			view_idx -= 1
			update_view()
	)
	next_button.pressed.connect(func():
		if view_idx < 1:
			view_idx += 1
			update_view()
	)
	close_button.pressed.connect(func():
		exit()
	)
