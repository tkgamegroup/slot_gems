extends Object

class_name Relic

const relic_frames : SpriteFrames = preload("res://images/relics.tres")

var name : String
var image_id : int
var description : String
var price : int
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
		image_id = 1
		description = "Explosion [color=gray][b]Power[/b][/color] +3."
		on_event = func(event : int, tween : Tween, data):
			if event == Event.GainRelic:
				if data == self:
					Game.modifiers["explode_power_i"] += 3
	elif name == "Uniform Blasting":
		image_id = 1
		description = "Explosion will push active effects."
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
		image_id = 1
		description = "Bombs will activate when cells next to are eliminate."
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
		image_id = 1
		description = "Once per level, before the matching ends, consume 1 rolls and 1 matches to perform rolling and matching."
		on_event = func(event : int, tween : Tween, data):
			if event == Event.GainRelic:
				if data == self:
					Game.modifiers["continuous_roll_and_match_i"] = 1
	elif name == "Mobius Strip":
		image_id = 1
		description = "The upper and lower parts of the Board are connected."
		on_event = func(event : int, tween : Tween, data):
			if event == Event.GainRelic:
				if data == self:
					Game.modifiers["board_upper_lower_connected_i"] = 1
	elif name == "Premeditation":
		image_id = 1
		description = "Combo starts from 4."
		on_event = func(event : int, tween : Tween, data):
			if event == Event.GainRelic:
				if data == self:
					Game.modifiers["base_combo_i"] = 4
	elif name == "Pentagram Power":
		image_id = 1
		description = "Get +5 Score Mult in the 5th Combo."
		on_event = func(event : int, tween : Tween, data):
			if event == Event.GainRelic:
				if data == self:
					Board.event_listeners.append(Hook.new(Event.Combo, self, HostType.Relic, false))
			elif event == Event.Combo:
				if Game.combos == 5:
					Buff.create(Game, Buff.Type.ValueModifier, {"target":"score_mult","add":5.0}, Buff.Duration.ThisCombo)
	elif name == "Red Stone":
		image_id = 1
		description = "Red gems' base score +{value}."
		extra["value"] = 4
		on_event = func(event : int, tween : Tween, data):
			if event == Event.GainRelic:
				if data == self:
					Game.modifiers["red_bouns_i"] += extra["value"]
	elif name == "Orange Stone":
		image_id = 1
		description = "Orange gems' base score +{value}."
		extra["value"] = 4
		on_event = func(event : int, tween : Tween, data):
			if event == Event.GainRelic:
				if data == self:
					Game.modifiers["orange_bouns_i"] += extra["value"]
	elif name == "Green Stone":
		image_id = 1
		description = "Green gems' base score +{value}."
		extra["value"] = 4
		on_event = func(event : int, tween : Tween, data):
			if event == Event.GainRelic:
				if data == self:
					Game.modifiers["green_bouns_i"] += extra["value"]
	elif name == "Blue Stone":
		image_id = 1
		description = "Blue gems' base score +{value}."
		extra["value"] = 4
		on_event = func(event : int, tween : Tween, data):
			if event == Event.GainRelic:
				if data == self:
					Game.modifiers["blue_bouns_i"] += extra["value"]
	elif name == "Pink Stone":
		image_id = 1
		description = "Pink gems' base score +{value}."
		extra["value"] = 4
		on_event = func(event : int, tween : Tween, data):
			if event == Event.GainRelic:
				if data == self:
					Game.modifiers["pink_bouns_i"] += extra["value"]
	elif name == "Rock Bottom":
		image_id = 1
		description = "Gems' score will not descent."
		on_event = func(event : int, tween : Tween, data):
			if event == Event.GemBaseScoreChanged || event == Event.GemBonusScoreChanged:
				if data["value"] < 0:
					data["value"] = 0

func get_tooltip():
	var ret : Array[Pair] = []
	var content = description.format(extra)
	ret.append(Pair.new(name, content))
	return ret
