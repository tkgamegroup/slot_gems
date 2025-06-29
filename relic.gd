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

func active_constellation(need_destroy : int, need_wisdom : int, need_grow : int, coords : Array, tween : Tween, do_active : bool = true):
	var runes = []
	for c in coords:
		var p = Pair.new(c, Board.get_gem_at(c).rune)
		if p.second == Gem.Rune.Destroy:
			if need_destroy > 0:
				need_destroy -= 1
				runes.append(p)
		elif p.second == Gem.Rune.Wisdom:
			if need_wisdom > 0:
				need_wisdom -= 1
				runes.append(p)
		elif p.second == Gem.Rune.Grow:
			if need_grow > 0:
				need_grow -= 1
				runes.append(p)
		elif p.second == Gem.Rune.Omni:
			if need_destroy > 0:
				need_destroy -= 1
				runes.append(p)
			elif need_wisdom > 0:
				need_wisdom -= 1
				runes.append(p)
			elif need_grow > 0:
				need_grow -= 1
				runes.append(p)
	if need_destroy == 0 && need_wisdom == 0 && need_grow == 0:
		var sps = []
		var c = Vector2(0.0, 0.0)
		for p in runes:
			var sp = AnimatedSprite2D.new()
			sp.sprite_frames = Gem.rune_frames
			sp.frame = p.second
			sp.modulate = Color("#5b6ee1", 1.0)
			sp.position = Board.get_pos(p.first)
			Game.board_ui.overlay.add_child(sp)
			sps.append(sp)
			c += sp.position
		c /= runes.size()
		var idx = 0
		for sp in sps:
			var subtween = Game.get_tree().create_tween()
			subtween.tween_interval(idx * 0.1)
			subtween.tween_property(sp, "scale", Vector2(1.5, 1.5), 0.2).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUART)
			subtween.tween_property(sp, "scale", Vector2(1.0, 1.0), 0.8)
			subtween.tween_property(sp, "position", c, 0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)
			subtween.parallel().tween_property(sp, "scale", Vector2(0.0, 0.0), 0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)
			if idx > 0:
				tween.parallel()
			tween.tween_subtween(subtween)
			idx += 1
		if do_active:
			tween.tween_callback(func():
				SSound.se_skill.play()
				SEffect.add_leading_line(c, ui.get_global_rect().get_center(), 0.3, 2.0)
			)
			tween.tween_interval(0.3)
			tween.tween_callback(func():
				Board.activate(self, HostType.Relic, 0, Vector2i(-1, -1), Board.ActiveReason.Relic, self)
			)

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
									new_place = SMath.pick_random(Board.offset_neighbors(c), Game.rng)
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
				var coords = data["coords"]
				var check_coords = []
				for c in coords:
					check_coords.append_array(Board.offset_neighbors(c))
					check_coords.append(c)
				for c in check_coords:
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
	elif name == "Aries":
		image_id = 15
		extra["range_i"] = 0
		on_event = func(event : int, tween : Tween, data):
			if event == Event.GainRelic:
				if data == self:
					Board.event_listeners.append(Hook.new(Event.Eliminated, self, HostType.Relic, false))
			elif event == Event.Eliminated:
				if data["reason"] == Board.ActiveReason.Pattern:
					active_constellation(3, 0, 0, data["coords"], tween)
		on_active = func(effect_index : int, _c : Vector2i, tween : Tween):
			for i in 1:
				var subtween = Game.get_tree().create_tween()
				var target = Vector2i(Game.rng.randi_range(0, Board.cx - 1), Game.rng.randi_range(0, Board.cy - 1))
				Board.effect_explode(ui.get_global_rect().get_center(), target, extra["range_i"], 0, subtween)
				if i > 0:
					tween.parallel()
				tween.tween_subtween(subtween)
	elif name == "Taurus":
		image_id = 16
		on_event = func(event : int, tween : Tween, data):
			if event == Event.GainRelic:
				if data == self:
					Board.event_listeners.append(Hook.new(Event.Eliminated, self, HostType.Relic, false))
			elif event == Event.Eliminated:
				if data["reason"] == Board.ActiveReason.Pattern:
					active_constellation(0, 0, 3, data["coords"], tween, false)
					tween.tween_callback(func():
						Game.add_score(int(Game.target_score * (0.01 * extra["percentage"])) + extra["basic_value"], ui.get_global_rect().get_center() + Vector2(84, 0), false)
					)
					tween.tween_interval(0.5 * Game.animation_speed)
	elif name == "Gemini":
		image_id = 17
		on_event = func(event : int, tween : Tween, data):
			if event == Event.GainRelic:
				if data == self:
					Board.event_listeners.append(Hook.new(Event.Eliminated, self, HostType.Relic, false))
			elif event == Event.Eliminated:
				if data["reason"] == Board.ActiveReason.Pattern:
					active_constellation(0, 3, 0, data["coords"], tween)
		on_active = func(effect_index : int, _c : Vector2i, tween : Tween):
			var idx = Game.rng.randi() % Hand.grabs.size()
			if idx != -1:
				var ui_pos = ui.get_global_rect().get_center()
				tween.tween_callback(func():
					SEffect.add_leading_line(ui_pos, Game.hand_ui.get_pos(idx))
				)
				tween.tween_interval(0.3)
				tween.tween_callback(func():
					if idx < Hand.grabs.size():
						Game.duplicate_gem(Hand.grabs[idx], Game.hand_ui.get_ui(idx))
				)
	elif name == "Cancer":
		image_id = 18
		on_event = func(event : int, tween : Tween, data):
			if event == Event.GainRelic:
				if data == self:
					Board.event_listeners.append(Hook.new(Event.Eliminated, self, HostType.Relic, false))
			elif event == Event.Eliminated:
				if data["reason"] == Board.ActiveReason.Pattern:
					active_constellation(0, 1, 2, data["coords"], tween)
		on_active = func(effect_index : int, _c : Vector2i, tween : Tween):
			pass
	elif name == "Leo":
		image_id = 19
		on_event = func(event : int, tween : Tween, data):
			if event == Event.GainRelic:
				if data == self:
					Board.event_listeners.append(Hook.new(Event.Eliminated, self, HostType.Relic, false))
			elif event == Event.Eliminated:
				if data["reason"] == Board.ActiveReason.Pattern:
					active_constellation(2, 0, 1, data["coords"], tween, false)
					tween.tween_callback(func():
						var ui_pos = ui.get_global_rect().get_center()
						SEffect.add_leading_line(ui_pos, Game.control_ui.swaps_text.get_global_rect().get_center())
					)
					tween.tween_interval(0.3)
					tween.tween_callback(func():
						SSound.se_vibra.play()
						Game.swaps += 1
					)
					tween.tween_interval(0.5 * Game.animation_speed)
	elif name == "Virgo":
		image_id = 20
		on_event = func(event : int, tween : Tween, data):
			if event == Event.GainRelic:
				if data == self:
					Board.event_listeners.append(Hook.new(Event.Eliminated, self, HostType.Relic, false))
			elif event == Event.Eliminated:
				if data["reason"] == Board.ActiveReason.Pattern:
					active_constellation(0, 2, 1, data["coords"], tween, false)
					tween.tween_callback(func():
						Game.float_text("+0.5 Mult", ui.get_global_rect().get_center() + Vector2(84, 0), Color(0.7, 0.3, 0.9))
						Buff.create(Game, Buff.Type.ValueModifier, {"target":"score_mult","add":0.5})
					)
					tween.tween_interval(0.5 * Game.animation_speed)
	elif name == "Libra":
		image_id = 21
		on_event = func(event : int, tween : Tween, data):
			if event == Event.GainRelic:
				if data == self:
					Board.event_listeners.append(Hook.new(Event.Eliminated, self, HostType.Relic, false))
			elif event == Event.Eliminated:
				if data["reason"] == Board.ActiveReason.Pattern:
					active_constellation(0, 2, 1, data["coords"], tween)
		on_active = func(effect_index : int, _c : Vector2i, tween : Tween):
			tween.tween_callback(func():
				var ui_pos = ui.get_global_rect().get_center()
				SEffect.add_leading_line(ui_pos, Game.hand_ui.global_position)
			)
			tween.tween_interval(0.3)
			tween.tween_callback(func():
				var colors = [0, 0, 0, 0, 0]
				for g in Hand.grabs:
					colors[g.type - 1] = 1
				
			)
	elif name == "Scorpio":
		image_id = 22
		on_event = func(event : int, tween : Tween, data):
			if event == Event.GainRelic:
				if data == self:
					Board.event_listeners.append(Hook.new(Event.Eliminated, self, HostType.Relic, false))
			elif event == Event.Eliminated:
				if data["reason"] == Board.ActiveReason.Pattern:
					active_constellation(2, 1, 0, data["coords"], tween)
		on_active = func(effect_index : int, _c : Vector2i, tween : Tween):
			var idx = randi() % Hand.grabs.size()
			if idx != -1:
				var ui_pos = ui.get_global_rect().get_center()
				tween.tween_callback(func():
					SEffect.add_leading_line(ui_pos, Game.hand_ui.get_pos(idx))
				)
				tween.tween_interval(0.3)
				tween.tween_callback(func():
					if idx < Hand.grabs.size():
						Game.delete_gem(Hand.grabs[idx], Game.hand_ui.get_ui(idx))
				)
	elif name == "Sagittarius":
		image_id = 23
		on_event = func(event : int, tween : Tween, data):
			if event == Event.GainRelic:
				if data == self:
					Board.event_listeners.append(Hook.new(Event.Eliminated, self, HostType.Relic, false))
			elif event == Event.Eliminated:
				if data["reason"] == Board.ActiveReason.Pattern:
					active_constellation(2, 1, 0, data["coords"], tween)
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
				Board.eliminate([target], tween, Board.ActiveReason.Relic, self)
	elif name == "Capricorn":
		image_id = 24
		on_event = func(event : int, tween : Tween, data):
			if event == Event.GainRelic:
				if data == self:
					Board.event_listeners.append(Hook.new(Event.Eliminated, self, HostType.Relic, false))
			elif event == Event.Eliminated:
				if data["reason"] == Board.ActiveReason.Pattern:
					active_constellation(1, 0, 2, data["coords"], tween, false)
					tween.tween_callback(func():
						SSound.se_coin.play()
						Game.float_text("+2G", ui.get_global_rect().get_center() + Vector2(84, 0), Color(0.8, 0.8, 0.0))
						Game.coins += 2
					)
					tween.tween_interval(0.5 * Game.animation_speed)
	elif name == "Aquarius":
		image_id = 25
		on_event = func(event : int, tween : Tween, data):
			if event == Event.GainRelic:
				if data == self:
					Board.event_listeners.append(Hook.new(Event.Eliminated, self, HostType.Relic, false))
			elif event == Event.Eliminated:
				if data["reason"] == Board.ActiveReason.Pattern:
					active_constellation(0, 3, 0, data["coords"], tween)
		on_active = func(effect_index : int, _c : Vector2i, tween : Tween):
			var cands = Board.filter(func(gem : Gem, item : Item):
				return gem != null
			)
			if !cands.is_empty():  
				var ui_pos = ui.get_global_rect().get_center()
				var targets = SMath.pick_n_random(cands, 1, Game.rng)
				tween.tween_callback(func():
					for c in targets:
						var g = Board.get_gem_at(c)
						if g:
							SEffect.add_leading_line(ui_pos, Board.get_pos(c))
				)
				tween.tween_interval(0.3)
				tween.tween_callback(func():
					var ok = false
					for c in targets:
						var g = Board.get_gem_at(c)
						if g:
							Game.float_text("+1", Board.get_pos(c), Color(0.7, 0.3, 0.9))
							g.base_score += 1
							ok = true
					if ok:
						SSound.se_vibra.play()
				)
	elif name == "Pisces":
		image_id = 26
		on_event = func(event : int, tween : Tween, data):
			if event == Event.GainRelic:
				if data == self:
					Board.event_listeners.append(Hook.new(Event.Eliminated, self, HostType.Relic, false))
			elif event == Event.Eliminated:
				if data["reason"] == Board.ActiveReason.Pattern:
					active_constellation(0, 1, 2, data["coords"], tween)
		on_active = func(effect_index : int, _c : Vector2i, tween : Tween):
			var cands = Board.filter(func(gem : Gem, item : Item):
				if gem && gem.type != Gem.Type.Wild:
					return true
				return false
			)
			if !cands.is_empty():
				var ui_pos = ui.get_global_rect().get_center()
				var targets = SMath.pick_n_random(cands, 2, Game.rng) 
				tween.tween_callback(func():
					for c in targets:
						var g = Board.get_gem_at(c)
						if g && g.type != Gem.Type.Wild:
							SEffect.add_leading_line(ui_pos, Board.get_pos(c))
				)
				tween.tween_interval(0.3)
				tween.tween_callback(func():
					var ok = false
					for c in targets:
						var g = Board.get_gem_at(c)
						if g && g.type != Gem.Type.Wild:
							Buff.create(g, Buff.Type.ChangeColor, {"color":Gem.Type.Wild}, Buff.Duration.ThisLevel)
							ok = true
					if ok:
						SSound.se_vibra.play()
				)

func get_tooltip():
	var ret : Array[Pair] = []
	var content = tr("relic_desc_" + name).format(extra)
	ret.append(Pair.new(tr("relic_name_" + name), content))
	return ret
