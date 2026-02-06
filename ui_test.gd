extends Panel

@onready var tab_container : TabContainer = $PanelContainer/VBoxContainer/TabContainer
@onready var use_save_checkbox : Button = $PanelContainer/VBoxContainer/TabContainer/New/HBoxContainer/CheckBox
@onready var reroll_checkbox : Button = $PanelContainer/VBoxContainer/TabContainer/New/HBoxContainer/CheckBox2
@onready var events_list : ItemList = $PanelContainer/VBoxContainer/TabContainer/New/HBoxContainer3/VBoxContainer/ItemList
@onready var variables_list : ItemList = $PanelContainer/VBoxContainer/TabContainer/New/HBoxContainer3/VBoxContainer2/ItemList
@onready var variable_name_edit : LineEdit = $PanelContainer/VBoxContainer/TabContainer/New/HBoxContainer3/VBoxContainer2/HBoxContainer/LineEdit
@onready var variable_base_edit : LineEdit = $PanelContainer/VBoxContainer/TabContainer/New/HBoxContainer3/VBoxContainer2/HBoxContainer/LineEdit2
@onready var variable_step_edit : LineEdit = $PanelContainer/VBoxContainer/TabContainer/New/HBoxContainer3/VBoxContainer2/HBoxContainer/LineEdit3
@onready var variable_add_button : Button = $PanelContainer/VBoxContainer/TabContainer/New/HBoxContainer3/VBoxContainer2/HBoxContainer/HBoxContainer/Button
@onready var variable_delete_button : Button = $PanelContainer/VBoxContainer/TabContainer/New/HBoxContainer3/VBoxContainer2/HBoxContainer/HBoxContainer/Button2
@onready var samples_edit : LineEdit = $PanelContainer/VBoxContainer/TabContainer/New/HBoxContainer2/LineEdit
@onready var groups_edit : LineEdit = $PanelContainer/VBoxContainer/TabContainer/New/HBoxContainer2/LineEdit2
@onready var start_button : Button = $PanelContainer/VBoxContainer/TabContainer/New/Button
@onready var test_list : ItemList = $PanelContainer/VBoxContainer/TabContainer/Tests/ItemList
@onready var test_result : ItemList = $PanelContainer/VBoxContainer/TabContainer/Tests/ItemList2
@onready var close_button : Button = $PanelContainer/VBoxContainer/Button

func enter():
	self.show()

func exit():
	self.hide()

func tab_changed(tab : int):
	if tab == 0:
		use_save_checkbox.set_pressed_no_signal(STest.use_save)
		reroll_checkbox.set_pressed_no_signal(STest.reroll)
		events_list.clear()
		for i in C.Event.Count:
			events_list.add_item(str(C.Event.find_key(i)))
		for d in STest.listen_events:
			events_list.select(d.event, false)
		variables_list.clear()
		for v in STest.variables:
			variables_list.add_item(v.name)
		samples_edit.text = "%d" % STest.samples
		groups_edit.text = "%d" % STest.groups
	elif tab == 1:
		test_list.clear()
		var files = []
		for fn in DirAccess.open("res://tests").get_files():
			if fn.ends_with(".csv"):
				files.append(fn)
		files.reverse()
		for fn in files:
			test_list.add_item(fn)

func _ready() -> void:
	tab_changed(0)
	tab_container.tab_changed.connect(func(tab : int):
		SSound.se_click.play()
		G.screen_shake_strength = 8.0
		tab_changed(tab)
	)
	use_save_checkbox.toggled.connect(func(v : bool):
		SSound.se_click.play()
		G.screen_shake_strength = 8.0
		STest.use_save = v
		STest.save_config()
	)
	reroll_checkbox.toggled.connect(func(v : bool):
		SSound.se_click.play()
		G.screen_shake_strength = 8.0
		STest.reroll = v
		STest.save_config()
	)
	events_list.multi_selected.connect(func(idx : int, selected : bool):
		if selected:
			STest.add_listen_event(idx)
		else:
			STest.remove_listen_event(idx)
		STest.save_config()
	)
	variables_list.item_selected.connect(func(idx : int):
		var v = STest.variables[idx]
		variable_name_edit.text = v.name
		variable_base_edit.text = "%d" % v.base
		variable_step_edit.text = "%d" % v.step
	)
	variable_name_edit.text_changed.connect(func(text : String):
		var sel = variables_list.get_selected_items()
		if !sel.is_empty():
			STest.variables[sel[0]].name = variable_name_edit.text
			variables_list.set_item_text(sel[0], variable_name_edit.text)
			STest.save_config()
	)
	variable_base_edit.text_changed.connect(func(text : String):
		var sel = variables_list.get_selected_items()
		if !sel.is_empty():
			var v = STest.variables[sel[0]]
			v.base = int(variable_base_edit.text)
			STest.save_config()
	)
	variable_step_edit.text_changed.connect(func(text : String):
		var sel = variables_list.get_selected_items()
		if !sel.is_empty():
			var v = STest.variables[sel[0]]
			v.step = int(variable_step_edit.text)
			STest.save_config()
	)
	variable_add_button.pressed.connect(func():
		STest.add_variable(variable_name_edit.text, int(variable_base_edit.text), int(variable_step_edit.text))
		variables_list.add_item(STest.variables[STest.variables.size() - 1].name)
		variables_list.select(STest.variables.size() - 1)
		STest.save_config()
	)
	variable_delete_button.pressed.connect(func():
		var sel = variables_list.get_selected_items()
		if !sel.is_empty():
			STest.variables.remove_at(sel[0])
			variables_list.remove_item(sel[0])
			STest.save_config()
	)
	samples_edit.text_changed.connect(func(text : String):
		STest.samples = int(text)
		STest.save_config()
	)
	groups_edit.text_changed.connect(func(text : String):
		STest.groups = int(text)
		STest.save_config()
	)
	start_button.pressed.connect(func():
		SSound.se_click.play()
		G.screen_shake_strength = 8.0
		exit()
		STest.start()
	)
	test_list.item_selected.connect(func(idx : int):
		test_result.clear()
		var result = STest.read_result("res://tests/" + test_list.get_item_text(idx))
		for k in result.keys():
			test_result.add_item("%s: %.3f" % [k, result[k]])
	)
	close_button.pressed.connect(func():
		SSound.se_click.play()
		G.screen_shake_strength = 8.0
		exit()
	)
