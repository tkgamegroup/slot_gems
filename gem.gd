extends Object

class_name Gem

enum Type
{
	None,
	Red,
	Orange,
	Green,
	Blue,
	Pink,
	Count = 5
}

enum Rune
{
	None,
	Star,
	Circle,
	Diamond,
	Count = 3
}

const gem_frames : SpriteFrames = preload("res://images/gems.tres")
const rune_frames : SpriteFrames = preload("res://images/runes.tres")

var type : int = Type.None
var rune : int = Rune.None

var name : String
var image_id : int
var base_score : int = 1
var bonus_score : int = 0
var description : String
var category : String
var coord : Vector2i = Vector2i(-1, -1)
var active : bool = false
var temporary : bool = false

var on_process : Callable
var on_place : Callable
var on_active : Callable
var on_combo : Callable

var extra = {}

static func color(t : int) -> Color:
	match t:
		Type.None: return Color(0, 0, 0, 0)
		Type.Red: return Color(214.0 / 255.0, 19.0 / 255.0, 25.0 / 255.0)
		Type.Orange: return Color(255.0 / 255.0, 186.0 / 255.0, 7.0 / 255.0)
		Type.Green: return Color(157.0 / 255.0, 192.0 / 255.0, 64.0 / 255.0)
		Type.Blue: return Color(143.0 / 255.0, 223.0 / 255.0, 246.0 / 255.0)
		Type.Pink: return Color(230.0 / 255.0, 53.0 / 255.0, 108.0 / 255.0)
	return Color.WHITE

static func rune_name(r : int):
	match r:
		Rune.Star: return "Star"
		Rune.Circle: return "Circle"
		Rune.Diamond: return "Diamond"
	return "None"

static func rune_icon(r : int):
	match r:
		Rune.Star: return "res://images/rune_star.png"
		Rune.Circle: return "res://images/rune_circle.png"
		Rune.Diamond: return "res://images/rune_diamond.png"
	return ""

static var name_list : Array[String]

static func get_name_list(base : int = 0, num : int = 10000):
	if name_list.is_empty():
		name_list.append("Red")
		name_list.append("Orange")
		name_list.append("Green")
		name_list.append("Blue")
		name_list.append("Pink")
		name_list.append("Bomb")
	return name_list.slice(base, base + num)

func get_base_score():
	var ret = base_score
	ret += Game.gem_bouns_scores[type - 1]
	return ret

func get_description():
	return "Rune: %s\nScore: %d%s\n%s" % [rune_name(rune), get_base_score(), ("+%d" % bonus_score) if bonus_score > 0 else "", description]

