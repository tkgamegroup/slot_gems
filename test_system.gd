extends Node

@onready var timer : Timer = $/root/Main/TestTimer
@onready var testing_label : Label = $/root/Main/SubViewportContainer/SubViewport/Canvas/Testing

enum TaskSteps
{
	Standby,
	Play,
	GetResult
}

var filename : String
var samples : int = 1000
var sample_idx : int
var groups : int = 1
var group_idx : int
var process : int = 0
var headless : bool = false
var use_save : bool = false
var random_seed : bool = false
var overwrite_target_score : int = -1
var reroll : bool = false
var variables : Array[Dictionary]
var listen_events : Array[Dictionary]
var extras : Array[Dictionary]
var on_event : Callable
var testing : bool = false
var start_time : int
var step : int

func format_filename():
	if groups > 1:
		return "res://tests/%s_g%d.csv" % [filename, group_idx]
	return "res://tests/%s.csv" % filename

var file : FileAccess = null
func begin_write():
	if !filename.is_empty():
		file = FileAccess.open(format_filename(), FileAccess.READ_WRITE)
		file.seek_end()
	else:
		file = null

func end_write():
	file.close()
	file = null

func write(s : String):
	if file:
		file.store_string(s + "\n")
	else:
		print(s)

func write_head():
	begin_write()
	var line = "Score"
	for d in listen_events:
		line += ",%s" % C.Event.find_key(d.event)
	write(line)
	end_write()

func write_sample():
	begin_write()
	var line = "%d" % G.score
	for d in listen_events:
		line += ",%d" % d.times
	write(line)
	end_write()

func write_game_status():
	begin_write()
	var cx = Board.cx
	var cy = Board.cy
	write("#Board Size: %dx%d(%d cells)" % [cx, cy, cx * cy])
	var red_num = 0
	var orange_num = 0
	var green_num = 0
	var blue_num = 0
	var magenta_num = 0
	var wild_num = 0
	var special_gems_str = ""
	for g in G.gems:
		if g.name == "":
			match g.type:
				Gem.ColorRed: red_num += 1
				Gem.ColorOrange: orange_num += 1
				Gem.ColorGreen: green_num += 1
				Gem.ColorBlue: blue_num += 1
				Gem.ColorMagenta: magenta_num += 1
				Gem.ColorWild: wild_num += 1
		else:
			if !special_gems_str.is_empty():
				special_gems_str += ", "
			special_gems_str += g.name
	write("#Red: %d, Orange: %d, Green: %d, Blue: %d, Magenta: %d, Wild: %d" % [red_num, orange_num, green_num, blue_num, magenta_num, wild_num])
	write("#Special Gems: %s" % special_gems_str)
	var patterns_str = ""
	for p in G.patterns:
		if !patterns_str.is_empty():
			patterns_str += ", "
		patterns_str += p.name
	write("#Patterns: %s" % patterns_str)
	var relics_str = ""
	for r in G.relics:
		if !relics_str.is_empty():
			relics_str += ", "
		relics_str += r.name
	write("#Relics: %s" % relics_str)
	write("#Swaps: %d" % G.swaps_per_round)
	var modifiers_str = ""
	for k in G.modifiers.keys():
		if G.modifiers[k] != 0:
			if !modifiers_str.is_empty():
				modifiers_str += ", "
			modifiers_str += "%s: %d" % [k, G.modifiers[k]]
	if !modifiers_str.is_empty():
		write("#Modifiers: %s" % modifiers_str)
	end_write()

func read_result(fn : String):
	var result = {}
	var columns = []
	result["comments"] = []
	var n = 0
	var file = FileAccess.open(fn, FileAccess.READ)
	while !file.eof_reached():
		var data = file.get_csv_line()
		if !data[0].is_empty():
			if data[0][0] == "#":
				var line = ""
				for t in data:
					if !line.is_empty():
						line += ","
					line += t
				result["comments"].append(line)
			else:
				if columns.is_empty():
					columns = data
					for i in data.size():
						result[columns[i]] = {"avg":0.0,"max":-10000.0,"min":+10000.0,"max_i":-1,"min_i":-1,"datas":[]}
				else:
					for i in data.size():
						var v = float(data[i])
						var col = result[columns[i]]
						col.avg += v
						if v > col.max:
							col.max = v
							col.max_i = n
						if v < col.min:
							col.min = v
							col.min_i = n
						col.datas.append(v)
					n += 1
	for i in columns.size():
		var col = result[columns[i]]
		col.avg = col.avg / n
	return result

