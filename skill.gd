extends Object

class_name Skill

const UiSkill = preload("res://ui_skill.gd")

var requirements : Array[Pair]
var requirement_map : Dictionary[int, int]
var spawn_gem : Gem = null
var ui : UiSkill = null

func add_requirement(rune : int, count : int):
	requirements.append(Pair.new(rune, count))
	requirement_map[rune] = count

func get_requirement_icons(w : int):
	var ret = ""
	for p in requirements:
		for i in p.second:
			ret += "[img width=%d]%s[/img]" % [w, Gem.rune_icon(p.first)]
	return ret

func check(coords : Array[Vector2i]):
	var runes = {}
	for c in coords:
		var g = Game.board.get_gem_at(c)
		if runes.has(g.rune):
			runes[g.rune].append(c)
		else:
			runes[g.rune] = [c]
	var ret = {}
	var ok = true
	for r in requirement_map:
		if !runes.has(r) || requirement_map[r] > runes[r].size():
			ok = false
			break
		else:
			ret[r] = runes[r]
			ret[r].resize(requirement_map[r])
	if ok:
		return ret
	return {}
	
