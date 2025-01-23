extends Object

class_name Item

var name : String
var image_path : String
var coord : Vector2i
var active : bool = false

var on_process : Callable
var on_place : Callable
var on_active : Callable
var on_combo : Callable

var extra = {}

const explosion_frames : SpriteFrames = preload("res://images/explosion.tres")
const fx_distortion = preload("res://fx_distortion.tscn")
const fx_lightning = preload("res://fx_lightning.tscn")

func setup(n : String):
	name = n
	if name == "mine":
		image_path = "res://images/mine.png"
		on_process = func(b : Board, tween : Tween):
			tween.tween_callback(func():
				var pos = b.get_pos(coord)
				var sp_expl = AnimatedSprite2D.new()
				sp_expl.position = pos
				sp_expl.sprite_frames = explosion_frames
				sp_expl.play("default")
				sp_expl.z_index = 3
				Game.cells_root.add_child(sp_expl)
				var fx = fx_distortion.instantiate()
				fx.position = pos
				fx.scale = Vector2(64, 64)
				fx.z_index = 4
				var mat : ShaderMaterial = fx.material
				Game.cells_root.add_child(fx)
				var tween2 = Game.get_tree().create_tween()
				tween2.tween_method(func(t):
					mat.set_shader_parameter("radius", t)
				, 0.0, 0.8, 0.5)
				tween2.tween_callback(sp_expl.queue_free)
				tween2.tween_callback(fx.queue_free)
				Game.sound.sfx_explode.play()
				var score = 0
				score += b.gem_score_at(coord)
				b.eliminate(coord, Board.ActiveReason.Item, self)
				for c in b.offset_neighbors(coord):
					if c.x >= 0 && c.y >= 0 && c.x < b.cx && c.y < b.cy:
						score += b.gem_score_at(c)
						b.eliminate(c, Board.ActiveReason.Item, self)
				Game.add_combo()
				Game.add_score(score, pos)
			)
			tween.tween_interval(0.6 * Game.animation_speed)
	elif name == "c4":
		image_path = "res://images/c4.png"
	elif name == "chain_bomb":
		image_path = "res://images/chain_bomb.png"
		on_process = func(b : Board, tween : Tween):
			tween.tween_callback(func():
				var score = 0
				score += b.gem_score_at(coord)
				b.eliminate(coord, Board.ActiveReason.Item, self)
				for c in b.offset_neighbors(coord):
					var item = b.get_item_at(c)
					if item:
						b.activate_item(item, Board.ActiveReason.Item, self)
				Game.add_combo()
				Game.add_score(score, b.get_pos(coord))
			)
			tween.tween_interval(0.6 * Game.animation_speed)
		on_combo = func(b : Board, combo : int):
			if combo >= 4:
				b.activate_item(self, Board.ActiveReason.Item, self)
	elif name == "virus":
		image_path = "res://images/virus.png"
		on_process = func(b : Board, tween : Tween):
			tween.tween_callback(func():
				var score = 0
				var gem = b.get_gem_at(coord)
				var touched = {}
				var coords = []
				coords.append(coord)
				touched[coord] = 1
				while !coords.is_empty():
					var c = coords[0]
					coords.remove_at(0)
					if b.get_gem_at(c) == gem:
						score += b.gem_score_at(c)
						b.eliminate(c, Board.ActiveReason.Item, self)
						for cc in b.offset_neighbors(c):
							if !touched.has(cc):
								coords.append(cc)
								touched[cc] = 1
				Game.add_combo()
				Game.add_score(score, b.get_pos(coord))
			)
			tween.tween_interval(0.6)
	elif name == "lightning":
		image_path = "res://images/lightning.png"
		on_process = func(b : Board, tween : Tween):
			var target : Item = null
			for y in b.cy:
				for x in b.cx:
					var item = b.get_item_at(Vector2i(x, y))
					if item && item != self && item.name == "lightning" && item.active:
						target = item
						break
				if target:
					break
			if target:
				tween.tween_callback(func():
						var score = 0
						var p0 : Vector2 = b.get_pos(coord)
						var pos : Vector2 = p0
						var p1 : Vector2 = b.get_pos(target.coord)
						pos = (p0 + p1) / 2.0
						var fx = fx_lightning.instantiate()
						fx.position = pos
						var dist = p0.distance_to(p1)
						fx.scale = Vector2(dist, dist)
						fx.rotation = (p1 - p0).angle() - PI * 0.5
						fx.z_index = 8
						Game.cells_root.add_child(fx)
						var tween2 = Game.get_tree().create_tween()
						tween2.tween_interval(0.5)
						tween2.tween_callback(fx.queue_free)
						score += b.gem_score_at(target.coord)
						b.eliminate(target.coord, Board.ActiveReason.Item, self)
						Game.sound.sfx_lighting_connect.play()
						for c in b.draw_line(b.offset_to_cube(coord), b.offset_to_cube(target.coord)):
							var cc = b.cube_to_offset(c)
							score += b.gem_score_at(cc)
							b.eliminate(cc, Board.ActiveReason.Item, self)
						Game.add_combo()
						Game.add_score(score, pos)
				)
				tween.tween_interval(0.6 * Game.animation_speed)
			else:
				tween.tween_callback(func():
					Game.sound.sfx_lighting_fail.play()
				)
	elif name == "color_palette":
		image_path = "res://images/color_palette.png"
		on_process = func(b : Board, tween : Tween):
			tween.tween_callback(func():
				var gem = b.get_gem_at(coord)
				var list = []
				for i in range(1, 5):
					if i != gem:
						list.append(i)
				b.set_gem_at(coord, list.pick_random())
			)
		on_place = func(b : Board):
			b.activate_item(self, Board.ActiveReason.Item, self)
	elif name == "fire":
		image_path = "res://images/fire.png"
		on_active = func(b : Board, reason : int, source):
			b.set_gem_state_at(coord, Cell.GemState.Burning)
	elif name == "black_hole":
		image_path = "res://images/black_hole.png"
		on_process = func(b : Board, tween : Tween):
			if b.active_items.size() == 1:
				tween.tween_callback(func():
						var pos = b.get_pos(coord)
						var score = 0
						for y in b.cy:
							for x in b.cx:
								var c = Vector2i(x, y)
								score += b.gem_score_at(c)
								b.eliminate(c, Board.ActiveReason.Item, self)
						Game.add_combo()
						Game.add_score(score, pos)
				)
				tween.tween_interval(0.6 * Game.animation_speed)
	elif name == "white_hole":
		image_path = "res://images/white_hole.png"
		on_active = func(b : Board, reason : int, source):
			extra["first"] = b.active_items.is_empty()
		on_process = func(b : Board, tween : Tween):
			if extra["first"]:
				extra["first"] = false
				tween.tween_callback(func():
						var pos = b.get_pos(coord)
						var score = 0
						for y in b.cy:
							for x in b.cx:
								var c = Vector2i(x, y)
								score += b.gem_score_at(c)
								b.eliminate(c, Board.ActiveReason.Item, self)
						Game.add_combo()
						Game.add_score(score, pos)
				)
				tween.tween_interval(0.6 * Game.animation_speed)
	elif name == "dog":
		image_path = "res://images/dog.png"
		on_process = func(b : Board, tween : Tween):
			tween.tween_callback(func():
				var pos = b.get_pos(coord)
				var score = 5
				if b.touched_items.has("cat") || b.touched_items.has("rooster"):
					score += 5
				Game.add_combo()
				Game.add_score(score, pos)
			)
	elif name == "cat":
		image_path = "res://images/cat.png"
		on_process = func(b : Board, tween : Tween):
			tween.tween_callback(func():
				var pos = b.get_pos(coord)
				var score = 20
				if b.touched_items.has("dog") || b.touched_items.has("rooster"):
					score -= 5
				if score > 0:
					Game.add_combo()
					Game.add_score(score, pos)
			)
	elif name == "rooster":
		image_path = "res://images/rooster.png"
		on_process = func(b : Board, tween : Tween):
			tween.tween_callback(func():
				var num = 3
				for y in b.cy:
					for x in b.cx:
						var c = Vector2i(x, y)
						var item = b.get_item_at(c)
						if item && !item.active:
							b.activate_item(item, Board.ActiveReason.Item, self)
							num -= 1
							if num == 0:
								break
					if num == 0:
						break
			)
	elif name == "hotdog":
		image_path = "res://images/hotdog.png"
		on_active = func(b : Board, reason : int, source):
			var pos = b.get_pos(coord)
			Game.add_combo()
			Game.add_score(50, pos)
	elif name == "lai_cut":
		image_path = "res://images/lai_cut.png"
		on_process = func(b : Board, tween : Tween):
			var no_others = true
			for y in b.cy:
				for x in b.cx:
					var item = b.get_item_at(Vector2i(x, y))
					if item && item.name == "lai_cut":
						no_others = false
						break
				if !no_others:
					break
			if no_others:
				tween.tween_callback(func():
					var pos = b.get_pos(coord)
					var cc = b.offset_to_cube(coord)
					var score = 0
					match randi() % 3:
						0: 
							for x in b.cx:
								var c = b.cube_to_offset(Vector3i(x, -x - cc.z, cc.z))
								score += b.gem_score_at(c)
								b.eliminate(c, Board.ActiveReason.Item, self)
						1: 
							for x in b.cx:
								var c = b.cube_to_offset(Vector3i(cc.x, x - cc.x, -x))
								score += b.gem_score_at(c)
								b.eliminate(c, Board.ActiveReason.Item, self)
						2: 
							for x in b.cx:
								var c = b.cube_to_offset(Vector3i(x - cc.y, cc.y, -x))
								score += b.gem_score_at(c)
								b.eliminate(c, Board.ActiveReason.Item, self)
					Game.add_combo()
					Game.add_score(score, pos)
				)
				tween.tween_interval(0.6 * Game.animation_speed)
	elif name == "magnet":
		image_path = "res://images/magnet.png"
		on_process = func(b : Board, tween : Tween):
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
	elif name == "rainbow":
		image_path = "res://images/rainbow.png"
		on_active = func(b : Board, reason : int, source):
			Game.rainbow_mult *= 1.5
	elif name == "ruby":
		image_path = "res://images/ruby.png"
		on_active = func(b : Board, reason : int, source):
			var gem = b.get_gem_at(coord)
			if reason == Board.ActiveReason.Pattern && gem == Board.Gem.Red:
				b.gem_scores[Board.Gem.Red] += 1
				Game.add_status("Red +1", b.gem_col(Board.Gem.Red))
	elif name == "citrine":
		image_path = "res://images/citrine.png"
		on_active = func(b : Board, reason : int, source):
			var gem = b.get_gem_at(coord)
			if reason == Board.ActiveReason.Pattern && gem == Board.Gem.Yellow:
				b.gem_scores[Board.Gem.Yellow] += 1
				Game.add_status("Yellow +1", b.gem_col(Board.Gem.Yellow))
	elif name == "emerald":
		image_path = "res://images/emerald.png"
		on_active = func(b : Board, reason : int, source):
			var gem = b.get_gem_at(coord)
			if reason == Board.ActiveReason.Pattern && gem == Board.Gem.Green:
				b.gem_scores[Board.Gem.Green] += 1
				Game.add_status("Green +1", b.gem_col(Board.Gem.Green))
	elif name == "sapphire":
		image_path = "res://images/sapphire.png"
		on_active = func(b : Board, reason : int, source):
			var gem = b.get_gem_at(coord)
			if reason == Board.ActiveReason.Pattern && gem == Board.Gem.Blue:
				b.gem_scores[Board.Gem.Blue] += 1
				Game.add_status("Blue +1", b.gem_col(Board.Gem.Blue))
	elif name == "amethyst":
		image_path = "res://images/amethyst.png"
		on_active = func(b : Board, reason : int, source):
			var gem = b.get_gem_at(coord)
			if reason == Board.ActiveReason.Pattern && gem == Board.Gem.Purple:
				b.gem_scores[Board.Gem.Purple] += 1
				Game.add_status("Purple +1", b.gem_col(Board.Gem.Purple))
