extends Object

class_name Relic

const relic_frames : SpriteFrames = preload("res://images/relics.tres")

var name : String
var image_id : int
var description : String
var price : int = 10
var extra : Dictionary

var on_event : Callable

func setup(n : String):
	name = n
	if name == "ExplosionScience":
		image_id = 1
		on_event = func(event : int, tween : Tween, data):
			if event == Event.GainRelic:
				if data == self:
					Game.change_modifier("explode_range_i", 1)
					Game.change_modifier("explode_power_i", -3)
	elif name == "HighExplosives":
		image_id = 2
		price = 5
		extra["value"] = 6
		on_event = func(event : int, tween : Tween, data):
			if event == Event.GainRelic:
				if data == self:
					Game.change_modifier("explode_power_i", extra["value"])
	elif name == "UniformBlasting":
		image_id = 3
		price = 5
		on_event = func(event : int, tween : Tween, data):
			if event == Event.GainRelic:
				if data == self:
					Board.event_listeners.append(Hook.new(Event.Exploded, self, HostType.Relic, false))
			elif event == Event.Exploded:
				var source = data["source"]
				var coord = data["coord"]
				var range = data["range"]
				var moved = []
				for i in range + 1:
					for c in Board.offset_ring(coord, i):
						for ae in Board.get_active_effects_at(c):
							if ae.host != source && !moved.has(ae.host):
								var new_place = Vector2i(-1, -1)
								if c == coord:
									new_place = Board.offset_neighbors(c).pick_random()
								else:
									var cc = Board.offset_to_cube(coord)
									var d = Board.offset_to_cube(c) - cc
									var sorted_d = SMath.component_sort(d)
									var s = sign(sorted_d[0].value)
									d[sorted_d[0].name] += s
									d[sorted_d[1].name] -= s
									new_place = Board.cube_to_offset(cc + d)
								if new_place.x != -1 && new_place.y != -1 && Board.is_valid(new_place):
									ae.coord = new_place
									ae.sp.position = Board.get_pos(new_place)
									moved.append(ae.host)
	elif name == "SympatheticDetonation":
		image_id = 4
		price = 5
		on_event = func(event : int, tween : Tween, data):
			if event == Event.GainRelic:
				if data == self:
					Board.event_listeners.append(Hook.new(Event.Eliminated, self, HostType.Relic, false))
			elif event == Event.Eliminated:
				var coords = Board.offset_neighbors(data)
				coords.append(data)
				for c in coords:
					var i = Board.get_item_at(c)
					if i && i.category == "Bomb":
						Board.activate(i, HostType.Item, 0, c, Board.ActiveReason.Relic, self)
	elif name == "BlockedLever":
		image_id = 5
		extra["enable"] = true
		extra["times_i"] = 0
		on_event = func(event : int, tween : Tween, data):
			if event == Event.GainRelic:
				if data == self:
					Game.event_listeners.append(Hook.new(Event.LevelBegan, self, HostType.Relic, false))
					Game.event_listeners.append(Hook.new(Event.RollingFinished, self, HostType.Relic, false))
					Game.event_listeners.append(Hook.new(Event.MatchingFinished, self, HostType.Relic, false))
			elif event == Event.LevelBegan:
				extra["enable"] = true
			elif event == Event.RollingFinished:
				if extra["times_i"] > 0:
					Board.matching()
					return true
				return false
			elif event == Event.MatchingFinished:
				if extra["times_i"] > 0:
					extra["times_i"] -= 1
					if extra["times_i"] == 0:
						return false
					else:
						Board.roll()
						return true
				else:
					if extra["enable"]:
						extra["enable"] = false
						extra["times_i"] = 2
						Board.roll()
						return true
				return false
	elif name == "MobiusStrip":
		image_id = 6
		on_event = func(event : int, tween : Tween, data):
			if event == Event.GainRelic:
				if data == self:
					Game.set_modifier("board_upper_lower_connected_i", 1)
	elif name == "Premeditation":
		image_id = 7
		on_event = func(event : int, tween : Tween, data):
			if event == Event.GainRelic:
				if data == self:
					Game.set_modifier("base_combo_i", 3)
	elif name == "PentagramPower":
		image_id = 8
		on_event = func(event : int, tween : Tween, data):
			if event == Event.GainRelic:
				if data == self:
					Board.event_listeners.append(Hook.new(Event.Combo, self, HostType.Relic, false))
			elif event == Event.Combo:
				if Game.combos > 0 && Game.combos % 5 == 0:
					Buff.create(Game, Buff.Type.ValueModifier, {"target":"score_mult","add":4.0}, Buff.Duration.ThisCombo)
	elif name == "RedStone":
		image_id = 9
		extra["value"] = 10
		on_event = func(event : int, tween : Tween, data):
			if event == Event.GainRelic:
				if data == self:
					Game.change_modifier("red_bouns_i", extra["value"])
	elif name == "OrangeStone":
		image_id = 10
		extra["value"] = 10
		on_event = func(event : int, tween : Tween, data):
			if event == Event.GainRelic:
				if data == self:
					Game.change_modifier("orange_bouns_i", extra["value"])
	elif name == "GreenStone":
		image_id = 11
		extra["value"] = 10
		on_event = func(event : int, tween : Tween, data):
			if event == Event.GainRelic:
				if data == self:
					Game.change_modifier("green_bouns_i", extra["value"])
	elif name == "BlueStone":
		image_id = 12
		extra["value"] = 10
		on_event = func(event : int, tween : Tween, data):
			if event == Event.GainRelic:
				if data == self:
					Game.change_modifier("blue_bouns_i", extra["value"])
	elif name == "PinkStone":
		image_id = 13
		extra["value"] = 10
		on_event = func(event : int, tween : Tween, data):
			if event == Event.GainRelic:
				if data == self:
					Game.change_modifier("pink_bouns_i", extra["value"])
	elif name == "RockBottom":
		image_id = 14
		on_event = func(event : int, tween : Tween, data):
			if event == Event.GainRelic:
				if data == self:
					Board.event_listeners.append(Hook.new(Event.GemBaseScoreChanged, self, HostType.Relic, false))
					Board.event_listeners.append(Hook.new(Event.GemBonusScoreChanged, self, HostType.Relic, false))
			elif event == Event.GemBaseScoreChanged || event == Event.GemBonusScoreChanged:
				if data["value"] < 0:
					data["value"] = 0

func get_tooltip():
	var ret : Array[Pair] = []
	var content = tr("relic_desc_" + name).format(extra)
	ret.append(Pair.new(tr("relic_name_" + name), content))
	return ret
