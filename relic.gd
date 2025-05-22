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
	if name == "Explosion Science":
		image_id = 1
		description = "Explosion [color=gray][b]Range[/b][/color] +1 but [color=gray][b]Power[/b][/color] -3."
		on_event = func(event : int, tween : Tween, data):
			if event == Event.GainRelic:
				if data == self:
					Game.modifiers["explode_range_i"] += 1
					Game.modifiers["explode_power_i"] -= 3
	elif name == "High Explosives":
		image_id = 2
		description = "Explosion [color=gray][b]Power[/b][/color] +{value}."
		price = 5
		extra["value"] = 6
		on_event = func(event : int, tween : Tween, data):
			if event == Event.GainRelic:
				if data == self:
					Game.modifiers["explode_power_i"] += extra["value"]
	elif name == "Uniform Blasting":
		image_id = 3
		description = "Explosion will push active effects."
		price = 557
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
	elif name == "Sympathetic Detonation":
		image_id = 4
		description = "Bombs will activate when cells next to are eliminate."
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
	elif name == "Blocked Lever":
		image_id = 5
		description = "Once per level, before the matching ends, perform another rolling and matching, repeat 1 time."
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
	elif name == "Mobius Strip":
		image_id = 6
		description = "The upper and lower parts of the Board are connected."
		on_event = func(event : int, tween : Tween, data):
			if event == Event.GainRelic:
				if data == self:
					Game.modifiers["board_upper_lower_connected_i"] = 1
	elif name == "Premeditation":
		image_id = 7
		description = "Combo starts from 3."
		on_event = func(event : int, tween : Tween, data):
			if event == Event.GainRelic:
				if data == self:
					Game.modifiers["base_combo_i"] = 3
					Game.combos = max(Game.combos, Game.modifiers["base_combo_i"])
	elif name == "Pentagram Power":
		image_id = 8
		description = "Get +4 Score Mult every 5 Combos."
		on_event = func(event : int, tween : Tween, data):
			if event == Event.GainRelic:
				if data == self:
					Board.event_listeners.append(Hook.new(Event.Combo, self, HostType.Relic, false))
			elif event == Event.Combo:
				if Game.combos > 0 && Game.combos % 5 == 0:
					Buff.create(Game, Buff.Type.ValueModifier, {"target":"score_mult","add":4.0}, Buff.Duration.ThisCombo)
	elif name == "Red Stone":
		image_id = 9
		description = "Red gems' base score +{value}."
		extra["value"] = 10
		on_event = func(event : int, tween : Tween, data):
			if event == Event.GainRelic:
				if data == self:
					Game.modifiers["red_bouns_i"] += extra["value"]
	elif name == "Orange Stone":
		image_id = 10
		description = "Orange gems' base score +{value}."
		extra["value"] = 10
		on_event = func(event : int, tween : Tween, data):
			if event == Event.GainRelic:
				if data == self:
					Game.modifiers["orange_bouns_i"] += extra["value"]
	elif name == "Green Stone":
		image_id = 11
		description = "Green gems' base score +{value}."
		extra["value"] = 10
		on_event = func(event : int, tween : Tween, data):
			if event == Event.GainRelic:
				if data == self:
					Game.modifiers["green_bouns_i"] += extra["value"]
	elif name == "Blue Stone":
		image_id = 12
		description = "Blue gems' base score +{value}."
		extra["value"] = 10
		on_event = func(event : int, tween : Tween, data):
			if event == Event.GainRelic:
				if data == self:
					Game.modifiers["blue_bouns_i"] += extra["value"]
	elif name == "Pink Stone":
		image_id = 13
		description = "Pink gems' base score +{value}."
		extra["value"] = 10
		on_event = func(event : int, tween : Tween, data):
			if event == Event.GainRelic:
				if data == self:
					Game.modifiers["pink_bouns_i"] += extra["value"]
	elif name == "Rock Bottom":
		image_id = 14
		description = "Gems' score will not descent."
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
	var content = description.format(extra)
	ret.append(Pair.new(name, content))
	return ret
