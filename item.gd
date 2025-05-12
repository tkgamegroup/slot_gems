extends Object

class_name Item

const item_frames : SpriteFrames = preload("res://images/items.tres")
const infected_pb = preload("res://infected.tscn")

var name : String
var image_id : int
var description : String
var category : String
var price : int
var power : int = 0
var is_duplicant : bool = false
var tradeable : bool = false
var mountable : String = ""
var mounted : Item = null
var coord : Vector2i = Vector2i(-1, -1)
var buffs : Array[Buff]
var extra = {}

var on_process : Callable
var on_active : Callable
var on_place : Callable
var on_quick : Callable
var on_eliminate : Callable
var on_mount : Callable
var on_event : Callable

func setup(n : String):
	name = n
	if name == "Dye: Red":
		image_id = 1
		description = "[color=gray][b]Quick[/b][/color]: Change gem to red color."
		on_quick = func(coord : Vector2i):
			var g = Board.get_gem_at(coord)
			if g:
				Buff.create(g, Buff.Type.ChangeColor, {"color":Gem.Type.Red})
				return true
			return false
	elif name == "Dye: Orange":
		image_id = 2
		description = "[color=gray][b]Quick[/b][/color]: Change gem to orange color."
		on_quick = func(coord : Vector2i):
			var g = Board.get_gem_at(coord)
			if g:
				Buff.create(g, Buff.Type.ChangeColor, {"color":Gem.Type.Orange})
				return true
			return false
	elif name == "Dye: Green":
		image_id = 3
		description = "[color=gray][b]Quick[/b][/color]: Change gem to green color."
		on_quick = func(coord : Vector2i):
			var g = Board.get_gem_at(coord)
			if g:
				Buff.create(g, Buff.Type.ChangeColor, {"color":Gem.Type.Green})
				return true
			return false
	elif name == "Dye: Blue":
		image_id = 4
		description = "[color=gray][b]Quick[/b][/color]: Change gem to blue color."
		on_quick = func(coord : Vector2i):
			var g = Board.get_gem_at(coord)
			if g:
				Buff.create(g, Buff.Type.ChangeColor, {"color":Gem.Type.Blue})
				return true
			return false
	elif name == "Dye: Pink":
		image_id = 5
		description = "[color=gray][b]Quick[/b][/color]: Change gem to pink color."
		on_quick = func(coord : Vector2i):
			var g = Board.get_gem_at(coord)
			if g:
				Buff.create(g, Buff.Type.ChangeColor, {"color":Gem.Type.Pink})
				return true
			return false
	elif name == "Pin":
		image_id = 6
		description = "[color=gray][b]Quick[/b][/color]: Freeze the cell."
		on_quick = func(coord : Vector2i):
			Board.freeze(coord)
			return true
	elif name == "Flag":
		image_id = 7
		description = "[color=gray][b]Aura[/b][/color]: Gems +{value} score."
		extra["value"] = 3
		extra["buff_ids"] = []
		on_event = func(event : int, tween : Tween, data):
			var value = extra["value"]
			match event: 
				Event.GemEntered:
					Buff.create(data, Buff.Type.ValueModifier, {"target":"bonus_score","add":value}, Buff.Duration.ThisLevel)
				Event.ItemEntered:
					extra["buff_ids"].clear()
					if data == self:
						for y in Board.cy:
							for x in Board.cx:
								var g = Board.get_gem_at(Vector2i(x, y))
								if g:
									extra["buff_ids"].append(Buff.create(g, Buff.Type.ValueModifier, {"target":"bonus_score","add":value}, Buff.Duration.ThisLevel))
				Event.ItemLeft:
					if data == self:
						for y in Board.cy:
							for x in Board.cx:
								var g = Board.get_gem_at(Vector2i(x, y))
								if g:
									Buff.remove_by_id_list(g, extra["buff_ids"])
	elif name == "Bomb":
		image_id = 8
		description = "[color=gray][b]Eliminate[/b][/color]: [color=gray][b](Active)[/b][/color] Eliminate cells in {range} [color=gray][b]Range[/b][/color]."
		category = "Bomb"
		price = 4
		power = 3
		extra["range"] = 1
		on_eliminate = func(coord : Vector2i, reason : int, source, tween : Tween):
			tween.tween_callback(func():
				Board.activate(self, HostType.Item, 0, coord, reason, source)
			)
		on_active = func(effect_index : int, coord : Vector2i, tween : Tween, item_ui : AnimatedSprite2D):
			Board.effect_explode(Board.get_pos(coord), coord, extra["range"], power, tween, self)
	elif name == "C4":
		image_id = 9
		description = "[color=gray][b]Eliminate[/b][/color] by [b]Bomb[/b]: [color=gray][b](Active)[/b][/color] Eliminate cells in {range} [color=gray][b]Range[/b][/color]."
		category = "Bomb"
		price = 4
		power = 5
		extra["range"] = 2
		on_eliminate = func(coord : Vector2i, reason : int, source, tween : Tween):
			if reason == Board.ActiveReason.Item && source.category == "Bomb":
				tween.tween_callback(func():
					Board.activate(self, HostType.Item, 0, coord, reason, source)
				)
		on_active = func(effect_index : int, coord : Vector2i, tween : Tween, item_ui : AnimatedSprite2D):
			Board.effect_explode(Board.get_pos(coord), coord, extra["range"], power, tween, self)
	elif name == "Chain Bomb":
		image_id = 10
		description = "[color=gray][b]Eliminate[/b][/color]: [color=gray][b](Active)[/b][/color] Eliminate cells in {range} [color=gray][b]Range[/b][/color].\n(If eliminated after 'Chain Bomb', range become that 'Chain Bomb's +1, and power become that 'Chain Bomb's +2.)"
		category = "Bomb"
		price = 4
		extra["range"] = 1
		on_eliminate = func(coord : Vector2i, reason : int, source, tween : Tween):
			if !Board.active_effects.is_empty():
				var i = Board.active_effects.back().host
				if i.name == "Chain Bomb":
					Buff.create(self, Buff.Type.ValueModifier, {"target":"power","set":i.power + 2})
					Buff.create(self, Buff.Type.ValueModifier, {"target":"range","sub_attr":"extra","set":i.extra["range"] + 1})
			tween.tween_callback(func():
				Board.activate(self, HostType.Item, 0, coord, reason, source)
			)
		on_active = func(effect_index : int, coord : Vector2i, tween : Tween, item_ui : AnimatedSprite2D):
			Board.effect_explode(Board.get_pos(coord), coord, extra["range"], power, tween, self)
	elif name == "Golden Bomb":
		image_id = 41
		description = "[color=gray][b]Eliminate[/b][/color]: [color=gray][b](Active)[/b][/color] Cost 6 coins to eliminate cells in {range} [color=gray][b]Range[/b][/color], earn 0-3 coins for each cell eliminated."
		category = "Bomb"
		extra["range"] = 1
		on_eliminate = func(coord : Vector2i, reason : int, source, tween : Tween):
			tween.tween_callback(func():
				Board.activate(self, HostType.Item, 0, coord, reason, source)
			)
		on_active = func(effect_index : int, coord : Vector2i, tween : Tween, item_ui : AnimatedSprite2D):
			if Game.coins >= 6:
				Game.coins -= 6
				var coords = Board.effect_explode(Board.get_pos(coord), coord, extra["range"], power, tween, self)
				tween.tween_callback(func():
					for c in coords:
						var v = randi_range(0, 3)
						Game.float_text("%dG" % v, Board.get_pos(c), Color(0.9, 0.75, 0.25))
						Game.coins += v
				)
	elif name == "Minefield":
		image_id = 41
		description = "[color=gray][b]Quick[/b][/color]: Setup a minefield within {setup_range} [color=gray][b]Range[/b][/color], and if any cell in that area is eliminated, an explosion will occur and eliminate cells in {range} [color=gray][b]Range[/b][/color]."
		extra["setup_range"] = 2
		extra["range"] = 0
		on_quick = func(coord : Vector2i):
			var setup_range = extra["setup_range"]
			var coords = []
			for i in setup_range + 1:
				for c in Board.offset_ring(coord, i):
					if Board.is_valid(c):
						Board.cell_at(c).event_listeners.append(Hook.new(Event.Eliminated, self, HostType.Item, true))
						coords.append(c)
			return true
		on_event = func(event : int, tween : Tween, data):
			if event == Event.Eliminated:
				Board.activate(self, HostType.Item, 0, data, Board.ActiveReason.Item, self)
		on_active = func(effect_index : int, coord : Vector2i, tween : Tween, item_ui : AnimatedSprite2D):
			Board.effect_explode(Board.get_pos(coord), coord, extra["range"], power, tween, self)
	elif name == "Echo Stone":
		image_id = 41
		description = "When an explosion occurs: [color=gray][b](Active)[/b][/color] Eliminate 1 random cell next to.\n[color=gray][b]Eliminate[/b][/color] by [b]Bomb[/b]: [color=gray][b](Active)[/b][/color] Eliminate cells in {range} [color=gray][b]Range[/b][/color]."
		category = "Normal"
		extra["range"] = 1
		on_event = func(event : int, tween : Tween, data):
			if event == Event.Exploded:
				Board.activate(self, HostType.Item, 0, coord, Board.ActiveReason.Item, self)
		on_eliminate = func(coord : Vector2i, reason : int, source, tween : Tween):
			if reason == Board.ActiveReason.Item && source.category == "Bomb":
				tween.tween_callback(func():
					Board.activate(self, HostType.Item, 1, coord, reason, source)
				)
		on_active = func(effect_index : int, coord : Vector2i, tween : Tween, item_ui : AnimatedSprite2D):
			if effect_index == 0:
				var places = []
				for c in Board.offset_neighbors(coord):
					if Board.is_valid(c):
						places.append(c)
				tween.tween_callback(func():
					Game.add_combo()
					Game.add_score(Board.gem_score_at(places.pick_random()), Board.get_pos(coord))
				)
				Board.eliminate([coord], tween, Board.ActiveReason.Item, self)
			elif effect_index == 1:
				Board.effect_explode(Board.get_pos(coord), coord, extra["range"], power, tween, self)
	elif name == "Virus":
		image_id = 11
		description = "[color=gray][b]Place[/b][/color]: Make two copies of this item into cells next to.\n[color=gray][b]Eliminate[/b][/color]: [color=gray][b](Active)[/b][/color] Eliminate all connected cells with the same color of this."
		category = "Normal"
		on_place = func(coord : Vector2i, reason : int):
			if reason == Board.PlaceReason.FromHand:
				var places = []
				for c in Board.offset_neighbors(coord):
					if Board.is_valid(c) && !Board.get_item_at(c):
						places.append(c)
				if !places.is_empty():
					places = SMath.pick_n(places, 2)
					for c in places:
						var new_item = Item.new()
						new_item.setup("Virus")
						new_item.is_duplicant = true
						Board.set_item_at(c, new_item)
		on_eliminate = func(coord : Vector2i, reason : int, source, tween : Tween):
			tween.tween_callback(func():
				Board.activate(self, HostType.Item, 0, coord, reason, source)
			)
		on_active = func(effect_index : int, coord : Vector2i, tween : Tween, item_ui : AnimatedSprite2D):
			var color = Board.get_gem_at(coord).type
			var arr = [coord]
			var sps = []
			var coords : Array[Vector2i] = [coord]
			while !arr.is_empty():
				var arr2 = []
				for c in arr:
					for cc in Board.offset_neighbors(c):
						if !coords.has(cc):
							var g = Board.get_gem_at(cc)
							if g && g.type == color:
								var sp = infected_pb.instantiate()
								sp.position = Board.get_pos(cc)
								sp.emitting = false
								Game.board_ui.cells_root.add_child(sp)
								tween.tween_callback(func():
									sp.emitting = true
								)
								sps.append(sp)
								arr2.append(cc)
								coords.append(cc)
				arr.clear()
				arr.append_array(arr2)
				tween.tween_interval(0.4 * Game.animation_speed)
			tween.tween_callback(func():
				for sp in sps:
					sp.queue_free()
				
				Game.add_combo()
				for c in coords:
					Game.add_score(Board.gem_score_at(c), Board.get_pos(c))
			)
			Board.eliminate(coords, tween, Board.ActiveReason.Item, self)
	elif name == "Lightning":
		image_id = 12
		description = "[color=gray][b]Eliminate[/b][/color]: [color=gray][b](Active)[/b][/color] Connect all 'Lightning's, eliminate cells on between."
		category = "Normal"
		price = 5
		power = 3
		on_eliminate = func(coord : Vector2i, reason : int, source, tween : Tween):
			tween.tween_callback(func():
				Board.activate(self, HostType.Item, 0, coord, reason, source)
			)
		on_active = func(effect_index : int, coord : Vector2i, tween : Tween, item_ui : AnimatedSprite2D):
			var targets = Board.filter(func(gem : Gem, item : Item):
				return item && item.name == "Lightning"
			)
			for ae in Board.active_effects:
				if ae.host.name == "Lightning":
					targets.append(ae.host)
			targets.sort_custom(func(c1, c2):
				return Board.offset_distance(c1, coord) < Board.offset_distance(c2, coord)
			)
			if targets.size() >= 2:
				var coords : Array[Vector2i] = []
				for i in targets.size() - 1:
					var p0 = targets[i]
					var p1 = targets[i + 1]
					for c in Board.draw_line(Board.offset_to_cube(p0), Board.offset_to_cube(p1)):
						var cc = Board.cube_to_offset(c)
						coords.append(cc)
					tween.tween_callback(func():
						var fx = SEffect.add_lighning(Board.get_pos(p0), Board.get_pos(p1), 3, 0.5 * Game.animation_speed)
						Game.board_ui.cells_root.add_child(fx)
					)
				coords.append(targets.back())
				tween.tween_interval(0.5 * Game.animation_speed)
				tween.tween_callback(func():
						Game.add_combo()
						for c in coords:
							if Board.is_valid(c):
								Game.add_score(Board.gem_score_at(c) + power, Board.get_pos(c))
				)
				Board.eliminate(coords, tween, Board.ActiveReason.Item, self)
	elif name == "Color Palette":
		image_id = 13
		description = "[color=gray][b]Quick[/b][/color]: Turn gem to wild type."
		category = "Normal"
		price = 4
		on_quick = func(coord : Vector2i):
			var g = Board.get_gem_at(coord)
			if g:
				Buff.create(g, Buff.Type.ChangeColor, {"color":Gem.Type.Wild})
				return true
			return false
	elif name == "Fire":
		image_id = 14
		description = "[color=gray][b]Eliminate[/b][/color]: Sets the cell to burning state."
		category = "Normal"
		on_eliminate = func(coord : Vector2i, reason : int, source, tween : Tween):
			tween.tween_callback(func():
				Board.set_state_at(coord, Cell.State.Burning)
				SSound.sfx_start_buring.play()
			)
	elif name == "Black Hole":
		image_id = 15
		description = "[color=gray][b]Eliminate[/b][/color]: [color=gray][b](Active)[/b][/color] If this is the last item activated. Eliminate all cells."
		category = "Normal"
		on_eliminate = func(coord : Vector2i, reason : int, source, tween : Tween):
			tween.tween_callback(func():
				Board.activate(self, HostType.Item, 0, coord, reason, source)
			)
		on_active = func(effect_index : int, coord : Vector2i, tween : Tween, item_ui : AnimatedSprite2D):
			if Board.active_effects.back().host == self:
				var coords : Array[Vector2i] = []
				for y in Board.cy:
					for x in Board.cx:
						var c = Vector2i(x, y)
						coords.append(c)
				tween.tween_callback(func():
					var pos : Vector2 = Board.get_pos(coord)
					var fx = SEffect.add_black_hole_rotating(pos, Vector2(128.0, 128.0), 0, 3.0)
					Game.board_ui.underlay.add_child(fx)
					
					for c in coords:
						var ui = Game.get_cell_ui(c).gem
						var data = {"ui":ui,"vel":SMath.tangent2(Board.get_pos(c) - pos).normalized() * 1.4}
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
							if Board.is_valid(c):
								Game.add_score(Board.gem_score_at(c), Board.get_pos(c))
				)
				Board.eliminate(coords, tween, Board.ActiveReason.Item, self)
	elif name == "White Hole":
		image_id = 16
		description = "[color=gray][b]Eliminate[/b][/color]: [color=gray][b](Active)[/b][/color] Eliminate all cells. (Only activate if this is the first item activated.)"
		category = "Normal"
		on_eliminate = func(coord : Vector2i, reason : int, source, tween : Tween):
			if Board.active_effects.is_empty():
				tween.tween_callback(func():
					Board.activate(self, HostType.Item, 0, coord, reason, source)
				)
		on_active = func(effect_index : int, coord : Vector2i, tween : Tween, item_ui : AnimatedSprite2D):
			var coords : Array[Vector2i] = []
			for y in Board.cy:
				for x in Board.cx:
					var c = Vector2i(x, y)
					coords.append(c)
			var pos : Vector2 = Board.get_pos(coord)
			tween.tween_callback(func():
				var fx = SEffect.add_white_hole_injection(pos, Vector2(128.0, 128.0), 0, 3.0)
				Game.board_ui.underlay.add_child(fx)
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
						if Board.is_valid(c):
							Game.add_score(Board.gem_score_at(c), Board.get_pos(c))
			)
			Board.eliminate(coords, tween, Board.ActiveReason.Item, self)
	elif name == "Dog":
		image_id = 17
		description = "[color=gray][b]Eliminate[/b][/color]: +{value} score for each [color=gray][b]Animal[/b][/color]. (Not affected by combos)"
		category = "Animal"
		price = 4
		extra["value"] = 375
		on_eliminate = func(coord : Vector2i, reason : int, source, tween : Tween):
			var targets = Board.filter(func(gem : Gem, item : Item):
				return item && item.category == "Animal"
			)
			for ae in Board.active_effects:
				if ae.host.category == "Animal":
					targets.append(ae.host)
			tween.tween_callback(func():
				Game.add_score(extra["value"] * targets.size(), Board.get_pos(coord), false)
			)
	elif name == "Cat":
		image_id = 18
		description = "[color=gray][b]Eliminate[/b][/color]: [color=gray][b](Active)[/b][/color] Jump to a cell and eliminate it within 2 [color=gray][b]Range[/b][/color]. Repeat 2 times."
		category = "Animal"
		price = 4
		extra["repeat"] = 2
		on_eliminate = func(coord : Vector2i, reason : int, source, tween : Tween):
			tween.tween_callback(func():
				Board.activate(self, HostType.Item, 0, coord, reason, source)
			)
		on_active = func(effect_index : int, coord : Vector2i, tween : Tween, item_ui : AnimatedSprite2D):
			var coords : Array[Vector2i] = []
			var bc = coord
			var times = 1 + extra["repeat"]
			for i in times:
				var cands = []
				for c in Board.offset_ring(bc, 1):
					if Board.is_valid(c) && !coords.has(c):
						cands.append(c)
				for c in Board.offset_ring(bc, 2):
					if Board.is_valid(c) && !coords.has(c):
						cands.append(c)
				if !cands.is_empty():
					var c = cands.pick_random()
					var pos = Board.get_pos(c)
					SAnimation.quadratic_curve_to(tween, item_ui, pos, 0.5, Vector2(0.0, -30.0), 0.4 * Game.animation_speed)
					coords.append(c)
					tween.tween_callback(func():
						Game.add_combo()
						Game.add_score(Board.gem_score_at(c), pos)
					)
					Board.eliminate([c], tween, Board.ActiveReason.Item, self)
					bc = c
	elif name == "Rooster":
		image_id = 19
		description = "[color=gray][b]Eliminate[/b][/color]: [color=gray][b](Active)[/b][/color] Activate all [color=gray][b]Animal[/b][/color] activater items."
		category = "Animal"
		on_eliminate = func(coord : Vector2i, reason : int, source, tween : Tween):
			tween.tween_callback(func():
				Board.activate(self, HostType.Item, 0, coord, reason, source)
			)
		on_active = func(effect_index : int, coord : Vector2i, tween : Tween, item_ui : AnimatedSprite2D):
			var targets = Board.filter(func(gem : Gem, item : Item):
				if item && item.on_process.is_valid() && item.category == "Animal":
					return true
				return false
			)
			if !targets.is_empty():
				var pos = Board.get_pos(coord)
				tween.tween_callback(func():
					for c in targets:
						SEffect.add_leading_line(pos, Board.get_pos(c))
				)
				tween.tween_interval(0.3)
				tween.tween_callback(func():
					for c in targets:
						var i = Board.get_item_at(c)
						if i:
							Board.activate(i, 0, 0, c, Board.ActiveReason.Item, self)
				)
	elif name == "Rabbit":
		image_id = 20
		description = "[color=gray][b]Eliminate[/b][/color]: [color=gray][b](Active)[/b][/color] Jump to a cell and eliminate it within 2 [color=gray][b]Range[/b][/color]. If jump to another 'Rabbit', add a new 'Rabbit' to Bag. Repeat 1 time."
		extra["repeat"] = 1
		on_eliminate = func(coord : Vector2i, reason : int, source, tween : Tween):
			tween.tween_callback(func():
				Board.activate(self, HostType.Item, 0, coord, reason, source)
			)
		on_active = func(effect_index : int, coord : Vector2i, tween : Tween, item_ui : AnimatedSprite2D):
			var coords : Array[Vector2i] = []
			var bc = coord
			var times = 1 + extra["repeat"]
			for i in times:
				var cands = []
				for c in Board.offset_ring(bc, 1):
					if Board.is_valid(c) && !coords.has(c):
						cands.append(c)
				for c in Board.offset_ring(bc, 2):
					if Board.is_valid(c) && !coords.has(c):
						cands.append(c)
				if !cands.is_empty():
					var c = cands.pick_random()
					var pos = Board.get_pos(c)
					SAnimation.quadratic_curve_to(tween, item_ui, pos, 0.5, Vector2(0.0, -30.0), 0.4 * Game.animation_speed)
					coords.append(c)
					tween.tween_callback(func():
						Game.add_combo()
						Game.add_score(Board.gem_score_at(c), pos)
						
						var item = Board.get_item_at(c)
						if !item:
							var ae = Board.get_active_at(c)
							if ae:
								item = ae.host
						if item && item != self && item.name == "Rabbit":
							var sp = AnimatedSprite2D.new()
							sp.position = Board.get_pos(coord)
							sp.sprite_frames = Item.item_frames
							sp.frame = image_id
							sp.z_index = 3
							Game.board_ui.cells_root.add_child(sp)
							var tween2 = Game.get_tree().create_tween()
							SAnimation.cubic_curve_to(tween2, sp, Game.status_bar_ui.bag_button.get_global_rect().get_center(), 0.1, Vector2(0, 150), 0.9, Vector2(0, 100), 0.4)
							tween2.tween_callback(func():
								var new_item = Item.new()
								new_item.setup("Rabbit")
								Game.add_item(new_item)
							)
					)
					Board.eliminate([c], tween, Board.ActiveReason.Item, self)
					bc = c
	elif name == "Fox":
		image_id = 21
		description = "[color=gray][b]Place[/b][/color]: If this item is placed from Bag, place another [color=gray][b]Animal[/b][/color] from Bag to Board."
		category = "Animal"
		tradeable = true
		on_place = func(coord : Vector2i, reason : int):
			if reason == Board.PlaceReason.FromBag:
				var cands = []
				for i in Game.items:
					if i.coord.x == -1 && i.coord.y == -1 && i.category == "Animal":
						cands.append(i)
				if !cands.is_empty():
					var item = cands.pick_random()
					Board.effect_place_item_from_bag(Board.get_pos(coord), item, Vector2i(-1, -1))
		
	elif name == "Eagle":
		image_id = 22
		description = "[color=gray][b]Place[/b][/color]: Place another [color=gray][b]Animal[/b][/color] from Bag to Board."
		category = "Animal"
		on_place = func(coord : Vector2i, reason : int):
			var cands = []
			for i in Game.items:
				if i.coord.x == -1 && i.coord.y == -1 && i.category == "Animal":
					cands.append(i)
			if !cands.is_empty():
				var item = cands.pick_random()
				
				Board.effect_place_item_from_bag(Board.get_pos(coord), item, Vector2i(-1, -1))
	elif name == "Mouse":
		image_id = 23
		description = "[color=gray][b]Eliminate[/b][/color]: [color=gray][b](Active)[/b][/color] Consume a [color=gray][b]Food[/b][/color] on the board, gain score it has."
		category = "Animal"
		on_eliminate = func(coord : Vector2i, reason : int, source, tween : Tween):
			tween.tween_callback(func():
				Board.activate(self, HostType.Item, 0, coord, reason, source)
			)
		on_active = func(effect_index : int, coord : Vector2i, tween : Tween, item_ui : AnimatedSprite2D):
			var targets = Board.filter(func(gem : Gem, item : Item):
				return item && item.category == "Food"
			)
			if !targets.is_empty():
				var c = targets.pick_random()
				var i = Board.get_item_at(c)
				var score = i.extra["score"]
				var pos = Board.get_pos(c)
				SAnimation.move_to(tween, item_ui, pos, 0.4 * Game.animation_speed)
				tween.tween_callback(func():
					Game.add_combo()
					Game.add_score(score, pos)
				)
				Board.item_moved(self, tween, coord, c)
	elif name == "Horse":
		image_id = 24
		description = "Turn mounted and this item into a new item."
		category = "Animal"
		mountable = "Character"
		on_mount = func(mounted : Item):
			if mounted.name == "Idol":
				var c = coord
				Board.set_item_at(c, null)
				Game.release_item(mounted)
				var new_item = Item.new()
				new_item.setup("Princess")
				new_item.is_duplicant = true
				Board.set_item_at(c, new_item)
				return false
			elif mounted.name == "Magician":
				var c = coord
				Board.set_item_at(c, null)
				Game.release_item(mounted)
				var new_item = Item.new()
				new_item.setup("Mage")
				new_item.is_duplicant = true
				Board.set_item_at(c, new_item)
				return false
			return true
	elif name == "Elephant":
		image_id = 25
		description = "Eliminate all cells this item traveled."
		category = "Animal"
		mountable = "Animal"
		on_event = func(event : int, tween : Tween, data):
			if event == Event.ItemMoved && tween:
				if data["item"] == mounted:
					var coords : Array[Vector2i] = []
					var p0 = data["from"]
					var p1 = data["to"]
					for c in Board.draw_line(Board.offset_to_cube(p0), Board.offset_to_cube(p1)):
						var cc = Board.cube_to_offset(c)
						coords.append(cc)
					tween.tween_callback(func():
						Game.add_combo()
						for c in coords:
							if Board.is_valid(c):
								Game.add_score(Board.gem_score_at(c), Board.get_pos(c))
					)
					Board.eliminate(coords, tween, Board.ActiveReason.Item, self)
	elif name == "Hot Dog":
		image_id = 26
		description = "[color=gray][b]Eliminate[/b][/color]: +{value} score. (Not affected by combos)"
		category = "Food"
		extra["value"] = 625
		on_eliminate = func(coord : Vector2i, reason : int, source, tween : Tween):
			tween.tween_callback(func():
				Game.add_score(extra["value"], Board.get_pos(coord), false)
			)
	elif name == "Iai Cut":
		image_id = 27
		description = "[color=gray][b]Eliminate[/b][/color]: [color=gray][b](Active)[/b][/color] Eliminate a row on a random direction. (Eliminated by 'Iai Cut' will add one direction, Max 3)"
		category = "Normal"
		price = 5
		on_place = func(coord : Vector2i, reason : int):
			extra.num = 1
		on_eliminate = func(coord : Vector2i, reason : int, source, tween : Tween):
			if reason == Board.ActiveReason.Item && source.name == "Iai Cut":
				extra.num += 1
			tween.tween_callback(func():
				Board.activate(self, HostType.Item, 0, coord, reason, source)
			)
		on_active = func(effect_index : int, coord : Vector2i, tween : Tween, item_ui : AnimatedSprite2D):
			var cc = Board.offset_to_cube(coord)
			var arr = [0, 1, 2]
			var coords : Array[Vector2i] = []
			for i in min(extra.num, 3):
				var sub_coords : Array[Vector2i] = []
				var d = SMath.pick_and_remove(arr)
				match d:
					0: 
						for x in Board.cx:
							var c = Board.cube_to_offset(Vector3i(x, -x - cc.z, cc.z))
							if Board.is_valid(c):
								sub_coords.append(c)
					1: 
						for x in Board.cx:
							var c = Board.cube_to_offset(Vector3i(cc.x, x - cc.x, -x))
							if Board.is_valid(c):
								sub_coords.append(c)
					2: 
						for x in Board.cx:
							var c = Board.cube_to_offset(Vector3i(x - cc.y, cc.y, -x))
							if Board.is_valid(c):
								sub_coords.append(c)
				var p0 = Board.get_pos(sub_coords.front())
				var p1 = Board.get_pos(sub_coords.back())
				tween.tween_callback(func():
					var sp = SEffect.add_slash(p0, p1, 3, 0.5 * Game.animation_speed)
					Game.board_ui.cells_root.add_child(sp)
				)
				coords.append_array(sub_coords)
			tween.tween_interval(0.5 * Game.animation_speed)
			tween.tween_callback(func():
				Game.add_combo()
				for c in coords:
					if Board.is_valid(c):
						Game.add_score(Board.gem_score_at(c), Board.get_pos(c))
			)
			Board.eliminate(coords, tween, Board.ActiveReason.Item, self)
	elif name == "Magnet":
		image_id = 28
		description = "When an item is activated, move it to the closest 'Magnet'."
		category = "Normal"
		on_event = func(event : int, tween : Tween, data):
			if event == Event.ItemActivated:
				var sp = data.third
				SAnimation.move_to(null, sp, Board.get_pos(coord), 0.3)
				data.second = coord
	elif name == "Rainbow":
		image_id = 29
		description = "[color=gray][b]Eliminate[/b][/color]: [color=gray][b](Active)[/b][/color] +0.5 score multipler this matching."
		category = "Normal"
		on_eliminate = func(coord : Vector2i, reason : int, source, tween : Tween):
			tween.tween_callback(func():
				Game.float_text("+0.5 Mult", Board.get_pos(coord), Color(0.7, 0.3, 0.9))
				Buff.create(Game, Buff.Type.ValueModifier, {"target":"score_mult","add":0.5})
			)
	elif name == "Idol":
		image_id = 30
		description = "[color=gray][b]Aura[/b][/color]: All gems +3 score.\n[color=gray][b]Eliminate[/b][/color]: [color=gray][b](Active)[/b][/color] Gems in 1 [color=gray][b]Range[/b][/color] get -1 score permanently."
		category = "Character"
		extra["value"] = 3
		on_event = func(event : int, tween : Tween, data):
			var value = extra["value"]
			match event: 
				Event.GemEntered:
					Buff.create(data, Buff.Type.ValueModifier, {"target":"bonus_score","add":value}, Buff.Duration.ThisLevel)
				Event.ItemEntered:
					extra["buff_ids"].clear()
					if data == self:
						for y in Board.cy:
							for x in Board.cx:
								var g = Board.get_gem_at(Vector2i(x, y))
								if g:
									extra["buff_ids"].append(Buff.create(g, Buff.Type.ValueModifier, {"target":"bonus_score","add":value}, Buff.Duration.ThisLevel))
				Event.ItemLeft:
					if data == self:
						for y in Board.cy:
							for x in Board.cx:
								var g = Board.get_gem_at(Vector2i(x, y))
								if g:
									Buff.remove_by_id_list(g, extra["buff_ids"])
		on_eliminate = func(coord : Vector2i, reason : int, source, tween : Tween):
			var coords : Array[Vector2i] = []
			coords.append(coord)
			for c in Board.offset_neighbors(coord):
				coords.append(c)
			tween.tween_interval(0.5 * Game.animation_speed)
			tween.tween_callback(func():
				for c in coords:
					var g = Board.get_gem_at(c)
					if g:
						var v = Game.gem_add_base_score(g, -1)
						Game.float_text("%d" % v, Board.get_pos(c), Color(0.8, 0.1, 0.0))
			)
	elif name == "Magician":
		image_id = 31
		description = "[color=gray][b]Eliminate[/b][/color]: [color=gray][b](Active)[/b][/color] Turn 5 random gems to Wild."
		category = "Character"
		on_eliminate = func(coord : Vector2i, reason : int, source, tween : Tween):
			tween.tween_callback(func():
				Board.activate(self, HostType.Item, 0, coord, reason, source)
			)
		on_active = func(effect_index : int, coord : Vector2i, tween : Tween, item_ui : AnimatedSprite2D):
			var cands = Board.filter(func(gem : Gem, item : Item):
				if gem && gem.type != Gem.Type.Wild:
					return true
				return false
			)
			if !cands.is_empty():
				var pos = Board.get_pos(coord)
				var targets = SMath.pick_n(cands, 5) 
				tween.tween_callback(func():
					for c in targets:
						SEffect.add_leading_line(pos, Board.get_pos(c))
				)
				tween.tween_interval(0.3)
				tween.tween_callback(func():
					for c in targets:
						Buff.create(Board.get_gem_at(c), Buff.Type.ChangeColor, {"color":Gem.Type.Wild})
				)
	elif name == "Merchant":
		image_id = 32
	elif name == "Princess":
		image_id = 32
		description = "[color=gray][b]Aura[/b][/color]: All gems +7 score.\n[color=gray][b]Eliminate[/b][/color]: [color=gray][b](Active)[/b][/color] Gems in 1 [color=gray][b]Range[/b][/color] get +1 score permanently."
		category = "Character"
		extra["value"] = 7
		on_event = func(event : int, tween : Tween, data):
			var value = extra["value"]
			match event: 
				Event.GemEntered:
					Buff.create(data, Buff.Type.ValueModifier, {"target":"bonus_score","add":value}, Buff.Duration.ThisLevel)
				Event.ItemEntered:
					extra["buff_ids"].clear()
					if data == self:
						for y in Board.cy:
							for x in Board.cx:
								var g = Board.get_gem_at(Vector2i(x, y))
								if g:
									extra["buff_ids"].append(Buff.create(g, Buff.Type.ValueModifier, {"target":"bonus_score","add":value}, Buff.Duration.ThisLevel))
				Event.ItemLeft:
					if data == self:
						for y in Board.cy:
							for x in Board.cx:
								var g = Board.get_gem_at(Vector2i(x, y))
								if g:
									Buff.remove_by_id_list(g, extra["buff_ids"])
		on_eliminate = func(coord : Vector2i, reason : int, source, tween : Tween):
			var coords : Array[Vector2i] = []
			coords.append(coord)
			for c in Board.offset_neighbors(coord):
				coords.append(c)
			tween.tween_callback(func():
				for c in coords:
					var g = Board.get_gem_at(c)
					if g:
						Game.float_text("+1", Board.get_pos(c), Color(0.1, 0.8, 0.0))
						g.base_score += 1
			)
	elif name == "Mage":
		image_id = 33
		description = "[color=gray][b]Eliminate[/b][/color]: [color=gray][b](Active)[/b][/color] Turn gems in 1 [color=gray][b]Range[/b][/color] to Wild."
		category = "Character"
		on_eliminate = func(coord : Vector2i, reason : int, source, tween : Tween):
			tween.tween_callback(func():
				Board.activate(self, HostType.Item, 0, coord, reason, source)
			)
		on_active = func(effect_index : int, coord : Vector2i, tween : Tween, item_ui : AnimatedSprite2D):
			tween.tween_callback(func():
				for c in Board.offset_neighbors(coord):
					var g = Board.get_gem_at(c)
					if g:
						Buff.create(g, Buff.Type.ChangeColor, {"color":Gem.Type.Wild})
			)
	elif name == "Ruby":
		image_id = 34
		description = "[color=gray][b]Eliminate[/b][/color]: +1 base score to Red."
		category = "Normal"
		price = 9
		on_eliminate = func(coord : Vector2i, reason : int, source, tween : Tween):
			tween.tween_callback(func():
				Game.modifiers["red_bouns_i"] += 1
				Game.float_text("Red +1", Board.get_pos(coord), Gem.type_color(Gem.Type.Red))
			)
	elif name == "Citrine":
		image_id = 35
		description = "[color=gray][b]Eliminate[/b][/color]: +1 base score to Orange."
		category = "Normal"
		price = 9
		on_eliminate = func(coord : Vector2i, reason : int, source, tween : Tween):
			tween.tween_callback(func():
				Game.modifiers["orange_bouns_i"] += 1
				Game.float_text("Orange +1", Board.get_pos(coord), Gem.type_color(Gem.Type.Orange))
			)
	elif name == "Emerald":
		image_id = 36
		description = "[color=gray][b]Eliminate[/b][/color]: +1 base score to Green."
		category = "Normal"
		price = 9
		on_eliminate = func(coord : Vector2i, reason : int, source, tween : Tween):
			tween.tween_callback(func():
				Game.modifiers["green_bouns_i"] += 1
				Game.float_text("Green +1", Board.get_pos(coord), Gem.type_color(Gem.Type.Green))
			)
	elif name == "Sapphire":
		image_id = 37
		description = "[color=gray][b]Eliminate[/b][/color]: +1 base score to Blue."
		category = "Normal"
		price = 9
		on_eliminate = func(coord : Vector2i, reason : int, source, tween : Tween):
			tween.tween_callback(func():
				Game.modifiers["blue_bouns_i"] += 1
				Game.float_text("Blue +1", Board.get_pos(coord), Gem.type_color(Gem.Type.Blue))
			)
	elif name == "Tourmaline":
		image_id = 38
		description = "[color=gray][b]Eliminate[/b][/color]: +1 base score to Pink."
		category = "Normal"
		price = 9
		on_eliminate = func(coord : Vector2i, reason : int, source, tween : Tween):
			tween.tween_callback(func():
				Game.modifiers["pink_bouns_i"] += 1
				Game.float_text("Pink +1", Board.get_pos(coord), Gem.type_color(Gem.Type.Pink))
			)
	elif name == "Strength Potion":
		image_id = 39
		description = "[color=gray][b]Quick[/b][/color]: Target Item +10 [color=gray][b]Power[/b][/color]."
		category = "Normal"
		price = 4
		on_quick = func(coord : Vector2i):
			var i = Board.get_item_at(coord)
			if i:
				Buff.create(i, Buff.Type.ValueModifier, {"target":"power","add":10})
				return true
			return false
	elif name == "Echo Totem":
		image_id = 39
		description = "[color=gray][b]Aura[/b][/color]: All Item's repeat number +1."
		category = "Normal"
		price = 4
		
	elif name == "Volcano":
		image_id = 40
		description = "[color=gray][b]Eliminate[/b][/color]: [color=gray][b](Active)[/b][/color] Eliminate 2 random cells in 2 [color=gray][b]Range[/b][/color]. Repeat 2 times."
		category = "Normal"
		price = 5
		on_eliminate = func(coord : Vector2i, reason : int, source, tween : Tween):
			tween.tween_callback(func():
				Board.activate(self, HostType.Item, 0, coord, reason, source)
			)
		on_active = func(effect_index : int, coord : Vector2i, tween : Tween, item_ui : AnimatedSprite2D):
			var pos = Board.get_pos(coord)
			var coords : Array[Vector2i] = []
			for i in 2:
				var cands = []
				for c in Board.offset_ring(coord, 1):
					if Board.is_valid(c) && !coords.has(c):
						cands.append(c)
				for c in Board.offset_ring(coord, 2):
					if Board.is_valid(c) && !coords.has(c):
						cands.append(c)
				if !cands.is_empty():
					var arr = []
					for c in SMath.pick_n(cands, 2):
						arr.append(Triple.new(c, Board.get_pos(c), null))
						coords.append(c)
					tween.tween_interval(0.1)
					for t in arr:
						var sp = Sprite2D.new()
						sp.texture = SEffect.fireball_image
						sp.position = pos
						sp.z_index = 3
						Game.board_ui.cells_root.add_child(sp)
						t.third = sp
						tween.parallel()
						SAnimation.quadratic_curve_to(tween, sp, t.second, 0.5, Vector2(0.0, -30.0), 0.4 * Game.animation_speed)
					tween.tween_callback(func():
						Game.add_combo()
						for t in arr:
							Game.add_score(Board.gem_score_at(t.first), t.second)
							t.third.queue_free()
					)
					Board.eliminate(coords, tween, Board.ActiveReason.Item, self)

func get_tooltip():
	var ret : Array[Pair] = []
	var content = description.format(extra)
	if power != 0:
		content = ("[color=gray][b]Power[/b][/color]: %d\n" % power) + content
	if tradeable:
		content = "[color=gray][b]Tradeable[/b][/color]\n" + content
	if mountable != "":
		content = ("[color=gray][b]Mount[/b][/color] for [color=gray][b]%s[/b][/color]\n" % mountable) + content
	ret.append(Pair.new(name, content))
	if mounted:
		ret.append_array(mounted.get_tooltip())
	return ret
