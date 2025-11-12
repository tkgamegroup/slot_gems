extends Node

@onready var timer : Timer = $/root/Main/TestTimer
@onready var label : Label = $/root/Main/SubViewportContainer/SubViewport/Canvas/TestingText

enum Mode
{
	AverageScore,
	RealPlay
}

enum TaskSteps
{
	ToRoll,
	ToMatch,
	GetResult,
	ToShop
}

var filename : String
var saving : String
var additional_patterns : Array
var additional_relics : Array
var additional_enchants : Array
var mode : int
var task_count : int
var task_level_count : int
var task_index : int:
	set(v):
		task_index = v
		label.text = "Testing %d/%d" % [task_index + 1, task_count]
var step : int
var enable_shopping : bool = false
var records : Array[TaskRecord]
var testing : bool = false

static var file : FileAccess = null
func begin_write():
	if !filename.is_empty():
		file = FileAccess.open(filename, FileAccess.READ_WRITE)
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

func write_level(l : LevelRecord):
	write("Level Score: %d, Level Combos: %d, Level Relic Effects: %d" % [l.score, l.combos, l.relic_effects])

func write_matching(idx : int, m : MatchingRecord):
	write("Matching %d: %d Score, %d Combos, %d Relic Effects" % [idx, m.score, m.combos, m.relic_effects])

func write_game_status():
	var cx = Board.cx
	var cy = Board.cy
	begin_write()
	write("========Game Status========")
	write("Board Size: %dx%d(%d cells)" % [cx, cy, cx * cy])
	var red_num = 0
	var orange_num = 0
	var green_num = 0
	var blue_num = 0
	var purple_num = 0
	var wild_num = 0
	for g in Game.gems:
		match g.type:
			Gem.ColorRed: red_num += 1
			Gem.ColorOrange: orange_num += 1
			Gem.ColorGreen: green_num += 1
			Gem.ColorBlue: blue_num += 1
			Gem.ColorPurple: purple_num += 1
			Gem.ColorWild: wild_num += 1
	write("Red: %d, Orange: %d, Green: %d, Blue: %d, Purple: %d, Wild: %d" % [red_num, orange_num, green_num, blue_num, purple_num, wild_num])
	var items_str = ""
	for i in Game.items:
		if !items_str.is_empty():
			items_str += ", "
		items_str += i.name
	write("Items: %s" % items_str)
	var patterns_str = ""
	for p in Game.patterns:
		if !patterns_str.is_empty():
			patterns_str += ", "
		patterns_str += p.name
	write("Patterns: %s" % patterns_str)
	var relics_str = ""
	for r in Game.relics:
		if !relics_str.is_empty():
			relics_str += ", "
		relics_str += r.name
	write("Relics: %s" % relics_str)
	write("Rolls: %d" % Game.rolls_per_level)
	write("Matches: %d" % Game.plays_per_level)
	end_write()

func has_matched_pattern():
	for y in Board.cy:
		for x in Board.cx:
			for p in Game.patterns:
				var res : Array[Vector2i] = p.match_with(Vector2i(x, y))
				if !res.is_empty():
					return true
	return false

func start_game():
	Game.start_game(saving)
	for n in additional_patterns:
		var p = Pattern.new()
		p.setup(n)
		Game.add_pattern(p)
	for n in additional_relics:
		var r = Relic.new()
		r.setup(n)
		Game.add_relic(r)

func start_test(_mode : int, _level_count : int, _task_count : int, fn : String = "", _saving : String = "", _additional_patterns : Array = [], _additional_relics : Array = [], _additional_enchants : Array = [], invincible : bool = true, _enable_shopping : bool = false):
	AudioServer.set_bus_volume_db(SSound.se_bus_index, linear_to_db(0))
	Game.performance_mode = true
	Game.base_speed = 4.0
	Game.speed = 1.0 / Game.base_speed
	
	mode = _mode
	task_count = _task_count
	task_level_count = _level_count
	task_index = 0
	step = TaskSteps.ToRoll
	
	records.append(TaskRecord.new())
	
	if fn.is_empty():
		filename = "res://test_%s.txt" % SUtils.get_formated_datetime()
		FileAccess.open(filename, FileAccess.WRITE)
	elif fn == "console":
		fn = ""
	else:
		filename = fn
	
	saving = _saving
	additional_patterns = _additional_patterns
	additional_relics = _additional_relics
	additional_enchants = _additional_enchants
	Game.invincible = invincible
	enable_shopping = _enable_shopping
	
	if Game.title_ui.visible:
		Game.title_ui.hide()
	start_game()
	
	write_game_status()
	timer.start()
	testing = true
	label.show()

