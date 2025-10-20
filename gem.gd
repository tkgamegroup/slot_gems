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
const item_frames : SpriteFrames = preload("res://images/items.tres")

var id : int
var type : int = Type.None
var rune : int = Rune.None
var name : String
var category : String
var image_id : int
var price : int = 5
var power : int = 0
var base_score : int = 4
var bonus_score : int = 0
var base_mult : float = 0.0
var bonus_mult : float = 0.0
var gain_scaler : float = 1.0
var trigger : bool = false
var eliminated : bool = false
var active : bool = false
var coord : Vector2i = Vector2i(-1, -1)
var buffs : Array[Buff]
var extra : Dictionary

var on_active : Callable
var on_eliminate : Callable
var on_aura : Callable
var on_event : Callable

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
		Type.Red: return Color(0.83, 0.07, 0.09, 1.0)
		Type.Orange: return Color(1.0, 0.71, 0.16)
		Type.Green: return Color(0.61, 0.75, 0.25)
		Type.Blue: return Color(0.56, 0.87, 0.96)
		Type.Purple: return Color(0.88, 0.20, 0.80)
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
	var ret = ""
	ret += tr("gem_score")
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

func get_tooltip():
	var ret : Array[Pair] = []
	var title = ""
	var content = ""
	ret.append(Pair.new(get_tt_name(), get_description()))
	if name != "":
		content += tr("item_desc_" + name).format(extra)
		if power != 0:
			content = ("w_power: %d\n" % power) + content
		if extra.has("buff_ids"):
			content += "\n%d" % extra["buff_ids"].size()
		ret.append(Pair.new(tr("item_name_" + name), content))
	return ret

static var s_id : int = 0

func setup(n : String):
	id = s_id
	s_id += 1
	name = n
	if name == "Bomb":
		type = Type.None
		rune = Rune.None
		base_score = 0
		image_id = 8
		category = "Bomb"
		trigger = true
		price = 2
		power = 8
		extra["range"] = 1
		on_eliminate = func(coord : Vector2i, reason : int, source, tween : Tween):
			tween.tween_callback(func():
				Board.activate(self, HostType.Gem, 0, coord, reason, source)
			)
		on_active = func(effect_index : int, coord : Vector2i, tween : Tween, item_ui : AnimatedSprite2D):
			Board.effect_explode(Board.get_pos(coord), coord, extra["range"], power, tween, self)
