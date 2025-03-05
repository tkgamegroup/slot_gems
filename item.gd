extends Object

class_name Item

const item_frames : SpriteFrames = preload("res://images/items.tres")

var name : String
var image_id : int
var active : bool = false
var description : String
var category : String
var require_type : int = Gem.Type.None

var extra = {}

var on_process : Callable
var on_place : Callable
var on_quick : Callable
var on_eliminate : Callable
var on_aura : Callable
var on_combo : Callable

func setup(n : String):
	name = n
	if name == "Dye: Red":
		image_id = 1
		description = "Quick: Change gem to red color."
		on_quick = func(b : Board, coord : Vector2i):
			var g = b.get_gem_at(coord)
			if g:
				Buff.create(g, Buff.Type.ChangeColor, {"color":Gem.Type.Red})
	elif name == "Dye: Orange":
		image_id = 2
		description = "Quick: Change gem to orange color."
		on_quick = func(b : Board, coord : Vector2i):
			var g = b.get_gem_at(coord)
			if g:
				Buff.create(g, Buff.Type.ChangeColor, {"color":Gem.Type.Orange})
	elif name == "Dye: Green":
		image_id = 3
		description = "Quick: Change gem to green color."
		on_quick = func(b : Board, coord : Vector2i):
			var g = b.get_gem_at(coord)
			if g:
				Buff.create(g, Buff.Type.ChangeColor, {"color":Gem.Type.Green})
	elif name == "Dye: Blue":
		image_id = 4
		description = "Quick: Change gem to blue color."
		on_quick = func(b : Board, coord : Vector2i):
			var g = b.get_gem_at(coord)
			if g:
				Buff.create(g, Buff.Type.ChangeColor, {"color":Gem.Type.Blue})
	elif name == "Dye: Pink":
		image_id = 5
		description = "Quick: Change gem to pink color."
		on_quick = func(b : Board, coord : Vector2i):
			var g = b.get_gem_at(coord)
			if g:
				Buff.create(g, Buff.Type.ChangeColor, {"color":Gem.Type.Pink})
	elif name == "Flag":
		image_id = 6
		description = "Aura: +1 score."
		on_aura = func(event : int, b : Board, coord : Vector2i):
			var g = b.get_gem_at(coord)
			if g:
				if event == Board.AuraEvent.Enter:
					g.bonus_score += 1
				else:
					g.bonus_score -= 1
	elif name == "Bomb":
		image_id = 7
		description = "Active: Eliminate cells in 1-ring."
		category = "Bomb"
		on_process = func(b : Board, coord : Vector2i, tween : Tween, item_ui : AnimatedSprite2D):
			var coords : Array[Vector2i] = []
			coords.append(coord)
			for c in b.offset_neighbors(coord):
				coords.append(c)
			tween.tween_callback(func():
				var pos = b.get_pos(coord)
				var sp_expl = SEffect.add_explosion(pos, Vector2(64.0, 64.0), 3, 0.5)
				Game.cells_root.add_child(sp_expl)
				var fx = SEffect.add_distortion(pos, Vector2(64.0, 64.0), 4, 0.5)
				Game.cells_root.add_child(fx)
				Game.add_combo()
				for c in coords:
					if b.is_valid(c):
						Game.add_score(b.gem_score_at(c), b.get_pos(c))
			)
			b.eliminate(coords, tween, Board.ActiveReason.Item, self)
	elif name == "C4":
		image_id = 8
		description = "Active: Eliminate cells in 2-ring (Only activate by Bomb)."
		category = "Bomb"
		on_eliminate = func(b : Board, coord : Vector2i, reason : int, source):
			if reason == Board.ActiveReason.Item && source.category == "Bomb":
				return true
			return false
		on_process = func(b : Board, coord : Vector2i, tween : Tween, item_ui : AnimatedSprite2D):
			var coords : Array[Vector2i] = []
			coords.append(coord)
			for i in 2:
				for c in b.offset_ring(coord, i + 1):
					coords.append(c)
			tween.tween_callback(func():
				var pos = b.get_pos(coord)
				var sp_expl = SEffect.add_big_explosion(pos, Vector2(128.0, 128.0), 3, 0.5)
				Game.cells_root.add_child(sp_expl)
				var fx = SEffect.add_distortion(pos, Vector2(128.0, 128.0), 4, 0.5)
				Game.cells_root.add_child(fx)
				var score = 0
				Game.add_combo()
				for c in coords:
					if b.is_valid(c):
						Game.add_score(b.gem_score_at(c), b.get_pos(c))
			)
			b.eliminate(coords, tween, Board.ActiveReason.Item, self)
	elif name == "Chain Bomb":
		image_id = 9
		description = "Active: activate a random nearby gem. \nWhen combos hits 4, activate this"
		category = "Bomb"
		on_process = func(b : Board, coord : Vector2i, tween : Tween, item_ui : AnimatedSprite2D):
			var coords : Array[Vector2i] = [coord]
			tween.tween_callback(func():
				for c in b.offset_neighbors(coord):
					var item = b.get_item_at(c)
					if item:
						b.activate_item(item, Board.ActiveReason.Item, self)
				Game.add_combo()
				Game.add_score(b.gem_score_at(coord), b.get_pos(coord))
			)
			b.eliminate(coords, tween, Board.ActiveReason.Item, self)
		on_combo = func(b : Board, combo : int):
			if combo >= 4:
				b.activate_item(self, Board.ActiveReason.Item, self)
	elif name == "Virus":
		image_id = 10
		description = "Active: Eliminate all connected cells with the same color of this."
		category = "Normal"
		on_process = func(b : Board, coord : Vector2i, tween : Tween, item_ui : AnimatedSprite2D):
			var temp_arr = [coord]
			var gem = b.get_gem_at(coord)
			var touched = {}
			temp_arr.append(coord)
			touched[coord] = 1
			while !temp_arr.is_empty():
				var c = temp_arr[0]
				temp_arr.remove_at(0)
				if b.get_gem_at(c) == gem:
					for cc in b.offset_neighbors(c):
						if !touched.has(cc):
							temp_arr.append(cc)
							touched[cc] = 1
			var coords : Array[Vector2i] = []
			for c in touched.keys():
				coords.append(c)
			tween.tween_callback(func():
				Game.add_combo()
				for c in coords:
					if b.is_valid(c):
						Game.add_score(b.gem_score_at(c), b.get_pos(c))
			)
			b.eliminate(coords, tween, Board.ActiveReason.Item, self)
	elif name == "Lightning":
		image_id = 11
		description = "Active: Eliminate cells that on the line to another active 'lightning'."
		category = "Normal"
		on_process = func(b : Board, coord : Vector2i, tween : Tween, item_ui : AnimatedSprite2D):
			var targets = b.find(func(gem : Gem, item : Item):
				return item && item != self && item.name == "lightning" && item.active
			)
			if !targets.is_empty():
				var target = targets.pick_random()
				var coords : Array[Vector2i] = [target]
				for c in b.draw_line(b.offset_to_cube(coord), b.offset_to_cube(target)):
					var cc = b.cube_to_offset(c)
					coords.append(cc)
				tween.tween_callback(func():
						var fx = SEffect.add_lighning(b.get_pos(coord), b.get_pos(target), 3, 0.5)
						Game.cells_root.add_child(fx)
						Game.add_combo()
						for c in coords:
							if b.is_valid(c):
								Game.add_score(b.gem_score_at(c), b.get_pos(c))
				)
				b.eliminate(coords, tween, Board.ActiveReason.Item, self)
			else:
				tween.tween_callback(func():
					SSound.sfx_lighting_fail.play()
				)
	elif name == "Color Palette":
		image_id = 12
		description = "Quick: Turn gem to wild type."
		category = "Normal"
		on_quick = func(b : Board, coord : Vector2i):
			var g = b.get_gem_at(coord)
			if g:
				Buff.create(g, Buff.Type.ChangeColor, {"color":Gem.Type.Wild})
		on_place = func(b : Board, coord : Vector2i):
			b.activate_item(self, Board.ActiveReason.Item, self)
	elif name == "Fire":
		image_id = 13
		description = "Active: Sets the cell to burning state."
		category = "Normal"
		on_eliminate = func(b : Board, coord : Vector2i, reason : int, source):
			b.set_state_at(coord, Cell.State.Burning)
			return true
	elif name == "Black Hole":
		image_id = 14
		description = "Active: if this the last item activated. Eliminate all cells."
		category = "Normal"
		on_process = func(b : Board, coord : Vector2i, tween : Tween, item_ui : AnimatedSprite2D):
			if SMath.last_one(b.active_items).first == self:
				var coords : Array[Vector2i] = []
				for y in b.cy:
					for x in b.cx:
						var c = Vector2i(x, y)
						coords.append(c)
				tween.tween_callback(func():
					var pos : Vector2 = b.get_pos(coord)
					var fx = SEffect.add_black_hole_rotating(pos, Vector2(128.0, 128.0), 0, 3.0)
					Game.underlay.add_child(fx)
					
					for c in coords:
						var ui = Game.get_cell_ui(c).gem
						var data = {"ui":ui,"vel":SMath.tangent2(b.get_pos(c) - pos).normalized() * 1.4}
						var tween2 = Game.get_tree().create_tween()
						tween2.tween_method(func(t):
							var d = pos.distance_to(data.ui.global_position)
							if d < 64.0:
								data.ui.scale = Vector2(d, d) / 64.0
								data.ui.global_position = lerp(data.ui.global_position, pos, 0.2)
							else:
								data.vel -= (data.ui.global_position - pos) * (0.2 / (d if d > 1.0 else 1.0))
								data.ui.global_position += data.vel
						, 0.0, 1.0, 2.5)
				)
				tween.tween_interval(3.0)
				tween.tween_callback(func():
						Game.add_combo()
						for c in coords:
							if b.is_valid(c):
								Game.add_score(b.gem_score_at(c), b.get_pos(c))
				)
				b.eliminate(coords, tween, Board.ActiveReason.Item, self)
	elif name == "White Hole":
		image_id = 15
		description = "Active: Eliminate all cells. (Only activate if this is the first item activated.)"
		category = "Normal"
		on_eliminate = func(b : Board, coord : Vector2i, reason : int, source):
			if b.active_items.is_empty():
				return true
			return false
		on_process = func(b : Board, coord : Vector2i, tween : Tween, item_ui : AnimatedSprite2D):
			var coords : Array[Vector2i] = []
			for y in b.cy:
				for x in b.cx:
					var c = Vector2i(x, y)
					coords.append(c)
			var pos : Vector2 = b.get_pos(coord)
			tween.tween_callback(func():
				var fx = SEffect.add_white_hole_injection(pos, Vector2(128.0, 128.0), 0, 3.0)
				Game.underlay.add_child(fx)
			)
			tween.tween_method(func(r : float):
				for c in coords:
					var ui = Game.get_cell_ui(c).gem
					if pos.distance_to(ui.global_position) < r:
						ui.scale = Vector2(0.0, 0.0).max(ui.scale - Vector2(0.1, 0.1))
			, 0.0, 1200.0, 3.0)
			tween.tween_callback(func():
					Game.add_combo()
					for c in coords:
						if b.is_valid(c):
							Game.add_score(b.gem_score_at(c), b.get_pos(c))
			)
			b.eliminate(coords, tween, Board.ActiveReason.Item, self)
	elif name == "Dog":
		image_id = 16
		description = "Get 1 base score more for each animal eliminated this roll."
		category = "Animal"
		on_process = func(b : Board, coord : Vector2i, tween : Tween, item_ui : AnimatedSprite2D):
			tween.tween_callback(func():
				var pos = b.get_pos(coord)
				var score = 5
				if b.touched_items.has("cat") || b.touched_items.has("rooster"):
					score += 5
				Game.add_combo()
				Game.add_score(score, pos)
			)
	elif name == "Cat":
		image_id = 17
		description = "Active: Jump to a cell and eliminate it within 2 distance. Repeat 4 times."
		category = "Animal"
		on_process = func(b : Board, coord : Vector2i, tween : Tween, item_ui : AnimatedSprite2D):
			var coords : Array[Vector2i] = []
			var bc = coord
			for i in 4:
				var cands = []
				for c in b.offset_ring(bc, 1):
					if b.is_valid(c) && !coords.has(c):
						cands.append(c)
				for c in b.offset_ring(bc, 2):
					if b.is_valid(c) && !coords.has(c):
						cands.append(c)
				if !cands.is_empty():
					var c = cands.pick_random()
					var pos = b.get_pos(c)
					SAnimation.quadratic_curve_to(tween, item_ui, pos, 0.5, Vector2(0.0, -30.0), 0.4)
					coords.append(c)
					tween.tween_callback(func():
						Game.add_combo()
						Game.add_score(b.gem_score_at(c), pos)
					)
					b.eliminate([c], tween, Board.ActiveReason.Item, self)
					bc = c
	elif name == "Rooster":
		image_id = 18
		description = "Active: activate 3 items."
		category = "Animal"
		on_process = func(b : Board, coord : Vector2i, tween : Tween, item_ui : AnimatedSprite2D):
			tween.tween_callback(func():
				var cands = b.find(func(gem : Gem, item : Item):
					return item && !item.active
				)
				for c in SMath.pick_n(cands, 3):
					var item = b.get_item_at(c)
					b.activate_item(item, Board.ActiveReason.Item, self)
			)
	elif name == "Hotdog":
		image_id = 19
		description = ""
		category = "Food"
		on_eliminate = func(b : Board, coord : Vector2i, reason : int, source):
			var pos = b.get_pos(coord)
			Game.add_combo()
			Game.add_score(50, pos)
			return true
	elif name == "Lai Cut":
		image_id = 20
		description = "Active: If there is no other 'Lai Cut' on board, eliminate a row on a random direction."
		category = "Normal"
		on_process = func(b : Board, coord : Vector2i, tween : Tween, item_ui : AnimatedSprite2D):
			var no_others = b.find(func(gem : Gem, item : Item):
				return item && item.name == "lai_cut"
			).size() == 1
			if no_others:
				var cc = b.offset_to_cube(coord)
				var coords : Array[Vector2i] = []
				match randi() % 3:
					0: 
						for x in b.cx:
							var c = b.cube_to_offset(Vector3i(x, -x - cc.z, cc.z))
							if b.is_valid(c):
								coords.append(c)
					1: 
						for x in b.cx:
							var c = b.cube_to_offset(Vector3i(cc.x, x - cc.x, -x))
							if b.is_valid(c):
								coords.append(c)
					2: 
						for x in b.cx:
							var c = b.cube_to_offset(Vector3i(x - cc.y, cc.y, -x))
							if b.is_valid(c):
								coords.append(c)
				var p0 = b.get_pos(coords[0])
				var p1 = b.get_pos(coords[coords.size() - 1])
				var sp = SEffect.add_slash(p0, p1, 3, 0.5)
				Game.cells_root.add_child(sp)
				var pos = (p0 + p1) / 2.0
				tween.tween_callback(func():
					Game.add_combo()
					for c in coords:
						if b.is_valid(c):
							Game.add_score(b.gem_score_at(c), b.get_pos(c))
				)
				b.eliminate(coords, tween, Board.ActiveReason.Item, self)
	elif name == "Magnet":
		image_id = 21
		description = "Active: Move 2-ring activable items toward this."
		category = "Normal"
		on_process = func(b : Board, coord : Vector2i, tween : Tween, item_ui : AnimatedSprite2D):
			tween.tween_callback(func():
				var empty_places = []
				for c in b.offset_neighbors(coord):
					if !b.get_item_at(c):
						empty_places.append(c)
				for r in range(2, 4):
					if !empty_places.is_empty():
						var ring_empty_places = []
						for c in b.offset_ring(coord, r):
							var item = b.get_item_at(c)
							if item:
								if !empty_places.is_empty():
									b.set_item_at(c, null)
									b.set_item_at(empty_places[0], item)
									empty_places.remove_at(0)
							else:
								ring_empty_places.append(c)
						for c in ring_empty_places:
							empty_places.append(c)
			)
	elif name == "Rainbow":
		image_id = 22
		description = "Active: Get 1.5x score mult this matching."
		category = "Normal"
		on_eliminate = func(b : Board, coord : Vector2i, reason : int, source):
			Buff.create(Game, Buff.Type.ValueModifier, {"target":"score_mult","modify_mult":1.5})
			return true
	elif name == "Idol":
		image_id = 23
		description = "Aura: +3 score.\nActive: Gems in 1-ring get -1 score permanently."
		category = "Normal"
		on_aura = func(event : int, b : Board, coord : Vector2i):
			var g = b.get_gem_at(coord)
			if g:
				if event == Board.AuraEvent.Enter:
					g.bonus_score += 3
				else:
					g.bonus_score -= 3
		on_process = func(b : Board, coord : Vector2i, tween : Tween, item_ui : AnimatedSprite2D):
			var coords : Array[Vector2i] = []
			coords.append(coord)
			for c in b.offset_neighbors(coord):
				coords.append(c)
			tween.tween_callback(func():
				for c in coords:
					var g = b.get_gem_at(c)
					if g:
						Game.float_text("-1", b.get_pos(c))
						g.base_score -= 1
			)
	elif name == "Magician":
		image_id = 23
		description = "Active: Turn 3 gems to wild."
		category = "Normal"
		on_process = func(b : Board, coord : Vector2i, tween : Tween, item_ui : AnimatedSprite2D):
			var cands = b.find(func(gem : Gem, item : Item):
				pass
			)
	elif name == "Ruby":
		image_id = 24
		description = "Eliminate: Red type gems' base score +1."
		category = "Normal"
		on_eliminate = func(b : Board, coord : Vector2i, reason : int, source):
			b.gem_scores[Gem.Type.Red] += 1
			Game.add_status("Red +1", b.gem_col(Gem.Type.Red))
			return true
	elif name == "Citrine":
		image_id = 25
		description = "Eliminate: Orange type gems' base score +1."
		category = "Normal"
		on_eliminate = func(b : Board, coord : Vector2i, reason : int, source):
			b.gem_scores[Gem.Type.Orange] += 1
			Game.add_status("Orange +1", b.gem_col(Gem.Type.Orange))
			return true
	elif name == "Emerald":
		image_id = 26
		description = "Eliminate: Green type gems' base score +1."
		category = "Normal"
		on_eliminate = func(b : Board, coord : Vector2i, reason : int, source):
			b.gem_scores[Gem.Type.Green] += 1
			Game.add_status("Green +1", b.gem_col(Gem.Type.Green))
			return true
	elif name == "Sapphire":
		image_id = 27
		description = "Eliminate: Blue type gems' base score +1."
		category = "Normal"
		on_eliminate = func(b : Board, coord : Vector2i, reason : int, source):
			b.gem_scores[Gem.Type.Blue] += 1
			Game.add_status("Blue +1", b.gem_col(Gem.Type.Blue))
			return true
	elif name == "Amethyst":
		image_id = 28
		description = "Eliminate: Pink type gems' base score +1."
		category = "Normal"
		on_eliminate = func(b : Board, coord : Vector2i, reason : int, source):
			b.gem_scores[Gem.Type.Pink] += 1
			Game.add_status("Pink +1", b.gem_col(Gem.Type.Pink))
			return true
	elif name == "Volcano":
		image_id = 29
		description = "Active: Eliminate 3 random cells in 2-ring. Repeat 2 times."
		category = "Normal"
		on_process = func(b : Board, coord : Vector2i, tween : Tween, item_ui : AnimatedSprite2D):
			var pos = b.get_pos(coord)
			var coords : Array[Vector2i] = []
			for i in 2:
				var cands = []
				for c in b.offset_ring(coord, 1):
					if b.is_valid(c) && !coords.has(c):
						cands.append(c)
				for c in b.offset_ring(coord, 2):
					if b.is_valid(c) && !coords.has(c):
						cands.append(c)
				if !cands.is_empty():
					var arr = []
					for c in SMath.pick_n(cands, 3):
						arr.append(Triple.new(c, b.get_pos(c), null))
						coords.append(c)
					tween.tween_interval(0.1)
					for t in arr:
						var sp = Sprite2D.new()
						sp.texture = SEffect.fireball_image
						sp.position = pos
						sp.z_index = 3
						Game.cells_root.add_child(sp)
						t.third = sp
						tween.parallel()
						SAnimation.quadratic_curve_to(tween, sp, t.second, 0.5, Vector2(0.0, -30.0), 0.4)
					tween.tween_callback(func():
						Game.add_combo()
						for t in arr:
							Game.add_score(b.gem_score_at(t.first), t.second)
							t.third.queue_free()
					)
					b.eliminate(coords, tween, Board.ActiveReason.Item, self)

func get_tooltip():
	var ret : Array[Pair] = []
	ret.append(Pair.new(name, description))
	if description.find("Active:") != -1:
		ret.append(Pair.new("Active", "Effect when the cell is eliminated. \nActive effects will stack and process one by one when the matching stops."))
	if description.find("Quick:") != -1:
		ret.append(Pair.new("Quick", "Effect when the item is placed into the board. And then the item will disapear."))
	if description.find("Aura:") != -1:
		ret.append(Pair.new("Aura", "Effect all gems while this item is on board."))
	return ret
