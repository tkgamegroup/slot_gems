extends Object

class_name Cell

enum State
{
	Normal,
	Consumed,
	Burning
}

enum Event
{
	Eliminated
}

var coord : Vector2i
var gem : Gem = null
var item : Item = null
var state : int = 0
var pinned : bool = false
var frozen : bool = false
var user_data = null
var event_listeners : Array[Callable]
