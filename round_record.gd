extends Object

class_name RoundRecord

var score : int = 0
var combos : int = 0
var relic_effects : int = 0
var actives : int = 0
var matchings : Array[MatchingRecord]

func _init() -> void:
	matchings.append(MatchingRecord.new())
