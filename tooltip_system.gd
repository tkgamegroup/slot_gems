extends Node

@onready var ui : Control = $/root/Main/SubViewportContainer/SubViewport/UI/Tooltips
@onready var list1 : Control = $/root/Main/SubViewportContainer/SubViewport/UI/Tooltips/HBoxContainer/VBoxContainer
@onready var list2 : Control = $/root/Main/SubViewportContainer/SubViewport/UI/Tooltips/HBoxContainer/VBoxContainer2
@onready var show_more_tip : Control = $/root/Main/SubViewportContainer/SubViewport/UI/Tooltips/HBoxContainer/VBoxContainer/MarginContainer
@onready var timer : Timer = $/root/Main/SubViewportContainer/SubViewport/UI/Tooltips/Timer

const Tooltip = preload("res://tooltip.gd")
const tooltip_pb = preload("res://tooltip.tscn")

var tween : Tween = null

func add_word_desc(word : String, words : Array, description : String):
	if !words.has(word):
		words.append(word)
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
			if c.second.find("w_colorless") != -1 || c.first.find("w_colorless") != -1:
				c.first = c.first.replace("w_colorless", tr("w_colorless"))
				c.second = c.second.replace("w_colorless", "[color=gray][b]%s[/b][/color]" % tr("w_colorless"))
				add_word_desc(tr("w_colorless"), words, tr("w_colorless_desc"))
			if c.second.find("w_wild") != -1 || c.first.find("w_wild") != -1:
				c.first.replace("w_wild", tr("w_wild"))
				c.second = c.second.replace("w_wild", "[color=gray][b]%s[/b][/color]" % tr("w_wild"))
				add_word_desc(tr("w_wild"), words, tr("w_wild_desc"))
			if c.second.find("w_eliminate") != -1:
				c.second = c.second.replace("w_eliminate", "[color=gray][b]%s[/b][/color]" % tr("w_eliminate"))
				add_word_desc("w_eliminate", words, tr("w_eliminate_desc"))
			if c.second.find("w_active") != -1:
				c.second = c.second.replace("w_active", "[color=gray][b]%s[/b][/color]" % tr("w_active"))
				add_word_desc("w_active", words, tr("w_active_desc"))
			if c.second.find("w_place") != -1:
				c.second = c.second.replace("w_place", "[color=gray][b]%s[/b][/color]" % tr("w_place"))
				add_word_desc("w_place", words, tr("w_place_desc"))
			if c.second.find("w_quick") != -1:
				c.second = c.second.replace("w_quick", "[color=gray][b]%s[/b][/color]" % tr("w_quick"))
				add_word_desc("w_quick", words, tr("w_quick_desc"))
			if c.second.find("w_consumed") != -1:
				c.second = c.second.replace("w_consumed", "[color=gray][b]%s[/b][/color]" % tr("w_consumed"))
				add_word_desc("w_consumed", words, tr("w_consumed_desc"))
			if c.second.find("w_aura") != -1:
				c.second = c.second.replace("w_aura", "[color=gray][b]%s[/b][/color]" % tr("w_aura"))
				add_word_desc("w_aura", words, tr("w_aura_desc"))
			if c.second.find("w_range") != -1:
				c.second = c.second.replace("w_range", "[color=gray][b]%s[/b][/color]" % tr("w_range"))
				add_word_desc("w_range", words, tr("w_range_desc"))
			if c.second.find("w_power") != -1:
				c.second = c.second.replace("w_power", "[color=gray][b]%s[/b][/color]" % tr("w_power"))
				add_word_desc("w_power", words, tr("w_power_desc"))
			if c.second.find("w_tradable") != -1:
				c.second = c.second.replace("w_tradable", "[color=gray][b]%s[/b][/color]" % tr("w_tradable"))
				add_word_desc("w_tradable", words, tr("w_tradable_desc"))
			if c.second.find("w_mount") != -1:
				c.second = c.second.replace("w_mount", "[color=gray][b]%s[/b][/color]" % tr("w_mount"))
				add_word_desc("w_mount", words, tr("w_mount_desc"))
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
