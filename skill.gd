extends Object

class_name Skill

const skill_frames : SpriteFrames = preload("res://images/skills.tres")
const UiSkill = preload("res://ui_skill.gd")

var name : String
var description : String
var image_id : int
var requirements : Array[int]
var price : int
var extra = {}
var on_cast : Callable
var on_active : Callable

var ui : UiSkill = null

func setup(n : String):
	name = n
	if name == "Xiao":
		requirements = [Gem.Rune.Zhe, Gem.Rune.Cha, Gem.Rune.Kou, Gem.Rune.Kou]
		description = "Eliminate one random rune after next roll."
		image_id = 1
		on_cast = func(tween : Tween):
			tween.tween_callback(func():
				SEffect.add_leading_line(ui.get_global_rect().get_center(), Game.control_ui.roll_button.get_global_rect().get_center())
			)
			tween.tween_interval(0.3)
			tween.tween_callback(func():
				Game.after_rolled_eliminate_one_rune += 1
			)
	elif name == "RoLL":
		requirements = [Gem.Rune.Cha, Gem.Rune.Kou, Gem.Rune.Zhe, Gem.Rune.Zhe]
		description = "+1 Roll."
		image_id = 2
		on_cast = func(tween : Tween):
			tween.tween_callback(func():
				Game.rolls += 1
			)
	elif name == "Mat.":
		requirements = [Gem.Rune.Zhe, Gem.Rune.Zhe, Gem.Rune.Kou, Gem.Rune.Cha]
		description = "+1 Match."
		image_id = 3
		on_cast = func(tween : Tween):
			tween.tween_callback(func():
				Game.matches += 1
			)
	elif name == "Qiang":
		requirements = [Gem.Rune.Zhe, Gem.Rune.Kou, Gem.Rune.Kou, Gem.Rune.Zhe]
		description = "+1 base score to a random color."
		image_id = 4
		on_cast = func(tween : Tween):
			tween.tween_callback(func():
				pass
			)
	elif name == "Jiang":
		requirements = [Gem.Rune.Zhe, Gem.Rune.Kou, Gem.Rune.Cha]
		description = "+{value} score. (Not affected by combos)"
		image_id = 5
		extra["value"] = 500
		on_cast = func(tween : Tween):
			tween.tween_callback(func():
				Game.add_score(extra["value"], ui.get_global_rect().get_center() + Vector2(84, 0), false)
			)
	elif name == "Huan":
		requirements = [Gem.Rune.Kou, Gem.Rune.Kou, Gem.Rune.Kou]
		description = "Place an item from Bag to Board."
		image_id = 6
		on_cast = func(tween : Tween):
			Board.effect_place_item_from_bag(ui.get_global_rect().get_center(), null, Vector2i(-1, -1), tween)
	elif name == "Chou":
		requirements = [Gem.Rune.Cha, Gem.Rune.Cha, Gem.Rune.Kou]
		description = "Draw an Item."
		image_id = 7
		on_cast = func(tween : Tween):
			tween.tween_callback(func():
				Game.hand_ui.draw()
			)
	elif name == "Jin":
		requirements = [Gem.Rune.Zhe, Gem.Rune.Cha, Gem.Rune.Zhe]
		description = "Get 1 Coin."
		image_id = 8
		on_cast = func(tween : Tween):
			tween.tween_callback(func():
				Game.float_text("+1G", ui.get_global_rect().get_center() + Vector2(84, 0), Color(0.8, 0.1, 0.0))
				Game.coins += 1
			)
	elif name == "Bao":
		requirements = [Gem.Rune.Cha, Gem.Rune.Kou, Gem.Rune.Cha]
		description = "Explode and eliminate cells in 1 Range at random location."
		image_id = 9
		on_cast = func(tween : Tween):
			tween.tween_callback(func():
				Board.activate(self, HostType.Skill, 0, Vector2i(-1, -1), Board.ActiveReason.Skill, self)
			)
		on_active = func(effect_index : int, c : Vector2i, tween : Tween):
			var target = Vector2i(randi_range(0, Board.cx - 1), randi_range(0, Board.cy - 1))
			Board.effect_explode(ui.get_global_rect().get_center(), target, 1, 0, tween)
	elif name == "Fang":
		requirements = [Gem.Rune.Zhe, Gem.Rune.Cha, Gem.Rune.Cha]
		description = "Duplicate 1 Item on Board to random location."
		image_id = 10
		on_cast = func(tween : Tween):
			tween.tween_callback(func():
				var targets = Board.filter(func(g : Gem, i : Item):
					return i != null
				)
				var places = Board.filter(func(g : Gem, i : Item):
					return i == null
				)
				if !targets.is_empty() && !places.is_empty():
					var target = targets.pick_random()
					var place = places.pick_random()
					tween.tween_callback(func():
						SEffect.add_leading_line(ui.get_global_rect().get_center(), Board.get_pos(target))
					)
					tween.tween_interval(0.3)
					tween.tween_callback(func():
						SEffect.add_leading_line(Board.get_pos(target), Board.get_pos(place))
					)
					tween.tween_interval(0.3)
					tween.tween_callback(func():
						var i = Board.get_item_at(target)
						var new_item = Item.new()
						new_item.setup(i.name)
						new_item.is_duplicant = true
						Board.set_item_at(place, new_item)
					)
			)
	elif name == "Fen":
		requirements = [Gem.Rune.Zhe, Gem.Rune.Zhe, Gem.Rune.Zhe]
		description = "Get 10% score of the target score."
		image_id = 11
		on_cast = func(tween : Tween):
			tween.tween_callback(func():
				Game.add_score(int(Game.target_score * 0.1), ui.get_global_rect().get_center() + Vector2(84, 0), false)
			)
	elif name == "Xing":
		requirements = [Gem.Rune.Cha, Gem.Rune.Cha, Gem.Rune.Cha]
		description = ""
		image_id = 12
		on_cast = func(tween : Tween):
			tween.tween_callback(func():
				Game.float_text("+0.5 Mult", ui.get_global_rect().get_center() + Vector2(84, 0), Color(0.7, 0.3, 0.9))
				Buff.create(Game, Buff.Type.ValueModifier, {"target":"score_mult","add":0.5})
			)

func get_requirement_icons(w : int):
	var ret = ""
	for r in requirements:
		ret += "[img width=%d]%s[/img]" % [w, Gem.rune_icon(r)]
	return ret

func check(runes : Array[int]):
	var ret = {}
	var temp = runes.duplicate()
	for r in requirements:
		if !SMath.find_and_remove(temp, r):
			return false
	return true

func add_exp(v : int):
	if ui:
		ui.container.position = Vector2(0, -5)
		var tween = Game.get_tree().create_tween()
		tween.tween_property(ui.container, "position", Vector2(0, 0), 0.2)

func get_tooltip():
	var ret : Array[Pair] = []
	var content = "Requirements: "
	for r in requirements:
		content += "[img width=16]%s[/img]" % Gem.rune_icon(r)
	content += "\n"
	content += description.format(extra)
	ret.append(Pair.new(name, content))
	return ret
