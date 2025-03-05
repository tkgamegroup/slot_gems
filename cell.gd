extends Object

class_name Cell

enum State
{
	Normal,
	Consumed,
	Burning
}

var gem : Gem = null
var item : Item = null
var state : int = 0
var pined : bool = false
var index : int
var user_data = null
