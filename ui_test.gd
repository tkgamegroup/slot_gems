extends Panel

@export var tab_container : TabContainer
@export var config_list : ItemList
@export var config_list_menu : PopupMenu
@export var config_add_button : Button
@export var config_remove_button : Button
@export var config_duplicate_button : Button
@export var config_name_edit : LineEdit
@export var config_rename_button : Button
@export var filename_edit : LineEdit
@export var rounds_edit : LineEdit
@export var headless_checkbox : Button
@export var use_save_checkbox : Button
@export var reroll_checkbox : Button
@export var action_type_select : OptionButton
@export var event_list : ItemList
@export var variable_list : ItemList
@export var variable_name_edit : LineEdit
@export var variable_base_edit : LineEdit
@export var variable_step_edit : LineEdit
@export var variable_add_button : Button
@export var variable_remove_button : Button
@export var extra_list : ItemList
@export var extra_category_edit : LineEdit
@export var extra_name_edit : LineEdit
@export var extra_base_count_edit : LineEdit
@export var extra_count_increase_edit : LineEdit
@export var extra_add_button : Button
@export var extra_remove_button : Button
@export var samples_edit : LineEdit
@export var groups_edit : LineEdit
@export var process_edit : LineEdit
@export var start_button : Button
@export var test_list : ItemList
@export var group_edit : LineEdit
@export var group_plus_button : Button
@export var group_mimus_button : Button
@export var name_edit : LineEdit
@export var rename_button : Button
@export var fit_result : Label
@export var group_avg : Label
@export var test_comment : TextEdit
@export var compare_controls : Control
@export var compare_toggle : Button
@export var compare_mult_edit : LineEdit
@export var reference_edit : LineEdit
@export var percentage_edit : LineEdit
@export var calc_result_edit : LineEdit
@export var test_result : GridContainer
@export var close_button : Button

var tests = []
var test_idx = -1
var group_idx = -1
var compare_idx = -1
var compare_mult = 1.0

func enter():
	self.show()

func exit():
	self.hide()

func find_group(t, idx : int):
	for i in t.groups.size():
		if t.groups[i].idx == idx:
			return i
	return -1

func find_column(g, name : String):
	for c in g.columns:
		if c.name == name:
			return c
	return null

func format_config_filename(name : String):
	return "%s/%s.ini" % [STest.folder, name]

func get_config_name(base : String = "config"):
	var ok = false
	var name = base
	var id = 2
	while !ok:
		if !FileAccess.file_exists(format_config_filename(name)):
			ok = true
			break
		name = base + "%d" % id
		id += 1
	return name

func select_config(idx : int):
	if idx < config_list.item_count:
		var name = config_list.get_item_text(idx)
		STest.load_config(name)
		config_name_edit.text = name
		update_config_ui()

func update_config_ui():
	filename_edit.text = STest.filename
	rounds_edit.text = "%d" % STest.rounds
	headless_checkbox.set_pressed_no_signal(STest.headless)
	use_save_checkbox.set_pressed_no_signal(STest.use_save)
	reroll_checkbox.set_pressed_no_signal(STest.reroll)
	
	action_type_select.selected = STest.action_type
	event_list.clear()
	for i in C.Event.Count:
		event_list.add_item(str(C.Event.find_key(i)))
	for d in STest.listen_events:
		event_list.select(d.event, false)
	variable_list.clear()
	for v in STest.variables:
		variable_list.add_item(v.name)
	extra_list.clear()
	for d in STest.extras:
		extra_list.add_item(d.name)
	samples_edit.text = "%d" % STest.samples
	groups_edit.text = "%d" % STest.groups
	process_edit.text = "%d" % STest.process

func on_tab_changed(tab : int):
	if tab == 0:
		config_list.clear()
		for fn in DirAccess.open(STest.folder).get_files():
			if fn.ends_with(".ini"):
				config_list.add_item(fn.substr(0, fn.length() - 4))
		update_config_ui()
	elif tab == 1:
		test_list.clear()
		var files = []
		for fn in DirAccess.open(STest.folder).get_files():
			if fn.ends_with(".csv"):
				files.append(fn.substr(0, fn.length() - 4))
		files.reverse()
		tests.clear()
		var regex = RegEx.new()
		regex.compile(r"(.*)_g([0-9]+)$")
		for fn in files:
			var m = regex.search(fn)
			if m:
				var n = m.get_string(1)
				var i = int(m.get_string(2))
				var found = false
				for t in tests:
					if t.name == n:
						t.groups.append({"comments":[],"columns":[],"idx":i})
						found = true
				if !found:
					tests.append({"name":n,"groups":[{"comments":[],"columns":[],"idx":i}]})
			else:
				tests.append({"name":fn,"groups":[{"comments":[],"columns":[],"idx":0}]})
		for t in tests:
			t.groups.reverse()
			test_list.add_item(t.name)

