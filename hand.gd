extends Node

var grabs : Array[Gem]

func add_gem(gem : Gem):
	gem.coord = Vector2i(grabs.size(), -1)
	if gem.bound_item:
		gem.bound_item.coord = Vector2i(grabs.size(), -1)
	grabs.append(gem)

func get_gem_from(gem : Gem, pos : Vector2):
	Game.begin_busy()
	var tween = Game.hand_ui.fly_gem_from(gem, pos)
	tween.tween_callback(func():
		add_gem(gem)
		Game.end_busy()
	)

func draw():
	if Game.bag_gems.is_empty():
		return null
	if grabs.size() >= Game.max_hand_grabs:
		return null
	var gem : Gem = Game.get_gem()
	add_gem(gem)
	var ui = Game.hand_ui.add_ui(gem)
	ui.position.y = 50
	return ui

func erase(idx : int):
	var g = grabs[idx]
	Game.release_gem(g)
	grabs.erase(g)
	
	Game.hand_ui.remove_ui(idx)
	return g

func clear():
	for g in grabs:
		Game.release_gem(g)
	grabs.clear()
	
	Game.hand_ui.clear()

func swap(coord : Vector2i, gem : Gem, remove_ui : bool = true, immediately : bool = false):
	if remove_ui:
		for i in grabs.size():
			if grabs[i] == gem:
				erase(i)
				break
	var og = Board.set_gem_at(coord, gem)
	Board.set_item_at(coord, null)
	if gem.bound_item:
		Board.set_item_at(coord, gem.bound_item)
	if immediately:
		Game.hand_ui.add_ui(og)
		add_gem(og)
	else:
		get_gem_from(og, Board.get_pos(coord))
