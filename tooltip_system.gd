extends Node

@onready var ui : Control = $/root/Main/SubViewportContainer/SubViewport/UI/Tooltips
@onready var list1 : Control = $/root/Main/SubViewportContainer/SubViewport/UI/Tooltips/HBoxContainer/VBoxContainer
@onready var list2 : Control = $/root/Main/SubViewportContainer/SubViewport/UI/Tooltips/HBoxContainer/VBoxContainer2
@onready var show_more_tip : Control = $/root/Main/SubViewportContainer/SubViewport/UI/Tooltips/HBoxContainer/VBoxContainer/MarginContainer
@onready var timer : Timer = $/root/Main/SubViewportContainer/SubViewport/UI/Tooltips/Timer

const Tooltip = preload("res://tooltip.gd")
const tooltip_pb = preload("res://tooltip.tscn")

var tween : Tween = null

func show(contents : Array[Pair], delay : float = 0.05):
	for n in list1.get_children():
		if n == show_more_tip:
			continue
		list1.remove_child(n)
		n.queue_free()
	for n in list2.get_children():
		list2.remove_child(n)
		n.queue_free()
	show_more_tip.hide()
	list2.hide()
	ui.position = get_viewport().get_mouse_position() + Vector2(30, 20)
	ui.size = Vector2(0, 0)
	if tween:
		tween.kill()
		tween = null
	tween = Game.get_tree().create_tween()
	tween.tween_interval(delay)
	tween.tween_callback(func():
		var words = []
		var items = []
		for c in contents:
			var ui = tooltip_pb.instantiate()
			ui.title = SUtils.format_text(c.first, false, false, words, items)
			ui.content = SUtils.format_text(c.second, true, false, words, items)
			list1.add_child(ui)
		for n in items:
			var i = Item.new()
			i.setup(n)
			for c in i.get_tooltip():
				var ui = tooltip_pb.instantiate()
				ui.title = SUtils.format_text(c.first, false, false, words, items)
				ui.content = SUtils.format_text(c.second, true, false, words, items)
				list1.add_child(ui)
		for w in words:
			var ui = tooltip_pb.instantiate()
			ui.title = w
			ui.content = tr(w + "_desc")
			list2.add_child(ui)
			show_more_tip.show()
		list1.move_child(show_more_tip, list1.get_child_count() - 1)
	)
	tween.tween_callback(func():
		tween = null
	)

func close():
	if tween:
		tween.kill()
		tween = null
	for n in list1.get_children():
		if n == show_more_tip:
			continue
		list1.remove_child(n)
		n.queue_free()
	for n in list2.get_children():
		list2.remove_child(n)
		n.queue_free()
		n.queue_free()
	show_more_tip.hide()
	list2.hide()

func _ready() -> void:
	timer.timeout.connect(func():
		if ui.visible:
			var screen = get_viewport().get_visible_rect()
			var rect = ui.get_global_rect()
			if rect.end.x > screen.end.x:
				ui.position.x = get_viewport().get_mouse_position().x - 20 - rect.size.x
			if rect.end.y > screen.end.y:
				ui.position.y = get_viewport().get_mouse_position().y - 30 - rect.size.y
	)

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.keycode == KEY_ALT:
			if event.is_pressed():
				list2.show()
			elif event.is_released():
				list2.hide()
				ui.size_flags_changed.emit()
