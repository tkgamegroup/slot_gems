extends Node

var grabs : Array[Gem]

func add_gem(gem : Gem, pos : int = -1):
	if pos == -1:
		pos = grabs.size()
	gem.coord = Vector2i(pos, -1)
	if gem.bound_item:
		gem.bound_item.coord = Vector2i(pos, -1)
	grabs.insert(pos, gem)

func get_gem_from(gem : Gem, pos : Vector2):
	Game.begin_busy()
	var tween = Game.hand_ui.fly_gem_from(gem, pos)
	tween.tween_callback(func():
		add_gem(gem)
		Game.end_busy()
	)

func draw(to_the_end : bool = true):
	if Game.bag_gems.is_empty():
		return null
	if grabs.size() >= Game.max_hand_grabs:
		return null
	var gem : Gem = Game.get_gem()
	add_gem(gem, -1 if to_the_end else 0)
	var ui = Game.hand_ui.add_ui(gem, -1 if to_the_end else 0)
	ui.position.y = 50
	return ui

func find(g : Gem):
	return grabs.find(g)

func erase(idx : int, release_gem : bool = true):
	var g = grabs[idx]
	if release_gem:
		Game.release_gem(g)
	grabs.erase(g)
	
	Game.hand_ui.remove_ui(idx)
	return g

func clear():
	for g in grabs:
		Game.release_gem(g)
	grabs.clear()
	
	Game.hand_ui.clear()

func swap(coord : Vector2i, gem : Gem, immediately : bool = false):
	Board.set_item_at(coord, null)
	var og = Board.set_gem_at(coord, gem)
	if gem.bound_item:
		Board.set_item_at(coord, gem.bound_item)
	if immediately:
		Game.hand_ui.add_ui(og)
		add_gem(og)
	else:
		get_gem_from(og, Board.get_pos(coord))
