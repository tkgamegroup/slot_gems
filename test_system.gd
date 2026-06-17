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

enum ActionType
{
	OnlyShuffle,
	AI0, # just matching colors
	AI1, # max out chains
	AI2, # max out triggers
	AI3, # put on auras
	AI4, # max out eliminate effects
	AI5  # eliminate specials
}

const object_type : int = C.ObjectType.Other

const folder = "G:/slot_gems/tests"

var filename : String
var samples : int = 1000
var sample_idx : int
var groups : int = 1
var group_idx : int
var process : int = 0
var rounds : int = 1
var headless : bool = false
var use_save : bool = false
var random_seed : bool = false
var overwrite_target_score : int = -1
var reroll : bool = false
var action_type : int = ActionType.AI0
var watches : Array[Dictionary]
var inputs : Array[Dictionary]
var try_out : bool = false

var on_event : Callable
var testing : bool = false
var start_time : int
var step : int

func format_filename():
	if groups > 1:
		return "%s/%s_g%d.csv" % [folder, filename, group_idx]
	return "%s/%s.csv" % [folder, filename]

var file : FileAccess = null
var ai_debug : bool = false
var ai_debug_file : FileAccess = null

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
	var line = ""
	for i in rounds:
		if !line.is_empty():
			line += ","
		line += "Score"
		if rounds > 1:
			line += "(r%d)" % (i + 1)
		for w in watches:
			line += ",%s" % (str(C.Event.find_key(w.ev)) if w.type == "event" else w.name)
			if rounds > 1:
				line += "(r%d)" % (i + 1)
	write(line)
	end_write()

var record_line = ""
func write_sample():
	if !record_line.is_empty():
		record_line += ","
	record_line += "%d" % G.score
	for w in watches:
		if w.type == "event":
			record_line += ",%d" % w.times
		else:
			if w.name == "gem_count":
				record_line += ",%d" % G.gems.size()
			elif w.name == "avg_gem_score":
				var sum = 0.0
				for g in G.gems:
					sum += g.get_score()
				record_line += ",%f" % (sum / G.gems.size())
			elif w.name.begins_with("attrs/"):
				record_line += ",%d" % G.attrs[w.name.substr(10)]
			else:
				record_line += ",%d" % G[w.name]
		w.times = 0
	if G.current_round == rounds:
		begin_write()
		write(record_line)
		end_write()
		record_line = ""

func write_game_status():
	begin_write()
	write("#Start Datetime: %s" % Time.get_datetime_string_from_system(false, true))
	write("#Rounds: %d" % rounds)
	write("#Action: %s" % str(ActionType.find_key(action_type)))
	var cx = Board.cx
	var cy = Board.cy
	write("#Board Size: %dx%d(%d cells)" % [cx, cy, cx * cy])
	write("#Hand Size: %d" % G.hand_size)
	var red_num = 0
	var orange_num = 0
	var green_num = 0
	var blue_num = 0
	var magenta_num = 0
	var wild_num = 0
	var special_gems = []
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
			special_gems.append(g.name)
	write("#Red: %d, Orange: %d, Green: %d, Blue: %d, Magenta: %d, Wild: %d" % [red_num, orange_num, green_num, blue_num, magenta_num, wild_num])
	if !special_gems.is_empty():
		var s = ""
		for n in special_gems:
			if !s.is_empty():
				s += ", "
			s += n
		write("#Special Gems: %s" % s)
	var patterns_str = ""
	for p in G.patterns:
		if !patterns_str.is_empty():
			patterns_str += ", "
		patterns_str += p.name
	write("#Patterns: %s" % patterns_str)
	var relics = []
	for r in G.relics:
		relics.append(r.name)
	if !relics.is_empty():
		var s = ""
		for n in relics:
			if !s.is_empty():
				s += ", "
			s += n
		write("#Relics: %s" % s)
	write("#Swaps: %d" % G.swaps_per_round)
	var attrs_str = ""
	for k in G.attrs.keys():
		if G.attrs[k] != G.modifier_defaults[k]:
			if !attrs_str.is_empty():
				attrs_str += ", "
			attrs_str += "%s: %d" % [k, G.attrs[k]]
	if !attrs_str.is_empty():
		write("#Attrs: %s" % attrs_str)
	if !special_gems.is_empty():
		var dic = {}
		for n in special_gems:
			dic[n] = 1
		for n in dic:
			write("#Special Gem - %s: " % n)
			var g = Gem.new()
			g.setup(n)
			var tt = g.get_tooltip()
			write("#%s" % tt[0].first)
			var sp = tt[0].second.split("\n")
			for l in sp:
				write("#%s" % l)
	if !relics.is_empty():
		var dic = {}
		for n in relics:
			dic[n] = 1
		for n in dic:
			write("#Relic - %s: " % n)
			var r = Relic.new()
			r.setup(n)
			var tt = r.get_tooltip()
			write("#%s" % tt[0].first)
			var sp = tt[0].second.split("\n")
			for l in sp:
				write("#%s" % l)
	end_write()

