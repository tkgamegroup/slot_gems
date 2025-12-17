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
	ColorRedOrange,
	ColorRedGreen,
	ColorRedBlue,
	ColorRedMagenta,
	ColorOrangeGreen,
	ColorOrangeBlue,
	ColorOrangeMagenta,
	ColorGreenBlue,
	ColorGreenMagenta,
	ColorBlueMagenta,
	ColorAny,
	RuneWave,
	RunePalm,
	RuneStarfish,
	RuneOmni,
	RuneWavePalm,
	RuneWaveStarfish,
	RunePalmStarfish,
	RuneAny
}

const ColorFirst = ColorRed
const ColorLast = ColorMagenta
const ColorCount = ColorLast - ColorFirst + 1
const ColorComboFirst = ColorRedOrange
const ColorComboLast = ColorAny
const RuneCount = RuneLast - RuneFirst + 1
const RuneFirst = RuneWave
const RuneLast = RuneStarfish
const RuneComboFirst = RuneWavePalm
const RuneComboLast = RuneAny

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
var score_mult : float = 1.0
var trigger : bool = false
var eliminated : bool = false
var active : bool = false
var coord : Vector2i = Vector2i(-1, -1)
var board_stamp : int = 0
var bag_stamp : int = 0
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
		ColorRedOrange: return App.tr("gem_red") + "&" + App.tr("gem_orange")
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

static func color_combo_contains(combo : int, v : int):
	match combo:
		ColorRedOrange:
			return v == ColorRed || v == ColorOrange
		ColorRedGreen:
			return v == ColorRed || v == ColorGreen
		ColorRedBlue:
			return v == ColorRed || v == ColorBlue
		ColorRedMagenta:
			return v == ColorRed || v == ColorMagenta
		ColorOrangeGreen:
			return v == ColorOrange || v == ColorGreen
		ColorOrangeBlue:
			return v == ColorOrange || v == ColorBlue
		ColorOrangeMagenta:
			return v == ColorOrange || v == ColorMagenta
		ColorGreenBlue:
			return v == ColorGreen || v == ColorBlue
		ColorGreenMagenta:
			return v == ColorGreen || v == ColorMagenta
		ColorBlueMagenta:
			return v == ColorBlue || v == ColorMagenta
		ColorAny:
			return true
	return false

static func rune_name(r : int):
	match r:
		RuneWave: return "wave"
		RunePalm: return "Palm"
		RuneStarfish: return "Starfish"
		RuneOmni: return "Omni"
		RuneAny: return "Any"
	return "None"

static func rune_display_name(r : int):
	match r:
		RuneWave: return App.tr("rune_wave")
		RunePalm: return App.tr("rune_palm")
		RuneStarfish: return App.tr("rune_starfish")
		RuneOmni: return "w_omni"
		RuneAny: return App.tr("rune_any")
	return "None"

static func rune_img(r : int):
	match r:
		RuneWave: return "res://images/rune_wave.png"
		RunePalm: return "res://images/rune_palm.png"
		RuneStarfish: return "res://images/rune_starfish.png"
		RuneOmni: return "res://images/rune_omni.png"
	return ""

static func rune_combo_contains(combo : int, v : int):
	match combo:
		RuneWavePalm:
			return v == RuneWave || v == RunePalm
		RuneWaveStarfish:
			return v == RuneWave || v == RuneStarfish
		RunePalmStarfish:
			return v == RunePalm || v == RuneStarfish
		RuneAny:
			return true
	return false

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
	return int((get_base_score() + bonus_score) * score_mult)

