extends Object

class_name Item

const infected_pb = preload("res://infected.tscn")

var id : int
var name : String
var image_id : int
var category : String
var price : int = 5
var power : int = 0
var eliminated : bool = false
var tradeable : bool = false
var mountable : String = ""
var mounted : Item = null
var coord : Vector2i = Vector2i(-1, -1)
var buffs : Array[Buff]
var extra = {}

var on_active : Callable
var on_place : Callable
var on_quick : Callable
var on_eliminate : Callable
var on_aura : Callable
var on_mount : Callable
var on_event : Callable

static func get_image_path(name : String):
	var temp = Item.new()
	temp.setup(name)
	return Gem.item_frames.get_frame_texture("default", temp.image_id).resource_path

static var s_id : int = 0

func setup(n : String):
	id = s_id
	s_id += 1
	name = n
	if name == "DyeRed":
		image_id = 1
		price = 1
		on_quick = func(coord : Vector2i):
			var g = Board.get_gem_at(coord)
			if g:
				Buff.create(g, Buff.Type.ChangeColor, {"color":Gem.ColorRed}, Buff.Duration.OnBoard)
				return true
			return false
	elif name == "DyeOrange":
		image_id = 2
		price = 1
		on_quick = func(coord : Vector2i):
			var g = Board.get_gem_at(coord)
			if g:
				Buff.create(g, Buff.Type.ChangeColor, {"color":Gem.ColorOrange}, Buff.Duration.OnBoard)
				return true
			return false
	elif name == "DyeGreen":
		image_id = 3
		price = 1
		on_quick = func(coord : Vector2i):
			var g = Board.get_gem_at(coord)
			if g:
				Buff.create(g, Buff.Type.ChangeColor, {"color":Gem.ColorGreen}, Buff.Duration.OnBoard)
				return true
			return false
	elif name == "DyeBlue":
		image_id = 4
		price = 1
		on_quick = func(coord : Vector2i):
			var g = Board.get_gem_at(coord)
			if g:
				Buff.create(g, Buff.Type.ChangeColor, {"color":Gem.ColorBlue}, Buff.Duration.ThisRound)
				return true
			return false
	elif name == "DyeMagenta":
		image_id = 5
		price = 1
		on_quick = func(coord : Vector2i):
			var g = Board.get_gem_at(coord)
			if g:
				Buff.create(g, Buff.Type.ChangeColor, {"color":Gem.ColorMagenta}, Buff.Duration.OnBoard)
				return true
			return false
	elif name == "Pin":
		image_id = 6
		on_quick = func(coord : Vector2i):
			var coords = [coord]
			for y in Board.cy:
				for x in Board.cx:
					for p in App.patterns:
						var res : Array[Vector2i] = p.match_with(Vector2i(x, y))
						if res.has(coord):
							for c in res:
								if !coords.has(c):
									coords.append(c)
			for c in coords:
				Board.pin(c)
			return true
	elif name == "ChainBomb":
		image_id = 10
		category = "Bomb"
		extra["range"] = 1
		on_eliminate = func(coord : Vector2i, reason : int, source, tween : Tween):
			if !Board.active_effects.is_empty():
				var i = Board.active_effects.back().host
				if i.name == "Chain Bomb":
					Buff.create(self, Buff.Type.ValueModifier, {"target":"power","set":i.power + 2})
					Buff.create(self, Buff.Type.ValueModifier, {"target":"range","sub_attr":"extra","set":i.extra["range"] + 1})
			tween.tween_callback(func():
				Board.activate(self, HostType.Gem, 0, coord, reason, source)
			)
		on_active = func(effect_index : int, coord : Vector2i, tween : Tween, item_ui : Node2D):
			Board.effect_explode(Board.get_pos(coord), coord, extra["range"], power, tween, self)
	elif name == "GoldenBomb":
		image_id = 42
		category = "Bomb"
		extra["range"] = 1
		on_eliminate = func(coord : Vector2i, reason : int, source, tween : Tween):
			tween.tween_callback(func():
				Board.activate(self, HostType.Gem, 0, coord, reason, source)
			)
		on_active = func(effect_index : int, coord : Vector2i, tween : Tween, item_ui : Node2D):
			if App.coins >= 6:
				App.coins -= 6
				var coords = Board.effect_explode(Board.get_pos(coord), coord, extra["range"], power, tween, self)
				tween.tween_callback(func():
					for c in coords:
						var v = App.game_rng.randi_range(0, 3)
						App.float_text("%dG" % v, Board.get_pos(c), Color(0.9, 0.75, 0.25))
						App.coins += v
				)
	elif name == "Minefield":
		image_id = 42
		extra["setup_range"] = 2
		extra["range"] = 0
		on_quick = func(coord : Vector2i):
			var setup_range = extra["setup_range"]
			var coords = []
			for i in setup_range + 1:
				for c in Board.offset_ring(coord, i):
					if Board.is_valid(c):
						Board.get_cell(c).event_listeners.append(Hook.new(Event.Eliminated, self, HostType.Gem, true))
						coords.append(c)
			return true
		on_event = func(event : int, tween : Tween, data):
			if event == Event.Eliminated:
				Board.activate(self, HostType.Gem, 0, data, Board.ActiveReason.Item, self)
		on_active = func(effect_index : int, coord : Vector2i, tween : Tween, item_ui : Node2D):
			Board.effect_explode(Board.get_pos(coord), coord, extra["range"], power, tween, self)
	elif name == "EchoStone":
		image_id = 42
		category = "Normal"
		extra["range"] = 1
		on_event = func(event : int, tween : Tween, data):
			if event == Event.Exploded:
				Board.activate(self, HostType.Gem, 0, coord, Board.ActiveReason.Item, self)
		on_eliminate = func(coord : Vector2i, reason : int, source, tween : Tween):
			if reason == Board.ActiveReason.Item && source.category == "Bomb":
				tween.tween_callback(func():
					Board.activate(self, HostType.Gem, 1, coord, reason, source)
				)
		on_active = func(effect_index : int, coord : Vector2i, tween : Tween, item_ui : Node2D):
			if effect_index == 0:
				var places = []
				for c in Board.offset_neighbors(coord):
					if Board.is_valid(c):
						places.append(c)
				tween.tween_callback(func():
					App.add_combo()
					Board.score_at(SMath.pick_random(places, App.game_rng))
				)
				Board.eliminate([coord], tween, Board.ActiveReason.Item, self)
			elif effect_index == 1:
				Board.effect_explode(Board.get_pos(coord), coord, extra["range"], power, tween, self)
	elif name == "Virus":
		image_id = 11
		category = "Normal"
		on_place = func(coord : Vector2i, reason : int):
			if reason == Board.PlaceReason.FromHand:
				var places = []
				'''
				for c in Board.offset_neighbors(coord):
					if Board.is_valid(c) && !Board.get_item_at(c):
						places.append(c)
				if !places.is_empty():
					places = SMath.pick_n_random(places, 2, App.game_rng)
					for c in places:
						var new_item = Item.new()
						new_item.setup("Virus")
						App.items.append(new_item)
						Board.set_item_at(c, new_item)
				'''
		on_eliminate = func(coord : Vector2i, reason : int, source, tween : Tween):
			tween.tween_callback(func():
				Board.activate(self, HostType.Gem, 0, coord, reason, source)
			)
		on_active = func(effect_index : int, coord : Vector2i, tween : Tween, item_ui : Node2D):
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
								Board.ui.overlay.add_child(sp)
								tween.tween_callback(func():
									sp.emitting = true
								)
								sps.append(sp)
								arr2.append(cc)
								coords.append(cc)
				arr.clear()
				arr.append_array(arr2)
				tween.tween_interval(0.4 * App.speed)
			tween.tween_callback(func():
				for sp in sps:
					sp.queue_free()
				
				App.add_combo()
				for c in coords:
					Board.score_at(c)
			)
			Board.eliminate(coords, tween, Board.ActiveReason.Item, self)
	elif name == "ColorPalette":
		image_id = 13
		category = "Normal"
		price = 4
		on_quick = func(coord : Vector2i):
			var g = Board.get_gem_at(coord)
			if g && g.type != Gem.ColorWild:
				var cands = Board.filter(func(gem : Gem, item : Item):
					if gem && gem.type != Gem.ColorWild:
						return true
					return false
				)
				if !cands.is_empty():
					var pos = Board.get_pos(coord)
					var targets = SMath.pick_n_random(cands, 3, App.game_rng) 
					for c in targets:
						Buff.create(Board.get_gem_at(c), Buff.Type.ChangeColor, {"color":Gem.ColorWild}, Buff.Duration.ThisRound)
				Buff.create(g, Buff.Type.ChangeColor, {"color":Gem.ColorWild}, Buff.Duration.ThisRound)
				return true
			return false
	elif name == "Fire":
		image_id = 14
		category = "Normal"
		on_eliminate = func(coord : Vector2i, reason : int, source, tween : Tween):
			tween.tween_callback(func():
				#Board.set_state_at(coord, Cell.State.Burning)
				SSound.se_start_buring.play()
			)
	elif name == "BlackHole":
		image_id = 15
		category = "Normal"
		on_eliminate = func(coord : Vector2i, reason : int, source, tween : Tween):
			tween.tween_callback(func():
				Board.activate(self, HostType.Gem, 0, coord, reason, source)
			)
		on_active = func(effect_index : int, coord : Vector2i, tween : Tween, item_ui : Node2D):
			if Board.active_effects.back().host == self:
				var coords : Array[Vector2i] = []
				for y in Board.cy:
					for x in Board.cx:
						var c = Vector2i(x, y)
						coords.append(c)
				tween.tween_callback(func():
					var pos : Vector2 = Board.get_pos(coord)
					var fx = SEffect.add_black_hole_rotating(pos, Vector2(128.0, 128.0), 0, 3.0)
					Board.ui.underlay.add_child(fx)
					
					for c in coords:
						var ui = Board.ui.get_cell(c).gem
						var data = {"ui":ui,"vel":SMath.tangent2(Board.get_pos(c) - pos).normalized() * 1.4}
						var tween2 = App.game_tweens.create_tween()
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
						App.add_combo()
						for c in coords:
							if Board.is_valid(c):
								Board.score_at(c)
				)
				Board.eliminate(coords, tween, Board.ActiveReason.Item, self)
	elif name == "WhiteHole":
		image_id = 16
		category = "Normal"
		on_eliminate = func(coord : Vector2i, reason : int, source, tween : Tween):
			if Board.active_effects.is_empty():
				tween.tween_callback(func():
					Board.activate(self, HostType.Gem, 0, coord, reason, source)
				)
		on_active = func(effect_index : int, coord : Vector2i, tween : Tween, item_ui : Node2D):
			var coords : Array[Vector2i] = []
			for y in Board.cy:
				for x in Board.cx:
					var c = Vector2i(x, y)
					coords.append(c)
			var pos : Vector2 = Board.get_pos(coord)
			tween.tween_callback(func():
				var fx = SEffect.add_white_hole_injection(pos, Vector2(128.0, 128.0), 0, 3.0)
				Board.ui.underlay.add_child(fx)
			)
			tween.tween_method(func(r : float):
				for c in coords:
					var ui = Board.ui.get_cell(c).gem
					if pos.distance_to(ui.global_position) < r:
						ui.scale = Vector2(0.0, 0.0).max(ui.scale - Vector2(0.1, 0.1))
			, 0.0, 1200.0, 3.0)
			tween.tween_callback(func():
					App.add_combo()
					for c in coords:
						if Board.is_valid(c):
							Board.score_at(c)
			)
			Board.eliminate(coords, tween, Board.ActiveReason.Item, self)
	elif name == "Chloroplast":
		image_id = 17
		category = "Normal"
		price = 5
		on_quick = func(coord : Vector2i):
			var g = Board.get_gem_at(coord)
			if g && g.type != Gem.None:
				Buff.create(g, Buff.Type.ChangeColor, {"color":Gem.None}, Buff.Duration.ThisRound)
				for i in 2:
					App.Hand.draw()
				return true
			return false
	elif name == "Dog":
		image_id = 18
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
				App.add_score(extra["value"] * targets.size(), Board.get_pos(coord))
			)
	elif name == "Cat":
		image_id = 19
		category = "Animal"
		price = 4
		extra["repeat"] = 2
		on_eliminate = func(coord : Vector2i, reason : int, source, tween : Tween):
			tween.tween_callback(func():
				Board.activate(self, HostType.Gem, 0, coord, reason, source)
			)
		on_active = func(effect_index : int, coord : Vector2i, tween : Tween, item_ui : Node2D):
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
					var c = SMath.pick_random(cands, App.game_rng)
					var pos = Board.get_pos(c)
					SAnimation.quadratic_curve_to(tween, item_ui, pos, Vector2(0.5, 0.5), 0.4 * App.speed)
					coords.append(c)
					tween.tween_callback(func():
						App.add_combo()
						Board.score_at(c)
					)
					Board.eliminate([c], tween, Board.ActiveReason.Item, self)
					bc = c
	elif name == "Rooster":
		image_id = 20
		category = "Animal"
		on_eliminate = func(coord : Vector2i, reason : int, source, tween : Tween):
			tween.tween_callback(func():
				Board.activate(self, HostType.Gem, 0, coord, reason, source)
			)
		on_active = func(effect_index : int, coord : Vector2i, tween : Tween, item_ui : Node2D):
			var targets = Board.filter(func(gem : Gem, item : Item):
				if item && item.category == "Animal":
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
					'''
					for c in targets:
						var i = Board.get_item_at(c)
						if i:
							Board.activate(i, 0, 0, c, Board.ActiveReason.Item, self)
					'''
				)
	elif name == "Rabbit":
		image_id = 21
		extra["repeat"] = 1
		on_eliminate = func(coord : Vector2i, reason : int, source, tween : Tween):
			tween.tween_callback(func():
				Board.activate(self, HostType.Gem, 0, coord, reason, source)
			)
		on_active = func(effect_index : int, coord : Vector2i, tween : Tween, item_ui : Node2D):
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
					var c = SMath.pick_random(cands, App.game_rng)
					var pos = Board.get_pos(c)
					SAnimation.quadratic_curve_to(tween, item_ui, pos, Vector2(0.5, 0.5), 0.4 * App.speed)
					coords.append(c)
					tween.tween_callback(func():
						App.add_combo()
						Board.score_at(c)
						'''
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
							Board.ui.overlay.add_child(sp)
							var tween2 = App.game_tweens.create_tween()
							SAnimation.cubic_curve_to(tween2, sp, App.status_bar_ui.bag_button.get_global_rect().get_center(), Vector2(0.1, 0.2), Vector2(0.9, 0.2), 0.4)
							tween2.tween_callback(func():
								var new_item = Item.new()
								new_item.setup("Rabbit")
								App.add_item(new_item)
							)
						'''
					)
					Board.eliminate([c], tween, Board.ActiveReason.Item, self)
					bc = c
	elif name == "Fox":
		image_id = 22
		category = "Animal"
		tradeable = true
		on_place = func(coord : Vector2i, reason : int):
			if reason == Board.PlaceReason.FromBag:
				var cands = []
				for i in App.items:
					if i.coord.x == -1 && i.coord.y == -1 && i.category == "Animal":
						cands.append(i)
				if !cands.is_empty():
					var item = SMath.pick_random(cands, App.game_rng)
					var tween = App.game_tweens.create_tween()
					tween.tween_callback(func():
						SEffect.add_leading_line(Board.get_pos(coord), App.status_bar_ui.bag_button.get_global_rect().get_center())
					)
					tween.tween_interval(0.3)
					Board.effect_place_items_from_bag([item], tween)
		
	elif name == "Eagle":
		image_id = 23
		category = "Animal"
		on_place = func(coord : Vector2i, reason : int):
			var cands = []
			for i in App.items:
				if i.coord.x == -1 && i.coord.y == -1 && i.category == "Animal":
					cands.append(i)
			if !cands.is_empty():
				var item = SMath.pick_random(cands, App.game_rng)
				var tween = App.game_tweens.create_tween()
				tween.tween_callback(func():
					SEffect.add_leading_line(Board.get_pos(coord), App.status_bar_ui.bag_button.get_global_rect().get_center())
				)
				tween.tween_interval(0.3)
				Board.effect_place_items_from_bag([item], tween)
	elif name == "Mouse":
		image_id = 24
		category = "Animal"
		on_eliminate = func(coord : Vector2i, reason : int, source, tween : Tween):
			tween.tween_callback(func():
				Board.activate(self, HostType.Gem, 0, coord, reason, source)
			)
		on_active = func(effect_index : int, coord : Vector2i, tween : Tween, item_ui : Node2D):
			var targets = Board.filter(func(gem : Gem, item : Item):
				return item && item.category == "Food"
			)
			if !targets.is_empty():
				var c = SMath.pick_random(targets, App.game_rng)
				'''
				var i = Board.get_item_at(c)
				var score = i.extra["score"]
				var pos = Board.get_pos(c)
				SAnimation.move_to(tween, item_ui, pos, 0.4 * App.speed)
				tween.tween_callback(func():
					App.add_combo()
					App.add_score(score, pos)
				)
				Board.item_moved(self, tween, coord, c)
				'''
	elif name == "Horse":
		image_id = 25
		category = "Animal"
		mountable = "Character"
		on_mount = func(mounted : Item):
			'''
			if mounted.name == "Idol":
				var c = coord
				Board.set_item_at(c, null)
				App.release_item(mounted)
				var new_item = Item.new()
				new_item.setup("Princess")
				App.items.append(new_item)
				Board.set_item_at(c, new_item)
				return false
			elif mounted.name == "Magician":
				var c = coord
				Board.set_item_at(c, null)
				App.release_item(mounted)
				var new_item = Item.new()
				new_item.setup("Mage")
				App.items.append(new_item)
				Board.set_item_at(c, new_item)
				return false
			'''
			return true
	elif name == "Elephant":
		image_id = 26
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
						App.add_combo()
						for c in coords:
							if Board.is_valid(c):
								Board.score_at(c)
					)
					Board.eliminate(coords, tween, Board.ActiveReason.Item, self)
	elif name == "HotDog":
		image_id = 27
		category = "Food"
		extra["value"] = 625
		on_eliminate = func(coord : Vector2i, reason : int, source, tween : Tween):
			tween.tween_callback(func():
				App.add_score(extra["value"], Board.get_pos(coord))
			)
	elif name == "Magnet":
		image_id = 29
		category = "Normal"
		on_event = func(event : int, tween : Tween, data):
			if event == Event.ItemActivated:
				var sp = data.third
				SAnimation.move_to(tween, sp, Board.get_pos(coord), 0.3)
				data.second = coord
	elif name == "Idol":
		image_id = 31
		category = "Character"
		extra["value"] = 3
		on_event = func(event : int, tween : Tween, data):
			var value = extra["value"]
			match event: 
				Event.GemEntered:
					extra["buff_ids"].append(Buff.create(data, Buff.Type.ValueModifier, {"target":"bonus_score","add":value}, Buff.Duration.OnBoard))
				Event.ItemEntered:
					extra["buff_ids"].clear()
					if data == self:
						for y in Board.cy:
							for x in Board.cx:
								var g = Board.get_gem_at(Vector2i(x, y))
								if g:
									extra["buff_ids"].append(Buff.create(g, Buff.Type.ValueModifier, {"target":"bonus_score","add":value}, Buff.Duration.OnBoard))
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
			tween.tween_interval(0.5 * App.speed)
			tween.tween_callback(func():
				for c in coords:
					var g = Board.get_gem_at(c)
					if g:
						var v = App.gem_add_base_score(g, -1)
						App.float_text("%d" % v, Board.get_pos(c), Color(0.8, 0.1, 0.0))
			)
	elif name == "Magician":
		image_id = 32
		price = 1
		category = "Character"
		extra["number"] = 5
		on_eliminate = func(coord : Vector2i, reason : int, source, tween : Tween):
			tween.tween_callback(func():
				Board.activate(self, HostType.Gem, 0, coord, reason, source)
			)
		on_active = func(effect_index : int, coord : Vector2i, tween : Tween, item_ui : Node2D):
			var cands = Board.filter(func(gem : Gem, item : Item):
				if gem && gem.type != Gem.ColorWild:
					return true
				return false
			)
			if !cands.is_empty():
				var pos = Board.get_pos(coord)
				var targets = SMath.pick_n_random(cands, extra["number"], App.game_rng) 
				tween.tween_callback(func():
					for c in targets:
						SEffect.add_leading_line(pos, Board.get_pos(c))
				)
				tween.tween_interval(0.3)
				tween.tween_callback(func():
					for c in targets:
						Buff.create(Board.get_gem_at(c), Buff.Type.ChangeColor, {"color":Gem.ColorWild}, Buff.Duration.OnBoard)
					if !targets.is_empty():
						SSound.se_vibra.play()
				)
	elif name == "Merchant":
		image_id = 33
	elif name == "Princess":
		image_id = 33
		category = "Character"
		extra["value"] = 7
		on_event = func(event : int, tween : Tween, data):
			var value = extra["value"]
			match event: 
				Event.GemEntered:
					extra["buff_ids"].append(Buff.create(data, Buff.Type.ValueModifier, {"target":"bonus_score","add":value}, Buff.Duration.OnBoard))
				Event.ItemEntered:
					extra["buff_ids"].clear()
					if data == self:
						for y in Board.cy:
							for x in Board.cx:
								var g = Board.get_gem_at(Vector2i(x, y))
								if g:
									extra["buff_ids"].append(Buff.create(g, Buff.Type.ValueModifier, {"target":"bonus_score","add":value}, Buff.Duration.OnBoard))
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
						App.float_text("+1", Board.get_pos(c), Color(0.1, 0.8, 0.0))
						g.base_score += 1
			)
	elif name == "Mage":
		image_id = 34
		category = "Character"
		on_eliminate = func(coord : Vector2i, reason : int, source, tween : Tween):
			tween.tween_callback(func():
				Board.activate(self, HostType.Gem, 0, coord, reason, source)
			)
		on_active = func(effect_index : int, coord : Vector2i, tween : Tween, item_ui : Node2D):
			tween.tween_callback(func():
				for c in Board.offset_neighbors(coord):
					var g = Board.get_gem_at(c)
					if g:
						Buff.create(g, Buff.Type.ChangeColor, {"color":Gem.ColorWild}, Buff.Duration.ThisRound)
			)
	elif name == "StrengthPotion":
		image_id = 40
		category = "Normal"
		price = 4
		on_quick = func(coord : Vector2i):
			'''
			var i = Board.get_item_at(coord)
			if i:
				Buff.create(i, Buff.Type.ValueModifier, {"target":"power","add":10}, Buff.Duration.ThisRound)
				return true
			'''
			return false
	elif name == "EchoTotem":
		image_id = 41
		category = "Normal"
		price = 4
	elif name == "SinLust":
		image_id = 42
		price = 0
		on_eliminate = func(coord : Vector2i, reason : int, source, tween : Tween):
			match Curse.lust_triggered:
				0:
					tween.tween_callback(func():
						var generated_score = 0
						for p in App.staging_scores:
							generated_score += p.second
						var pos = Board.get_pos(coord)
						App.float_text(tr("t_Lust_effect1"), Board.get_pos(coord), Color(1.0, 1.0, 1.0))
						App.add_score(generated_score, pos)
					)
				1:
					tween.tween_callback(func():
						App.float_text(tr("t_Lust_effect2"), Board.get_pos(coord), Color(1.0, 1.0, 1.0))
						Buff.create(App, Buff.Type.ValueModifier, {"target":"gain_scaler","set":0.0}, Buff.Duration.ThisRound)
					)
				2:
					tween.tween_callback(func():
						App.float_text(tr("t_Lust_effect3"), Board.get_pos(coord), Color(1.0, 1.0, 1.0))
						App.game_over_mark = "lust_dead"
					)
			Curse.lust_triggered += 1
	elif name == "SinGluttony":
		image_id = 43
		price = 0
		on_event = func(event : int, tween : Tween, data):
			match event: 
				Event.ItemEntered:
					if data == self:
						App.event_listeners.append(Hook.new(Event.MatchingFinished, self, HostType.Gem, false))
				Event.ItemLeft:
					if data == self:
						for l in App.event_listeners:
							if l.host == self:
								App.event_listeners.erase(l)
								break
				Event.MatchingFinished:
					var num_gluttony = Board.filter(func(g : Gem, i : Item):
						return i && i.name == "SinGluttony"
					).size()
					if App.combos < num_gluttony:
						App.game_over_mark = "sin_gluttony"
						App.lose()
						return true
	elif name == "SinGreed":
		image_id = 44
		price = 0
		extra["value"] = "?"
		on_eliminate = func(coord : Vector2i, reason : int, source, tween : Tween):
			tween.tween_callback(func():
				SSound.se_coin.play()
				App.coins += extra["value"]
				
				var num_greed = Board.filter(func(g : Gem, i : Item):
					return i && i.name == "SinGreed"
				).size()
				if num_greed == 1:
					App.float_text(tr("t_Greed_effect"), Board.get_pos(coord), Color(1.0, 1.0, 1.0))
					App.coins = 0
			)
	elif name == "SinEnvy":
		image_id = 45
		price = 0
		on_event = func(event : int, tween : Tween, data):
			match event: 
				Event.ItemEntered:
					if data == self:
						pass
						#Board.add_aura(self)
				Event.ItemLeft:
					if data == self:
						pass
						#Board.remove_aura(self)
		on_eliminate = func(coord : Vector2i, reason : int, source, tween : Tween):
			tween.tween_callback(func():
				App.float_text(tr("t_Envy_effect"), Board.get_pos(coord), Color(1.0, 1.0, 1.0))
			)
		on_aura = func(g : Gem):
			var b = Buff.create(g, Buff.Type.ValueModifier, {"target":"score_mult","add":-0.25}, Buff.Duration.OnBoard)
			b.caster = self

func get_tooltip():
	var ret : Array[Pair] = []
	var content = ""
	if tradeable:
		content = "w_tradable\n" + content
	if mountable != "":
		content = ("w_mount for [color=gray][b]%s[/b][/color]\n" % mountable) + content
	if mounted:
		ret.append_array(mounted.get_tooltip())
	return ret
