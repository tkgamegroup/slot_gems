extends Object

class_name Skill

const skill_frames : SpriteFrames = preload("res://images/skills.tres")
const UiSkill = preload("res://ui_skill.gd")

var name : String
var image_id : int
var requirements : Array[int]
var price : int = 10
var extra = {}
var on_cast : Callable
var on_event : Callable
var on_active : Callable

var ui : UiSkill = null

func setup(n : String):
	name = n
	if name == "Xiao":
		requirements = [Gem.Rune.Zhe, Gem.Rune.Cha, Gem.Rune.Kou, Gem.Rune.Kou]
		image_id = 1
		extra["eliminate_times"] = 0
		extra["processing"] = false
		on_cast = func(tween : Tween, coords:Array[Vector2i]):
			tween.tween_callback(func():
				SEffect.add_leading_line(ui.get_global_rect().get_center(), Game.control_ui.roll_button.get_global_rect().get_center())
			)
			tween.tween_interval(0.3)
			tween.tween_callback(func():
				extra["eliminate_times"] += 1
			)
		on_event = func(event : int, tween : Tween, data):
			if event == Event.GainSkill:
				if data == self:
					Game.event_listeners.append(Hook.new(Event.RollingFinished, self, HostType.Skill, false))
					Game.event_listeners.append(Hook.new(Event.FillingFinished, self, HostType.Skill, false))
			elif event == Event.RollingFinished:
				if extra["eliminate_times"] > 0:
					extra["eliminate_times"] -= 1
					extra["processing"] = true
					
					if !tween:
						tween = Game.get_tree().create_tween()
					var r = randi_range(1, 1 + Gem.Rune.Count)
					var coords = Board.filter(func(g : Gem, i):
						return g && g.rune == r
					)
					
					tween.tween_callback(func():
						SSound.sfx_bubble.play()
						Game.add_combo()
						for c in coords:
							Game.add_score(Board.gem_score_at(c), Board.get_pos(c))
					)
					Board.eliminate(coords, tween, Board.ActiveReason.Pattern)
					tween.tween_callback(Board.clear_consumed)
					tween.tween_interval(0.4 * Game.animation_speed)
					tween.tween_callback(Board.fill_blanks)
					return true
				return false
			elif event == Event.FillingFinished:
				if extra["processing"]:
					extra["processing"] = false
					Board.rolling_finished.emit()
					return true
				return false
	elif name == "Roll":
		requirements = [Gem.Rune.Cha, Gem.Rune.Kou, Gem.Rune.Zhe, Gem.Rune.Zhe]
		image_id = 2
		on_cast = func(tween : Tween, coords:Array[Vector2i]):
			tween.tween_callback(func():
				Game.rolls += 1
			)
	elif name == "Match":
		requirements = [Gem.Rune.Zhe, Gem.Rune.Zhe, Gem.Rune.Kou, Gem.Rune.Cha]
		image_id = 3
		on_cast = func(tween : Tween, coords:Array[Vector2i]):
			tween.tween_callback(func():
				Game.plays += 1
			)
	elif name == "Qiang":
		requirements = [Gem.Rune.Zhe, Gem.Rune.Kou, Gem.Rune.Kou, Gem.Rune.Zhe]
		image_id = 4
		on_cast = func(tween : Tween, coords:Array[Vector2i]):
			tween.tween_callback(func():
				pass
			)
	elif name == "Se":
		requirements = [Gem.Rune.Zhe, Gem.Rune.Kou, Gem.Rune.Cha]
		image_id = 5
		on_cast = func(tween : Tween, coords:Array[Vector2i]):
			tween.tween_callback(func():
				var cands = Board.filter(func(gem : Gem, item : Item):
					if gem && gem.type != Gem.Type.Wild:
						return true
					return false
				)
				if !cands.is_empty():
					var pos = ui.get_global_rect().get_center()
					var targets = SMath.pick_n(cands, 2) 
					tween.tween_callback(func():
						for c in targets:
							SEffect.add_leading_line(pos, Board.get_pos(c))
					)
					tween.tween_interval(0.3)
					tween.tween_callback(func():
						for c in targets:
							Buff.create(Board.get_gem_at(c), Buff.Type.ChangeColor, {"color":Gem.Type.Wild})
					)
				)
	elif name == "Huan":
		requirements = [Gem.Rune.Kou, Gem.Rune.Kou, Gem.Rune.Kou]
		image_id = 6
		on_cast = func(tween : Tween, coords:Array[Vector2i]):
			tween.tween_callback(func():
				SEffect.add_leading_line(ui.get_global_rect().get_center(), Game.status_bar_ui.bag_button.get_global_rect().get_center())
			)
			tween.tween_interval(0.3)
			var items = []
			for i in 3:
				items.append(null)
			Board.effect_place_items_from_bag(items, tween)
	elif name == "Chou":
		requirements = [Gem.Rune.Cha, Gem.Rune.Cha, Gem.Rune.Kou]
		image_id = 7
		on_cast = func(tween : Tween, coords:Array[Vector2i]):
			tween.tween_callback(func():
				Game.Hand.draw()
			)
	elif name == "Jin":
		requirements = [Gem.Rune.Zhe, Gem.Rune.Cha, Gem.Rune.Zhe]
		image_id = 8
		on_cast = func(tween : Tween, coords:Array[Vector2i]):
			tween.tween_callback(func():
				Game.float_text("+1G", ui.get_global_rect().get_center() + Vector2(84, 0), Color(0.8, 0.1, 0.0))
				Game.coins += 1
			)
	elif name == "Bao":
		requirements = [Gem.Rune.Cha, Gem.Rune.Kou, Gem.Rune.Cha]
		image_id = 9
		extra["range_i"] = 0
		on_cast = func(tween : Tween, coords:Array[Vector2i]):
			tween.tween_callback(func():
				Board.activate(self, HostType.Skill, 0, coords[1], Board.ActiveReason.Skill, self)
			)
		on_active = func(effect_index : int, c : Vector2i, tween : Tween):
			for i in 2:
				var subtween = Game.get_tree().create_tween()
				var target = Vector2i(randi_range(0, Board.cx - 1), randi_range(0, Board.cy - 1))
				Board.effect_explode(ui.get_global_rect().get_center(), target, extra["range_i"], 0, subtween)
				if i > 0:
					tween.parallel()
				tween.tween_subtween(subtween)
	elif name == "Fang":
		requirements = [Gem.Rune.Zhe, Gem.Rune.Cha, Gem.Rune.Cha]
		image_id = 10
		on_cast = func(tween : Tween, coords:Array[Vector2i]):
			var d = {}
			d.target = Vector2i(-1, -1)
			d.target_item = null
			d.target_effect = null
			d.place = Vector2i(-1, -1)
			d.sp = null
			tween.tween_callback(func():
				var targets = Board.filter(func(g : Gem, i : Item):
					return g && i != null
				)
				for ae in Board.active_effects:
					if ae.type == HostType.Item:
						targets.append(ae.coord)
				var places = Board.filter(func(g : Gem, i : Item):
					return g && !i && Board.get_active_effects_at(g.coord).is_empty()
				)
				if !targets.is_empty() && !places.is_empty():
					d.target = targets.pick_random()
					d.target_item = Board.get_item_at(d.target)
					if !d.target_item:
						d.target_effect = Board.get_active_effects_at(d.target).front()
					d.place = places.pick_random()
					
					SEffect.add_leading_line(ui.get_global_rect().get_center(), Board.get_pos(d.target))
			)
			tween.tween_interval(0.3)
			tween.tween_callback(func():
				if d.target_item:
					d.sp = AnimatedSprite2D.new()
					d.sp.position = Board.get_pos(d.target)
					d.sp.sprite_frames = Item.item_frames
					d.sp.frame = d.target_item.image_id
					d.sp.z_index = 4
					Game.board_ui.cells_root.add_child(d.sp)
				elif d.target_effect:
					d.sp = Board.active_effect_pb.instantiate()
					d.sp.position = Board.get_pos(d.target)
					d.sp.sprite_frames = Item.item_frames
					d.sp.frame = d.target_effect.host.image_id
					d.sp.z_index = 4
					Game.board_ui.cells_root.add_child(d.sp)
			)
			tween.tween_callback(func():
				if d.sp:
					var tween2 = Game.get_tree().create_tween()
					tween2.tween_property(d.sp, "position", Board.get_pos(d.place), 0.5 * Game.animation_speed)
			)
			tween.tween_interval(0.5 * Game.animation_speed)
			tween.tween_callback(func():
				if d.target_item:
					var new_item = Item.new()
					new_item.setup(d.target_item.name)
					new_item.duplicant = true
					Game.items.append(new_item)
					
					Board.set_item_at(d.place, new_item)
				elif d.target_effect:
					Board.activate(d.target_effect.host, d.target_effect.type, d.target_effect.effect_index, d.place, Board.ActiveReason.Duplicate)
					pass
				if d.sp:
					d.sp.queue_free()
			)
	elif name == "Fen":
		requirements = [Gem.Rune.Zhe, Gem.Rune.Zhe, Gem.Rune.Zhe]
		image_id = 11
		extra["percentage"] = 0
		extra["basic_value"] = 1500
		on_cast = func(tween : Tween, coords:Array[Vector2i]):
			tween.tween_callback(func():
				Game.add_score(int(Game.target_score * (0.01 * extra["percentage"])) + extra["basic_value"], ui.get_global_rect().get_center() + Vector2(84, 0), false)
			)
	elif name == "Xing":
		requirements = [Gem.Rune.Cha, Gem.Rune.Cha, Gem.Rune.Cha]
		image_id = 12
		on_cast = func(tween : Tween, coords:Array[Vector2i]):
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
	var content = tr("skill_requirements")
	for r in requirements:
		content += "[img width=16]%s[/img]" % Gem.rune_icon(r)
	content += "\n"
	content += tr("skill_desc_" + name).format(extra)
	ret.append(Pair.new(tr("skill_name_" + name), content))
	return ret