func time_out():
	if Game.stage == Game.Stage.Deploy || Game.stage == Game.Stage.LevelOver:
		if step == TaskSteps.ToRoll:
			if Game.level_clear_ui.visible || Game.game_over_ui.visible:
				var curr_task = records.back()
				if curr_task.levels.size() == task_level_count || Game.game_over_ui.visible:
					for l in curr_task.levels:
						l.matchings.pop_back()
					
					if mode == Mode.AverageScore:
						begin_write()
						write("======Task %d======" % task_index)
						for i in curr_task.levels.size():
							var curr_level = curr_task.levels[i]
							write("====Level %d====" % (i + 1))
							write_level(curr_level)
							for j in curr_level.matchings.size():
								write_matching(j, curr_level.matchings[j])
						write("======Statics For %d Task(s)======" % (task_index + 1))
						var head_str = ""
						for i in task_level_count:
							head_str += "\tLevel %d" % (i + 1)
						write(head_str)
						var max_matching_num = 0
						var avg_line = "Avg\t"
						for i in task_level_count:
							var score = 0
							var combos = 0
							var relic_effects = 0
							for r in records:
								var l = r.levels[i]
								max_matching_num = max(max_matching_num, l.matchings.size())
								score += l.score
								combos += l.combos
								relic_effects += l.relic_effects
							avg_line += "%.1f,%.2f,%.2f\t" % [float(score) / records.size(), float(combos) / records.size(), float(relic_effects) / records.size()]
						write(avg_line)
						for j in max_matching_num:
							var line = "Matching %d\t" % j
							for i in task_level_count:
								var score = 0
								var combos = 0
								var relic_effects = 0
								for r in records:
									if r.levels.size() <= i:
										continue
									var l = r.levels[i]
									if l.matchings.size() <= j:
										continue
									var m = l.matchings[j]
									score += m.score
									combos += m.combos
									relic_effects += m.relic_effects
								line += "%.1f,%.2f,%.2f\t" % [float(score) / records.size(), float(combos) / records.size(), float(relic_effects) / records.size()]
							write(line)
						end_write()
					
					task_index += 1
					if task_index == task_count:
						timer.stop()
						testing = false
						label.hide()
					else:
						records.append(TaskRecord.new())
						start_game()
				else:
					if mode == Mode.RealPlay:
						begin_write()
						write("======Level %d======" % curr_task.levels.size())
						var curr_level = curr_task.levels.back()
						write_level(curr_level)
						for j in curr_level.matchings.size():
							write_matching(j, curr_level.matchings[j])
						end_write()
					
					curr_task.levels.append(LevelRecord.new())
					if !enable_shopping:
						Game.new_level()
					else:
						step = TaskSteps.ToShop
						Game.level_clear_ui.exit()
				
				Game.level_clear_ui.hide()
				Game.game_over_ui.hide()
			else:
				step = TaskSteps.ToMatch
				#Game.roll()
		elif step == TaskSteps.ToMatch:
			#if Game.bag_items.size() > 0 && Hand.grabs.size() < Game.max_hand_grabs && Game.rolls >= Game.plays:
			#	step = TaskSteps.ToMatch
			#	Game.roll()
			#else:
				#if !has_matched_pattern() && Game.rolls >= Game.plays:
				#	step = TaskSteps.ToMatch
				#	Game.roll()
				#elif Game.plays > 0:
					var curr_task = records.back()
					if curr_task.levels.size() == 1:
						for ec in additional_enchants:
							var g = Hand.grabs.pick_random()
							Game.enchant_gem(g, ec)
					auto_swap_gems()
					#auto_place_items()
					step = TaskSteps.GetResult
					Game.play()
		elif step == TaskSteps.GetResult:
			var his = Game.history
			var curr_level : LevelRecord = records.back().levels.back()
			var curr_record : MatchingRecord = curr_level.matchings.back()
			curr_record.score = his.last_matching_score
			curr_record.combos = his.last_matching_combos
			curr_record.relic_effects = his.relic_effects
			curr_record.actives = his.last_matching_actives
			curr_level.score += his.last_matching_score
			curr_level.combos += his.last_matching_combos
			curr_level.relic_effects += his.relic_effects
			curr_level.actives += his.last_matching_actives
			curr_level.matchings.append(MatchingRecord.new())
			step = TaskSteps.ToRoll
			if his.last_matching_score == 0 && !Game.level_clear_ui.visible:
				Game.lose()
		elif step == TaskSteps.ToShop:
			if Game.shop_ui.visible:
				for i in 5:
					Game.shop_ui.buy_randomly()
				Game.shop_ui.exit()
				step = TaskSteps.ToRoll
				write_game_status()

