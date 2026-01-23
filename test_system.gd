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
	ToMatch,
	GetResult,
	ToShop
}

var filename : String
var saving : String
var mode : int
var task_count : int
var task_round_count : int
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

func write_round(r : RoundRecord):
	write("Round Score: %d, Round Combos: %d, Round Relic Effects: %d" % [r.score, r.combos, r.relic_effects])

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
	var magenta_num = 0
	var wild_num = 0
	for g in App.gems:
		match g.type:
			Gem.ColorRed: red_num += 1
			Gem.ColorOrange: orange_num += 1
			Gem.ColorGreen: green_num += 1
			Gem.ColorBlue: blue_num += 1
			Gem.ColorMagenta: magenta_num += 1
			Gem.ColorWild: wild_num += 1
	write("Red: %d, Orange: %d, Green: %d, Blue: %d, Magenta: %d, Wild: %d" % [red_num, orange_num, green_num, blue_num, magenta_num, wild_num])
	var items_str = ""
	for i in App.items:
		if !items_str.is_empty():
			items_str += ", "
		items_str += i.name
	write("Items: %s" % items_str)
	var patterns_str = ""
	for p in App.patterns:
		if !patterns_str.is_empty():
			patterns_str += ", "
		patterns_str += p.name
	write("Patterns: %s" % patterns_str)
	var relics_str = ""
	for r in App.relics:
		if !relics_str.is_empty():
			relics_str += ", "
		relics_str += r.name
	write("Relics: %s" % relics_str)
	write("Rolls: %d" % App.rolls_per_round)
	write("Matches: %d" % App.plays_per_round)
	end_write()

func has_matched_pattern():
	for y in Board.cy:
		for x in Board.cx:
			for p in App.patterns:
				var res : Array[Vector2i] = p.match_with(Vector2i(x, y))
				if !res.is_empty():
					return true
	return false

func start_game():
	App.start_game(saving)

func start_test(_mode : int, _round_count : int, _task_count : int, fn : String = "", _saving : String = "", invincible : bool = true, _enable_shopping : bool = false):
	AudioServer.set_bus_volume_db(SSound.se_bus_index, linear_to_db(0))
	App.performance_mode = true
	App.base_speed = 4.0
	App.speed = 1.0 / App.base_speed
	
	mode = _mode
	task_count = _task_count
	task_round_count = _round_count
	task_index = 0
	step = TaskSteps.ToMatch
	
	records.append(TaskRecord.new())
	
	if fn.is_empty():
		filename = "res://test_%s.txt" % SUtils.get_formated_datetime()
		FileAccess.open(filename, FileAccess.WRITE)
	elif fn == "console":
		fn = ""
	else:
		filename = fn
	
	saving = _saving
	App.invincible = invincible
	enable_shopping = _enable_shopping
	
	if App.title_ui.visible:
		App.title_ui.hide()
	start_game()
	
	write_game_status()
	timer.start()
	testing = true
	label.show()