func begin_write_ai():
	ai_debug_file = FileAccess.open("res://ai_debug.txt", FileAccess.READ_WRITE)
	ai_debug_file.seek_end()

func end_write_ai():
	ai_debug_file.close()
	ai_debug_file = null

func write_ai(s : String):
	ai_debug_file.store_string(s + "\n")

func read_result(fn : String):
	var result = {}
	var columns = []
	result["comments"] = []
	var n = 0
	var file = FileAccess.open(fn, FileAccess.READ)
	while !file.eof_reached():
		var csv_line = file.get_csv_line()
		if !csv_line[0].is_empty():
			if csv_line[0][0] == "#":
				var comments = ""
				for t in csv_line:
					if !comments.is_empty():
						comments += ","
					comments += t
				result["comments"].append(comments)
			else:
				if columns.is_empty():
					columns = csv_line
					for i in csv_line.size():
						result[columns[i]] = {"avg":0.0,"med":0.0,"max":0.0,"min":0.0,"max_i":-1,"min_i":-1,"datas":[]}
				else:
					for i in csv_line.size():
						var v = float(csv_line[i])
						var col = result[columns[i]]
						col.datas.append(v)
					n += 1
	for i in columns.size():
		var col = result[columns[i]]
		col.avg = SMath.array_avg(col.datas)
		col.med = SMath.array_med(col.datas)
		col.max_i = SMath.array_max_i(col.datas)
		col.min_i = SMath.array_min_i(col.datas)
		if col.max_i != -1:
			col.max = col.datas[col.max_i]
		if col.min_i != -1:
			col.min = col.datas[col.min_i]
	return result

func load_config(name : String = "config"):
	var config = ConfigFile.new()
	if config.load("%s/%s.ini" % [folder, name]) == OK:
		filename = config.get_value("", "filename", "")
		rounds = config.get_value("", "rounds", 1)
		samples = config.get_value("", "samples", 1)
		groups = config.get_value("", "groups", 1)
		process = config.get_value("", "process", 0)
		headless = config.get_value("", "headless", false)
		use_save = config.get_value("", "use_save", false)
		reroll = config.get_value("", "reroll", false)
		action_type = config.get_value("", "action_type", ActionType.AI0)
		watches = config.get_value("", "watches", [] as Array[Dictionary])
		inputs = config.get_value("", "inputs", [] as Array[Dictionary])

func save_config(name : String = "config"):
	var config = ConfigFile.new()
	config.set_value("", "filename", filename)
	config.set_value("", "rounds", rounds)
	config.set_value("", "samples", samples)
	config.set_value("", "groups", groups)
	config.set_value("", "process", process)
	config.set_value("", "headless", headless)
	config.set_value("", "use_save", use_save)
	config.set_value("", "reroll", reroll)
	config.set_value("", "action_type", action_type)
	config.set_value("", "watches", watches)
	config.set_value("", "inputs", inputs)
	config.save("%s/%s.ini" % [folder, name])

func has_matched_pattern():
	for y in Board.cy:
		for x in Board.cx:
			for p in G.patterns:
				var res : Array[Vector2i] = p.match_with(Vector2i(x, y))
				if !res.is_empty():
					return true
	return false

func add_watch(type : String, name : String, ev : int):
	watches.append({"type":type,"name":name,"ev":ev,"times":0})

func remove_watch(name : String):
	for w in watches:
		if w.name == name:
			watches.erase(w)
			break

func add_input(type : String, name : String, base : int, group_inc : int, given_round : int):
	inputs.append({"type":type,"name":name,"base":base,"group_inc":group_inc,"given_round":given_round})

func remove_input(name : String):
	for i in inputs:
		if i.name == name:
			inputs.erase(i)
			break

