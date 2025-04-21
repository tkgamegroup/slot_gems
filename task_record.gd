extends Object

class_name TaskRecord

var levels : Array[LevelRecord]

func _init() -> void:
	levels.append(LevelRecord.new())
