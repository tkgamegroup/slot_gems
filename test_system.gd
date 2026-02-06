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
var use_save : bool = false
var random_seed : bool = false
var overwrite_target_score : int = -1
var reroll : bool = false
var testing : bool = false
var step : int
var score : int
var variables : Array[Dictionary]
var listen_events : Array[Dictionary]
var on_event : Callable

func format_filename():
	if groups > 1:
		return "%s_g%d.csv" % [filename, group_idx]
	return "%s.csv" % filename

static var file : FileAccess = null
func begin_write():
	if !filename.is_empty():
		file = FileAccess.open(format_filename(), FileAccess.READ_WRITE)
		file.seek_end()
	else:
		file = null

func end_write():
	file = null

func write(s : String):
	if file:
		file.store_string(s + "\n")
	else:
		print(s)

func write_game_status():
	var cx = Board.cx
	var cy = Board.cy
	begin_write()
	write("#Board Size: %dx%d(%d cells)" % [cx, cy, cx * cy])
	var red_num = 0
	var orange_num = 0
	var green_num = 0
	var blue_num = 0
	var magenta_num = 0
	var wild_num = 0
	for g in G.gems:
		match g.type:
			Gem.ColorRed: red_num += 1
			Gem.ColorOrange: orange_num += 1
			Gem.ColorGreen: green_num += 1
			Gem.ColorBlue: blue_num += 1
			Gem.ColorMagenta: magenta_num += 1
			Gem.ColorWild: wild_num += 1
	write("#Red: %d, Orange: %d, Green: %d, Blue: %d, Magenta: %d, Wild: %d" % [red_num, orange_num, green_num, blue_num, magenta_num, wild_num])
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
	end_write()

func read_result(fn : String):
	var result = {}
	var columns = []
	var n = 0
	var file = FileAccess.open(fn, FileAccess.READ)
	while !file.eof_reached():
		var line = file.get_csv_line()
		if !line[0].is_empty() && line[0][0] != "#":
			if columns.is_empty():
				columns = line
				for i in line.size():
					result[columns[i]] = 0.0
			else:
				for i in line.size():
					result[columns[i]] += float(line[i])
				n += 1
	for i in columns.size():
		result[columns[i]] = result[columns[i]] / n
	return result

func load_config():
	var config = ConfigFile.new()
	if config.load("res://tests/config.ini") == OK:
		samples = config.get_value("", "samples")
		groups = config.get_value("", "groups")
		use_save = config.get_value("", "use_save")
		reroll = config.get_value("", "reroll")
		variables = config.get_value("", "variables")
		listen_events = config.get_value("", "listen_events")

func save_config():
	var config = ConfigFile.new()
	config.set_value("", "samples", samples)
	config.set_value("", "groups", groups)
	config.set_value("", "use_save", use_save)
	config.set_value("", "reroll", reroll)
	config.set_value("", "variables", variables)
	config.set_value("", "listen_events", listen_events)
	config.save("res://tests/config.ini")

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

func reset():
	G.start_game("1" if use_save else "")
	for v in variables:
		G[v.name] = v.base + v.step * group_idx
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
				Board.set_gem_at(Vector2i(x, y), G.take_out_gem_from_bag())
		for i in hands:
			Hand.draw()
	score = 0
	for d in listen_events:
		d.times = 0
	SUtils.add_event_listener(Board, C.Event.Any, self, C.HostType.Other)
	
	testing_label.text = "%d/%d %d/%d" % [sample_idx + 1, samples, group_idx + 1, groups]

func start(fn : String = ""):
	AudioServer.set_bus_volume_db(SSound.se_bus_index, linear_to_db(0))
	G.performance_mode = true
	G.base_speed = 4.0
	G.speed = 1.0 / G.base_speed
	
	random_seed = false
	overwrite_target_score = 9999999
	reroll = false
	
	sample_idx = -1
	group_idx = 0
	
	filename = "res://tests/%s" % SUtils.get_formated_datetime() if fn.is_empty() else fn
	
	step = TaskSteps.Standby
	timer.start()
	testing = true
	
	if G.title_ui.visible:
		G.title_ui.hide()

func stop():
	timer.stop()
	SUtils.remove_event_listeners(Board, self)
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
				#write_game_status()
				begin_write()
				var line = "Score"
				for d in listen_events:
					line += ",%s" % C.Event.find_key(d.event)
				write(line)
				end_write()
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
			
			begin_write()
			var line = "%d" % score
			for d in listen_events:
				line += ",%d" % d.times
			write(line)
			end_write()
			
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
	load_config()
	on_event = func(event : int, tween : Tween, data):
		for d in listen_events:
			if event == d.event:
				d.times += 1
	timer.timeout.connect(time_out)