func process_inputs(round : int):
	var parms = {}
	for i in inputs:
		var val = i.base + i.group_inc * group_idx
		if i.given_round == round || (round != -1 && i.given_round == -2):
			if i.type == "var":
				if i.name.begins_with("attrs/"):
					parms.get_or_add("attrs", []).append({"name":i.name.substr(6),"value":val})
				elif i.name == "board_size" && round != -1:
					G.board_size = val
					Board.resize(val, null)
				else:
					parms[i.name] = val
			elif i.type == "gem":
				if i.name == "all_kinds":
					G.add_all_kinds_of_gems(val)
				else:
					for j in val:
						var g = Gem.new()
						if i.name == "Wild":
							g.type = Gem.ColorWild
						else:
							g.setup(i.name)
						G.add_gem(g)
			elif i.type == "pattern":
				for j in val:
					var p = Gem.new()
					p.setup(i.name)
					G.add_pattern(p)
			elif i.type == "relic":
				for j in val:
					var r = Relic.new()
					r.setup(i.name)
					G.add_relic(r)
	return parms

func reset():
	if use_save:
		G.load_from_file("1")
	else:
		G.new_game(process_inputs(-1))
	process_inputs(1)
	if !headless || try_out:
		G.enter_game()
	G.start_first_round()
	if random_seed || reroll:
		G.random_seeds()
	if overwrite_target_score != -1:
		G.target_score = overwrite_target_score
	if reroll:
		for y in Board.cy:
			for x in Board.cx:
				Board.set_gem_at(Vector2i(x, y), null)
		for y in Board.cy:
			for x in Board.cx:
				Board.set_gem_at(Vector2i(x, y), G.take_from_bag())
		var hands = Hand.gems.size()
		Hand.clear()
		for i in hands:
			Hand.draw()
	for w in watches:
		w.times = 0
	if !try_out:
		SUtils.add_event_listener(Board, C.Event.Any, self)
	
	if !headless:
		var time_str = ""
		var n_past = sample_idx + samples * group_idx
		if n_past > 0:
			var seconds = (Time.get_ticks_msec() - start_time) / float(n_past) * (samples * groups - n_past) / 1000.0
			time_str = "%02d:%02d:%02d" % [int(seconds / 3600.0), int(fmod(seconds, 3600.0) / 60.0), int(fmod(seconds, 60.0))]
		testing_label.text = "%d/%d %d/%d %s" % [sample_idx + 1, samples, group_idx + 1, groups, time_str]

func start(base_group : int = 0, groups_num : int = -1, _try_out : bool = false):
	random_seed = false
	overwrite_target_score = 9999999
	reroll = false
	try_out = _try_out
	
	sample_idx = -1
	group_idx = 0
	
	start_time = Time.get_ticks_msec()
	step = TaskSteps.Standby
	testing = true
	
	if try_out:
		if G.title_ui.visible:
			G.title_ui.hide()
		reset()
	else:
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
					while true:
						auto_play()
						write_sample()
						if G.current_round >= rounds:
							break
						else:
							G.round_end()
							process_inputs(G.current_round + 1)
							G.next_round()
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

func timeout():
	if G.busy:
		return
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
				G.settlement_ui.exit(null, false)
			if G.game_over_ui.visible:
				G.game_over_ui.exit(false)
			if G.shop_ui.visible:
				G.shop_ui.exit(null, false)
			
			write_sample()
			
			if G.current_round == rounds:
				step = TaskSteps.Standby
				SUtils.remove_event_listeners(Board, self)
			else:
				if false && G.score < G.target_score:
					var n = (rounds - G.current_round) * (1 + watches.size())
					for i in n:
						record_line += ",N/A"
					begin_write()
					write(record_line)
					end_write()
					step = TaskSteps.Standby
				else:
					G.round_end()
					process_inputs(G.current_round + 1)
					G.next_round()
					step = TaskSteps.Play

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

func get_missing_one_places(board : Dictionary, sort_by_y : bool = true):
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
	if sort_by_y:
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

func get_missing_one_places_by_color(board, color : int):
	var ret = []
	for p in G.patterns:
		for y in Board.cy:
			for x in Board.cx:
				var c = Vector2i(x, y)
				var res : Array[Vector2i] = p.match_with(c, color, 0, board)
				if !res.is_empty():
					ret.append(res[0])
	return ret

