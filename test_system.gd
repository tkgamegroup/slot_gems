extends Node

@onready var timer : Timer = $/root/Main/TestTimer
@onready var testing_label : Label = $/root/Main/SubViewportContainer/SubViewport/Canvas/Testing

enum TaskSteps
{
	Standby,
	Play,
	WaitForResult,
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
var ai_level : int = 0

var on_event : Callable
var testing : bool = false
var start_time : int
var step : int

func format_filename():
	if groups > 1:
		return "res://tests/%s_g%d.csv" % [filename, group_idx]
	return "res://tests/%s.csv" % filename

var file : FileAccess = null
var debug_file : FileAccess = null

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
		ai_level = config.get_value("", "ai_level", 0)
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
	config.set_value("", "ai_level", ai_level)
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
			var n = d.base_count + d.count_increase * group_idx
			parms.get_or_add("extra_patterns", []).append({"name":d.name,"num":n})
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
				auto_play()
				write_sample()
				SUtils.remove_event_listeners(Board, self)
		stop()
	else:
		timer.start()

func stop():
	timer.stop()
	SUtils.remove_event_listeners(Board, self)
	if !headless:
		testing_label.text = ""
	testing = false

func time_out():
	if G.title_ui.visible || G.stage == G.Stage.Deploy || G.stage >= G.Stage.GameOver:
		if G.title_ui.visible:
			G.title_ui.hide()
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
			if G.control_ui.play_button.disabled == false:
				auto_play()
				step = TaskSteps.WaitForResult
		elif step == TaskSteps.WaitForResult:
			if G.control_ui.play_button.disabled == false:
				if G.swaps == 0:
					if has_matcheds():
						step = TaskSteps.Play
					else:
						step = TaskSteps.GetResult
				else:
					if !has_missing_one_place():
						step = TaskSteps.GetResult
					else:
						step = TaskSteps.Play
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

func get_sorted_hand(hand : Array, color : int):
	var ret = []
	for i in hand.size():
		if hand[i].type == color:
			ret.append(i)
	ret.sort_custom(func(i, j):
		return hand[i].score > hand[j].score
	)
	return ret

func has_matcheds(board : Dictionary = {}):
	for p in G.patterns:
		for y in Board.cy:
			for x in Board.cx:
				var c = Vector2i(x, y)
				var res : Array[Vector2i] = p.match_with(c, 0, 0, board)
				if !res.is_empty():
					return true
	return false

func has_missing_one_place(board : Dictionary = {}):
	for p in G.patterns:
		for y in Board.cy:
			for x in Board.cx:
				var c = Vector2i(x, y)
				for i in Gem.ColorCount:
					var res : Array[Vector2i] = p.match_with(c, Gem.ColorFirst + i, 0, board)
					if !res.is_empty():
						return true
	return false

func get_missing_one_places(board : Dictionary = {}):
	var ret = []
	for p in G.patterns:
		for y in Board.cy:
			for x in Board.cx:
				var c = Vector2i(x, y)
				for i in Gem.ColorCount:
					var res : Array[Vector2i] = p.match_with(c, Gem.ColorFirst + i, 0, board)
					if !res.is_empty():
						var all_coords = []
						var c_off = Board.offset_to_cube(c)
						for cc in p.all_coords():
							all_coords.append(Board.cube_to_offset(c_off + cc))
						ret.append({"coord":res[0], "color":Gem.ColorFirst + i, "all_coords":all_coords})
	ret.sort_custom(func(a, b):
		var a_max_y = 10000
		var b_max_y = 10000
		for c in a.all_coords:
			if c.y > a_max_y:
				a_max_y = c.y
		for c in b.all_coords:
			if c.y > b_max_y:
				b_max_y = c.y
		return a_max_y > b_max_y
	)
	return ret

func move(board : Dictionary, hand : Array, moves : Array, coord : Vector2i, coord_offseted : Vector2i, index : int):
	if hand[index].type == board[coord].type:
		var a = 1
	var temp = hand[index]
	hand[index] = board[coord]
	board[coord] = temp
	moves.append({"coord":coord_offseted, "index":index})

func calc_move_matcheds_change(board : Dictionary, coord : Vector2i, g : Dictionary):
	var n1 = SUtils.temp_board_matched_cells(board).size()
	var temp = board[coord]
	board[coord] = {"type":g.type, "rune":g.rune, "score":g.score}
	var n2 = SUtils.temp_board_matched_cells(board).size()
	board[coord] = temp
	return n2 - n1

func collect_eliminated_layers(matcheds : Dictionary, eliminated_layers : Array):
	var coords = matcheds.keys()
	var layer = {}
	for c in coords:
		layer.get_or_add(c.x, []).append(c.y)
	for x in layer.keys():
		layer[x].sort()
		layer[x].reverse()
	eliminated_layers.push_front(layer)

func elimination_contains(eliminated_layers : Array, coord : Vector2i):
	for l in eliminated_layers:
		for x in l.keys():
			for y in l[x]:
				if coord == Vector2i(x, y):
					return true
	return false

func offset_by_elimination(eliminated_layers : Array, coord : Vector2i):
	var ret = coord
	for l in eliminated_layers:
		if l.has(ret.x):
			for y in l[ret.x]:
				if y >= ret.y:
					ret.y -= 1
	return ret

func affected_by_elimination(eliminated_layers : Array, coords : Array):
	var cs = coords.duplicate(true)
	var n = 0
	for l in eliminated_layers:
		for c in cs:
			if l.has(c.x):
				for y in l[c.x]:
					if y >= c.y:
						c.y -= 1
						n += 1
	if n > 0 && n < cs.size():
		return true
	return false

func evolve_board_to_max_chains(board : Dictionary, hand : Array, eliminated_layers : Array, moves : Array, swaps : int, place : Dictionary):
	var chains = 0
	var coord1 = offset_by_elimination(eliminated_layers, place.coord)
	var sorted_hand1 = get_sorted_hand(hand, place.color)
	for i in sorted_hand1:
		if swaps > 0:
			swaps -= 1
			move(board, hand, moves, place.coord, coord1, i)
			break
	if !moves.is_empty():
		var initial_board = board.duplicate(true)
		debug_file.store_string("=====ATTAMP (%d, %d)<=> %d =====\n" % [moves[0].coord.x, moves[0].coord.y, moves[0].index])
		while true:
			debug_file.store_string("Board: " + var_to_str(board).replace("\n", "") + "\n")
			var matcheds = SUtils.temp_board_matched_cells(board)
			if matcheds.is_empty():
				if swaps == 0:
					break
				var missings = get_missing_one_places(board)
				debug_file.store_string("Missings: " + var_to_str(missings).replace("\n", "") + "\n")
				var ok = false
				for p in missings:
					if eliminated_layers.is_empty() || affected_by_elimination(eliminated_layers, p.all_coords):
						var coord = offset_by_elimination(eliminated_layers, p.coord)
						if calc_move_matcheds_change(initial_board, coord, {"type":p.color,"rune":Gem.None,"score":0}) == 0:
							var sorted_hand = get_sorted_hand(hand, p.color)
							for i in sorted_hand:
								if swaps > 0:
									swaps -= 1
									debug_file.store_string("Pick: (%d, %d) <=> %d\n" % [p.coord.x, p.coord.y, i])
									move(board, hand, moves, p.coord, coord, i)
									ok = true
									break
					if ok:
						break
				if !ok:
					break
				matcheds = SUtils.temp_board_matched_cells(board)
			if !matcheds.is_empty():
				chains += 1
				collect_eliminated_layers(matcheds, eliminated_layers)
				SUtils.temp_board_clear_matcheds(board)
		debug_file.store_string("MOVES: " + var_to_str(moves).replace("\n", "") + "\n")
		debug_file.store_string("==========\n")
	return chains

func swap_gems(coord : Vector2i, index : int):
	var g1 = Hand.grabs[index]
	Hand.erase(index)
	var g2 = Board.set_gem_at(coord, g1)
	G.take_from_bag(g2)
	Hand.add_gem(g2)

var no_move_played = 0
func auto_play():
	var board = SUtils.get_board_data()
	var hand = SUtils.get_hand_data()
	var swaps = G.swaps
	var moves = []
	
