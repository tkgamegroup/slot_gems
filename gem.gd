extends Object

class_name Gem

enum
{
	None = 0,
	Unknow,
	ColorRed,
	ColorOrange,
	ColorGreen,
	ColorBlue,
	ColorMagenta,
	ColorWild,
	ColorAny,
	Runewave,
	RunePalm,
	RuneStarfish,
	RuneOmni,
	RuneAny,
	ColorCount = 5,
	RuneCount = 5
}

const gem_frames : SpriteFrames = preload("res://images/gems.tres")
const rune_frames : SpriteFrames = preload("res://images/runes.tres")
const item_frames : SpriteFrames = preload("res://images/items.tres")

var id : int
var type : int = None
var rune : int = None
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
		None: return "None"
		ColorRed: return "Red"
		ColorOrange: return "Orange"
		ColorGreen: return "Green"
		ColorBlue: return "Blue"
		ColorMagenta: return "Magenta"
		ColorWild: return "Wild"
		ColorAny: return "Any"
	return ""

static func type_display_name(t : int):
	match t:
		None: return App.tr("gem_none")
		ColorRed: return App.tr("gem_red")
		ColorOrange: return App.tr("gem_orange")
		ColorGreen: return App.tr("gem_green")
		ColorBlue: return App.tr("gem_blue")
		ColorMagenta: return App.tr("gem_magenta")
		ColorWild: return "w_wild"
		ColorAny: return App.tr("gem_any")
	return ""

static func name_to_type(s : String):
	match s:
		"None": return None
		"Red": return ColorRed
		"Orange": return ColorOrange
		"Green": return ColorGreen
		"Blue": return ColorBlue
		"Magenta": return ColorMagenta
		"Wild": return ColorWild
		"Any": return ColorAny

static func type_color(t : int) -> Color:
	match t:
		None: return Color(0, 0, 0, 0)
		ColorRed: return Color(0.83, 0.07, 0.09, 1.0)
		ColorOrange: return Color(1.0, 0.71, 0.16)
		ColorGreen: return Color(0.61, 0.75, 0.25)
		ColorBlue: return Color(0.56, 0.87, 0.96)
		ColorMagenta: return Color(0.88, 0.20, 0.80)
	return Color.WHITE

static func type_img(t : int):
	match t:
		None: return "res://images/colorless.png"
		ColorRed: return "res://images/red.png"
		ColorOrange: return "res://images/orange.png"
		ColorGreen: return "res://images/green.png"
		ColorBlue: return "res://images/blue.png"
		ColorMagenta: return "res://images/magenta.png"
	return ""

static func rune_name(r : int):
	match r:
		Runewave: return "wave"
		RunePalm: return "Palm"
		RuneStarfish: return "Starfish"
		RuneOmni: return "Omni"
		RuneAny: return "Any"
	return "None"

static func rune_display_name(r : int):
	match r:
		Runewave: return App.tr("rune_wave")
		RunePalm: return App.tr("rune_palm")
		RuneStarfish: return App.tr("rune_starfish")
		RuneOmni: return "w_omni"
		RuneAny: return App.tr("rune_any")
	return "None"

static func rune_icon(r : int):
	match r:
		Runewave: return "res://images/rune_wave.png"
		RunePalm: return "res://images/rune_palm.png"
		RuneStarfish: return "res://images/rune_starfish.png"
		RuneOmni: return "res://images/rune_omni.png"
	return ""

func get_base_score():
	var ret = base_score
	match type:
		ColorRed: ret += App.modifiers["red_bouns_i"]
		ColorOrange: ret += App.modifiers["orange_bouns_i"]
		ColorGreen: ret += App.modifiers["green_bouns_i"]
		ColorBlue: ret += App.modifiers["blue_bouns_i"]
		ColorMagenta: ret += App.modifiers["magenta_bouns_i"]
		ColorWild: ret += App.modifiers["red_bouns_i"] + App.modifiers["orange_bouns_i"] + App.modifiers["green_bouns_i"] + App.modifiers["blue_bouns_i"] + App.modifiers["magenta_bouns_i"]
	return ret

func get_score():
	return int(get_base_score() * gain_scaler) + int(bonus_score * gain_scaler)

func get_mult():
	return (base_mult * gain_scaler) + (bonus_mult * gain_scaler)

func get_rank():
	return type * 0xffff + rune * 0xff + (100.0 / max(base_score + bonus_score + base_mult, 0.1))

