extends Object

class_name Curse

var type : String
var coord : Vector2i = Vector2i(-1, -1)
var afflicted_gem : Gem = null
var created_sin : Item = null

static var lust_triggered = 0

static func pick_targets():
	var cates = {}
	for c in G.current_curses:
		if cates.has(c.type):
			cates[c.type].append(c)
		else:
			cates[c.type] = [c]
	for k in cates.keys():
		if k == "curse_pride":
			var cands = Board.filter2(func(c : Cell):
				return !c.nullified
			)
			if !cands.is_empty():
				var cs = cates[k]
				var n = min(cs.size(), cands.size())
				var coords = SMath.pick_n_random(cands, n, G.game_rng)
				for i in n:
					cs[i].coord = coords[i]
		elif k == "curse_sloth":
			var cands = Board.filter2(func(c : Cell):
				return !c.in_mist
			)
			if !cands.is_empty():
				var cs = cates[k]
				var n = min(cs.size(), cands.size())
				var coords = SMath.pick_n_random(cands, n, G.game_rng)
				for i in n:
					cs[i].coord = coords[i]
		elif k == "curse_wrath":
			var cands = Board.filter(func(g : Gem):
				return g
			)
			if !cands.is_empty():
				var cs = cates[k]
				var n = min(cs.size(), cands.size())
				var coords = SMath.pick_n_random(cands, n, G.game_rng)
				for i in n:
					cs[i].coord = coords[i]
		elif k == "curse_lust" || k == "curse_envy" || k == "curse_gluttony" || k == "curse_greed":
			var cands = Board.filter(func(g : Gem):
				return g && !g.name == ""
			)
			if !cands.is_empty():
				var cs = cates[k]
				var n = min(cs.size(), cands.size())
				var coords = SMath.pick_n_random(cands, n, G.game_rng)
				if k == "curse_lust":
					if n >= 2:
						for i in n:
							cs[i].afflicted_gem = Board.get_gem_at(coords[i])
				elif k == "curse_greed":
					if n >= 2:
						for i in n:
							cs[i].afflicted_gem = Board.get_gem_at(coords[i])
				else:
					for i in n:
						cs[i].afflicted_gem = Board.get_gem_at(coords[i])

static func apply_curses():
	var cates = {}
	for c in G.current_curses:
		if cates.has(c.type):
			cates[c.type].append(c)
		else:
			cates[c.type] = [c]
	for k in cates.keys():
		var cs = cates[k]
		match k:
			"curse_red_no_score":
				G.no_score_marks[Gem.ColorRed].push_front(true)
			"curse_orange_no_score":
				G.no_score_marks[Gem.ColorOrange].push_front(true)
			"curse_green_no_score":
				G.no_score_marks[Gem.ColorGreen].push_front(true)
			"curse_blue_no_score":
				G.no_score_marks[Gem.ColorBlue].push_front(true)
			"curse_magenta_no_score":
				G.no_score_marks[Gem.ColorMagenta].push_front(true)
			"curse_wave_no_score":
				G.no_score_marks[Gem.RuneWave].push_front(true)
			"curse_palm_no_score":
				G.no_score_marks[Gem.RunePalm].push_front(true)
			"curse_starfish_no_score":
				G.no_score_marks[Gem.RuneStarfish].push_front(true)
			"curse_lust":
				for c in cs:
					c.add_sin("SinLust")
				lust_triggered = 0
			"curse_gluttony":
				for c in cs:
					c.add_sin("SinGluttony")
			"curse_greed":
				var n = 0
				for c in cs:
					if c.afflicted_gem:
						n += 1
				if n >= 2:
					var v = int((G.coins + 5) / n) + 1
					G.coins = 0
					for i in n:
						cs[i].add_sin("SinGreed")
						cs[i].created_sin.extra["value"] = v
			"curse_sloth":
				for c in cs:
					G.float_text(G.tr("tt_cell_in_mist"), Board.get_pos(c.coord))
					Board.set_in_mist(c.coord, true)
			"curse_wrath":
				for c in cs:
					G.delete_gem(null, Board.get_gem_at(c.coord), Board.ui.get_cell(c.coord).gem_ui, "board")
			"curse_envy":
				for c in cs:
					c.add_sin("SinEnvy")
			"curse_pride":
				for c in cs:
					G.float_text(G.tr("tt_cell_nullified"), Board.get_pos(c.coord))
					Board.set_nullified(c.coord, true)

func add_sin(n : String):
	if afflicted_gem:
		var b = Buff.create(afflicted_gem, Buff.Type.ChangeRune, {"rune":Gem.None}, Buff.Duration.OnBoard) 
		b.caster = self
		created_sin = Item.new()
		created_sin.setup(n)
		#G.items.append(created_sin)
		#Board.set_item_at(afflicted_gem.coord, created_sin)

func remove_sin():
	if afflicted_gem:
		Buff.remove_by_caster(afflicted_gem, self)
		if created_sin.coord.x != -1 && created_sin.coord.y != -1:
			pass
			#Board.set_item_at(created_sin.coord, null)
		created_sin = null

func remove():
	match type:
		"curse_red_no_score":
			G.no_score_marks[Gem.ColorRed].pop_front()
		"curse_orange_no_score":
			G.no_score_marks[Gem.ColorOrange].pop_front()
		"curse_green_no_score":
			G.no_score_marks[Gem.ColorGreen].pop_front()
		"curse_blue_no_score":
			G.no_score_marks[Gem.ColorBlue].pop_front()
		"curse_magenta_no_score":
			G.no_score_marks[Gem.ColorMagenta].pop_front()
		"curse_wave_no_score":
			G.no_score_marks[Gem.RuneWave].pop_front()
		"curse_palm_no_score":
			G.no_score_marks[Gem.RunePalm].pop_front()
		"curse_starfish_no_score":
			G.no_score_marks[Gem.RuneStarfish].pop_front()
		"curse_lust":
			remove_sin()
		"curse_gluttony":
			remove_sin()
		"curse_greed":
			remove_sin()
		"curse_sloth":
			Board.set_in_mist(coord, false)
		"curse_wrath":
			pass
		"curse_envy":
			remove_sin()
		"curse_pride":
			Board.set_nullified(coord, false)