func on_test_selected(idx : int):
	test_idx = idx
	var t = tests[test_idx]
	group_idx = int(t.groups[0].idx)
	group_edit.text = "%d" % group_idx
	name_edit.text = t.name
	
	compare_idx = -1
	var name_sp = t.name.split("_")
	while !name_sp.is_empty():
		name_sp.remove_at(name_sp.size() - 1)
		var n = "_".join(name_sp)
		for i in test_list.item_count:
			if test_list.get_item_text(i) == n:
				compare_idx = i
				compare_toggle.text = "Compare To '%s'" % n
				compare_mult_edit.text = "%.1f" % compare_mult
				compare_controls.show()
				name_sp.clear()
				break
	if compare_idx == -1:
		compare_toggle.set_pressed_no_signal(false)
		compare_controls.hide()
	
	read_datas(test_idx)
	if compare_toggle.button_pressed && compare_idx != -1:
		read_datas(compare_idx)
	update_page(compare_toggle.button_pressed)
	
	fit_result.text = ""
	group_avg.text = ""
	if t.groups.size() > 1:
		var avgs = []
		var sum = 0.0
		for g in t.groups:
			avgs.append(g.columns[0].avg)
		var line = SMath.linear_fit(avgs)
		fit_result.text = "y=%.3fx+%.3f" % [line.first, line.second]
		for v in avgs:
			sum += v
		group_avg.text = "%.3f" % (sum / avgs.size())

func show_sample(idx : int):
	var sel = test_list.get_selected_items()
	if !sel.is_empty():
		var t = tests[sel[0]]
		var g = t.groups[int(group_edit.text)]
		test_result.get_child(7).text = "%d" % idx
		for i in g.columns.size():
			test_result.get_child(8 * (i + 2) - 1).text = "%d" % int(g.columns[i].datas[idx])

func format_filename(name : String, grounp_idx : int):
	return "%s/%s" % [STest.folder, ("%s_g%d.csv" % [name, grounp_idx] if grounp_idx != -1 else "%s.csv" % name)]

func read_datas(idx : int):
	var t = tests[idx]
	for i in t.groups.size():
		var g = t.groups[i]
		var fn = format_filename(t.name, g.idx if t.groups.size() > 1 else -1)
		var result = STest.read_result(fn)
		g.comments.clear()
		g.columns.clear()
		g.comments = result["comments"].duplicate()
		for k in result.keys():
			if k != "comments":
				var c = result[k]
				var max_i = c.max_i
				var min_i = c.min_i
				var column = {"name":k,"avg":c.avg,"med":c.med,"max":c.max,"min":c.min,"max_i":max_i,"min_i":min_i,"datas":c.datas.duplicate()}
				g.columns.append(column)

func result_grid_add(txt : String):
	var lb = Label.new()
	lb.text = txt
	test_result.add_child(lb)

func calc_effect_percentage(current : float, base : float):
	if compare_mult == 1.0:
		return 0
	return int(((current - base) / (base * (compare_mult - 1.0))) * 100.0)

func calc_modify():
	var a = float(reference_edit.text)
	var b = float(int(percentage_edit.text) / 100.0)
	calc_result_edit.text = "%.2f" % (a / b)

