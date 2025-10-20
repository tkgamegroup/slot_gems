extends Object

class_name Curse

var type : String
var coord : Vector2i = Vector2i(-1, -1)
var afflicted_gem : Gem = null
var created_sin : Item = null

static var lust_triggered = 0

static func pick_targets():
	var cates = {}
	for c in Game.current_curses:
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
				var coords = SMath.pick_n_random(cands, n)
				for i in n:
					cs[i].coord = coords[i]
		elif k == "curse_sloth":
			var cands = Board.filter2(func(c : Cell):
				return !c.in_mist
			)
			if !cands.is_empty():
				var cs = cates[k]
				var n = min(cs.size(), cands.size())
				var coords = SMath.pick_n_random(cands, n)
				for i in n:
					cs[i].coord = coords[i]
		elif k == "curse_wrath":
			var cands = Board.filter(func(g : Gem, i : Item):
				return g
			)
			if !cands.is_empty():
				var cs = cates[k]
				var n = min(cs.size(), cands.size())
				var coords = SMath.pick_n_random(cands, n, Game.rng)
				for i in n:
					cs[i].coord = coords[i]
		elif k == "curse_lust" || k == "curse_envy" || k == "curse_gluttony" || k == "curse_greed":
			var cands = Board.filter(func(g : Gem, i : Item):
				return g && !i
			)
			if !cands.is_empty():
				var cs = cates[k]
				var n = min(cs.size(), cands.size())
				var coords = SMath.pick_n_random(cands, n, Game.rng)
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
	for c in Game.current_curses:
		if cates.has(c.type):
			cates[c.type].append(c)
		else:
			cates[c.type] = [c]
	for k in cates.keys():
		var cs = cates[k]
		match k:
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
					var v = int((Game.coins + 5) / n) + 1
					Game.coins = 0
					for i in n:
						cs[i].add_sin("SinGreed")
						cs[i].created_sin.extra["value"] = v
			"curse_sloth":
				for c in cs:
					Game.float_text(Game.tr("tt_cell_in_mist"), Board.get_pos(c.coord), Color(1.0, 1.0, 1.0), 22)
					Board.set_in_mist(c.coord, true)
			"curse_wrath":
				for c in cs:
					Game.delete_gem(Board.get_gem_at(c.coord), Board.ui.get_cell(c.coord).gem_ui, "board")
			"curse_envy":
				for c in cs:
					c.add_sin("SinEnvy")
			"curse_pride":
				for c in cs:
					Game.float_text(Game.tr("tt_cell_nullified"), Board.get_pos(c.coord), Color(1.0, 1.0, 1.0), 22)
					Board.set_nullified(c.coord, true)

func add_sin(n : String):
	if afflicted_gem:
		var b = Buff.create(afflicted_gem, Buff.Type.ChangeRune, {"rune":Gem.Rune.None}, Buff.Duration.OnBoard) 
		b.caster = self
		created_sin = Item.new()
		created_sin.setup(n)
		Game.items.append(created_sin)
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