func load_config(name : String = "config"):
	var config = ConfigFile.new()
	if config.load("res://tests/%s.ini" % name) == OK:
		filename = config.get_value("", "filename", "")
		samples = config.get_value("", "samples", 1)
		groups = config.get_value("", "groups", 1)
		process = config.get_value("", "process", 0)
		headless = config.get_value("", "headless", false)
		use_save = config.get_value("", "use_save", false)
		reroll = config.get_value("", "reroll", false)
		variables = config.get_value("", "variables", [] as Array[Dictionary])
		listen_events = config.get_value("", "listen_events", [] as Array[Dictionary])
		extras = config.get_value("", "extras", [] as Array[Dictionary])

func save_config(name : String = "config"):
	var config = ConfigFile.new()
	config.set_value("", "filename", filename)
	config.set_value("", "samples", samples)
	config.set_value("", "groups", groups)
	config.set_value("", "process", process)
	config.set_value("", "headless", headless)
	config.set_value("", "use_save", use_save)
	config.set_value("", "reroll", reroll)
	config.set_value("", "variables", variables)
	config.set_value("", "listen_events", listen_events)
	config.set_value("", "extras", extras)
	config.save("res://tests/%s.ini" % name)

func has_matched_pattern():
	for y in Board.cy:
		for x in Board.cx:
			for p in G.patterns:
				var res : Array[Vector2i] = p.match_with(Vector2i(x, y))
				if !res.is_empty():
					return true
	return false

func add_listen_event(ev : int):
	listen_events.append({"event":ev,"times":0})

func remove_listen_event(ev : int):
	for d in listen_events:
		if d.event == ev:
			listen_events.erase(d)
			break

func add_variable(name : String, base : int, step : int):
	variables.append({"name":name,"base":base,"step":step})

func remove_variable(name : String):
	for d in variables:
		if d.name == name:
			variables.erase(d)
			break

func add_extra(category : String, name : String, base_count : int, count_increase : int):
	extras.append({"category":category,"name":name,"base_count":base_count,"count_increase":count_increase})

func remove_extra(name : String):
	for d in extras:
		if d.name == name:
			extras.erase(d)
			break

func reset():
	var parms = {}
	for v in variables:
		var val = v.base + v.step * group_idx
		if v.name.begins_with("modifiers/"):
			parms.get_or_add("modifiers", []).append({"name":v.name.substr(10),"value":val})
		else:
			parms[v.name] = val
	for d in extras:
		if d.category == "gem":
			var n = d.base_count + d.count_increase * group_idx
			parms.get_or_add("extra_gems", []).append({"name":d.name,"num":n})
		elif d.category == "pattern":
			pass
		elif d.category == "relic":
			var n = d.base_count + d.count_increase * group_idx
			parms.get_or_add("extra_relics", []).append({"name":d.name,"num":n})
	G.start_game("1" if use_save else "", parms)
	if random_seed || reroll:
		G.random_seeds()
	if overwrite_target_score != -1:
		G.target_score = overwrite_target_score
	if reroll:
		for y in Board.cy:
			for x in Board.cx:
				Board.set_gem_at(Vector2i(x, y), null)
		var hands = Hand.grabs.size()
		Hand.clear()
		for y in Board.cy:
			for x in Board.cx:
				Board.set_gem_at(Vector2i(x, y), G.take_from_bag())
		for i in hands:
			Hand.draw()
	for d in listen_events:
		d.times = 0
	SUtils.add_event_listener(Board, C.Event.Any, self, C.HostType.Other)
	
	if !headless:
		var time_str = ""
		var n_past = sample_idx + samples * group_idx
		if n_past > 0:
			var seconds = (Time.get_ticks_msec() - start_time) / float(n_past) * (samples * groups - n_past) / 1000.0
			time_str = "%02d:%02d:%02d" % [int(seconds / 3600.0), int(fmod(seconds, 3600.0) / 60.0), int(fmod(seconds, 60.0))]
		testing_label.text = "%d/%d %d/%d %s" % [sample_idx + 1, samples, group_idx + 1, groups, time_str]