	if ai_level == 0:
		while true:
			var missings = get_missing_one_places(board)
			var changed = false
			for p in missings:
				if swaps > 0:
					var sorted_hand = get_sorted_hand(hand, p.color)
					for i in sorted_hand:
						var coord = p.coord
						if calc_move_matcheds_change(board, coord, hand[i]) > 0:
							swaps -= 1
							move(board, hand, moves, coord, coord, i)
							changed = true
							break
			if !changed:
				break
	else:
		if SUtils.temp_board_matched_cells(board).is_empty():
			var eliminated_layers = []
			var missings = get_missing_one_places(board)
			var max_chains = 0
			var max_chains_moves = []
			debug_file = FileAccess.open("res://debug.txt", FileAccess.WRITE)
			debug_file.store_string("=====Init=====\n")
			debug_file.store_string("Board: " + var_to_str(board).replace("\n", "") + "\n")
			debug_file.store_string("Missings: " + var_to_str(missings).replace("\n", "") + "\n")
			debug_file.store_string("==============\n")
			for p in missings:
				var temp_board = board.duplicate(true)
				var temp_hand = hand.duplicate(true)
				var temp_eliminated_layers = eliminated_layers.duplicate(true)
				var current_moves = []
				var chains = evolve_board_to_max_chains(temp_board, temp_hand, temp_eliminated_layers, current_moves, swaps, p)
				if chains > max_chains:
					max_chains = chains
					max_chains_moves = current_moves.duplicate(true)
			moves = max_chains_moves.duplicate(true)
			debug_file.store_string("FINAL MOVES: " + var_to_str(moves).replace("\n", "") + "\n")
			debug_file.close()
	if moves.is_empty():
		no_move_played += 1
	else:
		no_move_played = 0
	if headless:
		for m in moves:
			swap_gems(m.coord, m.index)
			G.swaps -= 1
		if no_move_played >= 2 && G.swaps > 0:
			Board.shuffle()
			G.swaps -= 1
			no_move_played = 0
		else:
			G.play()
	else:
		G.begin_busy()
		var tween = G.create_game_tween()
		for m in moves:
			var pos = Board.get_pos(m.coord) - Vector2(C.BOARD_TILE_SZ, C.BOARD_TILE_SZ) * 0.5
			tween.tween_callback(func():
				var slot1 = Hand.ui.get_slot(m.index)
				slot1.elastic = -1.0
				var tween2 = G.create_game_tween()
				tween2.tween_property(slot1, "global_position", pos, 0.5)
				tween2.tween_callback(func():
					var g1 = Hand.grabs[m.index]
					Hand.erase(m.index)
					var g2 = Board.set_gem_at(m.coord, g1)
					var slot2 = Hand.add_gem(g2, m.index)
					slot2.global_position = pos
					slot2.elastic = -1.0
					var tween3 = G.create_game_tween()
					tween3.tween_property(slot2, "elastic", 1.0, 0.2).from(0.0)
					G.swaps -= 1
				)
			)
			tween.tween_interval(1.0)
		tween.tween_callback(func():
			if no_move_played >= 2 && G.swaps > 0:
				Board.shuffle()
				G.swaps -= 1
				no_move_played = 0
			else:
				G.end_busy()
				G.play()
		)

func _ready() -> void:
	on_event = func(event : int, tween : Tween, data):
		for d in listen_events:
			if event == d.event:
				d.times += 1
	timer.timeout.connect(time_out)
