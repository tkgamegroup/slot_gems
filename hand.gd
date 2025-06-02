extends Node

var grabs : Array[Gem]

func draw():
	if Game.bag_gems.is_empty():
		return null
	if grabs.size() >= Game.max_hand_grabs:
		return null
	var gem : Gem = Game.get_gem()
	var ui = Game.hand_ui.add_ui(gem)
	ui.position.y = 50
	return ui

func clear():
	for g in grabs:
		Game.release_gem(g)
	
	Game.hand_ui.clear()

func swap(coord : Vector2i, gem : Gem):
	var og = Board.set_gem_at(coord, gem)
	var idx = grabs.find(gem)
	grabs[idx] = og
