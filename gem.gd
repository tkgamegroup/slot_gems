extends Object

class_name Gem

enum Type
{
	None,
	Red,
	Orange,
	Green,
	Blue,
	Purple,
	Colorless,
	Wild,
	Unknow,
	Count = 5
}

enum Rune
{
	None,
	Destroy,
	Wisdom,
	Grow,
	Omni,
	Unknow,
	Count = 3
}

const gem_frames : SpriteFrames = preload("res://images/gems.tres")
const rune_frames : SpriteFrames = preload("res://images/runes.tres")

var type : int = Type.None
var rune : int = Rune.None

var base_score : int = 4
var bonus_score : int = 0:
	set(v):
		bonus_score = v
		var a = 1
var base_mult : float = 0.0
var bonus_mult : float = 0.0
var gain_scaler : float = 1.0
var coord : Vector2i = Vector2i(-1, -1)
var buffs : Array[Buff]
var bound_item : Item = null

static func type_name(t : int):
	match t:
		Type.None: return "None"
		Type.Red: return "Red"
		Type.Orange: return "Orange"
		Type.Green: return "Green"
		Type.Blue: return "Blue"
		Type.Purple: return "Purple"
		Type.Colorless: return "Colorless"
		Type.Wild: return "Wild"
	return ""

static func type_display_name(t : int):
	match t:
		Type.None: return Game.tr("gem_none")
		Type.Red: return Game.tr("gem_red")
		Type.Orange: return Game.tr("gem_orange")
		Type.Green: return Game.tr("gem_green")
		Type.Blue: return Game.tr("gem_blue")
		Type.Purple: return Game.tr("gem_purple")
		Type.Colorless: return "w_colorless"
		Type.Wild: return "w_wild"
	return ""

static func name_to_type(s : String):
	match s:
		"None": return Type.None
		"Red": return Type.Red
		"Orange": return Type.Orange
		"Green": return Type.Green
		"Blue": return Type.Blue
		"Purple": return Type.Purple
		"Colorless": return Type.Colorless
		"Wild": return Type.Wild

static func type_color(t : int) -> Color:
	match t:
		Type.None: return Color(0, 0, 0, 0)
		Type.Red: return Color(214.0 / 255.0, 19.0 / 255.0, 25.0 / 255.0)
		Type.Orange: return Color(255.0 / 255.0, 186.0 / 255.0, 7.0 / 255.0)
		Type.Green: return Color(157.0 / 255.0, 192.0 / 255.0, 64.0 / 255.0)
		Type.Blue: return Color(143.0 / 255.0, 223.0 / 255.0, 246.0 / 255.0)
		Type.Purple: return Color(226.0 / 255.0, 53.0 / 255.0, 206.0 / 255.0)
	return Color.WHITE

static func type_img(t : int):
	match t:
		Type.Red: return "res://images/red.png"
		Type.Orange: return "res://images/orange.png"
		Type.Green: return "res://images/green.png"
		Type.Blue: return "res://images/blue.png"
		Type.Purple: return "res://images/purple.png"
		Type.Colorless: return "res://images/colorless.png"
	return ""

static func rune_name(r : int):
	match r:
		Rune.Destroy: return "Destroy"
		Rune.Wisdom: return "Wisdom"
		Rune.Grow: return "Grow"
		Rune.Omni: return "Omni"
	return "None"

static func rune_display_name(r : int):
	match r:
		Rune.Destroy: return Game.tr("rune_destroy")
		Rune.Wisdom: return Game.tr("rune_wisdom")
		Rune.Grow: return Game.tr("rune_grow")
		Rune.Omni: return "w_omni"
	return "None"

static func rune_icon(r : int):
	match r:
		Rune.Destroy: return "res://images/rune_destroy.png"
		Rune.Wisdom: return "res://images/rune_wisdom.png"
		Rune.Grow: return "res://images/rune_grow.png"
		Rune.Omni: return "res://images/rune_omni.png"
	return ""

func get_base_score():
	var ret = base_score
	match type:
		Type.Red: ret += Game.modifiers["red_bouns_i"]
		Type.Orange: ret += Game.modifiers["orange_bouns_i"]
		Type.Green: ret += Game.modifiers["green_bouns_i"]
		Type.Blue: ret += Game.modifiers["blue_bouns_i"]
		Type.Purple: ret += Game.modifiers["purple_bouns_i"]
		Type.Wild: ret += Game.modifiers["red_bouns_i"] + Game.modifiers["orange_bouns_i"] + Game.modifiers["green_bouns_i"] + Game.modifiers["blue_bouns_i"] + Game.modifiers["purple_bouns_i"]
	return ret

func get_score():
	return int(get_base_score() * gain_scaler) + int(bonus_score * gain_scaler)

func get_mult():
	return (base_mult * gain_scaler) + (bonus_mult * gain_scaler)

func get_rank():
	return type * 0xffff + rune * 0xff + (100.0 / max(base_score + bonus_score + base_mult, 0.1))

func get_tt_name():
	var ret = ""
	if coord.x != -1 && coord.y != -1:
		var cell = Board.get_cell(coord)
		if cell.in_mist:
			ret = "%s (%s)" % [tr("gem_unknown"), tr("rune_unknown")]
			return ret
	var color_change = Buff.find_typed(self, Buff.Type.ChangeColor)
	if color_change && color_change.duration != Buff.Duration.Eternal:
		ret = "[color=GRAY][s]%s[/s][/color] %s" % [type_display_name(color_change.data["original_color_i"]), type_display_name(type)]
	else:
		ret = type_display_name(type)
	if rune != Rune.None:
		ret += " (%s)" % rune_display_name(rune)
	return ret

func get_description():
	var ret = tr("gem_score")
	ret += "%d" % int(get_base_score() * gain_scaler)
	if bonus_score > 0:
		ret += "+%d" % int(bonus_score * gain_scaler)
	elif bonus_score < 0:
		ret += "%d" % bonus_score
	if base_mult != 0.0 || bonus_mult != 0.0:
		ret += "\n" + tr("gem_mult")
		ret += "%.2f" % (base_mult * gain_scaler)
		if bonus_mult > 0:
			ret += "+%.2f" % (bonus_mult * gain_scaler)
		elif bonus_mult < 0:
			ret += "%.2f" % (bonus_mult * gain_scaler)
	for enchant in Buff.find_all_typed(self, Buff.Type.Enchant):
		ret += "\n[color=GREEN]%s[/color]" % (tr("gem_enchant") % tr(enchant.data["type"]))
	return ret

func get_tooltip(with_bound : bool = true):
	var ret : Array[Pair] = []
	ret.append(Pair.new(get_tt_name(), get_description()))
	if with_bound && bound_item:
		ret.append_array(bound_item.get_tooltip())
	return ret
