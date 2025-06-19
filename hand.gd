extends Node

var grabs : Array[Gem]

func get_gem_from(gem : Gem, pos : Vector2):
	Game.begin_busy()
	var tween = Game.hand_ui.fly_gem_from(gem, pos)
	tween.tween_callback(func():
		grabs.append(gem)
		Game.end_busy()
	)

func draw():
	if Game.bag_gems.is_empty():
		return null
	if grabs.size() >= Game.max_hand_grabs:
		return null
	var gem : Gem = Game.get_gem()
	grabs.append(gem)
	var ui = Game.hand_ui.add_ui(gem)
	ui.position.y = 50
	return ui

func erase(idx : int):
	var g = grabs[idx]
	grabs.erase(g)
	
	Game.hand_ui.remove_ui(idx)
	return g

func clear():
	for g in grabs:
		Game.release_gem(g)
	grabs.clear()
	
	Game.hand_ui.clear()

func swap(coord : Vector2i, gem : Gem):
	if Game.swaps > 0:
		Game.swaps -= 1
		
		var og = Board.set_gem_at(coord, gem)
		grabs.erase(gem)
		get_gem_from(og, Board.get_pos(coord))
		
		return true
	else:
		Game.control_ui.swaps_text.hint()
	return false
