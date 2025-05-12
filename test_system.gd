extends Node

@onready var timer : Timer = $/root/Main/TestTimer
@onready var text : Label = $/root/Main/SubViewportContainer/SubViewport/UI/TestingText

var filename : String

enum TaskType
{
	AvgScore
}

enum TaskSteps
{
	ToRoll,
	ToMatch,
	GetResult
}

var task_count : int
var task_type : int
var task_level_count : int
var task_index : int:
	set(v):
		task_index = v
		text.text = "Testing %d/%d" % [task_index + 1, task_count]
var step : int
var records : Array[TaskRecord]
var testing : bool = false
var multiple_test_args : Array[Dictionary] = []

func get_formated_datetime():
	var datetime = Time.get_datetime_string_from_system(false, true)
	datetime = datetime.replace("-", "_")
	datetime = datetime.replace(":", "_")
	datetime = datetime.replace(" ", "_")
	return datetime

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

func start_test(type : int, level_count : int, tasks : int, fn : String = ""):
	AudioServer.set_bus_volume_db(SSound.sfx_bus_index, linear_to_db(0))
	Game.base_animation_speed = 0.25
	Game.animation_speed = Game.base_animation_speed
	
	task_count = tasks
	task_type = type
	task_level_count = level_count
	task_index = 0
	step = TaskSteps.ToRoll
	
	records.append(TaskRecord.new())
	
	if fn.is_empty():
		filename = "res://test_%s.txt" % get_formated_datetime()
		FileAccess.open(filename, FileAccess.WRITE)
	elif fn == "console":
		fn = ""
	else:
		filename = fn
	
	Game.start_game()
	Game.new_level()
	
	var cx = Board.cx
	var cy = Board.cy
	begin_write()
	write("Board Size: %dx%d(%d cells)" % [cx, cy, cx * cy])
	var red_num = 0
	var orange_num = 0
	var green_num = 0
	var blue_num = 0
	var pink_num = 0
	var wild_num = 0
	for g in Game.gems:
		match g.type:
			Gem.Type.Red: red_num += 1
			Gem.Type.Orange: orange_num += 1
			Gem.Type.Green: green_num += 1
			Gem.Type.Blue: blue_num += 1
			Gem.Type.Pink: pink_num += 1
			Gem.Type.Wild: wild_num += 1
	write("Red: %d, Orange: %d, Green: %d, Blue: %d, Pink: %d, Wild: %d" % [red_num, orange_num, green_num, blue_num, pink_num, wild_num])
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
	write("Rolls: %d" % Game.rolls_per_level)
	write("Matches: %d" % Game.matches_per_level)
	end_write()
	timer.start()
	testing = true

func next_test():
	if !multiple_test_args.is_empty():
		var args = multiple_test_args[0]
		multiple_test_args.pop_front()
		start_test(args["type"], args["level_count"], args["tasks"], args["fn"])

func start_multiple_tests(args : Array[Dictionary]):
	multiple_test_args = args
	next_test()

func time_out():
	match task_type:
		TaskType.AvgScore:
			if Game.stage == Game.Stage.Deploy:
				if step == TaskSteps.ToRoll:
					if Game.matches == 0 || Game.rolls == 0:
						var curr_task = records.back()
						if curr_task.levels.size() == task_level_count:
							for l in curr_task.levels:
								l.matchings.pop_back()
							
							begin_write()
							write("======Task %d======" % task_index)
							for i in curr_task.levels.size():
								var curr_level = curr_task.levels[i]
								write("====Level %d====" % (i + 1))
								write("Level Score: %d, Level Combos: %d" % [curr_level.score, curr_level.combos])
								for j in curr_level.matchings.size():
									var curr_matching = curr_level.matchings[j]
									write("Matching %d: %d score, %d combos" % [j, curr_matching.score, curr_matching.combos])
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
								for r in records:
									var l = r.levels[i]
									max_matching_num = max(max_matching_num, l.matchings.size())
									for m in l.matchings:
										score += m.score
										combos += m.combos
								avg_line += "%.1f,%.2f\t" % [float(score) / records.size(), float(combos) / records.size()]
							write(avg_line)
							for j in max_matching_num:
								var line = "Matching %d\t" % j
								for i in task_level_count:
									var score = 0
									var combos = 0
									for r in records:
										if r.levels.size() <= i:
											continue
										var l = r.levels[i]
										if l.matchings.size() <= j:
											continue
										var m = l.matchings[j]
										score += m.score
										combos += m.combos
									line += "%.1f,%.2f\t" % [float(score) / records.size(), float(combos) / records.size()]
								write(line)
							end_write()
							
							task_index += 1
							if task_index == task_count:
								timer.stop()
								testing = false
								if !multiple_test_args.is_empty():
									var args = multiple_test_args[0]
									multiple_test_args.pop_front()
									start_test(args["type"], args["level_count"], args["tasks"], args["fn"])
							else:
								records.append(TaskRecord.new())
								Game.start_game()
								Game.new_level()
						else:
							curr_task.levels.append(LevelRecord.new())
							Game.new_level()
					else:
						step = TaskSteps.ToMatch
						Game.roll()
				elif step == TaskSteps.ToMatch:
					if Game.matches > 0:
						auto_place_items()
						step = TaskSteps.GetResult
						Game.play()
				elif step == TaskSteps.GetResult:
					var his = Game.history
					var curr_level = records.back().levels.back()
					var curr_record = curr_level.matchings.back()
					curr_record.score = his.last_matching_score
					curr_record.combos = his.last_matching_combos
					curr_level.score += his.last_matching_score
					curr_level.combos += his.last_matching_combos
					curr_level.matchings.append(MatchingRecord.new())
					step = TaskSteps.ToRoll

