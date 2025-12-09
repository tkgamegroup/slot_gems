extends Object

class_name Relic

const relic_frames : SpriteFrames = preload("res://images/relics.tres")
const UiRelic = preload("res://ui_relic.gd")

var name : String
var image_id : int
var description : String
var price : int = 10
var extra : Dictionary

var on_event : Callable
var on_active : Callable

var ui : UiRelic = null

static var relic_names : Array[String] = ["ExplosionScience", "HighExplosives", "UniformBlasting", "SympatheticDetonation", "BlockedLever", "MobiusStrip", "Premeditation", "PentagramPower", "RedComposition", "Sunflowers", "WaterLilies", "BlueNude", "LesDemoisellesDAvignon", "RockBottom", "Aries", "Taurus", "Gemini", "Cancer", "Leo", "Virgo", "Libra", "Scorpio", "Sagittarius", "Capricorn", "Aquarius", "Pisces"]

func setup(n : String):
	name = n
	if name == "ExplosionScience":
		image_id = 1
		extra["range_increase"] = 1
		extra["power_decrease"] = 8
		on_event = func(event : int, tween : Tween, data):
			if event == Event.GainRelic:
				if data == self:
					App.change_modifier("explode_range_i", extra["range_increase"])
					App.change_modifier("explode_power_i", -extra["power_decrease"])
			elif event == Event.LostRelic:
				if data == self:
					App.change_modifier("explode_range_i", -extra["range_increase"])
					App.change_modifier("explode_power_i", extra["power_decrease"])
	elif name == "HighExplosives":
		image_id = 2
		price = 4
		extra["value"] = 329
		on_event = func(event : int, tween : Tween, data):
			if event == Event.GainRelic:
				if data == self:
					App.change_modifier("explode_power_i", extra["value"])
			elif event == Event.LostRelic:
				if data == self:
					App.change_modifier("explode_power_i", -extra["value"])
	elif name == "UniformBlasting":
		image_id = 3
		price = 5
		on_event = func(event : int, tween : Tween, data):
			if event == Event.GainRelic:
				if data == self:
					Board.event_listeners.append(Hook.new(Event.Exploded, self, HostType.Relic, false))
			elif event == Event.LostRelic:
				if data == self:
					for l in Board.event_listeners:
						if l.host == self:
							Board.event_listeners.erase(l)
							break
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
									new_place = SMath.pick_random(Board.offset_neighbors(c), App.game_rng)
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
			elif event == Event.LostRelic:
				if data == self:
					for l in Board.event_listeners:
						if l.host == self:
							Board.event_listeners.erase(l)
							break
			elif event == Event.Eliminated:
				var reason = data["reason"]
				var source = data["source"]
				if reason == Board.ActiveReason.Item:
					if source.category == "Bomb":
						var coords = data["coords"]
						var check_coords = []
						for c in coords:
							for cc in Board.offset_neighbors(c):
								if !check_coords.has(cc):
									check_coords.append(cc)
							if !check_coords.has(c):
								check_coords.append(c)
						'''
						for c in check_coords:
							var g = Board.get_gem_at(c)
							if g && g.category == "Bomb":
								Board.activate(g, HostType.Gem, 0, c, Board.ActiveReason.Relic, self)
								Board.set_item_at(c, null)
						'''
	elif name == "BlockedLever":
		image_id = 5
		extra["enable"] = true
		extra["times_i"] = 0
		on_event = func(event : int, tween : Tween, data):
			if event == Event.GainRelic:
				if data == self:
					App.event_listeners.append(Hook.new(Event.RoundBegan, self, HostType.Relic, false))
					App.event_listeners.append(Hook.new(Event.RollingFinished, self, HostType.Relic, false))
					App.event_listeners.append(Hook.new(Event.MatchingFinished, self, HostType.Relic, false))
			elif event == Event.LostRelic:
				if data == self:
					var ls = []
					for l in Board.event_listeners:
						if l.host == self:
							ls.append(l)
					for l in ls:
							Board.event_listeners.erase(l)
			elif event == Event.RoundBegan:
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
		price = 10
		on_event = func(event : int, tween : Tween, data):
			if event == Event.GainRelic:
				if data == self:
					App.set_modifier("board_upper_lower_connected_i", 1)
			elif event == Event.LostRelic:
				if data == self:
					App.set_modifier("board_upper_lower_connected_i", 0)
	elif name == "Premeditation":
		image_id = 7
		price = 3
		extra["value"] = 5
		on_event = func(event : int, tween : Tween, data):
			if event == Event.GainRelic:
				if data == self:
					App.set_modifier("base_combo_i", extra["value"])
			elif event == Event.LostRelic:
				if data == self:
					App.set_modifier("base_combo_i", 0)
	elif name == "PentagramPower":
		image_id = 8
		price = 9
		extra["value"] = 25.0
		on_event = func(event : int, tween : Tween, data):
			if event == Event.GainRelic:
				if data == self:
					Board.event_listeners.append(Hook.new(Event.Combo, self, HostType.Relic, false))
			elif event == Event.LostRelic:
				if data == self:
					for l in Board.event_listeners:
						if l.host == self:
							Board.event_listeners.erase(l)
							break
			elif event == Event.Combo:
				if App.combos > 0 && App.combos % 5 == 0:
					var v = extra["value"]
					Buff.create(App, Buff.Type.ValueModifier, {"target":"gain_scaler","mult":v}, Buff.Duration.ThisCombo)
	elif name == "PaintingOfRed":
		image_id = 9
		extra["value"] = 40
		price = 5
		on_event = func(event : int, tween : Tween, data):
			if event == Event.GainRelic:
				if data == self:
					App.change_modifier("red_bouns_i", extra["value"])
			elif event == Event.LostRelic:
				if data == self:
					App.change_modifier("red_bouns_i", -extra["value"])
	elif name == "PaintingOfOrange":
		image_id = 10
		extra["value"] = 40
		price = 5
		on_event = func(event : int, tween : Tween, data):
			if event == Event.GainRelic:
				if data == self:
					App.change_modifier("orange_bouns_i", extra["value"])
			elif event == Event.LostRelic:
				if data == self:
					App.change_modifier("orange_bouns_i", -extra["value"])
	elif name == "PaintingOfGreen":
		image_id = 11
		extra["value"] = 40
		price = 5
		on_event = func(event : int, tween : Tween, data):
			if event == Event.GainRelic:
				if data == self:
					App.change_modifier("green_bouns_i", extra["value"])
			elif event == Event.LostRelic:
				if data == self:
					App.change_modifier("green_bouns_i", -extra["value"])
	elif name == "PaintingOfBlue":
		image_id = 12
		extra["value"] = 40
		price = 5
		on_event = func(event : int, tween : Tween, data):
			if event == Event.GainRelic:
				if data == self:
					App.change_modifier("blue_bouns_i", extra["value"])
			elif event == Event.LostRelic:
				if data == self:
					App.change_modifier("blue_bouns_i", -extra["value"])
	elif name == "PaintingOfMagenta":
		image_id = 13
		extra["value"] = 40
		price = 5
		on_event = func(event : int, tween : Tween, data):
			if event == Event.GainRelic:
				if data == self:
					App.change_modifier("magenta_bouns_i", extra["value"])
			elif event == Event.LostRelic:
				if data == self:
					App.change_modifier("magenta_bouns_i", -extra["value"])
	elif name == "PaintingOfWave":
		image_id = 14
		extra["value"] = 40
		price = 5
		on_event = func(event : int, tween : Tween, data):
			if event == Event.GainRelic:
				if data == self:
					Board.event_listeners.append(Hook.new(Event.Eliminated, self, HostType.Relic, false))
			elif event == Event.LostRelic:
				if data == self:
					for l in Board.event_listeners:
						if l.host == self:
							Board.event_listeners.erase(l)
							break
			elif event == Event.Eliminated:
				for c in data["coords"]:
					var g = Board.get_gem_at(c)
					if g && g.rune == Gem.RuneWave || g.rune == Gem.RuneOmni:
						App.add_score(extra["value"], Board.get_pos(c))
	elif name == "PaintingOfPalm":
		image_id = 15
		extra["value"] = 40
		price = 5
		on_event = func(event : int, tween : Tween, data):
			if event == Event.GainRelic:
				if data == self:
					Board.event_listeners.append(Hook.new(Event.Eliminated, self, HostType.Relic, false))
			elif event == Event.LostRelic:
				if data == self:
					for l in Board.event_listeners:
						if l.host == self:
							Board.event_listeners.erase(l)
							break
			elif event == Event.Eliminated:
				for c in data["coords"]:
					var g = Board.get_gem_at(c)
					if g && g.rune == Gem.RunePalm || g.rune == Gem.RuneOmni:
						App.add_score(extra["value"], Board.get_pos(c))
	elif name == "PaintingOfStarfish":
		image_id = 16
		extra["value"] = 40
		price = 5
		on_event = func(event : int, tween : Tween, data):
			if event == Event.GainRelic:
				if data == self:
					Board.event_listeners.append(Hook.new(Event.Eliminated, self, HostType.Relic, false))
			elif event == Event.LostRelic:
				if data == self:
					for l in Board.event_listeners:
						if l.host == self:
							Board.event_listeners.erase(l)
							break
			elif event == Event.Eliminated:
				for c in data["coords"]:
					var g = Board.get_gem_at(c)
					if g && g.rune == Gem.RuneStarfish || g.rune == Gem.RuneOmni:
						App.add_score(extra["value"], Board.get_pos(c))
	elif name == "RockBottom":
		image_id = 17
		on_event = func(event : int, tween : Tween, data):
			if event == Event.GainRelic:
				if data == self:
					Board.event_listeners.append(Hook.new(Event.GemBaseScoreChanged, self, HostType.Relic, false))
					Board.event_listeners.append(Hook.new(Event.GemBonusScoreChanged, self, HostType.Relic, false))
			elif event == Event.LostRelic:
				if data == self:
					var ls = []
					for l in Board.event_listeners:
						if l.host == self:
							ls.append(l)
					for l in ls:
							Board.event_listeners.erase(l)
			elif event == Event.GemBaseScoreChanged || event == Event.GemBonusScoreChanged:
				if data["value"] < 0:
					data["value"] = 0
	elif name == "Aries":
		image_id = 18
		price = 4
		extra["range_i"] = 0
		extra["times"] = 3
		on_event = func(event : int, tween : Tween, data):
			if event == Event.GainRelic:
				if data == self:
					Board.event_listeners.append(Hook.new(Event.Eliminated, self, HostType.Relic, false))
			elif event == Event.LostRelic:
				if data == self:
					for l in Board.event_listeners:
						if l.host == self:
							Board.event_listeners.erase(l)
							break
			elif event == Event.Eliminated:
				if data["reason"] == Board.ActiveReason.Pattern:
					#active_constellation(3, 0, 0, data["coords"], tween)
					pass
		on_active = func(effect_index : int, _c : Vector2i, tween : Tween):
			var times = extra["times"]
			for i in times:
				var subtween = App.game_tweens.create_tween()
				subtween.tween_interval(i * 0.1 * App.speed)
				var target = Vector2i(App.game_rng.randi_range(0, Board.cx - 1), App.game_rng.randi_range(0, Board.cy - 1))
				Board.effect_explode(ui.get_global_rect().get_center(), target, extra["range_i"], 0, subtween)
				if i > 0:
					tween.parallel()
				tween.tween_subtween(subtween)
	elif name == "Taurus":
		image_id = 19
		price = 4
		extra["value"] = 500
		on_event = func(event : int, tween : Tween, data):
			if event == Event.GainRelic:
				if data == self:
					Board.event_listeners.append(Hook.new(Event.Eliminated, self, HostType.Relic, false))
			elif event == Event.LostRelic:
				if data == self:
					for l in Board.event_listeners:
						if l.host == self:
							Board.event_listeners.erase(l)
							break
			elif event == Event.Eliminated:
				if data["reason"] == Board.ActiveReason.Pattern:
					#if active_constellation(0, 0, 3, data["coords"], tween, false):
					#	tween.tween_callback(func():
					#		App.add_score(extra["value"], ui.get_global_rect().get_center() + Vector2(84, 0))
					#	)
					#	tween.tween_interval(0.5 * App.speed)
					pass
	elif name == "Gemini":
		image_id = 20
		price = 4
		on_event = func(event : int, tween : Tween, data):
			if event == Event.GainRelic:
				if data == self:
					Board.event_listeners.append(Hook.new(Event.Eliminated, self, HostType.Relic, false))
			elif event == Event.LostRelic:
				if data == self:
					for l in Board.event_listeners:
						if l.host == self:
							Board.event_listeners.erase(l)
							break
			elif event == Event.Eliminated:
				if data["reason"] == Board.ActiveReason.Pattern:
					#active_constellation(0, 3, 0, data["coords"], tween)
					pass
		on_active = func(effect_index : int, _c : Vector2i, tween : Tween):
			if !Hand.grabs.is_empty():
				var idx = 0
				var ui_pos = ui.get_global_rect().get_center()
				tween.tween_callback(func():
					SEffect.add_leading_line(ui_pos, Hand.ui.get_pos(idx), 0.3 * App.speed)
				)
				tween.tween_interval(0.3 * App.speed)
				tween.tween_callback(func():
					App.duplicate_gem(Hand.grabs[idx], Hand.ui.get_slot(idx))
				)
	elif name == "Cancer":
		image_id = 21
		on_event = func(event : int, tween : Tween, data):
			if event == Event.GainRelic:
				if data == self:
					Board.event_listeners.append(Hook.new(Event.Eliminated, self, HostType.Relic, false))
			elif event == Event.LostRelic:
				if data == self:
					for l in Board.event_listeners:
						if l.host == self:
							Board.event_listeners.erase(l)
							break
			elif event == Event.Eliminated:
				if data["reason"] == Board.ActiveReason.Pattern:
					#active_constellation(0, 1, 2, data["coords"], tween)
					pass
		on_active = func(effect_index : int, _c : Vector2i, tween : Tween):
			if !App.current_curses.is_empty():
				var ui_pos = ui.get_global_rect().get_center()
				var curse = App.current_curses[App.game_rng.randi_range(0, App.current_curses.size() - 1)]
				if curse.coord.x != -1 && curse.coord.y != -1:
					tween.tween_callback(func():
						SEffect.add_leading_line(ui_pos, Board.get_pos(curse.coord), 0.3 * App.speed)
					)
					tween.tween_interval(0.3 * App.speed)
				tween.tween_callback(func():
					App.remove_curse(curse)
				)
	elif name == "Leo":
		image_id = 22
		price = 10
		on_event = func(event : int, tween : Tween, data):
			if event == Event.GainRelic:
				if data == self:
					Board.event_listeners.append(Hook.new(Event.Eliminated, self, HostType.Relic, false))
			elif event == Event.LostRelic:
				if data == self:
					for l in Board.event_listeners:
						if l.host == self:
							Board.event_listeners.erase(l)
							break
			elif event == Event.Eliminated:
				if data["reason"] == Board.ActiveReason.Pattern:
					#if active_constellation(2, 1, 1, data["coords"], tween, false):
					#	tween.tween_callback(func():
					#		var ui_pos = ui.get_global_rect().get_center()
					#		SEffect.add_leading_line(ui_pos, App.control_ui.swaps_text.get_global_rect().get_center())
					#	)
					#	tween.tween_interval(0.3)
					#	tween.tween_callback(func():
					#		SSound.se_vibra.play()
					#		App.swaps += 1
					#	)
					#	tween.tween_interval(0.5 * App.speed)
					pass
	elif name == "Virgo":
		image_id = 23
		price = 4
		extra["value"] = 1.8
		on_event = func(event : int, tween : Tween, data):
			if event == Event.GainRelic:
				if data == self:
					Board.event_listeners.append(Hook.new(Event.Eliminated, self, HostType.Relic, false))
			elif event == Event.LostRelic:
				if data == self:
					for l in Board.event_listeners:
						if l.host == self:
							Board.event_listeners.erase(l)
							break
			elif event == Event.Eliminated:
				if data["reason"] == Board.ActiveReason.Pattern:
					#if active_constellation(0, 2, 1, data["coords"], tween, false):
					#	tween.tween_callback(func():
					#		var v = extra["value"]
					#		var pos = ui.get_global_rect().get_center() + Vector2(84, 0)
					#		App.add_mult(v, pos)
					#	)
					#	tween.tween_interval(0.5 * App.speed)
					pass
	elif name == "Libra":
		image_id = 24
		on_event = func(event : int, tween : Tween, data):
			if event == Event.GainRelic:
				if data == self:
					Board.event_listeners.append(Hook.new(Event.Eliminated, self, HostType.Relic, false))
			elif event == Event.LostRelic:
				if data == self:
					for l in Board.event_listeners:
						if l.host == self:
							Board.event_listeners.erase(l)
							break
			elif event == Event.Eliminated:
				if data["reason"] == Board.ActiveReason.Pattern:
					#active_constellation(0, 2, 1, data["coords"], tween)
					pass
		on_active = func(effect_index : int, _c : Vector2i, tween : Tween):
			tween.tween_callback(func():
				App.float_text(tr("t_Libra_effect"), ui.get_global_rect().get_center() + Vector2(84, 0), Color(1.0, 1.0, 1.0, 1.0), 22)
				var v = App.base_score + App.score_mult
				v = ceil(v / 2.0)
				App.base_score = int(v)
				App.score_mult = v
			)
	elif name == "Scorpio":
		image_id = 25
		price = 4
		on_event = func(event : int, tween : Tween, data):
			if event == Event.GainRelic:
				if data == self:
					Board.event_listeners.append(Hook.new(Event.Eliminated, self, HostType.Relic, false))
			elif event == Event.LostRelic:
				if data == self:
					for l in Board.event_listeners:
						if l.host == self:
							Board.event_listeners.erase(l)
							break
			elif event == Event.Eliminated:
				if data["reason"] == Board.ActiveReason.Pattern:
					#active_constellation(2, 1, 0, data["coords"], tween)
					pass
		on_active = func(effect_index : int, _c : Vector2i, tween : Tween):
			if !Hand.grabs.is_empty() && App.gems.size() - 1 >= Board.curr_min_gem_num:
				var idx = Hand.grabs.size() - 1
				var ui_pos = ui.get_global_rect().get_center()
				tween.tween_callback(func():
					SEffect.add_leading_line(ui_pos, Hand.ui.get_pos(idx))
				)
				tween.tween_interval(0.3)
				tween.tween_callback(func():
					App.delete_gem(Hand.grabs[idx], Hand.ui.get_slot(idx).gem_ui)
				)
	elif name == "Sagittarius":
		image_id = 26
		price = 4
		on_event = func(event : int, tween : Tween, data):
			if event == Event.GainRelic:
				if data == self:
					Board.event_listeners.append(Hook.new(Event.Eliminated, self, HostType.Relic, false))
			elif event == Event.LostRelic:
				if data == self:
					for l in Board.event_listeners:
						if l.host == self:
							Board.event_listeners.erase(l)
							break
			elif event == Event.Eliminated:
				if data["reason"] == Board.ActiveReason.Pattern:
					#active_constellation(2, 1, 0, data["coords"], tween)
					pass
		on_active = func(effect_index : int, _c : Vector2i, tween : Tween):
			var target = Vector2i(-1, -1)
			var highest_score = 0
			for y in Board.cy:
				for x in Board.cx:
					var c = Vector2i(x, y)
					var g = Board.get_gem_at(c)
					if g && g.base_score > highest_score:
						target = c
						highest_score = g.base_score
			if target.x != -1:
				var ui_pos = ui.get_global_rect().get_center()
				tween.tween_callback(func():
					SEffect.add_leading_line(ui_pos, Board.get_pos(target))
				)
				tween.tween_interval(0.3)
				tween.tween_callback(func():
					App.add_combo()
					Board.score_at(target)
				)
				Board.eliminate([target], tween, Board.ActiveReason.Relic, self)
	elif name == "Capricorn":
		image_id = 27
		price = 4
		extra["amount"] = 1
		on_event = func(event : int, tween : Tween, data):
			if event == Event.GainRelic:
				if data == self:
					Board.event_listeners.append(Hook.new(Event.Eliminated, self, HostType.Relic, false))
			elif event == Event.LostRelic:
				if data == self:
					for l in Board.event_listeners:
						if l.host == self:
							Board.event_listeners.erase(l)
							break
			elif event == Event.Eliminated:
				if data["reason"] == Board.ActiveReason.Pattern:
					#if active_constellation(1, 0, 2, data["coords"], tween, false):
					#	tween.tween_callback(func():
					#		var amount = extra["amount"]
					#		SSound.se_coin.play()
					#		App.float_text("+%dG" % amount, ui.get_global_rect().get_center() + Vector2(84, 0), Color(1.0, 0.84, 0.0), 22)
					#		App.coins += amount
					#	)
					#	tween.tween_interval(0.5 * App.speed)
					pass
	elif name == "Aquarius":
		image_id = 28
		price = 4
		extra["value"] = 1
		on_event = func(event : int, tween : Tween, data):
			if event == Event.GainRelic:
				if data == self:
					Board.event_listeners.append(Hook.new(Event.Eliminated, self, HostType.Relic, false))
			elif event == Event.LostRelic:
				if data == self:
					for l in Board.event_listeners:
						if l.host == self:
							Board.event_listeners.erase(l)
							break
			elif event == Event.Eliminated:
				if data["reason"] == Board.ActiveReason.Pattern:
					#active_constellation(0, 3, 0, data["coords"], tween)
					pass
		on_active = func(effect_index : int, _c : Vector2i, tween : Tween):
			var cands = Board.filter(func(gem : Gem, item : Item):
				return gem != null
			)
			if !cands.is_empty():  
				var ui_pos = ui.get_global_rect().get_center()
				var targets = SMath.pick_n_random(cands, 1, App.game_rng)
				tween.tween_callback(func():
					for c in targets:
						var g = Board.get_gem_at(c)
						if g:
							SEffect.add_leading_line(ui_pos, Board.get_pos(c))
				)
				tween.tween_interval(0.3)
				tween.tween_callback(func():
					var value = extra["value"]
					var ok = false
					for c in targets:
						var g = Board.get_gem_at(c)
						if g:
							App.float_text("+%d" % value, Board.get_pos(c), Color(0.7, 0.3, 0.9, 1.0), 22)
							g.base_score += value
							ok = true
					if ok:
						SSound.se_vibra.play()
				)
	elif name == "Pisces":
		image_id = 29
		price = 4
		on_event = func(event : int, tween : Tween, data):
			if event == Event.GainRelic:
				if data == self:
					Board.event_listeners.append(Hook.new(Event.Eliminated, self, HostType.Relic, false))
			elif event == Event.LostRelic:
				if data == self:
					for l in Board.event_listeners:
						if l.host == self:
							Board.event_listeners.erase(l)
							break
			elif event == Event.Eliminated:
				if data["reason"] == Board.ActiveReason.Pattern:
					#active_constellation(0, 1, 2, data["coords"], tween)
					pass
		on_active = func(effect_index : int, _c : Vector2i, tween : Tween):
			var cands = Board.filter(func(gem : Gem, item : Item):
				if gem && gem.type != Gem.ColorWild:
					return true
				return false
			)
			if !cands.is_empty():
				var ui_pos = ui.get_global_rect().get_center()
				var targets = SMath.pick_n_random(cands, 2, App.game_rng) 
				tween.tween_callback(func():
					for c in targets:
						var g = Board.get_gem_at(c)
						if g && g.type != Gem.ColorWild:
							SEffect.add_leading_line(ui_pos, Board.get_pos(c))
				)
				tween.tween_interval(0.3)
				tween.tween_callback(func():
					var ok = false
					for c in targets:
						var g = Board.get_gem_at(c)
						if g && g.type != Gem.ColorWild:
							Buff.create(g, Buff.Type.ChangeColor, {"color":Gem.ColorWild}, Buff.Duration.OnBoard)
							ok = true
					if ok:
						SSound.se_vibra.play()
				)
	elif name == "HalfPriceCoupon":
		image_id = 30
		price = 5
		on_event = func(event : int, tween : Tween, data):
			if event == Event.GainRelic:
				if data == self:
					App.set_modifier("half_price_i", 1)
					if App.shop_ui.visible:
						App.shop_ui.refresh_prices()
			elif event == Event.LostRelic:
				if data == self:
					App.set_modifier("half_price_i", 0)
					if App.shop_ui.visible:
						App.shop_ui.refresh_prices()

func get_tooltip():
	var ret : Array[Pair] = []
	var content = tr("relic_desc_" + name).format(extra)
	ret.append(Pair.new(tr("relic_name_" + name), content))
	return ret
