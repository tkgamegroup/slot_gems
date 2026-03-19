extends Panel

@export var tab_container : TabContainer
@export var configs_list : ItemList
@export var config_add_button : Button
@export var config_remove_button : Button
@export var config_duplicate_button : Button
@export var config_name_edit : LineEdit
@export var config_rename_button : Button
@export var filename_edit : LineEdit
@export var headless_checkbox : Button
@export var use_save_checkbox : Button
@export var reroll_checkbox : Button
@export var events_list : ItemList
@export var variables_list : ItemList
@export var variable_name_edit : LineEdit
@export var variable_base_edit : LineEdit
@export var variable_step_edit : LineEdit
@export var variable_add_button : Button
@export var variable_remove_button : Button
@export var extras_list : ItemList
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
@export var test_result : GridContainer
@export var close_button : Button

var tests = []

func enter():
	self.show()

func exit():
	self.hide()

func find_group(t, idx : int):
	for i in t.groups.size():
		if t.groups[i].idx == idx:
			return i
	return -1

func format_config_filename(name : String):
	return "res://tests/%s.ini" % name

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
	if idx < configs_list.item_count:
		var name = configs_list.get_item_text(idx)
		STest.load_config(name)
		config_name_edit.text = name
		update_config_ui()

func update_config_ui():
	filename_edit.text = STest.filename
	headless_checkbox.set_pressed_no_signal(STest.headless)
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
	extras_list.clear()
	for d in STest.extras:
		extras_list.add_item(d.name)
	samples_edit.text = "%d" % STest.samples
	groups_edit.text = "%d" % STest.groups
	process_edit.text = "%d" % STest.process

func tab_changed(tab : int):
	if tab == 0:
		configs_list.clear()
		for fn in DirAccess.open("res://tests").get_files():
			if fn.ends_with(".ini"):
				configs_list.add_item(fn.substr(0, fn.length() - 4))
		update_config_ui()
	elif tab == 1:
		test_list.clear()
		var files = []
		for fn in DirAccess.open("res://tests").get_files():
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

func show_sample(idx : int):
	var sel = test_list.get_selected_items()
	if !sel.is_empty():
		var t = tests[sel[0]]
		var g = t.groups[int(group_edit.text)]
		test_result.get_child(6).text = "%d" % idx
		for i in g.columns.size():
			test_result.get_child(7 * (i + 2) - 1).text = "%d" % int(g.columns[i].datas[idx])

func format_filename(name : String, idx : int, has_groups : bool):
		return "res://tests/" + ("%s_g%d.csv" % [name, idx] if has_groups else "%s.csv" % name)

func read_datas():
	var sel = test_list.get_selected_items()
	if !sel.is_empty():
		var t = tests[sel[0]]
		for i in t.groups.size():
			var g = t.groups[i]
			var fn = format_filename(t.name, g.idx, t.groups.size() > 1)
			var result = STest.read_result(fn)
			g.comments.clear()
			g.columns.clear()
			g.comments = result["comments"].duplicate()
			for k in result.keys():
				if k != "comments":
					var c = result[k]
					var max_i = c.max_i
					var min_i = c.min_i
					var column = {"name":k,"avg":c.avg,"max":c.max,"min":c.min,"max_i":max_i,"min_i":min_i,"datas":c.datas.duplicate()}
					g.columns.append(column)

