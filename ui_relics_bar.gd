extends PanelContainer

@onready var list : Control = $MarginContainer/HBoxContainer

const relic_pb = preload("res://ui_relic.tscn")

func add_ui(r : Relic):
	var ui = relic_pb.instantiate()
	ui.setup(r)
	list.add_child(ui)

func clear():
	if list:
		for n in list.get_children():
			n.queue_free()
			list.remove_child(n)
