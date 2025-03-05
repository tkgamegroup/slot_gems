extends Node

@onready var timer : Timer = $/root/Main/TestTimer

const result_fn : String = "res://test_result.txt"

enum TaskType
{
	AvgScore
}

enum Stage
{
	GameIdle,
	GameRolling
}

var task_num : int
var task_type : int
var task_index : int
var stage : int
var total_scores : int
var total_combos : int

func start_test_avg_score(times : int):
	task_num = times
	task_type = TaskType.AvgScore
	task_index = 0
	stage = Stage.GameIdle
	total_scores = 0
	total_combos = 0
	FileAccess.open(result_fn, FileAccess.WRITE)
	timer.start()

func write_to_file(line : String):
	var file = FileAccess.open(result_fn, FileAccess.READ_WRITE)
	file.seek_end()
	file.store_string(line)

func time_out():
	match task_type:
		TaskType.AvgScore:
			match stage:
				Stage.GameIdle:
					Game.roll()
					stage = Stage.GameRolling
				Stage.GameRolling:
					if !Game.game_ui.roll_button.disabled:
						write_to_file("%d\t%d\t%d\n" % [task_index, Game.history.last_roll_score, Game.history.last_roll_combos])
						total_scores += Game.history.last_roll_score
						total_combos += Game.history.last_roll_combos
						Game.score = 0
						Game.setup()
						stage = Stage.GameIdle
						task_index += 1
						if task_index == task_num:
							write_to_file("--------\n%.1f  %.1f" % [float(total_scores) / task_num, float(total_combos) / task_num])
							timer.stop()

func _ready() -> void:
	timer.timeout.connect(time_out)