func auto_place_items():
	if !Game.hand_ui.is_empty():
		var cx = Board.cx
		var cy = Board.cy
		var center = Vector2i(cx / 2, cy / 2)
		var item_uis = []
		for i in Game.hand_ui.get_ui_count():
			var ui = Game.hand_ui.get_ui(i)
			item_uis.append(ui)
		var one_less_places : Array[Array] = []
		for i in Gem.Type.Count - 1:
			one_less_places.append([])
		for y in cy:
			for x in cx:
				var c = Vector2i(x, y)
				for p in Game.patterns:
					for col in Gem.Type.Count - 1:
						var res : Array[Vector2i] = p.differ(c, col + 1)
						if !res.is_empty():
							one_less_places[col].append(res[0])
		SMath.remove_if(item_uis, func(ui):
			var item = ui.item
			if item.name.begins_with("Dye: "):
				var color = Gem.name_to_type(item.name.substr(5))
				var arr = one_less_places[color - 1]
				if !arr.is_empty():
					if Game.hand_ui.place_item(ui, SMath.pick_and_remove(arr)):
						return true
			elif item.name == "Color Palette":
				for arr in one_less_places:
					if !arr.is_empty():
						if Game.hand_ui.place_item(ui, SMath.pick_and_remove(arr)):
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
				if item.name == "C4" || item.name == "Chain Bomb" || item.name == "Lightning":
					return false
				if !central_activater_places.is_empty():
					var c = central_activater_places.front()
					if Game.hand_ui.place_item(ui, c):
						central_activater_places.pop_front()
						activater_places.erase(c)
						return true
			return false
		)
		SMath.remove_if(item_uis, func(ui):
			var item = ui.item
			if item.on_process.is_valid():
				if item.name == "C4" || item.name == "Chain Bomb":
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
						if Game.hand_ui.place_item(ui, c):
							return true
					elif item.name == "Chain Bomb":
						if !central_activater_places.is_empty():
							var c = central_activater_places.front()
							if Game.hand_ui.place_item(ui, c):
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
								if Game.hand_ui.place_item(ui, coord):
									central_activater_places.erase(coord)
									activater_places.erase(coord)
									return true
					else:
						if !central_activater_places.is_empty():
							var c = central_activater_places.back()
							if Game.hand_ui.place_item(ui, c):
								central_activater_places.pop_back()
								activater_places.erase(c)
								return true
			return false
		)
		SMath.remove_if(item_uis, func(ui):
			var item = ui.item
			if item.description.find("[b]Aura[/b]") != -1:
				if !aura_places.is_empty():
					if Game.hand_ui.place_item(ui, SMath.pick_and_remove(aura_places)):
						aura_places.pop_front()
						return true
			return false
		)
		SMath.remove_if(item_uis, func(ui):
			var item = ui.item
			if item.on_eliminate.is_valid():
				if item.name == "Rainbow" || item.name == "Fire":
					var c = activater_places[0]
					if Game.hand_ui.place_item(ui, c):
						activater_places.pop_front()
						central_activater_places.erase(c)
						return true
				else:
					if !central_activater_places.is_empty():
						var c = central_activater_places.front()
						if Game.hand_ui.place_item(ui, c):
							central_activater_places.pop_front()
							activater_places.erase(c)
							return true
			return false
		)

func _ready() -> void:
	timer.timeout.connect(time_out)