func get_missing_one_places() -> Dictionary[int, Array]:
	var ret : Dictionary[int, Array]
	for y in Board.cy:
		for x in Board.cx:
			var c = Vector2i(x, y)
			for p in Game.patterns:
				for i in Gem.ColorCount:
					var res : Array[Vector2i] = p.match_with(c, Gem.ColorRed + i)
					if !res.is_empty():
						ret[Gem.ColorRed + i].append(res[0])
	return ret

func auto_swap_gems():
	var changed = true
	while changed:
		changed = false
		var missing_one_places : Dictionary[int, Array] = get_missing_one_places()
		var grabs = []
		for g in Hand.grabs:
			grabs.append(g)
		grabs.sort_custom(func(a : Gem, b : Gem):
			return a.get_score() + a.get_mult() > b.get_score() + b.get_mult()
		)
		for g in grabs:
			if g.type == Gem.ColorRed:
				var arr = missing_one_places[Gem.ColorRed]
				if !arr.is_empty():
					if Game.swaps > 0:
						Game.swaps -= 1
						Hand.erase(Hand.find(g))
						Hand.swap(SMath.pick_and_remove(arr), g, true)
						changed = true
			elif g.type == Gem.ColorOrange:
				var arr = missing_one_places[Gem.ColorOrange]
				if !arr.is_empty():
					if Game.swaps > 0:
						Game.swaps -= 1
						Hand.erase(Hand.find(g))
						Hand.swap(SMath.pick_and_remove(arr), g, true)
						changed = true
			elif g.type == Gem.ColorGreen:
				var arr = missing_one_places[Gem.ColorGreen]
				if !arr.is_empty():
					if Game.swaps > 0:
						Game.swaps -= 1
						Hand.erase(Hand.find(g))
						Hand.swap(SMath.pick_and_remove(arr), g, true)
						changed = true
			elif g.type == Gem.ColorBlue:
				var arr = missing_one_places[Gem.ColorBlue]
				if !arr.is_empty():
					if Game.swaps > 0:
						Game.swaps -= 1
						Hand.erase(Hand.find(g))
						Hand.swap(SMath.pick_and_remove(arr), g, true)
						changed = true
			elif g.type == Gem.ColorPurple:
				var arr = missing_one_places[Gem.ColorPurple]
				if !arr.is_empty():
					if Game.swaps > 0:
						Game.swaps -= 1
						Hand.erase(Hand.find(g))
						Hand.swap(SMath.pick_and_remove(arr), g, true)
						changed = true

