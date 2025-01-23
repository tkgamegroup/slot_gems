extends Object

class_name Cell

enum GemState
{
	Normal,
	Consumed,
	Burning
}

enum State
{
	Normal,
	Pined
}

var gem : int = 0
var gem_state : int = 0
var state : int = 0
var item : Item = null
var index : int
var user_data
