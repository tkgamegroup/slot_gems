extends RefCounted

class_name Cell

var coord : Vector2i
var gem : Gem = null
var consumed : bool = false
var pinned : bool = false
var frozen : int = 0
var nullified : bool = false
var in_mist : bool = false
var floating : bool = false
var buffs : Array[Buff]
var event_listeners : Array[Hook]

func is_unmovable():
	return pinned || frozen > 0 || floating || (gem && gem.active)
