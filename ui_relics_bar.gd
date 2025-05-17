extends Control

@onready var list : Control = $HBoxContainer

const relic_pb = preload("res://ui_relic.tscn")
const item_h = 32
const item_w = 32
const gap = 8

func add_ui(r : Relic):
	var ui = relic_pb.instantiate()
	ui.setup(r)
	list.add_child(ui)
	var n = list.get_child_count()
	ui.position = Vector2((n - 1) * item_w + (n - 1) * gap, 0)

func clear():
	if list:
		for n in list.get_children():
			n.queue_free()
			list.remove_child(n)