func setup(n : String):
	name = n
	if name == "Red":
		image_id = 1
		description = ""
		category = "Normal"
		type = Type.Red
	elif name == "Orange":
		image_id = 2
		description = ""
		type = Type.Orange
	elif name == "Green":
		image_id = 3
		description = ""
		type = Type.Green
	elif name == "Blue":
		image_id = 4
		description = ""
		type = Type.Blue
	elif name == "Pink":
		image_id = 5
		description = ""
		type = Type.Pink
	elif name == "Bomb":
		image_id = 6
		description = "Activate: Eliminate cells in 1-ring."
		category = "Bomb"
		type = Type.Red
		rune = Rune.None
		on_process = func(b : Board, tween : Tween):
			var coords : Array[Vector2i] = []
			for c in b.offset_neighbors(coord):
				coords.append(c)
			tween.tween_callback(func():
				var pos = b.get_pos(coord)
				var sp_expl = AnimatedSprite2D.new()
				sp_expl.position = pos
				sp_expl.sprite_frames = Effects.explosion_frames
				sp_expl.scale = Vector2(2.0, 2.0)
				sp_expl.play("default")
				sp_expl.z_index = 3
				Game.cells_root.add_child(sp_expl)
				var fx = Effects.distortion.instantiate()
				fx.position = pos
				fx.scale = Vector2(128, 128)
				fx.z_index = 4
				var mat : ShaderMaterial = fx.material
				Game.cells_root.add_child(fx)
				var tween2 = Game.get_tree().create_tween()
				tween2.tween_method(func(t):
					mat.set_shader_parameter("radius", t)
				, 0.0, 0.5, 0.5)
				tween2.tween_callback(sp_expl.queue_free)
				tween2.tween_callback(fx.queue_free)
				Sounds.sfx_explode.play()
				var score = 0
				for c in coords:
					score += b.gem_score_at(c)
				Game.add_combo()
				Game.add_score(score, pos)
			)
			b.eliminate(coords, tween, Board.ActiveReason.Item, self)
	elif name == "C4":
		image_id = 0
		description = "Activate: Eliminate 2-rings cells. \nMust activate by 'Bomb'"
		category = "Bomb"
		type = Type.Red
	elif name == "Chain Bomb":
		image_id = 7
		description = "Activate: activate a random nearby gem. \nWhen combos hits 4, activate this"
		category = "Bomb"
		type = Type.Red
		on_process = func(b : Board, tween : Tween):
			var coords : Array[Vector2i] = [coord]
			tween.tween_callback(func():
				var score = 0
				score += b.gem_score_at(coord)
				for c in b.offset_neighbors(coord):
					var item = b.get_item_at(c)
					if item:
						b.activate_item(item, Board.ActiveReason.Item, self)
				Game.add_combo()
				Game.add_score(score, b.get_pos(coord))
			)
			b.eliminate(coords, tween, Board.ActiveReason.Item, self)
		on_combo = func(b : Board, combo : int):
			if combo >= 4:
				b.activate_item(self, Board.ActiveReason.Item, self)
	elif name == "Virus":
		image_id = 8
		description = "Activate: Eliminate all connected cells with the same color of this."
		category = "Normal"
		type = Type.Red
		on_process = func(b : Board, tween : Tween):
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
				var score = 0
				for c in coords:
					score += b.gem_score_at(c)
				Game.add_combo()
				Game.add_score(score, b.get_pos(coord))
			)
			b.eliminate(coords, tween, Board.ActiveReason.Item, self)
	elif name == "Lightning":
		image_id = 9
		description = "Activate: If there is another active 'lightning', draw a line to that one, then eliminate cells within the line."
		category = "Normal"
		type = Type.Red
		on_process = func(b : Board, tween : Tween):
			var target : Gem = null
			for y in b.cy:
				for x in b.cx:
					var item = b.get_item_at(Vector2i(x, y))
					if item && item != self && item.name == "lightning" && item.active:
						target = item
						break
				if target:
					break
			if target:
				var coords : Array[Vector2i] = [target.coord]
				for c in b.draw_line(b.offset_to_cube(coord), b.offset_to_cube(target.coord)):
					var cc = b.cube_to_offset(c)
					coords.append(cc)
				tween.tween_callback(func():
						var score = 0
						var p0 : Vector2 = b.get_pos(coord)
						var pos : Vector2 = p0
						var p1 : Vector2 = b.get_pos(target.coord)
						pos = (p0 + p1) / 2.0
						var fx = Effects.lightning.instantiate()
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
						Sounds.sfx_lighting_connect.play()
						for c in coords:
							score += b.gem_score_at(c)
						Game.add_combo()
						Game.add_score(score, pos)
				)
				b.eliminate(coords, tween, Board.ActiveReason.Item, self)
			else:
				tween.tween_callback(func():
					Sounds.sfx_lighting_fail.play()
				)
	elif name == "Color Palette":
		image_id = 10
		description = "Wild"
		category = "Normal"
		type = Type.Red
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
	elif name == "Fire":
		image_id = 11
		description = "Activate: Sets the cell to burning state."
		category = "Normal"
		type = Type.Red
		on_active = func(b : Board, reason : int, source):
			b.set_state_at(coord, Cell.State.Burning)
	elif name == "Black Hole":
		image_id = 12
		description = "Activate: If this is the last gem activated this roll, eliminate all cells on board."
		category = "Normal"
		type = Type.Red
		on_process = func(b : Board, tween : Tween):
			if b.active_items.size() == 1:
				var coords : Array[Vector2i] = []
				for y in b.cy:
					for x in b.cx:
						var c = Vector2i(x, y)
						coords.append(c)
				tween.tween_callback(func():
						var pos = b.get_pos(coord)
						var score = 0
						for c in coords:
							score += b.gem_score_at(c)
						Game.add_combo()
						Game.add_score(score, pos)
				)
				b.eliminate(coords, tween, Board.ActiveReason.Item, self)
	elif name == "White Hole":
		image_id = 13
		description = "Activate: If this is the first gem activated this roll, eliminate all cells on board."
		category = "Normal"
		type = Type.Red
		on_active = func(b : Board, reason : int, source):
			extra["first"] = b.active_items.is_empty()
		on_process = func(b : Board, tween : Tween):
			if extra["first"]:
				extra["first"] = false
				var coords : Array[Vector2i] = []
				for y in b.cy:
					for x in b.cx:
						var c = Vector2i(x, y)
						coords.append(c)
				tween.tween_callback(func():
						var pos = b.get_pos(coord)
						var score = 0
						for c in coords:
							score += b.gem_score_at(c)
						Game.add_combo()
						Game.add_score(score, pos)
				)
				b.eliminate(coords, tween, Board.ActiveReason.Item, self)
	elif name == "Dog":
		image_id = 14
		description = "Get 1 base score more for each animal eliminated this roll."
		category = "Animal"
		type = Type.Red
		on_process = func(b : Board, tween : Tween):
			tween.tween_callback(func():
				var pos = b.get_pos(coord)
				var score = 5
				if b.touched_items.has("cat") || b.touched_items.has("rooster"):
					score += 5
				Game.add_combo()
				Game.add_score(score, pos)
			)
	elif name == "Cat":
		image_id = 15
		description = "+4 mult, if you have eliminated other types of animals this roll, get 1 mult less for each type."
		category = "Animal"
		type = Type.Blue
		on_process = func(b : Board, tween : Tween):
			tween.tween_callback(func():
				var pos = b.get_pos(coord)
				var score = 20
				if b.eliminated_gems.has("dog") || b.eliminated_gems.has("rooster"):
					score -= 5
				if score > 0:
					Game.add_combo()
					Game.add_score(score, pos)
			)
	elif name == "Rooster":
		image_id = 16
		description = "Activate: activate another 3 animals."
		category = "Animal"
		type = Type.Red
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
	elif name == "Hotdog":
		image_id = 17
		description = ""
		category = "Food"
		type = Type.Red
		on_active = func(b : Board, reason : int, source):
			var pos = b.get_pos(coord)
			Game.add_combo()
			Game.add_score(50, pos)
	elif name == "Lai Cut":
		image_id = 18
		description = "Activate: If there is no other 'Lai Cut' on board, eliminate a row on a random direction."
		category = "Normal"
		type = Type.Red
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
				var pos = b.get_pos(coord)
				var cc = b.offset_to_cube(coord)
				var coords : Array[Vector2i] = []
				match randi() % 3:
					0: 
						for x in b.cx:
							var c = b.cube_to_offset(Vector3i(x, -x - cc.z, cc.z))
							coords.append(c)
					1: 
						for x in b.cx:
							var c = b.cube_to_offset(Vector3i(cc.x, x - cc.x, -x))
							coords.append(c)
					2: 
						for x in b.cx:
							var c = b.cube_to_offset(Vector3i(x - cc.y, cc.y, -x))
							coords.append(c)
				tween.tween_callback(func():
					var score = 0
					for c in coords:
						score += b.gem_score_at(c)
					Game.add_combo()
					Game.add_score(score, pos)
				)
				b.eliminate(coords, tween, Board.ActiveReason.Item, self)
	elif name == "Magnet":
		image_id = 19
		description = "Activate: Move 2-rings activable gems toward this."
		category = "Normal"
		type = Type.Red
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
	elif name == "Rainbow":
		image_id = 20
		description = "Activate: Get 1.5 times to the earned score until this roll."
		category = "Normal"
		type = Type.Red
		on_active = func(b : Board, reason : int, source):
			Game.rainbow_mult *= 1.5
	elif name == "Ruby":
		image_id = 21
		description = "Activate: Red type gems' base score +1."
		category = "Normal"
		type = Type.Red
		on_active = func(b : Board, reason : int, source):
			var gem = b.get_gem_at(coord)
			if reason == Board.ActiveReason.Pattern && gem == Gem.Type.Red:
				b.gem_scores[Gem.Type.Red] += 1
				Game.add_status("Red +1", b.gem_col(Gem.Type.Red))
	elif name == "Citrine":
		image_id = 22
		description = "Activate: Orange type gems' base score +1."
		category = "Normal"
		type = Type.Red
		on_active = func(b : Board, reason : int, source):
			var gem = b.get_gem_at(coord)
			if reason == Board.ActiveReason.Pattern && gem == Gem.Type.Orange:
				b.gem_scores[Gem.Type.Orange] += 1
				Game.add_status("Orange +1", b.gem_col(Gem.Type.Orange))
	elif name == "Emerald":
		image_id = 23
		description = "Activate: Green type gems' base score +1."
		category = "Normal"
		type = Type.Red
		on_active = func(b : Board, reason : int, source):
			var gem = b.get_gem_at(coord)
			if reason == Board.ActiveReason.Pattern && gem == Gem.Type.Green:
				b.gem_scores[Gem.Type.Green] += 1
				Game.add_status("Green +1", b.gem_col(Gem.Type.Green))
	elif name == "Sapphire":
		image_id = 24
		description = "Activate: Blue type gems' base score +1."
		category = "Normal"
		type = Type.Red
		on_active = func(b : Board, reason : int, source):
			var gem = b.get_gem_at(coord)
			if reason == Board.ActiveReason.Pattern && gem == Gem.Type.Blue:
				b.gem_scores[Gem.Type.Blue] += 1
				Game.add_status("Blue +1", b.gem_col(Gem.Type.Blue))
	elif name == "Amethyst":
		image_id = 25
		description = "Activate: Pink type gems' base score +1."
		category = "Normal"
		type = Type.Red
		on_active = func(b : Board, reason : int, source):
			var gem = b.get_gem_at(coord)
			if reason == Board.ActiveReason.Pattern && gem == Gem.Type.Pink:
				b.gem_scores[Gem.Type.Pink] += 1
				Game.add_status("Pink +1", b.gem_col(Gem.Type.Pink))
