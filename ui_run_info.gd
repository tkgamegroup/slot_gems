extends Control

@export var panel : Control
@export var widgets_root : Control
@export var tab_container : TabContainer
@export var rounds_list : GridContainer
@export var close_button : Button

func idx_to_pos(i : int):
	var y = i / 6
	var x = i % 6
	return y * 6 + (x if y % 2 == 0 else 5 - x)

func add_widgets():
	var line = G.dashed_line_pb.instantiate()
	line.width = 3
	widgets_root.add_child(line)
	for i in 23:
		var p0 = rounds_list.get_child(idx_to_pos(i)).get_rect().get_center()
		var p1 = rounds_list.get_child(idx_to_pos(i + 1)).get_rect().get_center()
		line.add_point(p0)
		line.add_point(p1)
		var w = G.round_widget_pb.instantiate()
		w.setup(i + 1)
		w.position = (p0 + p1) * 0.5
		widgets_root.add_child(w)

func enter():
	self.self_modulate.a = 0.0
	self.show()
	panel.show()
	
	var tween = G.create_tween()
	tween.tween_property(self, "self_modulate:a", 1.0, 0.3)
	
	for n in rounds_list.get_children():
		rounds_list.remove_child(n)
		n.queue_free()
	for n in widgets_root.get_children():
		widgets_root.remove_child(n)
		n.queue_free()
	for i in 24:
		var ui = G.round_info_pb.instantiate()
		ui.setup(idx_to_pos(i) + 1)
		rounds_list.add_child(ui)
	add_widgets.call_deferred()

func exit():
	panel.hide()
	
	self.self_modulate.a = 1.0
	var tween = G.create_tween()
	tween.tween_property(self, "self_modulate:a", 0.0, 0.3)
	tween.tween_callback(func():
		self.hide()
	)
	
func _ready() -> void:
	tab_container.set_tab_title(0, tr("ui_stage"))
	close_button.pressed.connect(func():
		exit()
	)
