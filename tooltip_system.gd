extends Node

@onready var ui : Control = $/root/Main/UI/Tooltips
@onready var list : Control = $/root/Main/UI/Tooltips/HBoxContainer
@onready var timer : Timer = $/root/Main/UI/Tooltips/Timer

const tooltip_pb = preload("res://tooltip.tscn")

var tween : Tween = null

func show(contents : Array[Pair], delay : float = 0.05):
	for n in list.get_children():
		list.remove_child(n)
		n.queue_free()
	ui.position = get_viewport().get_mouse_position() + Vector2(30, 20)
	ui.size = Vector2(0, 0)
	if tween:
		tween.kill()
		tween = null
	tween = Game.get_tree().create_tween()
	tween.tween_interval(delay)
	tween.tween_callback(func():
		for c in contents:
			var item = tooltip_pb.instantiate()
			item.title = c.first
			item.content = c.second
			list.add_child(item)
	)
	tween.tween_callback(func():
		tween = null
	)

func close():
	if tween:
		tween.kill()
		tween = null
	for n in list.get_children():
		list.remove_child(n)
		n.queue_free()

func _ready() -> void:
	timer.timeout.connect(func():
		if ui.visible:
			var screen = get_viewport().get_visible_rect()
			var rect = ui.get_global_rect()
			if rect.position.x < screen.position.x + 12:
				ui.position.x = screen.position.x + 12
			if rect.end.x > screen.end.x - 12:
				ui.position.x = screen.end.x - 12 - rect.size.x
			if rect.position.y < screen.position.y + 12:
				ui.position.y = screen.position.y + 12
			if rect.end.y > screen.end.y - 12:
				ui.position.y = screen.end.y - 12 - rect.size.y
	)
