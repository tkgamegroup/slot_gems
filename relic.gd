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

func setup(n : String):
	name = n
	if name == "PaintingOfRed":
		image_id = 1
		extra["value_i"] = 40
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
		extra["value_i"] = 40
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
		extra["value_i"] = 40
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
		extra["value_i"] = 40
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
		extra["value_i"] = 40
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
		extra["value_i"] = 40
		price = 5
		on_event = func(event : int, tween : Tween, data):
			if event == C.Event.GainRelic:
				if data == self:
					SUtils.add_event_listener(Board, C.Event.Eliminated, self, C.HostType.Relic)
			elif event == C.Event.LostRelic:
				if data == self:
					SUtils.remove_event_listeners(Board, self)
			elif event == C.Event.Eliminated:
				var c = data["coord"]
				var g = Board.get_gem_at(c)
				if g && g.rune == Gem.RuneWave || g.rune == Gem.RuneOmni:
					G.add_score(extra["value_i"], Board.get_pos(c))
	elif name == "PaintingOfPalm":
		image_id = 7
		extra["value_i"] = 40
		price = 5
		on_event = func(event : int, tween : Tween, data):
			if event == C.Event.GainRelic:
				if data == self:
					SUtils.add_event_listener(Board, C.Event.Eliminated, self, C.HostType.Relic)
			elif event == C.Event.LostRelic:
				if data == self:
					SUtils.remove_event_listeners(Board, self)
			elif event == C.Event.Eliminated:
				var c = data["coord"]
				var g = Board.get_gem_at(c)
				if g && g.rune == Gem.RunePalm || g.rune == Gem.RuneOmni:
					G.add_score(extra["value_i"], Board.get_pos(c))
	elif name == "PaintingOfStarfish":
		image_id = 8
		extra["value_i"] = 40
		price = 5
		on_event = func(event : int, tween : Tween, data):
			if event == C.Event.GainRelic:
				if data == self:
					SUtils.add_event_listener(Board, C.Event.Eliminated, self, C.HostType.Relic)
			elif event == C.Event.LostRelic:
				if data == self:
					SUtils.remove_event_listeners(Board, self)
			elif event == C.Event.Eliminated:
				var c = data["coord"]
				var g = Board.get_gem_at(c)
				if g && g.rune == Gem.RuneStarfish || g.rune == Gem.RuneOmni:
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
					G.set_modifier("base_combo_i", extra["value_i"])
			elif event == C.Event.LostRelic:
				if data == self:
					G.set_modifier("base_combo_i", 0)
	elif name == "PentagramPower":
		image_id = 15
		price = 9
		extra["value_f"] = 25.0
		on_event = func(event : int, tween : Tween, data):
			if event == C.Event.GainRelic:
				if data == self:
					SUtils.add_event_listener(Board, C.Event.Combo, self, C.HostType.Relic)
			elif event == C.Event.LostRelic:
				if data == self:
					SUtils.remove_event_listeners(Board, self)
			elif event == C.Event.Combo:
				if G.combos > 0 && G.combos % 5 == 0:
					var v = extra["value_f"]
					Buff.create(G, Buff.Type.ValueModifier, {"target":"gain_scaler","mult":v}, Buff.Duration.ThisCombo)
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
			elif event == C.Event.LostRelic:
				if data == self:
					SUtils.remove_event_listeners(Board, self)
			elif event == C.Event.GemBaseScoreChanged || event == C.Event.GemBonusScoreChanged:
				if data["value"] < 0:
					data["value"] = 0
	elif name == "Aries":
		image_id = 18
		price = 4
		extra["range_i"] = 0
		extra["times_i"] = 3
		on_event = func(event : int, tween : Tween, data):
			if event == C.Event.GainRelic:
				if data == self:
					SUtils.add_event_listener(Board, C.Event.Eliminated, self, C.HostType.Relic)
			elif event == C.Event.LostRelic:
				if data == self:
					SUtils.remove_event_listeners(Board, self)
			elif event == C.Event.Eliminated:
				if data["reason"] == Board.ActiveReason.Pattern:
					#active_constellation(3, 0, 0, data["coords"], tween)
					pass
		on_active = func(effect_index : int, _c : Vector2i, tween : Tween):
			var times = extra["times_i"]
			for i in times:
				var subtween = G.game_tweens.create_tween()
				subtween.tween_interval(i * 0.1 * G.speed)
				var target = Vector2i(G.game_rng.randi_range(0, Board.cx - 1), G.game_rng.randi_range(0, Board.cy - 1))
				Board.effect_explode(ui.get_global_rect().get_center(), target, extra["range_i"], 0, subtween)
				if i > 0:
					tween.parallel()
				tween.tween_subtween(subtween)
	elif name == "Taurus":
		image_id = 19
		price = 4
		extra["value_i"] = 500
		on_event = func(event : int, tween : Tween, data):
			if event == C.Event.GainRelic:
				if data == self:
					SUtils.add_event_listener(Board, C.Event.Eliminated, self, C.HostType.Relic)
			elif event == C.Event.LostRelic:
				if data == self:
					SUtils.remove_event_listeners(Board, self)
			elif event == C.Event.Eliminated:
				if data["reason"] == Board.ActiveReason.Pattern:
					#if active_constellation(0, 0, 3, data["coords"], tween, false):
					#	tween.tween_callback(func():
					#		G.add_score(extra["value_i"], ui.get_global_rect().get_center() + Vector2(84, 0))
					#	)
					#	tween.tween_interval(0.5 * G.speed)
					pass
	elif name == "Gemini":
		image_id = 20
		price = 4
		on_event = func(event : int, tween : Tween, data):
			if event == C.Event.GainRelic:
				if data == self:
					SUtils.add_event_listener(Board, C.Event.Eliminated, self, C.HostType.Relic)
			elif event == C.Event.LostRelic:
				if data == self:
					SUtils.remove_event_listeners(Board, self)
			elif event == C.Event.Eliminated:
				if data["reason"] == Board.ActiveReason.Pattern:
					#active_constellation(0, 3, 0, data["coords"], tween)
					pass
		on_active = func(effect_index : int, _c : Vector2i, tween : Tween):
			if !Hand.grabs.is_empty():
				var idx = 0
				var ui_pos = ui.get_global_rect().get_center()
				tween.tween_callback(func():
					SEffect.add_leading_line(ui_pos, Hand.ui.get_pos(idx), 0.3 * G.speed)
				)
				tween.tween_interval(0.3 * G.speed)
				tween.tween_callback(func():
					G.duplicate_gem(null, Hand.grabs[idx], Hand.ui.get_slot(idx))
				)
	elif name == "Cancer":
		image_id = 21
		on_event = func(event : int, tween : Tween, data):
			if event == C.Event.GainRelic:
				if data == self:
					SUtils.add_event_listener(Board, C.Event.Eliminated, self, C.HostType.Relic)
			elif event == C.Event.LostRelic:
				if data == self:
					SUtils.remove_event_listeners(Board, self)
			elif event == C.Event.Eliminated:
				if data["reason"] == Board.ActiveReason.Pattern:
					#active_constellation(0, 1, 2, data["coords"], tween)
					pass
		on_active = func(effect_index : int, _c : Vector2i, tween : Tween):
			if !G.current_curses.is_empty():
				var ui_pos = ui.get_global_rect().get_center()
				var curse = G.current_curses[G.game_rng.randi_range(0, G.current_curses.size() - 1)]
				if curse.coord.x != -1 && curse.coord.y != -1:
					tween.tween_callback(func():
						SEffect.add_leading_line(ui_pos, Board.get_pos(curse.coord), 0.3 * G.speed)
					)
					tween.tween_interval(0.3 * G.speed)
				tween.tween_callback(func():
					G.remove_curse(curse)
				)
	elif name == "Leo":
		image_id = 22
		price = 10
		on_event = func(event : int, tween : Tween, data):
			if event == C.Event.GainRelic:
				if data == self:
					SUtils.add_event_listener(Board, C.Event.Eliminated, self, C.HostType.Relic)
			elif event == C.Event.LostRelic:
				if data == self:
					SUtils.remove_event_listeners(Board, self)
			elif event == C.Event.Eliminated:
				if data["reason"] == Board.ActiveReason.Pattern:
					#if active_constellation(2, 1, 1, data["coords"], tween, false):
					#	tween.tween_callback(func():
					#		var ui_pos = ui.get_global_rect().get_center()
					#		SEffect.add_leading_line(ui_pos, G.control_ui.swaps_text.get_global_rect().get_center())
					#	)
					#	tween.tween_interval(0.3)
					#	tween.tween_callback(func():
					#		SSound.se_vibra.play()
					#		G.swaps += 1
					#	)
					#	tween.tween_interval(0.5 * G.speed)
					pass
	elif name == "Virgo":
		image_id = 23
		price = 4
		extra["value_f"] = 1.8
		on_event = func(event : int, tween : Tween, data):
			if event == C.Event.GainRelic:
				if data == self:
					SUtils.add_event_listener(Board, C.Event.Eliminated, self, C.HostType.Relic)
			elif event == C.Event.LostRelic:
				if data == self:
					SUtils.remove_event_listeners(Board, self)
			elif event == C.Event.Eliminated:
				if data["reason"] == Board.ActiveReason.Pattern:
					#if active_constellation(0, 2, 1, data["coords"], tween, false):
					#	tween.tween_callback(func():
					#		var v = extra["value_f"]
					#		var pos = ui.get_global_rect().get_center() + Vector2(84, 0)
					#		G.add_mult(v, pos)
					#	)
					#	tween.tween_interval(0.5 * G.speed)
					pass
	elif name == "Libra":
		image_id = 24
		on_event = func(event : int, tween : Tween, data):
			if event == C.Event.GainRelic:
				if data == self:
					SUtils.add_event_listener(Board, C.Event.Eliminated, self, C.HostType.Relic)
			elif event == C.Event.LostRelic:
				if data == self:
					SUtils.remove_event_listeners(Board, self)
			elif event == C.Event.Eliminated:
				if data["reason"] == Board.ActiveReason.Pattern:
					#active_constellation(0, 2, 1, data["coords"], tween)
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
					SUtils.add_event_listener(Board, C.Event.Eliminated, self, C.HostType.Relic)
			elif event == C.Event.LostRelic:
				if data == self:
					SUtils.remove_event_listeners(Board, self)
			elif event == C.Event.Eliminated:
				if data["reason"] == Board.ActiveReason.Pattern:
					#active_constellation(2, 1, 0, data["coords"], tween)
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
					SUtils.add_event_listener(Board, C.Event.Eliminated, self, C.HostType.Relic)
			elif event == C.Event.LostRelic:
				if data == self:
					SUtils.remove_event_listeners(Board, self)
			elif event == C.Event.Eliminated:
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
					G.add_combo()
					Board.score_at(target)
				)
				Board.eliminate([target], tween, Board.ActiveReason.Relic, self)
	elif name == "Capricorn":
		image_id = 27
		price = 4
		extra["amount_i"] = 1
		on_event = func(event : int, tween : Tween, data):
			if event == C.Event.GainRelic:
				if data == self:
					SUtils.add_event_listener(Board, C.Event.Eliminated, self, C.HostType.Relic)
			elif event == C.Event.LostRelic:
				if data == self:
					SUtils.remove_event_listeners(Board, self)
			elif event == C.Event.Eliminated:
				if data["reason"] == Board.ActiveReason.Pattern:
					#if active_constellation(1, 0, 2, data["coords"], tween, false):
					#	tween.tween_callback(func():
					#		var amount = extra["amount_i"]
					#		SSound.se_coin.play()
					#		G.float_text("[img]res://images/coin.png[/img][color=FFAA00]+%d[/color]" % amount, ui.get_global_rect().get_center() + Vector2(84, 0))
					#		G.coins += amount
					#	)
					#	tween.tween_interval(0.5 * G.speed)
					pass
	elif name == "Aquarius":
		image_id = 28
		price = 4
		extra["value_i"] = 1
		on_event = func(event : int, tween : Tween, data):
			if event == C.Event.GainRelic:
				if data == self:
					SUtils.add_event_listener(Board, C.Event.Eliminated, self, C.HostType.Relic)
			elif event == C.Event.LostRelic:
				if data == self:
					SUtils.remove_event_listeners(Board, self)
			elif event == C.Event.Eliminated:
				if data["reason"] == Board.ActiveReason.Pattern:
					#active_constellation(0, 3, 0, data["coords"], tween)
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
					SUtils.add_event_listener(Board, C.Event.Eliminated, self, C.HostType.Relic)
			elif event == C.Event.LostRelic:
				if data == self:
					SUtils.remove_event_listeners(Board, self)
			elif event == C.Event.Eliminated:
				if data["reason"] == Board.ActiveReason.Pattern:
					#active_constellation(0, 1, 2, data["coords"], tween)
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

func get_tooltip():
	var ret : Array[Pair] = []
	var content = tr("relic_desc_" + name).format(extra)
	ret.append(Pair.new(tr("relic_name_" + name), content))
	return ret