func time_out():
	if App.stage == App.Stage.Deploy || App.stage >= App.Stage.Settlement:
		if step == TaskSteps.ToMatch:
			if App.settlement_ui.visible || App.game_over_ui.visible:
				var curr_task = records.back()
				if curr_task.rounds.size() == task_round_count || App.game_over_ui.visible:
					for r in curr_task.rounds:
						r.matchings.pop_back()
					
					if mode == Mode.AverageScore:
						begin_write()
						write("======Task %d======" % task_index)
						for i in curr_task.rounds.size():
							var r = curr_task.rounds[i]
							write("====Round %d====" % (i + 1))
							write_round(r)
							for j in r.matchings.size():
								write_matching(j, r.matchings[j])
						write("======Statics For %d Task(s)======" % (task_index + 1))
						var head_str = ""
						for i in task_round_count:
							head_str += "\tRound %d" % (i + 1)
						write(head_str)
						var max_matching_num = 0
						var avg_line = "Avg\t"
						for i in task_round_count:
							var score = 0
							var combos = 0
							var relic_effects = 0
							for rc in records:
								var r = rc.rounds[i]
								max_matching_num = max(max_matching_num, r.matchings.size())
								score += r.score
								combos += r.combos
								relic_effects += r.relic_effects
							avg_line += "%.1f,%.2f,%.2f\t" % [float(score) / records.size(), float(combos) / records.size(), float(relic_effects) / records.size()]
						write(avg_line)
						for j in max_matching_num:
							var line = "Matching %d\t" % j
							for i in task_round_count:
								var score = 0
								var combos = 0
								var relic_effects = 0
								for rc in records:
									if rc.rounds.size() <= i:
										continue
									var r = rc.rounds[i]
									if r.matchings.size() <= j:
										continue
									var m = r.matchings[j]
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
						write("======Round %d======" % curr_task.rounds.size())
						var r = curr_task.rounds.back()
						write_round(r)
						for j in r.matchings.size():
							write_matching(j, r.matchings[j])
						end_write()
					
					curr_task.rounds.append(RoundRecord.new())
					if !enable_shopping:
						App.next_round()
					else:
						step = TaskSteps.ToShop
						App.settlement_ui.exit()
				
				App.settlement_ui.hide()
				App.game_over_ui.hide()
			
			auto_swap_gems()
			step = TaskSteps.GetResult
			App.play()
		elif step == TaskSteps.GetResult:
			var his = App.history
			var curr_round : RoundRecord = records.back().rounds.back()
			var curr_record : MatchingRecord = curr_round.matchings.back()
			curr_record.score = his.last_matching_score
			curr_record.combos = his.last_matching_combos
			curr_record.relic_effects = his.relic_effects
			curr_record.actives = his.last_matching_actives
			curr_round.score += his.last_matching_score
			curr_round.combos += his.last_matching_combos
			curr_round.relic_effects += his.relic_effects
			curr_round.actives += his.last_matching_actives
			curr_round.matchings.append(MatchingRecord.new())
			step = TaskSteps.ToMatch
			if his.last_matching_score == 0 && !App.settlement_ui.visible:
				App.lose()
		elif step == TaskSteps.ToShop:
			if App.shop_ui.visible:
				for i in 5:
					App.shop_ui.buy_randomly()
				App.shop_ui.exit()
				step = TaskSteps.ToMatch
				write_game_status()

func get_missing_one_places() -> Dictionary[int, Array]:
	var ret : Dictionary[int, Array]
	for y in Board.cy:
		for x in Board.cx:
			var c = Vector2i(x, y)
			for p in App.patterns:
				for i in Gem.ColorCount:
					var res : Array[Vector2i] = p.match_with(c, Gem.ColorFirst + i)
					if !res.is_empty():
						ret[Gem.ColorFirst + i].append(res[0])
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
			return a.get_score() > b.get_score()
		)
		for g in grabs:
			if g.type == Gem.ColorRed:
				var arr = missing_one_places[Gem.ColorRed]
				if !arr.is_empty():
					if App.swaps > 0:
						App.swaps -= 1
						Hand.erase(Hand.find(g))
						Hand.swap(SMath.pick_and_remove(arr), g, true)
						changed = true
			elif g.type == Gem.ColorOrange:
				var arr = missing_one_places[Gem.ColorOrange]
				if !arr.is_empty():
					if App.swaps > 0:
						App.swaps -= 1
						Hand.erase(Hand.find(g))
						Hand.swap(SMath.pick_and_remove(arr), g, true)
						changed = true
			elif g.type == Gem.ColorGreen:
				var arr = missing_one_places[Gem.ColorGreen]
				if !arr.is_empty():
					if App.swaps > 0:
						App.swaps -= 1
						Hand.erase(Hand.find(g))
						Hand.swap(SMath.pick_and_remove(arr), g, true)
						changed = true
			elif g.type == Gem.ColorBlue:
				var arr = missing_one_places[Gem.ColorBlue]
				if !arr.is_empty():
					if App.swaps > 0:
						App.swaps -= 1
						Hand.erase(Hand.find(g))
						Hand.swap(SMath.pick_and_remove(arr), g, true)
						changed = true
			elif g.type == Gem.ColorMagenta:
				var arr = missing_one_places[Gem.ColorMagenta]
				if !arr.is_empty():
					if App.swaps > 0:
						App.swaps -= 1
						Hand.erase(Hand.find(g))
						Hand.swap(SMath.pick_and_remove(arr), g, true)
						changed = true

func _ready() -> void:
	timer.timeout.connect(time_out)