func get_rank():
	return type * 0xffff + rune * 0xff + (100.0 / max(base_score + bonus_score + score_mult, 0.1))

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
	var base = get_base_score()
	content += tr("gem_score") + ("%d" % base)
	var bonus = int((base + bonus_score) * score_mult) - base
	if bonus > 0:
		content += "[color=GREEN]+%d[/color]" % bonus
	elif bonus < 0:
		content += "[color=RED]%d[/color]" % bonus
	if score_mult != 1.0:
		content += "\n" + tr("gem_mult") + ("%.2f" % score_mult)
	for enchant in Buff.find_all_typed(self, Buff.Type.Enchant):
		content += "\n[color=GREEN]%s[/color]" % (tr("gem_enchant") % tr(enchant.data["type"]))
	if power != 0:
		content += "\nw_power: %d" % power
	if trigger:
		content += "\nw_trigger"
	if name != "":
		content += "\n" + tr("item_desc_" + name).format(extra)
	ret.append(Pair.new(title, content))
	return ret

static var s_id : int = 0

func setup(n : String):
	id = s_id
	s_id += 1
	name = n
	if name == "Ruby":
		type = ColorRed
		rune = None
		image_id = 9
		category = "Gem"
		price = 3
		on_eliminate = func(coord : Vector2i, reason : int, source, tween : Tween):
			tween.tween_callback(func():
				App.change_modifier("red_bouns_i", 1)
				App.float_text("%s +1" % tr("gem_red"), Board.get_pos(coord), Color(1.0, 0.84, 0.0))
			)
	elif name == "Heliodor":
		type = ColorOrange
		rune = None
		image_id = 10
		category = "Gem"
		price = 3
		on_eliminate = func(coord : Vector2i, reason : int, source, tween : Tween):
			tween.tween_callback(func():
				App.change_modifier("orange_bouns_i", 1)
				App.float_text("%s +1" % tr("gem_orange"), Board.get_pos(coord), Color(1.0, 0.84, 0.0))
			)
	elif name == "Emerald":
		type = ColorGreen
		rune = None
		image_id = 11
		category = "Gem"
		price = 3
		on_eliminate = func(coord : Vector2i, reason : int, source, tween : Tween):
			tween.tween_callback(func():
				App.change_modifier("green_bouns_i", 1)
				App.float_text("%s +1" % tr("gem_green"), Board.get_pos(coord), Color(1.0, 0.84, 0.0))
			)
	elif name == "Sapphire":
		type = ColorBlue
		rune = None
		image_id = 12
		category = "Gem"
		price = 3
		on_eliminate = func(coord : Vector2i, reason : int, source, tween : Tween):
			tween.tween_callback(func():
				App.change_modifier("blue_bouns_i", 1)
				App.float_text("%s +1" % tr("gem_blue"), Board.get_pos(coord), Color(1.0, 0.84, 0.0))
			)
	elif name == "Amethyst":
		type = ColorMagenta
		rune = None
		image_id = 13
		category = "Gem"
		price = 3
		on_eliminate = func(coord : Vector2i, reason : int, source, tween : Tween):
			tween.tween_callback(func():
				App.change_modifier("magenta_bouns_i", 1)
				App.float_text("%s +1" % tr("gem_magenta"), Board.get_pos(coord), Color(1.0, 0.84, 0.0))
			)
	elif name == "Flag":
		type = None
		rune = None
		image_id = 14
		price = 2
		extra["value"] = 10
		on_event = func(event : int, tween : Tween, data):
			match event: 
				Event.GemEntered:
					if data == self:
						Board.add_aura(self)
				Event.GemLeft:
					if data == self:
						Board.remove_aura(self)
		on_aura = func(g : Gem):
			var b = Buff.create(g, Buff.Type.ValueModifier, {"target":"bonus_score","add":extra["value"]}, Buff.Duration.OnBoard)
			b.caster = self
	elif name == "Bomb":
		type = None
		rune = None
		base_score = 0
		image_id = 15
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
	elif name == "C4":
		type = None
		rune = None
		base_score = 0
		image_id = 16
		category = "Bomb"
		price = 3
		power = 50
		extra["range"] = 2
		on_eliminate = func(coord : Vector2i, reason : int, source, tween : Tween):
			if reason == Board.ActiveReason.Gem && source.category == "Bomb":
				tween.tween_callback(func():
					Board.activate(self, HostType.Gem, 0, coord, reason, source)
				)
		on_active = func(effect_index : int, coord : Vector2i, tween : Tween, item_ui : AnimatedSprite2D):
			Board.effect_explode(Board.get_pos(coord), coord, extra["range"], power, tween, self)
	elif name == "Rainbow":
		type = ColorWild
		rune = None
		image_id = 17
		category = "Normal"
		price = 2
		extra["value"] = 1.5
		on_eliminate = func(coord : Vector2i, reason : int, source, tween : Tween):
			tween.tween_callback(func():
				var v = extra["value"]
				Buff.create(App, Buff.Type.ValueModifier, {"target":"gain_scaler","mult":v}, Buff.Duration.ThisMatching)
				App.float_text("%d%%" % int(App.gain_scaler * 100.0), Board.get_pos(coord), Color(1.0, 0.84, 0.0))
			)
	elif name == "Orange":
		type = ColorOrange
		rune = None
		base_score = 0
		image_id = 18
		category = "Normal"
		price = 3
		on_eliminate = func(coord : Vector2i, reason : int, source, tween : Tween):
			tween.tween_callback(func():
				Board.activate(self, HostType.Gem, 0, coord, reason, source)
			)
		on_active = func(effect_index : int, coord : Vector2i, tween : Tween, item_ui : AnimatedSprite2D):
			var targets = []
			for c in Board.offset_neighbors(coord):
				var g = Board.get_gem_at(c)
				if g && g.type != Gem.ColorOrange && g.type != Gem.ColorWild && !g.active:
					targets.append(c)
			if !targets.is_empty():
				var target = SMath.pick_random(targets, App.game_rng)
				tween.tween_callback(func():
					var fx = SEffect.add_splash(Board.get_pos(coord), Board.get_pos(target), Color.ORANGE, 3, 0.5 * App.speed)
					Board.ui.overlay.add_child(fx)
				)
				tween.tween_interval(0.5 * App.speed)
				tween.tween_callback(func():
					var g = Board.get_gem_at(target)
					g.type = Gem.ColorOrange
					Board.ui.update_cell(target)
				)
	elif name == "IaiCut":
		type = None
		rune = None
		image_id = 19
		category = "Normal"
		trigger = true
		price = 5
		on_eliminate = func(coord : Vector2i, reason : int, source, tween : Tween):
			tween.tween_callback(func():
				Board.activate(self, HostType.Gem, 0, coord, reason, source)
			)
		on_active = func(effect_index : int, coord : Vector2i, tween : Tween, item_ui : AnimatedSprite2D):
			var cc = Board.offset_to_cube(coord)
			var arr = [0, 1, 2]
			var coords : Array[Vector2i] = []
			var times = 1
			for i in times:
				var sub_coords : Array[Vector2i] = []
				var d = SMath.pick_and_remove(arr, App.game_rng)
				match d:
					0: 
						for x in Board.cx:
							var c = Board.cube_to_offset(Vector3i(x, -x - cc.z, cc.z))
							if Board.is_valid(c):
								sub_coords.append(c)
					1: 
						for x in Board.cx:
							var c = Board.cube_to_offset(Vector3i(cc.x, x - cc.x, -x))
							if Board.is_valid(c):
								sub_coords.append(c)
					2: 
						for x in Board.cx:
							var c = Board.cube_to_offset(Vector3i(x - cc.y, cc.y, -x))
							if Board.is_valid(c):
								sub_coords.append(c)
				var p0 = Board.get_pos(sub_coords.front())
				var p1 = Board.get_pos(sub_coords.back())
				tween.tween_callback(func():
					var sp = SEffect.add_slash(p0, p1, 3, 0.25 * App.speed)
					Board.ui.overlay.add_child(sp)
				)
				coords.append_array(sub_coords)
			tween.tween_interval(0.5 * App.speed)
			tween.tween_callback(func():
				App.add_combo()
				for c in coords:
					if Board.is_valid(c):
						Board.score_at(c)
			)
			Board.eliminate(coords, tween, Board.ActiveReason.Gem, self)
	elif name == "Lightning":
		type = ColorOrange
		rune = None
		image_id = 20
		category = "Normal"
		price = 5
		power = 3
		on_eliminate = func(coord : Vector2i, reason : int, source, tween : Tween):
			tween.tween_callback(func():
				Board.activate(self, HostType.Gem, 0, coord, reason, source)
			)
		on_active = func(effect_index : int, coord : Vector2i, tween : Tween, item_ui : AnimatedSprite2D):
			var targets = Board.filter(func(gem : Gem, item : Item):
				return gem && gem.name == "Lightning"
			)
			for ae in Board.active_effects:
				if ae.host.name == "Lightning":
					targets.append(ae.host)
			targets.sort_custom(func(c1, c2):
				return Board.offset_distance(c1, coord) < Board.offset_distance(c2, coord)
			)
			if targets.size() >= 2:
				var coords : Array[Vector2i] = []
				for i in targets.size() - 1:
					var p0 = targets[i]
					var p1 = targets[i + 1]
					for c in Board.draw_line(Board.offset_to_cube(p0), Board.offset_to_cube(p1)):
						var cc = Board.cube_to_offset(c)
						coords.append(cc)
					tween.tween_callback(func():
						var fx = SEffect.add_lighning(Board.get_pos(p0), Board.get_pos(p1), 3, 0.5 * App.speed)
						Board.ui.overlay.add_child(fx)
					)
				coords.append(targets.back())
				tween.tween_interval(0.5 * App.speed)
				tween.tween_callback(func():
						App.add_combo()
						for c in coords:
							if Board.is_valid(c):
								Board.score_at(c, power)
				)
				Board.eliminate(coords, tween, Board.ActiveReason.Gem, self)
	elif name == "Volcano":
		type = ColorRedOrange
		rune = None
		image_id = 21
		category = "Normal"
		price = 5
		on_eliminate = func(coord : Vector2i, reason : int, source, tween : Tween):
			tween.tween_callback(func():
				Board.activate(self, HostType.Gem, 0, coord, reason, source)
			)
		on_active = func(effect_index : int, coord : Vector2i, tween : Tween, item_ui : AnimatedSprite2D):
			var pos = Board.get_pos(coord)
			var coords : Array[Vector2i] = []
			var cands = []
			for c in Board.offset_ring(coord, 1):
				if Board.is_valid(c) && !cands.has(c):
					cands.append(c)
			for c in Board.offset_ring(coord, 2):
				if Board.is_valid(c) && !cands.has(c):
					cands.append(c)
			for i in 2:
				if !cands.is_empty():
					var arr = []
					for c in SMath.pick_n_random(cands, 2, App.game_rng):
						arr.append(Triple.new(c, Board.get_pos(c), null))
						coords.append(c)
					tween.tween_interval(0.1)
					for t in arr:
						var sp = Sprite2D.new()
						sp.texture = SEffect.fireball_image
						sp.scale = Vector2(2.0, 2.0)
						sp.position = pos
						sp.z_index = 3
						Board.ui.overlay.add_child(sp)
						t.third = sp
						tween.parallel()
						tween.tween_property(sp, "position", t.second, 0.4 * App.speed).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
					tween.tween_callback(func():
						App.add_combo()
						for t in arr:
							Board.score_at(t.first)
							t.third.queue_free()
					)
					Board.eliminate(coords, tween, Board.ActiveReason.Item, self)
	elif name == "PolishingPowder":
		type = None
		rune = None
		base_score = 0
		image_id = 22
		category = "Normal"
		price = 5
		on_event = func(event : int, tween : Tween, data):
			match event: 
				Event.GainGem:
					if data == self:
						App.event_listeners.append(Hook.new(Event.RoundEnded, self, HostType.Gem, false))
				Event.LostGem:
					if data == self:
						for l in App.event_listeners:
							if l.host == self:
								App.event_listeners.erase(l)
								break
				Event.RoundEnded:
					if coord.x == -1 && coord.y == -1:
						for g in App.bag_gems:
							if g.name == "" || g.name == "Gem":
								if g.bag_stamp < App.round:
									g.base_score += 1
