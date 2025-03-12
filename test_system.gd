extends Node

@onready var timer : Timer = $/root/Main/TestTimer

const result_fn : String = "res://test_result.txt"
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

var task_num : int
var task_type : int
var task_index : int
var step : int
var level_score : int
var level_combos : int
var matching_results : Array[Pair]
var max_matching_score : int
var min_matching_score : int
var max_matching_combos : int
var min_matching_combos : int
var total_score : int
var total_combos : int

func new_test(tasks : int, type : int):
	AudioServer.set_bus_volume_db(SSound.sfx_bus_index, linear_to_db(0))
	Game.base_animation_speed = 0.25
	Game.animation_speed = Game.base_animation_speed
	
	task_num = tasks
	task_type = type
	task_index = 0
	if Game.game_ui.play_button.disabled:
		step = TaskSteps.ToRoll
	else:
		step = TaskSteps.ToMatch
	level_score = 0
	level_combos = 0
	matching_results.clear()
	max_matching_score = 0
	min_matching_score = 1000000
	max_matching_combos = 0
	min_matching_combos = 1000000
	total_score = 0
	total_combos = 0
	var datetime = Time.get_datetime_string_from_system(false, true)
	datetime = datetime.replace("-", "_")
	datetime = datetime.replace(":", "_")
	datetime = datetime.replace(" ", "_")
	filename = "res://test_%s.txt" % datetime
	var file = FileAccess.open(filename, FileAccess.WRITE)
	var cx = Game.board.cx
	var cy = Game.board.cy
	file.store_string("Board Size: %dx%d(%d cells)\n" % [cx, cy, cx * cy])
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
	file.store_string("Red: %d, Orange: %d, Green: %d, Blue: %d, Pink: %d, Wild: %d\n" % [red_num, orange_num, green_num, blue_num, pink_num, wild_num])
	var items = ""
	for i in Game.items:
		if !items.is_empty():
			items += ", "
		items += i.name
	file.store_string("Items: %s\n" % items)
	file.store_string("Rolls: %d\n" % Game.rolls_per_level)
	file.close()
	timer.start()

func start_test_avg_score(times : int):
	new_test(times, TaskType.AvgScore)

func auto_place_items():
	if Game.hand.get_item_count() > 0:
		var bd = Game.board
		var cx = Game.board.cx
		var cy = Game.board.cy
		var center = Vector2i(cx / 2, cy / 2)
		var item_uis = []
		for i in Game.hand.get_item_count():
			var ui = Game.hand.get_item(i)
			item_uis.append(ui)
		var one_less_places : Array[Array] = []
		for i in Gem.Type.Count - 1:
			one_less_places.append([])
		for y in cy:
			for x in cx:
				var c = Vector2i(x, y)
				for p in Game.patterns:
					for col in Gem.Type.Count - 1:
						var res : Array[Vector2i] = p.differ(bd, c, col + 1)
						if !res.is_empty():
							one_less_places[col].append(res[0])
		SMath.remove_if(item_uis, func(ui):
			var item = ui.item
			if item.name.begins_with("Dye: "):
				var color = Gem.name_to_type(item.name.substr(5))
				var arr = one_less_places[color - 1]
				if !arr.is_empty():
					if Game.hand.use_item(ui, SMath.pick_and_remove(arr)):
						return true
			elif item.name == "Color Palette":
				for arr in one_less_places:
					if !arr.is_empty():
						if Game.hand.use_item(ui, SMath.pick_and_remove(arr)):
							return true
			return false
		)
		var activater_places : Array[Vector2i] = []
		var central_activater_places : Array[Vector2i] = []
		for y in cy:
			for x in cx:
				var c = Vector2i(x, y)
				for p in Game.patterns:
					var res : Array[Vector2i] = p.match_with(bd, c)
					for cc in res:
						activater_places.append(cc)
						central_activater_places.append(cc)
		central_activater_places.sort_custom(func(c1, c2):
			return bd.offset_distance(c1, center) < bd.offset_distance(c2, center)
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
				if !central_activater_places.is_empty():
					var c = central_activater_places[0]
					if Game.hand.use_item(ui, c):
						central_activater_places.remove_at(0)
						activater_places.erase(c)
						return true
			return false
		)
		SMath.remove_if(item_uis, func(ui):
			var item = ui.item
			if item.on_aura.is_valid():
				if !aura_places.is_empty():
					if Game.hand.use_item(ui, SMath.pick_and_remove(aura_places)):
						aura_places.remove_at(0)
						return true
			return false
		)
		SMath.remove_if(item_uis, func(ui):
			var item = ui.item
			if item.on_eliminate.is_valid():
				if item.name == "Rainbow" || item.name == "Fire":
					var c = activater_places[0]
					if Game.hand.use_item(ui, c):
						activater_places.remove_at(0)
						central_activater_places.erase(c)
						return true
				else:
					if !central_activater_places.is_empty():
						var c = central_activater_places[0]
						if Game.hand.use_item(ui, c):
							central_activater_places.remove_at(0)
							activater_places.erase(c)
							return true
			return false
		)

func time_out():
	match task_type:
		TaskType.AvgScore:
			if Game.stage == Game.Stage.Deploy:
				if step == TaskSteps.ToRoll:
					if Game.rolls == 0:
						total_score += level_score
						total_combos += level_combos
						var his = Game.history
						var file = FileAccess.open(filename, FileAccess.READ_WRITE)
						file.seek_end()
						file.store_string("===Task %d===\n" % task_index)
						file.store_string("Level Score: %d, Level Combos: %d\n" % [level_score, level_combos])
						file.store_string("Avg Matching Score: %.1f, Avg Matching Combos: %.2f\n" % [float(level_score) / matching_results.size(), float(level_combos) / matching_results.size()])
						for i in matching_results.size():
							var p = matching_results[i]
							file.store_string("matching %d: %d score, %d combos\n" % [i, p.first, p.second])
						file.store_string("================\n")
						file.store_string("Avg Level Score: %.1f, Avg Level Combos: %.2f\n" % [float(total_score) / (task_index + 1), float(total_combos) / (task_index + 1)])
						file.store_string("Min, Max Matching Score: %d, %d\n" % [min_matching_score, max_matching_score])
						file.store_string("Min, Max Matching Combos: %d, %d\n" % [min_matching_combos, max_matching_combos])
						file.close()
						matching_results.clear()
						level_score = 0
						level_combos = 0
						Game.new_level(true)
						for p in Game.patterns:
							p.reset()
						task_index += 1
						if task_index == task_num:
							timer.stop()
					else:
						step = TaskSteps.ToMatch
						Game.roll()
				elif step == TaskSteps.ToMatch:
					auto_place_items()
					step = TaskSteps.GetResult
					Game.play()
				elif step == TaskSteps.GetResult:
					var his = Game.history
					max_matching_score = max(max_matching_score, his.last_matching_score)
					min_matching_score = min(min_matching_score, his.last_matching_score)
					max_matching_combos = max(max_matching_combos, his.last_matching_combos)
					min_matching_combos = min(min_matching_combos, his.last_matching_combos)
					matching_results.append(Pair.new(his.last_matching_score, his.last_matching_combos))
					level_score += his.last_matching_score
					level_combos += his.last_matching_combos
					step = TaskSteps.ToRoll

func _ready() -> void:
	timer.timeout.connect(time_out)
