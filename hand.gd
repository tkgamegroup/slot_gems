extends Node

const UiHand = preload("res://ui_hand.gd")

var ui : UiHand = null

var grabs : Array[Gem]

func add_gem(gem : Gem, pos : int = -1, no_ui : bool = false):
	if pos == -1:
		pos = grabs.size()
	gem.coord = Vector2i(pos, -1)
	grabs.insert(pos, gem)
	if no_ui:
		return null
	return ui.add_slot(gem, pos)

func draw(to_the_end : bool = true):
	if G.bag_gems.is_empty():
		return null
	if grabs.size() >= G.max_hand_grabs:
		return null
	var gem : Gem = G.take_out_gem_from_bag()
	var slot = add_gem(gem, -1 if to_the_end else 0)
	slot.position.y = 50
	return slot

func find(g : Gem):
	return grabs.find(g)

func erase(idx : int):
	var g = grabs[idx]
	grabs.erase(g)
	for i in grabs.size():
		grabs[i].coord = Vector2i(i, -1)
	
	ui.remove_slot(idx)
	return g

func clear():
	for g in grabs:
		G.put_back_gem_to_bag(g)
	grabs.clear()
	
	ui.clear()

func swap(coord : Vector2i, gem : Gem):
	var og = Board.set_gem_at(coord, null)
	Board.set_gem_at(coord, gem)
	add_gem(og)
