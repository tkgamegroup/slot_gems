extends PanelContainer

@onready var list : Control = $MarginContainer/VBoxContainer/PanelContainer/MarginContainer/List

const skill_pb = preload("res://ui_skill.tscn")
const item_h = 64
const gap = 16

var float_island = FloatIsland.new()

func add_ui(s : Skill):
	var ui = skill_pb.instantiate()
	ui.setup(s)
	list.add_child(ui)
	s.ui = ui
	var n = list.get_child_count()
	list.custom_minimum_size = Vector2(56, item_h * n + (n - 1) * gap if n > 0 else 0)

func clear():
	if list:
		for n in list.get_children():
			n.queue_free()
			list.remove_child(n)

func _ready() -> void:
	float_island.setup(self, 2.0, 0.1, 0.2)

func _process(delta: float) -> void:
	float_island.update(delta)