func start(base_group : int = 0, groups_num : int = -1):
	random_seed = false
	overwrite_target_score = 9999999
	reroll = false
	
	sample_idx = -1
	group_idx = 0
	
	start_time = Time.get_ticks_msec()
	step = TaskSteps.Standby
	testing = true
	
	if headless:
		if groups_num == -1:
			groups_num = groups
		for i in groups_num:
			group_idx = base_group + i
			for j in samples:
				sample_idx = j
				reset()
				if j == 0:
					FileAccess.open(format_filename(), FileAccess.WRITE)
					write_game_status()
					write_head()
				auto_swap_gems()
				G.play()
				write_sample()
				SUtils.remove_event_listeners(Board, self)
		stop()
	else:
		AudioServer.set_bus_volume_db(SSound.se_bus_index, linear_to_db(0))
		G.performance_mode = true
		G.base_speed = 4.0
		G.speed = 1.0 / G.base_speed
		
		if G.title_ui.visible:
			G.title_ui.hide()
		
		timer.start()

func stop():
	timer.stop()
	SUtils.remove_event_listeners(Board, self)
	if !headless:
		testing_label.text = ""
	testing = false

func time_out():
	if G.stage == G.Stage.Deploy || G.stage >= G.Stage.GameOver:
		if step == TaskSteps.Standby:
			sample_idx += 1
			if sample_idx == samples:
				group_idx += 1
				if group_idx == groups:
					stop()
					return
				else:
					sample_idx = 0
			reset()
			if sample_idx == 0:
				FileAccess.open(format_filename(), FileAccess.WRITE).close()
				write_game_status()
				write_head()
			step = TaskSteps.Play
		elif step == TaskSteps.Play:
			auto_swap_gems()
			step = TaskSteps.GetResult
			G.play()
		elif step == TaskSteps.GetResult:
			if G.settlement_ui.visible:
				G.settlement_ui.exit(false)
			if G.game_over_ui.visible:
				G.game_over_ui.exit(false)
			if G.shop_ui.visible:
				G.shop_ui.exit(null, false)
			
			write_sample()
			
			step = TaskSteps.Standby
			SUtils.remove_event_listeners(Board, self)

func get_missing_one_places() -> Dictionary[int, Array]:
	var ret : Dictionary[int, Array]
	for i in Gem.ColorCount:
		ret[Gem.ColorFirst + i] = []
	for y in Board.cy:
		for x in Board.cx:
			var c = Vector2i(x, y)
			for p in G.patterns:
				for i in Gem.ColorCount:
					var res : Array[Vector2i] = p.match_with(c, Gem.ColorFirst + i)
					if !res.is_empty():
						ret[Gem.ColorFirst + i].append(res[0])
	return ret

func swap_gems(coord : Vector2i, gem : Gem):
	Hand.erase(Hand.find(gem))
	var og = Board.set_gem_at(coord, null)
	Board.set_gem_at(coord, gem)
	Hand.add_gem(og)

func auto_swap_gems():
	if G.swaps == 0:
		return
	var changed = true
	while changed:
		changed = false
		var missing_one_places : Dictionary[int, Array] = get_missing_one_places()
		var grabs = []
		for g in Hand.grabs:
			grabs.append(g)
		grabs.sort_custom(func(a : Gem, b : Gem):
			return a.get_score() > b.get_score()
		)
		for g in grabs:
			if g.type == Gem.ColorRed:
				var arr = missing_one_places[Gem.ColorRed]
				if !arr.is_empty():
					if G.swaps > 0:
						G.swaps -= 1
						swap_gems(SMath.pick_and_remove(arr), g)
						changed = true
			elif g.type == Gem.ColorOrange:
				var arr = missing_one_places[Gem.ColorOrange]
				if !arr.is_empty():
					if G.swaps > 0:
						G.swaps -= 1
						swap_gems(SMath.pick_and_remove(arr), g)
						changed = true
			elif g.type == Gem.ColorGreen:
				var arr = missing_one_places[Gem.ColorGreen]
				if !arr.is_empty():
					if G.swaps > 0:
						G.swaps -= 1
						swap_gems(SMath.pick_and_remove(arr), g)
						changed = true
			elif g.type == Gem.ColorBlue:
				var arr = missing_one_places[Gem.ColorBlue]
				if !arr.is_empty():
					if G.swaps > 0:
						G.swaps -= 1
						swap_gems(SMath.pick_and_remove(arr), g)
						changed = true
			elif g.type == Gem.ColorMagenta:
				var arr = missing_one_places[Gem.ColorMagenta]
				if !arr.is_empty():
					if G.swaps > 0:
						G.swaps -= 1
						swap_gems(SMath.pick_and_remove(arr), g)
						changed = true

func _ready() -> void:
	on_event = func(event : int, tween : Tween, data):
		for d in listen_events:
			if event == d.event:
				d.times += 1
	timer.timeout.connect(time_out)
