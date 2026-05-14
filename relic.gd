extends RefCounted

class_name Relic

var name : String
var image_id : int
var description : String
var price : int = 10
var sockets : Array[Gem]
var extra : Dictionary

var on_event : Callable
var on_active : Callable
var on_aura : Callable
var on_socket : Callable

var ui : G.UiRelic = null

func setup(n : String):
	name = n
	if name == "PaintingOfRed":
		image_id = 1
		extra["value_i"] = 27
		price = 5
		on_event = func(event : int, tween : Tween, data):
			if event == C.Event.GainRelic:
				if data == self:
					G.change_modifier("red_bouns_i", extra["value_i"])
			elif event == C.Event.LostRelic:
				if data == self:
					G.change_modifier("red_bouns_i", -extra["value_i"])
	elif name == "PaintingOfOrange":
		image_id = 2
		extra["value_i"] = 27
		price = 5
		on_event = func(event : int, tween : Tween, data):
			if event == C.Event.GainRelic:
				if data == self:
					G.change_modifier("orange_bouns_i", extra["value_i"])
			elif event == C.Event.LostRelic:
				if data == self:
					G.change_modifier("orange_bouns_i", -extra["value_i"])
	elif name == "PaintingOfGreen":
		image_id = 3
		extra["value_i"] = 27
		price = 5
		on_event = func(event : int, tween : Tween, data):
			if event == C.Event.GainRelic:
				if data == self:
					G.change_modifier("green_bouns_i", extra["value_i"])
			elif event == C.Event.LostRelic:
				if data == self:
					G.change_modifier("green_bouns_i", -extra["value_i"])
	elif name == "PaintingOfBlue":
		image_id = 4
		extra["value_i"] = 27
		price = 5
		on_event = func(event : int, tween : Tween, data):
			if event == C.Event.GainRelic:
				if data == self:
					G.change_modifier("blue_bouns_i", extra["value_i"])
			elif event == C.Event.LostRelic:
				if data == self:
					G.change_modifier("blue_bouns_i", -extra["value_i"])
	elif name == "PaintingOfMagenta":
		image_id = 5
		extra["value_i"] = 27
		price = 5
		on_event = func(event : int, tween : Tween, data):
			if event == C.Event.GainRelic:
				if data == self:
					G.change_modifier("magenta_bouns_i", extra["value_i"])
			elif event == C.Event.LostRelic:
				if data == self:
					G.change_modifier("magenta_bouns_i", -extra["value_i"])
	elif name == "PaintingOfWave":
		image_id = 6
		extra["value_i"] = 18
		price = 5
		on_event = func(event : int, tween : Tween, data):
			if event == C.Event.GainRelic:
				if data == self:
					SUtils.add_event_listener(Board, C.Event.Eliminated, self, C.HostType.Relic)
			elif event == C.Event.Eliminated:
				var c = data["coord"]
				var g = Board.get_gem_at(c)
				if g && g.rune == Gem.RuneWave || g.rune == Gem.RuneOmni:
					G.add_score(extra["value_i"], Board.get_pos(c))
	elif name == "PaintingOfCircle":
		image_id = 7
		extra["value_i"] = 18
		price = 5
		on_event = func(event : int, tween : Tween, data):
			if event == C.Event.GainRelic:
				if data == self:
					SUtils.add_event_listener(Board, C.Event.Eliminated, self, C.HostType.Relic)
			elif event == C.Event.Eliminated:
				var c = data["coord"]
				var g = Board.get_gem_at(c)
				if g && g.rune == Gem.RuneCircle || g.rune == Gem.RuneOmni:
					G.add_score(extra["value_i"], Board.get_pos(c))
	elif name == "PaintingOfStar":
		image_id = 8
		extra["value_i"] = 18
		price = 5
		on_event = func(event : int, tween : Tween, data):
			if event == C.Event.GainRelic:
				if data == self:
					SUtils.add_event_listener(Board, C.Event.Eliminated, self, C.HostType.Relic)
			elif event == C.Event.Eliminated:
				var c = data["coord"]
				var g = Board.get_gem_at(c)
				if g && g.rune == Gem.RuneStar || g.rune == Gem.RuneOmni:
					G.add_score(extra["value_i"], Board.get_pos(c))
	elif name == "Amplifier":
		image_id = 9
		on_event = func(event : int, tween : Tween, data):
			if event == C.Event.GainRelic:
				if data == self:
					G.set_modifier("extra_range_i", 1)
			elif event == C.Event.LostRelic:
				if data == self:
					G.set_modifier("extra_range_i", 0)
	elif name == "Recorder":
		image_id = 10
		price = 5
		on_event = func(event : int, tween : Tween, data):
			if event == C.Event.GainRelic:
				if data == self:
					G.set_modifier("additional_active_times_i", 1)
			elif event == C.Event.LostRelic:
				if data == self:
					G.set_modifier("additional_active_times_i", 0)
	elif name == "GhostAmmo":
		image_id = 11
		price = 5
		on_event = func(event : int, tween : Tween, data):
			if event == C.Event.GainRelic:
				if data == self:
					G.set_modifier("not_consume_repeat_count_chance_i", 50)
			elif event == C.Event.LostRelic:
				if data == self:
					G.set_modifier("not_consume_repeat_count_chance_i", 0)
	elif name == "Multicast":
		image_id = 12
		price = 5
		on_event = func(event : int, tween : Tween, data):
			if event == C.Event.GainRelic:
				if data == self:
					G.set_modifier("additional_targets_i", 2)
			elif event == C.Event.LostRelic:
				if data == self:
					G.set_modifier("additional_targets_i", 0)
	elif name == "MobiusStrip":
		image_id = 13
		price = 10
		on_event = func(event : int, tween : Tween, data):
			if event == C.Event.GainRelic:
				if data == self:
					G.set_modifier("board_upper_lower_connected_i", 1)
			elif event == C.Event.LostRelic:
				if data == self:
					G.set_modifier("board_upper_lower_connected_i", 0)
	elif name == "Premeditation":
		image_id = 14
		price = 3
		extra["value_i"] = 5
		on_event = func(event : int, tween : Tween, data):
			if event == C.Event.GainRelic:
				if data == self:
					G.set_modifier("base_chain_i", extra["value_i"])
			elif event == C.Event.LostRelic:
				if data == self:
					G.set_modifier("base_chain_i", 0)
	elif name == "PentagramPower":
		image_id = 15
		price = 9
		extra["value_f"] = 25.0
		on_event = func(event : int, tween : Tween, data):
			if event == C.Event.GainRelic:
				if data == self:
					SUtils.add_event_listener(Board, C.Event.Chain, self, C.HostType.Relic)
			elif event == C.Event.Chain:
				if G.chains > 0 && G.chains % 5 == 0:
					var v = extra["value_f"]
					Buff.create(G, Buff.Type.ValueModifier, {"target":"gain_scaler","mult":v}, Buff.Duration.ThisChain)
	elif name == "HalfPriceCoupon":
		image_id = 16
		price = 5
		on_event = func(event : int, tween : Tween, data):
			if event == C.Event.GainRelic:
				if data == self:
					G.set_modifier("half_price_i", 1)
					if G.shop_ui.visible:
						G.shop_ui.refresh_prices()
			elif event == C.Event.LostRelic:
				if data == self:
					G.set_modifier("half_price_i", 0)
					if G.shop_ui.visible:
						G.shop_ui.refresh_prices()
	elif name == "RockBottom":
		image_id = 17
		on_event = func(event : int, tween : Tween, data):
			if event == C.Event.GainRelic:
				if data == self:
					SUtils.add_event_listener(Board, C.Event.GemBaseScoreChanged, self, C.HostType.Relic)
					SUtils.add_event_listener(Board, C.Event.GemBonusScoreChanged, self, C.HostType.Relic)
			elif event == C.Event.GemBaseScoreChanged || event == C.Event.GemBonusScoreChanged:
				if data["value"] < 0:
					data["value"] = 0
	elif name == "Aries":
		image_id = 18
		price = 4
		extra["range_i"] = 0
		extra["times_i"] = 3
		extra["achieved_i"] = 0
		on_event = func(event : int, tween : Tween, data):
			if event == C.Event.GainRelic:
				if data == self:
					SUtils.add_event_listener(G, C.Event.RoundBegin, self, C.HostType.Relic)
					SUtils.add_event_listener(Board, C.Event.BeforeMatching, self, C.HostType.Relic)
					SUtils.add_event_listener(Board, C.Event.GemEntered, self, C.HostType.Relic)
					SUtils.add_event_listener(Board, C.Event.GemLeft, self, C.HostType.Relic)
			elif event == C.Event.GemEntered:
				var coords = get_constellation_star_coords("Aries", true)
				var g = data as Gem
				for c in coords:
					if g.coord == c && g.rune == Gem.RuneStar:
						Board.set_floating(g.coord, true)
						break
			elif event == C.Event.GemLeft:
				var coords = get_constellation_star_coords("Aries", true)
				var g = data as Gem
				for c in coords:
					if g.coord == c && g.rune == Gem.RuneStar:
						Board.set_floating(g.coord, false)
						break
			elif event == C.Event.RoundBegin:
				extra["achieved_i"] = 0
			elif event == C.Event.BeforeMatching:
				if extra["achieved_i"] == 0 && try_to_activate_constellation("Aries"):
					extra["achieved_i"] = 1
					tween.tween_callback(func():
						SEffect.show_constellation(name)
					)
					tween.tween_interval(1.0 * G.time_scale)
					tween.tween_callback(func():
						Board.activate(self, C.HostType.Relic, 0, Vector2i(-1, -1), Board.ActiveReason.Relic, self)
					)
					return true
				return false
		on_active = func(effect_index : int, _c : Vector2i, tween : Tween):
			var range = 6
			var coord = Board.center
			var coords : Array[Vector2i] = []
			for r in range:
				if r == 0:
					coords.append(coord)
				else:
					for c in Board.offset_ring(coord, r):
						if Board.is_valid(c):
							coords.append(c)
			var time_scale = 1.2
			var ui = SEffect.add_movie("Aries", 2.0 * time_scale * G.time_scale, time_scale / G.time_scale)
			G.game_ui.game_overlay.add_child(ui)
			ui.position = Board.get_pos(Board.center)
			tween.tween_interval(1.2 * time_scale * G.time_scale)
			tween.tween_callback(func():
				SEffect.add_gem_burst(coord, coords, range, 0.3 * G.time_scale)
			)
			tween.tween_interval(0.3 * G.time_scale)
			tween.tween_callback(func():
				G.add_chain()
			)
			Board.eliminate(coords, 0, tween, Board.ActiveReason.Relic, self, true)
			'''
			var times = extra["times_i"]
			for i in times:
				var subtween = G.create_game_tween()
				subtween.tween_interval(i * 0.1 * G.time_scale)
				var target = Vector2i(G.game_rng.randi_range(0, Board.cx - 1), G.game_rng.randi_range(0, Board.cy - 1))
				Board.effect_explode(ui.get_global_rect().get_center(), target, extra["range_i"], 0, subtween)
				if i > 0:
					tween.parallel()
				tween.tween_subtween(subtween)
			'''
	elif name == "Taurus":
		image_id = 19
		price = 4
		extra["value_i"] = 500
		on_event = func(event : int, tween : Tween, data):
			if event == C.Event.GainRelic:
				if data == self:
					SUtils.add_event_listener(Board, C.Event.BeforeMatching, self, C.HostType.Relic)
			elif event == C.Event.BeforeMatching:
				if try_to_activate_constellation("Taurus"):
					pass
	elif name == "Gemini":
		image_id = 20
		price = 4
		on_event = func(event : int, tween : Tween, data):
			if event == C.Event.GainRelic:
				if data == self:
					SUtils.add_event_listener(Board, C.Event.BeforeMatching, self, C.HostType.Relic)
			elif event == C.Event.BeforeMatching:
				if try_to_activate_constellation("Gemini"):
					pass
		on_active = func(effect_index : int, _c : Vector2i, tween : Tween):
			if !Hand.grabs.is_empty():
				var idx = 0
				var ui_pos = ui.get_global_rect().get_center()
				tween.tween_callback(func():
					SEffect.add_leading_line(ui_pos, Hand.ui.get_pos(idx), 0.3 * G.time_scale)
				)
				tween.tween_interval(0.3 * G.time_scale)
				tween.tween_callback(func():
					G.duplicate_gem(null, Hand.grabs[idx], Hand.ui.get_slot(idx))
				)
	elif name == "Cancer":
		image_id = 21
		on_event = func(event : int, tween : Tween, data):
			if event == C.Event.GainRelic:
				if data == self:
					SUtils.add_event_listener(Board, C.Event.BeforeMatching, self, C.HostType.Relic)
			elif event == C.Event.BeforeMatching:
				if try_to_activate_constellation("Cancer"):
					pass
		on_active = func(effect_index : int, _c : Vector2i, tween : Tween):
			if !G.current_curses.is_empty():
				var ui_pos = ui.get_global_rect().get_center()
				var curse = G.current_curses[G.game_rng.randi_range(0, G.current_curses.size() - 1)]
				if curse.coord.x != -1 && curse.coord.y != -1:
					tween.tween_callback(func():
						SEffect.add_leading_line(ui_pos, Board.get_pos(curse.coord), 0.3 * G.time_scale)
					)
					tween.tween_interval(0.3 * G.time_scale)
				tween.tween_callback(func():
					G.remove_curse(curse)
				)
	elif name == "Leo":
		image_id = 22
		price = 10
		on_event = func(event : int, tween : Tween, data):
			if event == C.Event.GainRelic:
				if data == self:
					SUtils.add_event_listener(Board, C.Event.BeforeMatching, self, C.HostType.Relic)
			elif event == C.Event.BeforeMatching:
				if try_to_activate_constellation("Leo"):
					pass
	elif name == "Virgo":
		image_id = 23
		price = 4
		extra["value_f"] = 1.8
		on_event = func(event : int, tween : Tween, data):
			if event == C.Event.GainRelic:
				if data == self:
					SUtils.add_event_listener(Board, C.Event.BeforeMatching, self, C.HostType.Relic)
			elif event == C.Event.BeforeMatching:
				if try_to_activate_constellation("Virgo"):
					pass
	elif name == "Libra":
		image_id = 24
		on_event = func(event : int, tween : Tween, data):
			if event == C.Event.GainRelic:
				if data == self:
					SUtils.add_event_listener(Board, C.Event.BeforeMatching, self, C.HostType.Relic)
			elif event == C.Event.BeforeMatching:
				if try_to_activate_constellation("Libra"):
					pass
		on_active = func(effect_index : int, _c : Vector2i, tween : Tween):
			tween.tween_callback(func():
				G.float_text(tr("str_Libra_effect"), ui.get_global_rect().get_center() + Vector2(84, 0))
				var v = G.base_score + G.score_mult
				v = ceil(v / 2.0)
				G.base_score = int(v)
				G.score_mult = v
			)
	elif name == "Scorpio":
		image_id = 25
		price = 4
		on_event = func(event : int, tween : Tween, data):
			if event == C.Event.GainRelic:
				if data == self:
					SUtils.add_event_listener(Board, C.Event.BeforeMatching, self, C.HostType.Relic)
			elif event == C.Event.BeforeMatching:
				if try_to_activate_constellation("Scorpio"):
					pass
		on_active = func(effect_index : int, _c : Vector2i, tween : Tween):
			if !Hand.grabs.is_empty() && G.gems.size() - 1 >= Board.curr_min_gem_num:
				var idx = Hand.grabs.size() - 1
				var ui_pos = ui.get_global_rect().get_center()
				tween.tween_callback(func():
					SEffect.add_leading_line(ui_pos, Hand.ui.get_pos(idx))
				)
				tween.tween_interval(0.3)
				tween.tween_callback(func():
					G.delete_gem(null, Hand.grabs[idx], Hand.ui.get_slot(idx).gem_ui)
				)
	elif name == "Sagittarius":
		image_id = 26
		price = 4
		on_event = func(event : int, tween : Tween, data):
			if event == C.Event.GainRelic:
				if data == self:
					SUtils.add_event_listener(Board, C.Event.BeforeMatching, self, C.HostType.Relic)
			elif event == C.Event.BeforeMatching:
				if try_to_activate_constellation("Sagittarius"):
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
					G.add_chain()
				)
				Board.eliminate([target], 0, tween, Board.ActiveReason.Relic, self)
	elif name == "Capricorn":
		image_id = 27
		price = 4
		extra["amount_i"] = 1
		on_event = func(event : int, tween : Tween, data):
			if event == C.Event.GainRelic:
				if data == self:
					SUtils.add_event_listener(Board, C.Event.BeforeMatching, self, C.HostType.Relic)
			elif event == C.Event.BeforeMatching:
				if try_to_activate_constellation("Capricorn"):
					pass
	elif name == "Aquarius":
		image_id = 28
		price = 4
		extra["value_i"] = 1
		on_event = func(event : int, tween : Tween, data):
			if event == C.Event.GainRelic:
				if data == self:
					SUtils.add_event_listener(Board, C.Event.BeforeMatching, self, C.HostType.Relic)
			elif event == C.Event.BeforeMatching:
				if try_to_activate_constellation("Aquarius"):
					pass
		on_active = func(effect_index : int, _c : Vector2i, tween : Tween):
			var cands = Board.filter(func(gem : Gem):
				return gem != null
			)
			if !cands.is_empty():  
				var ui_pos = ui.get_global_rect().get_center()
				var targets = SMath.pick_n_random(cands, 1, G.game_rng)
				tween.tween_callback(func():
					for c in targets:
						var g = Board.get_gem_at(c)
						if g:
							SEffect.add_leading_line(ui_pos, Board.get_pos(c))
				)
				tween.tween_interval(0.3)
				tween.tween_callback(func():
					var value = extra["value_i"]
					var ok = false
					for c in targets:
						var g = Board.get_gem_at(c)
						if g:
							G.float_text("[color=AA75DD]+%d" % value, Board.get_pos(c))
							g.base_score += value
							ok = true
					if ok:
						SSound.se_vibra.play()
				)
	elif name == "Pisces":
		image_id = 29
		price = 4
		on_event = func(event : int, tween : Tween, data):
			if event == C.Event.GainRelic:
				if data == self:
					SUtils.add_event_listener(Board, C.Event.BeforeMatching, self, C.HostType.Relic)
			elif event == C.Event.BeforeMatching:
				if try_to_activate_constellation("Pisces"):
					pass
		on_active = func(effect_index : int, _c : Vector2i, tween : Tween):
			var cands = Board.filter(func(gem : Gem):
				if gem && gem.type != Gem.ColorWild:
					return true
				return false
			)
			if !cands.is_empty():
				var ui_pos = ui.get_global_rect().get_center()
				var targets = SMath.pick_n_random(cands, 2, G.game_rng) 
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
	elif name == "Sandcastle":
		image_id = 30
		price = 5
		sockets.resize(3)
		extra["bouns_i"] = 10
		on_socket = func(index : int, g : Gem):
			var bouns = extra["bouns_i"]
			if sockets[index]:
				G.change_modifier(Gem.color_bouns_name(sockets[index].type), -bouns)
			if g:
				G.change_modifier(Gem.color_bouns_name(g.type), bouns)

static var constellation_star_coords : Dictionary = {}

static func get_constellation_star_coords(name : String, translate : bool = false):
	if !constellation_star_coords.has(name):
		var content = Painting.load_from_file(name)
		var whites = content.colors.get(Gem.ColorWhite, [])
		var coords = []
		for p in whites:
			coords.append(p)
		constellation_star_coords[name] = coords
	if !translate:
		return constellation_star_coords[name]
	var coords = constellation_star_coords[name]
	var center = Board.offset_to_cube(Board.center)
	var ret = []
	for c in coords:
		ret.append(Board.cube_to_offset(center + c))
	return ret

func try_to_activate_constellation(name : String):
	var coords = get_constellation_star_coords(name, true)
	var ok = true
	for c in coords:
		var g = Board.get_gem_at(c)
		if !g || (g.rune != Gem.RuneStar && g.rune != Gem.RuneOmni):
			ok = false
			break
	# TODO
	ok = true
	return ok

func get_tooltip():
	var ret : Array[Pair] = []
	var content = tr("relic_desc_" + name).format(extra)
	ret.append(Pair.new(tr("relic_name_" + name), content))
	return ret
