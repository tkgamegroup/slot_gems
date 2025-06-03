extends Node

const gem_ui = preload("res://ui_gem.tscn")
const trail_pb = preload("res://trail.tscn")

var grabs : Array[Gem]

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

func clear():
	for g in grabs:
		Game.release_gem(g)
	grabs.clear()
	
	Game.hand_ui.clear()

func swap(coord : Vector2i, gem : Gem):
	Game.begin_busy()
	
	var og = Board.set_gem_at(coord, gem)
	grabs.erase(gem)
	
	var ui = gem_ui.instantiate()
	ui.set_image(og.type, og.rune, og.bound_item.image_id if og.bound_item else 0)
	ui.position = Board.get_pos(coord)
	var trail = trail_pb.instantiate()
	ui.add_child(trail)
	Game.board_ui.cells_root.add_child(ui)
	var pos = Game.hand_ui.end_pos()
	var tween = Game.get_tree().create_tween()
	tween.tween_property(ui, "position", pos, 0.3)
	tween.tween_callback(func():
		ui.queue_free()
		var slot = Game.hand_ui.add_ui(og)
		slot.position = pos - Game.hand_ui.list.global_position
		Game.end_busy()
	)
