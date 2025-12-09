extends Object

class_name Cell

enum State
{
	Normal,
	Consumed
}

var coord : Vector2i
var gem : Gem = null
var state : int = 0
var pinned : bool = false
var frozen : bool = false
var nullified : bool = false
var in_mist : bool = false
var buffs : Array[Buff]
var event_listeners : Array[Hook]

func is_unmovable():
	return pinned || frozen || (gem && gem.active)
