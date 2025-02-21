extends Object

class_name History

var max_roll_score : int
var last_roll_score : int
var max_combos : int
var last_roll_combos : int
var rolls : int

func init():
	max_roll_score = 0
	last_roll_score = Game.score
	rolls = 0

func update():
	var roll_score = Game.score - last_roll_score
	if roll_score > max_roll_score:
		max_roll_score = roll_score
	last_roll_score = Game.score
	max_combos = max(max_combos, Game.combos)
	last_roll_combos = Game.combos
