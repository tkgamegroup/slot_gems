extends Node

var ui : G.UiHand = null

var gems : Array[Gem]

func add_gem(gem : Gem, pos : int = -1, no_ui : bool = false) -> G.UiHandSlot:
	if pos == -1:
		pos = gems.size()
	gem.coord = Vector2i(pos, -1)
	gems.insert(pos, gem)
	if no_ui || G.is_headless():
		return null
	return ui.add_slot(gem, pos)

func draw(to_the_end : bool = true):
	if G.bag_gems.is_empty():
		return null
	var gem : Gem = G.take_from_bag()
	var slot = add_gem(gem, -1 if to_the_end else 0)
	if slot:
		slot.position.y = 50
	return slot

func find(g : Gem):
	return gems.find(g)

func erase(idx : int):
	var g = gems[idx]
	gems.erase(g)
	for i in gems.size():
		gems[i].coord = Vector2i(i, -1)
	
	if !G.is_headless():
		ui.remove_slot(idx)
	return g

func discard(idx : int):
	var g = erase(idx)
	var gem_ui = G.create_gem_ui(g, ui.get_pos(idx))
	
	var tween = G.create_game_tween()
	tween.tween_property(gem_ui, "scale", Vector2(0.7, 0.7), 0.4)
	tween.parallel()
	SAnimation.quadratic_curve_to(tween, gem_ui, G.game_ui.status_bar.bag_button.global_position, Vector2(0.5, 0.2), 0.4)
	tween.tween_callback(func():
		G.put_to_bag(g)
		G.sort_gems()
		gem_ui.queue_free()
	)

func clear():
	for g in gems:
		G.put_to_bag(g)
	gems.clear()
	
	if !G.is_headless():
		ui.clear()

func swap(coord : Vector2i, gem : Gem):
	var og = Board.set_gem_at(coord, null)
	Board.set_gem_at(coord, gem)
	add_gem(og)