func update_page(compare : bool = false):
	if test_idx == -1:
		return
	var t = tests[test_idx]
	var t2 = tests[compare_idx] if compare else null
	var i = find_group(t, group_idx)
	if i == -1:
		return
	var g = t.groups[i]
	var i2 = find_group(t2, group_idx) if t2 else -1
	var g2 = t2.groups[i2] if i2 != -1 else null
	test_comment.clear()
	for n in test_result.get_children():
		test_result.remove_child(n)
		n.queue_free()
	test_comment.text += "%d Samples\n" % g.columns[0].datas.size()
	for lno in g.comments.size():
		var l = g.comments[lno]
		if lno == 0 && l.begins_with("#Start Datetime: "):
			var elapsed = FileAccess.get_modified_time(format_filename(t.name, g.idx if t.groups.size() > 1 else -1)) + Time.get_time_zone_from_system().bias * 60 - Time.get_unix_time_from_datetime_string(l.right(19))
			test_comment.text += l + " (%02d:%02d:%02d)\n" % [int(elapsed / 3600), int(elapsed / 60) % 60, int(elapsed) % 60]
		else:
			test_comment.text += l + "\n"
	test_result.columns = 8
	result_grid_add("Name")
	result_grid_add("Avg")
	result_grid_add("Med")
	result_grid_add("Max")
	result_grid_add("Max i")
	result_grid_add("Min")
	result_grid_add("Min i")
	result_grid_add("N/A")
	
	for c in g.columns:
		var c2 = find_column(g2, c.name) if g2 else null
		result_grid_add(c.name)
		if !c2:
			result_grid_add("%.3f" % c.avg)
		else:
			result_grid_add("%.3f(%.3f, %d%%)" % [c.avg, c2.avg * compare_mult, calc_effect_percentage(c.avg, c2.avg)])
		if !c2:
			result_grid_add("%.3f" % c.med)
		else:
			result_grid_add("%.3f(%.3f, %d%%)" % [c.med, c2.med * compare_mult, calc_effect_percentage(c.med, c2.med)])
		if !c2:
			result_grid_add("%.1f" % c.max)
		else:
			result_grid_add("%.1f(%.1f, %d%%)" % [c.max, c2.max * compare_mult, calc_effect_percentage(c.max, c2.max)])
		var max_i = c.max_i
		var txt_max_i = LinkButton.new()
		txt_max_i.text = "%d" % max_i
		test_result.add_child(txt_max_i)
		txt_max_i.pressed.connect(func():
			show_sample(max_i)
		)
		if !c2:
			result_grid_add("%.1f" % c.min)
		else:
			result_grid_add("%.1f(%.1f, %d%%)" % [c.min, c2.min * compare_mult, calc_effect_percentage(c.min, c2.min)])
		var min_i = c.min_i
		var txt_min_i = LinkButton.new()
		txt_min_i.text = "%d" % min_i
		test_result.add_child(txt_min_i)
		txt_min_i.pressed.connect(func():
			show_sample(min_i)
		)
		result_grid_add("N/A")

func save_config():
	var sel = config_list.get_selected_items()
	if !sel.is_empty():
		var name = config_name_edit.text
		STest.save_config(name)
	else:
		STest.save_config()

