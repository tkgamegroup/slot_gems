extends Object

class_name Gem

enum Type
{
	None,
	Red,
	Orange,
	Green,
	Blue,
	Pink,
	Wild,
	Count = 6
}

enum Rune
{
	None,
	Star,
	Circle,
	Diamond,
	Count = 3
}

const gem_frames : SpriteFrames = preload("res://images/gems.tres")
const rune_frames : SpriteFrames = preload("res://images/runes.tres")

var type : int = Type.None
var rune : int = Rune.None

var base_score : int = 1
var bonus_score : int = 0
var coord : Vector2i = Vector2i(-1, -1)
var buffs : Array[Buff]

var extra = {}

static func type_name(t : int):
	match t:
		Type.None: return "None"
		Type.Red: return "Red"
		Type.Orange: return "Orange"
		Type.Green: return "Green"
		Type.Blue: return "Blue"
		Type.Pink: return "Pink"
		Type.Wild: return "Wild"
	return ""

static func name_to_type(s : String):
	match s:
		"None": return Type.None
		"Red": return Type.Red
		"Orange": return Type.Orange
		"Green": return Type.Green
		"Blue": return Type.Blue
		"Pink": return Type.Pink
		"Wild": return Type.Wild

static func type_color(t : int) -> Color:
	match t:
		Type.None: return Color(0, 0, 0, 0)
		Type.Red: return Color(214.0 / 255.0, 19.0 / 255.0, 25.0 / 255.0)
		Type.Orange: return Color(255.0 / 255.0, 186.0 / 255.0, 7.0 / 255.0)
		Type.Green: return Color(157.0 / 255.0, 192.0 / 255.0, 64.0 / 255.0)
		Type.Blue: return Color(143.0 / 255.0, 223.0 / 255.0, 246.0 / 255.0)
		Type.Pink: return Color(230.0 / 255.0, 53.0 / 255.0, 108.0 / 255.0)
	return Color.WHITE

static func type_img(t : int):
	match t:
		Type.Red: return "res://images/red.png"
		Type.Orange: return "res://images/orange.png"
		Type.Green: return "res://images/green.png"
		Type.Blue: return "res://images/blue.png"
		Type.Pink: return "res://images/pink.png"
	return ""

static func rune_name(r : int):
	match r:
		Rune.Star: return "Star"
		Rune.Circle: return "Circle"
		Rune.Diamond: return "Diamond"
	return "None"

static func rune_icon(r : int):
	match r:
		Rune.Star: return "res://images/rune_star.png"
		Rune.Circle: return "res://images/rune_circle.png"
		Rune.Diamond: return "res://images/rune_diamond.png"
	return ""

func get_base_score():
	var ret = base_score
	ret += Game.gem_bouns_scores[type - 1]
	return ret

func get_name():
	var b = Buff.find_typed(self, Buff.Type.ChangeColor)
	if b:
		return "[color=GRAY][s]%s[/s][/color] %s" % [type_name(b.data["original_color"]), type_name(type)]
	return type_name(type)

func get_description():
	return "Rune: %s\nScore: %d%s" % [rune_name(rune), get_base_score(), ("+%d" % bonus_score) if bonus_score > 0 else ""]

func get_tooltip():
	var ret : Array[Pair] = []
	var desc = get_description()
	ret.append(Pair.new(get_name(), desc))
	if type == Type.Wild:
		ret.append(Pair.new("#Wild", "Can match with any color."))
	return ret