func move(board : Dictionary, hand : Array, moves : Array, coord : Vector2i, coord_offseted : Vector2i, index : int):
	var temp = hand[index]
	hand[index] = board[coord]
	board[coord] = temp
	moves.append({"coord":coord_offseted, "index":index})

func calc_move_matcheds_change(board : Dictionary, coord : Vector2i, g : Dictionary):
	var n1 = SUtils.temp_board_matched_cells(board).size()
	var temp = board[coord]
	board[coord] = g.duplicate(true)
	var n2 = SUtils.temp_board_matched_cells(board).size()
	board[coord] = temp
	return n2 - n1

func calc_move_triggers(board : Dictionary, coord : Vector2i, g : Dictionary):
	var temp = board[coord]
	board[coord] = g.duplicate(true)
	var n = SUtils.temp_board_trigger_cells(board).size()
	board[coord] = temp
	return n

func collect_eliminated_layers(matcheds : Array, eliminated_layers : Array):
	var layer = {}
	for c in matcheds:
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

func elimination_contains_one_of(eliminated_layers : Array, coords : Array):
	for c in coords:
		if elimination_contains(eliminated_layers, c):
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
		if ai_debug:
			begin_write_ai()
			write_ai("=====ATTAMP (%d, %d)<=> %d =====" % [moves[0].coord.x, moves[0].coord.y, moves[0].index])
			end_write_ai()
		while true:
			if ai_debug:
				begin_write_ai()
				write_ai("Board: " + var_to_str(board).replace("\n", ""))
				end_write_ai()
			var matcheds = SUtils.temp_board_matched_cells(board)
			if matcheds.is_empty():
				if swaps == 0:
					break
				var missings = get_missing_one_places(board)
				if ai_debug:
					begin_write_ai()
					write_ai("Missings: " + var_to_str(missings).replace("\n", ""))
					end_write_ai()
				var ok = false
				for p in missings:
					if eliminated_layers.is_empty() || affected_by_elimination(eliminated_layers, p.all_coords):
						var coord = offset_by_elimination(eliminated_layers, p.coord)
						if calc_move_matcheds_change(initial_board, coord, {"type":p.color,"rune":Gem.None,"score":0}) == 0:
							var sorted_hand = get_sorted_hand(hand, p.color)
							for i in sorted_hand:
								if swaps > 0:
									swaps -= 1
									if ai_debug:
										begin_write_ai()
										write_ai("Pick: (%d, %d) <=> %d" % [p.coord.x, p.coord.y, i])
										end_write_ai()
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
		if ai_debug:
			begin_write_ai()
			write_ai("MOVES: " + var_to_str(moves).replace("\n", ""))
			write_ai("==========")
			end_write_ai()
	return chains

