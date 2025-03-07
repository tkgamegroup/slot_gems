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
	task_num = tasks
	task_type = type
	task_index = 0
	step = TaskSteps.ToRoll
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
						file.store_string("Max Matching Score: %d, Min Matching Score: %d\n" % [max_matching_score, min_matching_score])
						file.store_string("Max Matching Combos: %d, Min Matching Combos: %d\n" % [max_matching_combos, min_matching_combos])
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
					var cx = Game.board.cx
					var cy = Game.board.cy
					for i in Game.hand.get_item_count():
						var ui = Game.hand.get_item(i)
						var item = ui.item
						var used = false
						if item.name.begins_with("Dye: "):
							var color = Gem.name_to_type(item.name.substr(5))
							for y in cy:
								for x in cx:
									var c = Vector2i(x, y)
									for p in Game.patterns:
										var res : Array[Vector2i] = p.differ(Game.board, c, color)
										if !res.is_empty() && Game.hand.use_item(ui, res[0]):
											used = true
											break
									if used:
										break
								if used:
									break
						elif item.on_process.is_valid():
							for y in cy:
								for x in cx:
									var c = Vector2i(x, y)
									for p in Game.patterns:
										var res : Array[Vector2i] = p.match_with(Game.board, c)
										for cc in res:
											if Game.hand.use_item(ui, cc):
												used = true
												break
										if used:
											break
									if used:
										break
								if used:
									break
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
