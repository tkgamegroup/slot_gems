extends Object

class_name History

var max_roll : int
var last_roll_score : int
var max_combos : int
var rolls : int

func init():
	max_roll = 0
	last_roll_score = Game.score
	rolls = 0

func update_max_roll():
	var v = Game.score - last_roll_score
	if v > max_roll:
		max_roll = v
	last_roll_score = Game.score

func update_max_combos():
	max_combos = max(max_combos, Game.combos)
