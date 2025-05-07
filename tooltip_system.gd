extends Node

@onready var ui : Control = $/root/Main/SubViewportContainer/SubViewport/UI/Tooltips
@onready var list1 : Control = $/root/Main/SubViewportContainer/SubViewport/UI/Tooltips/HBoxContainer/VBoxContainer
@onready var list2 : Control = $/root/Main/SubViewportContainer/SubViewport/UI/Tooltips/HBoxContainer/VBoxContainer2
@onready var show_more_tip : Control = $/root/Main/SubViewportContainer/SubViewport/UI/Tooltips/HBoxContainer/VBoxContainer/MarginContainer
@onready var timer : Timer = $/root/Main/SubViewportContainer/SubViewport/UI/Tooltips/Timer

const Tooltip = preload("res://tooltip.gd")
const tooltip_pb = preload("res://tooltip.tscn")

var tween : Tween = null

func process_word(word : String, processed : Array, description : String):
	if !processed.has(word):
		processed.append(word)
		var item = tooltip_pb.instantiate()
		item.title = word
		item.content = description
		list2.add_child(item)
		show_more_tip.show()

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
		for c in contents:
			if c.second.find("[b]Wild[/b]") != -1 || c.first.find("Wild") != -1:
				process_word("Wild", words, "Can match with any color.")
			if c.second.find("[b]Eliminate[/b]") != -1:
				process_word("Eliminate", words, "Effect when the cell is eliminated.")
			if c.second.find("[b]Active[/b]") != -1:
				process_word("Active", words, "Active effects will stack and process one by one when the matching stops.")
			if c.second.find("[b]Quick[/b]") != -1:
				process_word("Quick", words, "Effect when the item is placed into the board. And then the item will be removed.")
			if c.second.find("[b]Aura[/b]") != -1:
				process_word("Aura", words, "Effect all gems while this item is on board.")
			if c.second.find("[b]Range[/b]") != -1:
				process_word("Range", words, "The cells within the distance of n. 0[color=gray][b]Range[/b][/color] means the cell itself.")
			if c.second.find("[b]Tradeable[/b]") != -1:
				process_word("Tradeable", words, "You can drag this item to Bag inorder to exchange another item.")
			if c.second.find("[b]Mount[/b]") != -1:
				process_word("Mount", words, "Place another satisfied item to form a combine item that basicly have the effects of both.")
			var item = tooltip_pb.instantiate()
			item.title = c.first
			item.content = c.second
			list1.add_child(item)
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
