extends Object

class_name History

var max_matching_score : int
var last_matching_score : int
var previous_score : int
var max_combos : int
var last_matching_combos : int
var max_relic_effects : int
var last_matching_relic_effects : int
var relic_effects : int
var max_actives : int
var last_matching_actives : int
var actives : int
var rolls : int

func init():
	max_matching_score = 0
	last_matching_score = 0
	previous_score = App.score
	max_combos = 0
	last_matching_combos = 0
	rolls = 0

func round_reset():
	last_matching_score = 0
	previous_score = 0
	relic_effects = 0
	actives = 0

func update():
	last_matching_score = App.score - previous_score
	if last_matching_score > max_matching_score:
		max_matching_score = last_matching_score
	previous_score = App.score
	max_combos = max(max_combos, App.combos)
	last_matching_combos = App.combos
	max_relic_effects = max(max_relic_effects, relic_effects)
	last_matching_relic_effects = relic_effects
	max_actives = max(max_actives, actives)
	last_matching_actives = actives