func _ready() -> void:
	var launch_args = OS.get_cmdline_args()
	for i in launch_args.size():
		if launch_args[i] == "-test":
			var config_name = launch_args[i + 1]
			var sp = launch_args[i + 2].split(",")
			STest.load_config(config_name)
			STest.start(int(sp[0]), int(sp[1]))
			get_tree().quit()
			return
	
	on_tab_changed(0)
	tab_container.tab_changed.connect(func(tab : int):
		on_tab_changed(tab)
	)
	config_list.item_selected.connect(func(idx : int):
		select_config(idx)
		config_add_button.disabled = true
		config_remove_button.disabled = false
		config_duplicate_button.disabled = false
	)
	config_list.empty_clicked.connect(func(at_position: Vector2, mouse_button_index: int):
		config_list.deselect_all()
		config_add_button.disabled = false
		config_remove_button.disabled = true
		config_duplicate_button.disabled = true
	)
	config_list.gui_input.connect(func(event : InputEvent):
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
				config_list_menu.position = get_global_mouse_position()
				config_list_menu.popup()
	)
	config_list_menu.id_pressed.connect(func(id : int):
		match id:
			0:
				if !filename_edit.text.is_empty():
					tab_container.current_tab = 1
					for i in test_list.item_count:
						if test_list.get_item_text(i) == filename_edit.text:
							test_list.select(i)
							test_list.ensure_current_is_visible()
							on_test_selected(i)
							break
	)
	config_add_button.pressed.connect(func():
		var name = get_config_name()
		FileAccess.open(format_config_filename(name), FileAccess.WRITE)
		config_list.add_item(name)
		config_list.select(config_list.item_count - 1)
		select_config(config_list.item_count - 1)
	)
	config_remove_button.pressed.connect(func():
		var sel = config_list.get_selected_items()
		if !sel.is_empty():
			DirAccess.remove_absolute(format_config_filename(config_list.get_item_text(sel[0])))
			config_list.remove_item(sel[0])
	)
	config_duplicate_button.pressed.connect(func():
		var sel = config_list.get_selected_items()
		if !sel.is_empty():
			var name = config_list.get_item_text(sel[0])
			var new_name = get_config_name(name)
			DirAccess.copy_absolute(format_config_filename(name), format_config_filename(new_name))
			config_list.add_item(new_name)
			config_list.select(config_list.item_count - 1)
			select_config(config_list.item_count - 1)
	)
	config_rename_button.pressed.connect(func():
		var sel = config_list.get_selected_items()
		if !sel.is_empty():
			var name = config_name_edit.text
			if name.is_valid_filename():
				DirAccess.rename_absolute(format_config_filename(config_list.get_item_text(sel[0])), format_config_filename(name))
				config_list.set_item_text(sel[0], name)
				STest.filename = name
				save_config()
				filename_edit.text = name
	)
	filename_edit.text_changed.connect(func(text : String):
		STest.filename = text
		save_config()
	)
	rounds_edit.text_changed.connect(func(text : String):
		STest.rounds = int(text)
		save_config()
	)
	headless_checkbox.toggled.connect(func(v : bool):
		STest.headless = v
		save_config()
	)
	use_save_checkbox.toggled.connect(func(v : bool):
		STest.use_save = v
		save_config()
	)
	reroll_checkbox.toggled.connect(func(v : bool):
		STest.reroll = v
		save_config()
	)
	action_type_select.item_selected.connect(func(idx):
		STest.action_type = idx
		save_config()
	)
	event_list.multi_selected.connect(func(idx : int, selected : bool):
		if selected:
			STest.add_listen_event(idx)
		else:
			STest.remove_listen_event(idx)
		save_config()
	)
	variable_list.item_selected.connect(func(idx : int):
		var v = STest.variables[idx]
		variable_name_edit.text = v.name
		variable_base_edit.text = "%d" % v.base
		variable_step_edit.text = "%d" % v.step
		variable_name_edit.editable = true
		variable_base_edit.editable = true
		variable_step_edit.editable = true
		variable_add_button.disabled = true
		variable_remove_button.disabled = false
	)
	variable_list.empty_clicked.connect(func(at_position: Vector2, mouse_button_index: int):
		variable_list.deselect_all()
		variable_name_edit.text = ""
		variable_base_edit.text = ""
		variable_step_edit.text = ""
		variable_name_edit.editable = false
		variable_base_edit.editable = false
		variable_step_edit.editable = false
		variable_add_button.disabled = false
		variable_remove_button.disabled = true
	)
	variable_name_edit.text_changed.connect(func(text : String):
		var sel = variable_list.get_selected_items()
		if !sel.is_empty():
			STest.variables[sel[0]].name = variable_name_edit.text
			variable_list.set_item_text(sel[0], variable_name_edit.text)
			save_config()
	)
	variable_base_edit.text_changed.connect(func(text : String):
		var sel = variable_list.get_selected_items()
		if !sel.is_empty():
			var v = STest.variables[sel[0]]
			v.base = int(variable_base_edit.text)
			save_config()
	)
	variable_step_edit.text_changed.connect(func(text : String):
		var sel = variable_list.get_selected_items()
		if !sel.is_empty():
			var v = STest.variables[sel[0]]
			v.step = int(variable_step_edit.text)
			save_config()
	)
	variable_add_button.pressed.connect(func():
		STest.add_variable("new", 0, 0)
		variable_list.add_item("new")
		save_config()
	)
	variable_remove_button.pressed.connect(func():
		var sel = variable_list.get_selected_items()
		if !sel.is_empty():
			STest.variables.remove_at(sel[0])
			variable_list.remove_item(sel[0])
			save_config()
	)
	extra_list.item_selected.connect(func(idx : int):
		var d = STest.extras[idx]
		extra_category_edit.text = d.category
		extra_name_edit.text = d.name
		extra_base_count_edit.text = "%d" % d.base_count
		extra_count_increase_edit.text = "%d" % d.count_increase
		extra_category_edit.editable = true
		extra_name_edit.editable = true
		extra_base_count_edit.editable = true
		extra_count_increase_edit.editable = true
		extra_add_button.disabled = true
		extra_remove_button.disabled = false
	)
	extra_list.empty_clicked.connect(func(at_position: Vector2, mouse_button_index: int):
		extra_list.deselect_all()
		extra_category_edit.text = ""
		extra_name_edit.text = ""
		extra_base_count_edit.text = ""
		extra_count_increase_edit.text = ""
		extra_category_edit.editable = false
		extra_name_edit.editable = false
		extra_base_count_edit.editable = false
		extra_count_increase_edit.editable = false
		extra_add_button.disabled = false
		extra_remove_button.disabled = true
	)
	extra_category_edit.text_changed.connect(func(text : String):
		var sel = extra_list.get_selected_items()
		if !sel.is_empty():
			STest.extras[sel[0]].category = extra_category_edit.text
			save_config()
	)
	extra_name_edit.text_changed.connect(func(text : String):
		var sel = extra_list.get_selected_items()
		if !sel.is_empty():
			STest.extras[sel[0]].name = extra_name_edit.text
			extra_list.set_item_text(sel[0], extra_name_edit.text)
			save_config()
	)
	extra_base_count_edit.text_changed.connect(func(text : String):
		var sel = extra_list.get_selected_items()
		if !sel.is_empty():
			var d = STest.extras[sel[0]]
			d.base_count = int(extra_base_count_edit.text)
			save_config()
	)
	extra_count_increase_edit.text_changed.connect(func(text : String):
		var sel = extra_list.get_selected_items()
		if !sel.is_empty():
			var d = STest.extras[sel[0]]
			d.count_increase = int(extra_count_increase_edit.text)
			save_config()
	)
	extra_add_button.pressed.connect(func():
		STest.add_extra("", "new", 0, 0)
		extra_list.add_item("new")
		save_config()
	)
	extra_remove_button.pressed.connect(func():
		var sel = extra_list.get_selected_items()
		if !sel.is_empty():
			STest.extras.remove_at(sel[0])
			extra_list.remove_item(sel[0])
			save_config()
	)
	samples_edit.text_changed.connect(func(text : String):
		STest.samples = int(text)
		save_config()
	)
	groups_edit.text_changed.connect(func(text : String):
		STest.groups = int(text)
		save_config()
	)
	process_edit.text_changed.connect(func(text : String):
		STest.process = int(text)
		save_config()
	)
	start_button.pressed.connect(func():
		if STest.process > 0:
			var config_name = "config"
			var sel = config_list.get_selected_items()
			if !sel.is_empty():
				config_name = config_name_edit.text
			start_button.disabled = true
			var n = min(STest.process, STest.groups)
			var q = STest.groups / n
			var m = STest.groups % n
			for i in n :
				var gs = q
				if m > 0:
					gs += 1
					m -= 1
				OS.create_instance(["-test", config_name, "%d,%d" % [i * q, gs]])
		else:
			exit()
			STest.filename = SUtils.get_formated_datetime() if STest.filename.is_empty() else STest.filename
			STest.start()
		
		var last_test = FileAccess.open("%s/last_test.txt" % STest.folder, FileAccess.WRITE)
		last_test.store_string(config_name_edit.text)
		last_test.close()
	)
	test_list.item_selected.connect(func(idx : int):
		on_test_selected(idx)
	)
	compare_toggle.toggled.connect(func(v : bool):
		if v:
			if compare_idx != -1:
				read_datas(compare_idx)
			update_page(true)
		else:
			update_page(false)
	)
	compare_mult_edit.text_changed.connect(func(text : String):
		compare_mult = float(text)
		update_page(compare_toggle.button_pressed)
	)
	reference_edit.text_changed.connect(func(text : String):
		calc_modify()
	)
	percentage_edit.text_changed.connect(func(text : String):
		calc_modify()
	)
	group_plus_button.pressed.connect(func():
		if test_idx != -1:
			var t = tests[test_idx]
			var idx = int(group_edit.text)
			var i = find_group(t, idx)
			if i < t.groups.size() - 1:
				group_idx = int(t.groups[i + 1].idx)
				group_edit.text = "%d" % group_idx
				update_page(compare_toggle.button_pressed)
	)
	group_mimus_button.pressed.connect(func():
		if test_idx != -1:
			var t = tests[test_idx]
			var idx = int(group_edit.text)
			var i = find_group(t, idx)
			if i > 0:
				group_idx = int(t.groups[i - 1].idx)
				group_edit.text = "%d" % group_idx
				update_page(compare_toggle.button_pressed)
	)
	rename_button.pressed.connect(func():
		if test_idx != -1:
			var t = tests[test_idx]
			for i in t.groups.size():
				DirAccess.rename_absolute(format_filename(t.name, t.groups[i].idx if t.groups.size() > 1 else -1), format_filename(name_edit.text, t.groups[i].idx if t.groups.size() > 1 else -1))
			test_list.set_item_text(test_idx, name_edit.text)
			t.name = name_edit.text
	)
	close_button.pressed.connect(func():
		exit()
	)
	
	var last_test = FileAccess.get_file_as_string("%s/last_test.txt" % STest.folder)
	for i in config_list.item_count:
		if last_test == config_list.get_item_text(i):
			config_list.select(i)
			config_list.ensure_current_is_visible()
			select_config(i)
			config_add_button.disabled = true
			config_remove_button.disabled = false
			config_duplicate_button.disabled = false
			break
