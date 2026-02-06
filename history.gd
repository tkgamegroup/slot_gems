extends Object

class_name History

var max_matching_score : int
var last_matching_score : int
var previous_score : int
var max_combos : int
var last_matching_combos : int

func init():
	max_matching_score = 0
	last_matching_score = 0
	previous_score = G.score
	max_combos = 0
	last_matching_combos = 0

func round_reset():
	last_matching_score = 0
	previous_score = 0

func update():
	last_matching_score = G.score - previous_score
	if last_matching_score > max_matching_score:
		max_matching_score = last_matching_score
	previous_score = G.score
	max_combos = max(max_combos, G.combos)
	last_matching_combos = G.combos