'''
func auto_place_items():
	if !Hand.grabs.is_empty():
		var cx = Board.cx
		var cy = Board.cy
		var center = Vector2i(cx / 2, cy / 2)
		var item_uis = []
		for i in Hand.grabs.size():
			var ui = Hand.ui.get_slot(i)
			item_uis.append(ui)
		var missing_one_places : Array[Array] = get_missing_one_places()
		SMath.remove_if(item_uis, func(ui):
			var item = ui.item
			if item.name.begins_with("DyeRed"):
				var arr = missing_one_places[Gem.ColorRed - 1]
				if !arr.is_empty():
					if Hand.ui.place_item(ui, SMath.pick_and_remove(arr)):
						return true
			elif item.name.begins_with("DyeOrange"):
				var arr = missing_one_places[Gem.ColorOrange - 1]
				if !arr.is_empty():
					if Hand.ui.place_item(ui, SMath.pick_and_remove(arr)):
						return true
			elif item.name.begins_with("DyeGreen"):
				var arr = missing_one_places[Gem.ColorGreen - 1]
				if !arr.is_empty():
					if Hand.ui.place_item(ui, SMath.pick_and_remove(arr)):
						return true
			elif item.name.begins_with("DyeBlue"):
				var arr = missing_one_places[Gem.ColorBlue - 1]
				if !arr.is_empty():
					if Hand.ui.place_item(ui, SMath.pick_and_remove(arr)):
						return true
			elif item.name.begins_with("DyePurple"):
				var arr = missing_one_places[Gem.ColorPurple - 1]
				if !arr.is_empty():
					if Hand.ui.place_item(ui, SMath.pick_and_remove(arr)):
						return true
			elif item.name == "ColorPalette":
				for arr in missing_one_places:
					if !arr.is_empty():
						if Hand.ui.place_item(ui, SMath.pick_and_remove(arr)):
							return true
			return false
		)
		var activater_places : Array[Vector2i] = []
		var central_activater_places : Array[Vector2i] = []
		for y in cy:
			for x in cx:
				var c = Vector2i(x, y)
				for p in Game.patterns:
					var res : Array[Vector2i] = p.match_with(c)
					for cc in res:
						activater_places.append(cc)
						central_activater_places.append(cc)
		central_activater_places.sort_custom(func(c1, c2):
			return Board.offset_distance(c1, center) < Board.offset_distance(c2, center)
		)
		var aura_places = []
		for y in cy:
			for x in cx:
				var c = Vector2i(x, y)
				if !activater_places.has(c):
					aura_places.append(c)
		SMath.remove_if(item_uis, func(ui):
			var item = ui.item
			if item.on_process.is_valid():
				if item.name == "C4" || item.name == "ChainBomb" || item.name == "Lightning":
					return false
				if !central_activater_places.is_empty():
					var c = central_activater_places.front()
					if Hand.ui.place_item(ui, c):
						central_activater_places.pop_front()
						activater_places.erase(c)
						return true
			return false
		)
		SMath.remove_if(item_uis, func(ui):
			var item = ui.item
			if item.on_process.is_valid():
				if item.name == "C4" || item.name == "ChainBomb":
					var bomb_places = []
					for y in Board.cy:
						for x in Board.cx:
							var c = Vector2i(x, y)
							var i = Board.get_item_at(c)
							if i && i.category == "Bomb":
								for cc in Board.offset_neighbors(c):
									if !Board.get_item_at(cc) && !activater_places.has(cc):
										bomb_places.append(cc)
					if !bomb_places.is_empty():
						var c = bomb_places[0]
						if Hand.ui.place_item(ui, c):
							return true
					elif item.name == "ChainBomb":
						if !central_activater_places.is_empty():
							var c = central_activater_places.front()
							if Hand.ui.place_item(ui, c):
								central_activater_places.pop_front()
								activater_places.erase(c)
								return true
				elif item.name == "Lightning":
					var coords = Board.filter(func(gem : Gem, item : Item):
						return item && item.name == "Lightning"
					)
					if !coords.is_empty():
						var dist = 0
						var coord = Vector2i(-1, -1)
						for y in Board.cy:
							for x in Board.cx:
								var c = Vector2i(x, y)
								if !Board.get_item_at(c):
									var d = 0
									for cc in coords:
										d += Board.offset_distance(c, cc)
									if d > dist:
										coord = c
										dist = d
						if coord.x != -1 && coord.y != -1:
							if !Board.get_item_at(coord):
								if Hand.ui.place_item(ui, coord):
									central_activater_places.erase(coord)
									activater_places.erase(coord)
									return true
					else:
						if !central_activater_places.is_empty():
							var c = central_activater_places.back()
							if Hand.ui.place_item(ui, c):
								central_activater_places.pop_back()
								activater_places.erase(c)
								return true
			return false
		)
		SMath.remove_if(item_uis, func(ui):
			var item = ui.item
			if item.description.find("[b]Aura[/b]") != -1:
				if !aura_places.is_empty():
					if Hand.ui.place_item(ui, SMath.pick_and_remove(aura_places)):
						aura_places.pop_front()
						return true
			return false
		)
		SMath.remove_if(item_uis, func(ui):
			var item = ui.item
			if item.on_eliminate.is_valid():
				if item.name == "Rainbow" || item.name == "Fire":
					var c = activater_places[0]
					if Hand.ui.place_item(ui, c):
						activater_places.pop_front()
						central_activater_places.erase(c)
						return true
				else:
					if !central_activater_places.is_empty():
						var c = central_activater_places.front()
						if Hand.ui.place_item(ui, c):
							central_activater_places.pop_front()
							activater_places.erase(c)
							return true
			return false
		)
'''

func _ready() -> void:
	timer.timeout.connect(time_out)
