extends Node

const UiHand = preload("res://ui_hand.gd")

var ui : UiHand = null

var grabs : Array[Gem]

func add_gem(gem : Gem, pos : int = -1):
	if pos == -1:
		pos = grabs.size()
	gem.coord = Vector2i(pos, -1)
	grabs.insert(pos, gem)
	return ui.add_slot(gem, pos)

func draw(to_the_end : bool = true):
	if Game.bag_gems.is_empty():
		return null
	if grabs.size() >= Game.max_hand_grabs:
		return null
	var gem : Gem = Game.get_gem()
	var slot = add_gem(gem, -1 if to_the_end else 0)
	slot.position.y = 50
	return slot

func find(g : Gem):
	return grabs.find(g)

func erase(idx : int, release_gem : bool = true):
	var g = grabs[idx]
	if release_gem:
		Game.release_gem(g)
	grabs.erase(g)
	
	ui.remove_slot(idx)
	return g

func clear():
	for g in grabs:
		Game.release_gem(g)
	grabs.clear()
	
	ui.clear()

func swap(coord : Vector2i, gem : Gem, immediately : bool = false):
	var og = Board.set_gem_at(coord, null)
	if immediately:
		Board.set_gem_at(coord, gem)
		add_gem(og)
	else:
		var pos = Board.get_pos(coord) - Vector2(16, 24)
		var slot = add_gem(og)
		slot.elastic = -1.0
		var tween = get_tree().create_tween()
		tween.tween_property(slot, "global_position", pos + Vector2(0.0, -48.0), 0.3).from(pos)
		tween.tween_property(slot, "elastic", 1.0, 0.3).from(0.0)
		tween.tween_callback(func():
			Board.set_gem_at(coord, gem)
		)