func get_tooltip():
	var ret : Array[Pair] = []
	var title = ""
	var content = ""
	var in_mist = false
	if coord.x != -1 && coord.y != -1:
		var cell = Board.get_cell(coord)
		in_mist = cell.in_mist
	if name == "":
		title = tr("gem")
	else:
		title = tr("item_name_" + name)
	var basics = ""
	if type != None:
		var color_change = Buff.find_typed(self, Buff.Type.ChangeColor)
		if color_change && color_change.duration != Buff.Duration.Eternal:
			basics += "[color=GRAY][s]%s[/s][/color] %s" % [type_display_name(color_change.data["original_color_i"]), type_display_name(type)]
		else:
			basics += type_display_name(type)
	if rune != None:
		if !basics.is_empty():
			basics += ", "
		basics += rune_display_name(rune)
	if !basics.is_empty():
		content += basics + "\n"
	content += tr("gem_score") + ("%d" % int(get_base_score() * gain_scaler))
	if bonus_score > 0:
		content += "+%d" % int(bonus_score * gain_scaler)
	elif bonus_score < 0:
		content += "%d" % bonus_score
	if base_mult != 0.0 || bonus_mult != 0.0:
		content += "\n" + tr("gem_mult") + ("%.2f" % (base_mult * gain_scaler))
		if bonus_mult > 0:
			content += "+%.2f" % (bonus_mult * gain_scaler)
		elif bonus_mult < 0:
			content += "%.2f" % (bonus_mult * gain_scaler)
	for enchant in Buff.find_all_typed(self, Buff.Type.Enchant):
		content += "\n[color=GREEN]%s[/color]" % (tr("gem_enchant") % tr(enchant.data["type"]))
	if name != "":
		if power != 0:
			content += ("\nw_power: %d" % power)
		content += "\n" + tr("item_desc_" + name).format(extra)
		if extra.has("buff_ids"):
			content += "\n%d" % extra["buff_ids"].size()
	ret.append(Pair.new(title, content))
	return ret

static var s_id : int = 0

func setup(n : String):
	id = s_id
	s_id += 1
	name = n
	if name == "Bomb":
		type = None
		rune = None
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
	elif name == "Flag":
		type = None
		rune = None
		image_id = 7
		price = 2
		extra["value"] = 10
		on_event = func(event : int, tween : Tween, data):
			match event: 
				Event.ItemEntered:
					if data == self:
						Board.add_aura(self)
				Event.ItemLeft:
					if data == self:
						Board.remove_aura(self)
		on_aura = func(g : Gem):
			var b = Buff.create(g, Buff.Type.ValueModifier, {"target":"bonus_score","add":extra["value"]}, Buff.Duration.OnBoard)
			b.caster = self
	elif name == "Rainbow":
		type = ColorWild
		rune = None
		image_id = 30
		category = "Normal"
		price = 2
		extra["value"] = 8.0
		on_eliminate = func(coord : Vector2i, reason : int, source, tween : Tween):
			tween.tween_callback(func():
				var v = extra["value"]
				var pos = Board.get_pos(coord)
				App.add_mult(v, pos)
			)
	elif name == "Ruby":
		type = ColorRed
		rune = None
		image_id = 35
		category = "Normal"
		price = 3
		on_eliminate = func(coord : Vector2i, reason : int, source, tween : Tween):
			tween.tween_callback(func():
				App.change_modifier("red_bouns_i", 1)
				App.float_text("%s +1" % tr("gem_red"), Board.get_pos(coord), Color(1.0, 0.84, 0.0))
			)
	elif name == "Citrine":
		type = ColorOrange
		rune = None
		image_id = 36
		category = "Normal"
		price = 3
		on_eliminate = func(coord : Vector2i, reason : int, source, tween : Tween):
			tween.tween_callback(func():
				App.change_modifier("orange_bouns_i", 1)
				App.float_text("%s +1" % tr("gem_orange"), Board.get_pos(coord), Color(1.0, 0.84, 0.0))
			)
	elif name == "Emerald":
		type = ColorGreen
		rune = None
		image_id = 37
		category = "Normal"
		price = 3
		on_eliminate = func(coord : Vector2i, reason : int, source, tween : Tween):
			tween.tween_callback(func():
				App.change_modifier("green_bouns_i", 1)
				App.float_text("%s +1" % tr("gem_green"), Board.get_pos(coord), Color(1.0, 0.84, 0.0))
			)
	elif name == "Sapphire":
		type = ColorBlue
		rune = None
		image_id = 38
		category = "Normal"
		price = 3
		on_eliminate = func(coord : Vector2i, reason : int, source, tween : Tween):
			tween.tween_callback(func():
				App.change_modifier("blue_bouns_i", 1)
				App.float_text("%s +1" % tr("gem_blue"), Board.get_pos(coord), Color(1.0, 0.84, 0.0))
			)
	elif name == "Amethyst":
		type = ColorMagenta
		rune = None
		image_id = 39
		category = "Normal"
		price = 3
		on_eliminate = func(coord : Vector2i, reason : int, source, tween : Tween):
			tween.tween_callback(func():
				App.change_modifier("magenta_bouns_i", 1)
				App.float_text("%s +1" % tr("gem_magenta"), Board.get_pos(coord), Color(1.0, 0.84, 0.0))
			)
