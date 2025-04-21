extends Object

class_name LevelRecord

var score : int = 0
var combos : int = 0
var matchings : Array[MatchingRecord]

func _init() -> void:
	matchings.append(MatchingRecord.new())