func update_page():
	var sel = test_list.get_selected_items()
	if !sel.is_empty():
		var t = tests[sel[0]]
		var i = find_group(t, int(group_edit.text))
		if i != -1:
			var g = t.groups[i]
			test_comment.clear()
			for n in test_result.get_children():
				test_result.remove_child(n)
				n.queue_free()
			test_comment.text += "%d Samples\n" % g.columns[0].datas.size()
			for l in g.comments:
				test_comment.text += l + "\n"
			test_result.columns = 7
			var lb_head_name = Label.new()
			lb_head_name.text = "Name"
			test_result.add_child(lb_head_name)
			var lb_head_avg = Label.new()
			lb_head_avg.text = "Avg"
			test_result.add_child(lb_head_avg)
			var lb_head_max = Label.new()
			lb_head_max.text = "Max" 
			test_result.add_child(lb_head_max)
			var lb_head_max_i = Label.new()
			lb_head_max_i.text = "Max i"
			test_result.add_child(lb_head_max_i)
			var lb_head_min = Label.new()
			lb_head_min.text = "Min"
			test_result.add_child(lb_head_min)
			var lb_head_min_i = Label.new()
			lb_head_min_i.text = "Min i"
			test_result.add_child(lb_head_min_i)
			var lb_head_data = Label.new()
			lb_head_data.text = "N/A"
			test_result.add_child(lb_head_data)
			
			for c in g.columns:
				var max_i = c.max_i
				var min_i = c.min_i
				var lb_name = Label.new()
				lb_name.text = c.name
				test_result.add_child(lb_name)
				var lb_avg = Label.new()
				lb_avg.text = "%.3f" % c.avg
				test_result.add_child(lb_avg)
				var lb_max = Label.new()
				lb_max.text = "%.1f" % c.max
				test_result.add_child(lb_max)
				var lb_max_i = LinkButton.new()
				lb_max_i.text = "%d" % max_i
				test_result.add_child(lb_max_i)
				lb_max_i.pressed.connect(func():
					show_sample(max_i)
				)
				var lb_min = Label.new()
				lb_min.text = "%.1f" % c.min
				test_result.add_child(lb_min)
				var lb_min_i = LinkButton.new()
				lb_min_i.text = "%d" % min_i
				test_result.add_child(lb_min_i)
				lb_min_i.pressed.connect(func():
					show_sample(min_i)
				)
				var lb_data = Label.new()
				lb_data.text = "N/A"
				test_result.add_child(lb_data)

func save_config():
	var sel = configs_list.get_selected_items()
	if !sel.is_empty():
		var name = config_name_edit.text
		STest.save_config(name)
	else:
		STest.save_config()