func swap_gems(coord : Vector2i, index : int):
	var g1 = Hand.gems[index]
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
	
	if action_type != ActionType.OnlyShuffle:
		if action_type == ActionType.AI0:
			while true:
				var changed = false
				var missings = get_missing_one_places(board)
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
		elif action_type == ActionType.AI1:
			var eliminated_layers = []
			while true:
				var matcheds = SUtils.temp_board_matched_cells(board)
				if matcheds.is_empty():
					board = SUtils.get_board_data()
					break
				collect_eliminated_layers(matcheds, eliminated_layers)
				SUtils.temp_board_clear_matcheds(board)
			
			var missings = get_missing_one_places(board)
			var max_chains = 0
			var max_chains_moves = []
			if ai_debug:
				ai_debug_file = FileAccess.open("res://ai_debug.txt", FileAccess.WRITE)
				ai_debug_file.close()
				begin_write_ai()
				write_ai("=====Init=====")
				write_ai("Board: " + var_to_str(board).replace("\n", ""))
				write_ai("Missings: " + var_to_str(missings).replace("\n", ""))
				write_ai("==============")
				end_write_ai()
			for p in missings:
				if elimination_contains_one_of(eliminated_layers, p.all_coords) || affected_by_elimination(eliminated_layers, p.all_coords):
					continue
				var temp_board = board.duplicate(true)
				var temp_hand = hand.duplicate(true)
				var temp_eliminated_layers = []
				var current_moves = []
				var chains = evolve_board_to_max_chains(temp_board, temp_hand, temp_eliminated_layers, current_moves, swaps, p)
				if chains > max_chains:
					max_chains = chains
					max_chains_moves = current_moves.duplicate(true)
			moves = max_chains_moves.duplicate(true)
			if ai_debug:
				begin_write_ai()
				write_ai("FINAL MOVES: " + var_to_str(moves).replace("\n", ""))
				end_write_ai()
		elif action_type == ActionType.AI2:
			while true:
				var changed = false
				if swaps > 0:
					var best_move = {}
					var best_triggers = -1
					for i in hand.size():
						if hand[i].tags.has("trigger"):
							var places = SUtils.temp_board_potential_trigger_cells(board)
							for p in places:
								var n = calc_move_triggers(board, p, hand[i])
								if n > best_triggers:
									best_move = {"coord":p,"idx":i}
									best_triggers = n
						elif hand[i].name == "C4":
							var map = {}
							var matcheds = SUtils.temp_board_matched_cells(board)
							for c in matcheds:
								map[c] = 1
								for cc in Board.offset_adjacents(c):
									if Board.is_valid(cc):
										map[cc] = 1
							var places = {}
							for c in map.keys():
								var g = board[c]
								if g.name == "Bomb":
									for cc in Board.offset_adjacents(c):
										if Board.is_valid(cc):
											places[cc] = 1
							for p in places:
								var n = calc_move_triggers(board, p, hand[i])
								if n > best_triggers:
									best_move = {"coord":p,"idx":i}
									best_triggers = n
						else:
							var missings = get_missing_one_places_by_color(board, hand[i].type)
							for p in missings:
								var n = calc_move_triggers(board, p, hand[i])
								if n > best_triggers:
									best_move = {"coord":p,"idx":i}
									best_triggers = n
					if best_triggers >= 0:
						move(board, hand, moves, best_move.coord, best_move.coord, best_move.idx)
						swaps -= 1
						changed = true
				if !changed:
					break
		elif action_type == ActionType.AI3:
			while true:
				var changed = false
				var missings = get_missing_one_places(board, false)
				var aura_places = []
				var aura_affected_places = {}
				for c in board:
					var g = board[c]
					if g.tags.has("aura"):
						aura_places.append(c)
						var r = g.extras["range_i"]
						for i in range(1, r):
							for cc in Board.offset_ring(c, i):
								if aura_affected_places.has(cc):
									aura_affected_places[cc] += 1
								else:
									aura_affected_places[cc] = 1
				missings.sort_custom(func(a, b):
					var a_value = 0
					var b_value = 0
					if !aura_places.has(a.coord):
						for c in a.all_coords:
							if aura_affected_places.has(c):
								a_value += aura_affected_places[c]
					else:
						a_value = -100
					if !aura_places.has(b.coord):
						for c in b.all_coords:
							if aura_affected_places.has(c):
								b_value += aura_affected_places[c]
					else:
						b_value = -100
					return a_value > b_value
				)
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
		elif action_type == ActionType.AI4:
			while true:
				var changed = false
				var missings = get_missing_one_places(board, false)
				var eliminate_effects_places = []
				for c in board:
					var g = board[c]
					if g.tags.has("eliminate_effect"):
						eliminate_effects_places.append(c)
				missings.sort_custom(func(a, b):
					var a_value = 0
					var b_value = 0
					for c in a.all_coords:
						if eliminate_effects_places.has(c):
							a_value += 1
					for c in b.all_coords:
						if eliminate_effects_places.has(c):
							b_value += 1
					return a_value > b_value
				)
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
		elif action_type == ActionType.AI5:
			while true:
				var changed = false
				var missings = get_missing_one_places(board, false)
				var special_places = []
				for c in board:
					var g = board[c]
					if g.category == "Special":
						special_places.append(c)
				missings.sort_custom(func(a, b):
					var a_value = 0
					var b_value = 0
					for c in a.all_coords:
						if special_places.has(c):
							a_value += 1
					for c in b.all_coords:
						if special_places.has(c):
							b_value += 1
					return a_value > b_value
				)
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
			var pos = Board.get_pos(m.coord) - Vector2(C.TILE_SZ, C.TILE_SZ) * 0.5
			tween.tween_callback(func():
				var slot1 = Hand.ui.get_slot(m.index)
				slot1.elastic = -1.0
				var tween2 = G.create_game_tween()
				tween2.tween_property(slot1, "global_position", pos, 0.5)
				tween2.tween_callback(func():
					var g1 = Hand.gems[m.index]
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
		for w in watches:
			if event == w.ev:
				w.times += 1
	
	timer.timeout.connect(timeout)