func _ready() -> void:
	tab_changed(0)
	tab_container.tab_changed.connect(func(tab : int):
		tab_changed(tab)
	)
	configs_list.item_selected.connect(func(idx : int):
		select_config(idx)
		config_add_button.disabled = true
		config_remove_button.disabled = false
		config_duplicate_button.disabled = false
	)
	configs_list.empty_clicked.connect(func(at_position: Vector2, mouse_button_index: int):
		configs_list.deselect_all()
		config_add_button.disabled = false
		config_remove_button.disabled = true
		config_duplicate_button.disabled = true
	)
	config_add_button.pressed.connect(func():
		var name = get_config_name()
		FileAccess.open(format_config_filename(name), FileAccess.WRITE)
		configs_list.add_item(name)
		configs_list.select(configs_list.item_count - 1)
		select_config(configs_list.item_count - 1)
	)
	config_remove_button.pressed.connect(func():
		var sel = configs_list.get_selected_items()
		if !sel.is_empty():
			DirAccess.remove_absolute(format_config_filename(configs_list.get_item_text(sel[0])))
			configs_list.remove_item(sel[0])
	)
	config_duplicate_button.pressed.connect(func():
		var sel = configs_list.get_selected_items()
		if !sel.is_empty():
			var name = configs_list.get_item_text(sel[0])
			var new_name = get_config_name(name)
			DirAccess.copy_absolute(format_config_filename(name), format_config_filename(new_name))
			configs_list.add_item(new_name)
			configs_list.select(configs_list.item_count - 1)
			select_config(configs_list.item_count - 1)
	)
	config_rename_button.pressed.connect(func():
		var sel = configs_list.get_selected_items()
		if !sel.is_empty():
			var name = config_name_edit.text
			if name.is_valid_filename():
				DirAccess.rename_absolute(format_config_filename(configs_list.get_item_text(sel[0])), format_config_filename(name))
				configs_list.set_item_text(sel[0], name)
	)
	filename_edit.text_changed.connect(func(text : String):
		STest.filename = text
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
	events_list.multi_selected.connect(func(idx : int, selected : bool):
		if selected:
			STest.add_listen_event(idx)
		else:
			STest.remove_listen_event(idx)
		save_config()
	)
	variables_list.item_selected.connect(func(idx : int):
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
	variables_list.empty_clicked.connect(func(at_position: Vector2, mouse_button_index: int):
		variables_list.deselect_all()
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
		var sel = variables_list.get_selected_items()
		if !sel.is_empty():
			STest.variables[sel[0]].name = variable_name_edit.text
			variables_list.set_item_text(sel[0], variable_name_edit.text)
			save_config()
	)
	variable_base_edit.text_changed.connect(func(text : String):
		var sel = variables_list.get_selected_items()
		if !sel.is_empty():
			var v = STest.variables[sel[0]]
			v.base = int(variable_base_edit.text)
			save_config()
	)
	variable_step_edit.text_changed.connect(func(text : String):
		var sel = variables_list.get_selected_items()
		if !sel.is_empty():
			var v = STest.variables[sel[0]]
			v.step = int(variable_step_edit.text)
			save_config()
	)
	variable_add_button.pressed.connect(func():
		STest.add_variable("new", 0, 0)
		variables_list.add_item("new")
		save_config()
	)
	variable_remove_button.pressed.connect(func():
		var sel = variables_list.get_selected_items()
		if !sel.is_empty():
			STest.variables.remove_at(sel[0])
			variables_list.remove_item(sel[0])
			save_config()
	)
	extras_list.item_selected.connect(func(idx : int):
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
	extras_list.empty_clicked.connect(func(at_position: Vector2, mouse_button_index: int):
		extras_list.deselect_all()
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
		var sel = extras_list.get_selected_items()
		if !sel.is_empty():
			STest.extras[sel[0]].category = extra_category_edit.text
			save_config()
	)
	extra_name_edit.text_changed.connect(func(text : String):
		var sel = extras_list.get_selected_items()
		if !sel.is_empty():
			STest.extras[sel[0]].name = extra_name_edit.text
			extras_list.set_item_text(sel[0], extra_name_edit.text)
			save_config()
	)
	extra_base_count_edit.text_changed.connect(func(text : String):
		var sel = extras_list.get_selected_items()
		if !sel.is_empty():
			var d = STest.extras[sel[0]]
			d.base_count = int(extra_base_count_edit.text)
			save_config()
	)
	extra_count_increase_edit.text_changed.connect(func(text : String):
		var sel = extras_list.get_selected_items()
		if !sel.is_empty():
			var d = STest.extras[sel[0]]
			d.count_increase = int(extra_count_increase_edit.text)
			save_config()
	)
	extra_add_button.pressed.connect(func():
		STest.add_extra("", "new", 0, 0)
		extras_list.add_item("new")
		save_config()
	)
	extra_remove_button.pressed.connect(func():
		var sel = extras_list.get_selected_items()
		if !sel.is_empty():
			STest.extras.remove_at(sel[0])
			extras_list.remove_item(sel[0])
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
			var sel = configs_list.get_selected_items()
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
	)
	test_list.item_selected.connect(func(idx : int):
		var t = tests[idx]
		group_edit.text = "%d" % int(t.groups[0].idx)
		name_edit.text = t.name
		read_datas()
		update_page()
		
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
	)
	group_plus_button.pressed.connect(func():
		var sel = test_list.get_selected_items()
		if !sel.is_empty():
			var t = tests[sel[0]]
			var idx = int(group_edit.text)
			var i = find_group(t, idx)
			if i < t.groups.size() - 1:
				group_edit.text = "%d" % int(t.groups[i + 1].idx)
				update_page()
	)
	group_mimus_button.pressed.connect(func():
		var sel = test_list.get_selected_items()
		if !sel.is_empty():
			var t = tests[sel[0]]
			var idx = int(group_edit.text)
			var i = find_group(t, idx)
			if i > 0:
				group_edit.text = "%d" % int(t.groups[i - 1].idx)
				update_page()
	)
	rename_button.pressed.connect(func():
		var sel = test_list.get_selected_items()
		if !sel.is_empty():
			var t = tests[sel[0]]
			for i in t.groups.size():
				DirAccess.rename_absolute(format_filename(t.name, t.groups[i].idx, t.groups.size() > 1), format_filename(name_edit.text, t.groups[i].idx, t.groups.size() > 1))
			test_list.set_item_text(sel[0], name_edit.text)
			t.name = name_edit.text
	)
	close_button.pressed.connect(func():
		exit()
	)
	
	var launch_args = OS.get_cmdline_args()
	for i in launch_args.size():
		if launch_args[i] == "-test":
			var config_name = launch_args[i + 1]
			var sp = launch_args[i + 2].split(",")
			STest.load_config(config_name)
			STest.start(int(sp[0]), int(sp[1]))
			get_tree().quit()
