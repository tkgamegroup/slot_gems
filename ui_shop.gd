extends Control

@onready var title_txt : Label = $Label
var slot_uis : Array[Control]
@onready var next_button : Button = $Button
@onready var buy_board_size_button : Button = $Button2

const item_pb = preload("res://ui_shop_item.tscn")

func buy_gem(g : Gem, img : AnimatedSprite2D):
	var tween = Game.get_tree().create_tween()
	tween.tween_property(img, "scale", Vector2(1.0, 1.0), 0.5)
	tween.parallel()
	SAnimation.cubic_curve_to(tween, img, Game.bag_button.get_global_rect().get_center(), 0.1, Vector2(0, 150), 0.9, Vector2(0, 100), 0.7)
	tween.tween_callback(func():
		Game.gems.append(g)
		img.queue_free()
	)

func enter():
	self.show()
	
	var tween = get_tree().create_tween()
	var p0 = title_txt.position
	title_txt.position = p0  - Vector2(0, 300)
	tween.tween_property(title_txt, "position", p0, 0.3)
	var p1 = next_button.position
	next_button.position = p1  + Vector2(0, 300)
	tween.parallel().tween_property(next_button, "position", p1, 0.3)
	
	var list = ["Bomb", "Ruby", "Citrine", "Emerald", "Sapphire", "Amethyst"]
	for i in 8:
		tween.tween_interval(0.1)
		tween.tween_callback(func():
			var ui = item_pb.instantiate()
			var g = Gem.new()
			g.setup(list.pick_random())
			var gold = randi_range(1, 5)
			ui.setup(g.image_id, gold)
			ui.gui_input.connect(func(event : InputEvent):
				if event is InputEventMouseButton:
					if event.pressed && event.button_index == MOUSE_BUTTON_LEFT:
						if Game.gold >= gold:
							SSound.sfx_coin.play()
							Game.gold -= gold
							var img = ui.image
							img.reparent(self)
							ui.get_parent().remove_child(ui)
							ui.queue_free()
							buy_gem(g, img)
			)
			slot_uis[i].add_child(ui)
		)

func _ready() -> void:
	for i in 8:
		slot_uis.append(find_child("Slot%d" % i))
	
	next_button.pressed.connect(func():
		SSound.sfx_click.play()
		self.hide()
		Game.new_level()
	)
	#next_button.mouse_entered.connect(SSound.sfx_select.play)
	buy_board_size_button.pressed.connect(func():
		Game.blocker_ui.enter()
		Game.outlines_root.reparent(Game.blocker_ui)
		
		var cx_mult = Game.board.cx_mult
		var cx = Game.board_size * 2 * cx_mult
		var cy = Game.board_size * 2
		var hf_cx = cx / 2
		var hf_cy = cy / 2
		
		var margin = MarginContainer.new()
		margin.add_theme_constant_override("margin_top", 30)
		var hbox = HBoxContainer.new()
		margin.add_child(hbox)
		var txt0 = Label.new()
		txt0.text = "Board Size: %dX%d" % [cx, cy]
		txt0.add_theme_font_size_override("font_size", 24)
		hbox.add_child(txt0)
		SSound.sfx_click.play()
		var txt1 = Label.new()
		txt1.text = "=>"
		txt1.add_theme_font_size_override("font_size", 24)
		txt1.hide()
		hbox.add_child(txt1)
		var txt2 = Label.new()
		txt2.add_theme_font_size_override("font_size", 24)
		hbox.add_child(txt2)
		txt2.hide()
		Game.blocker_ui.add_child(margin)
		margin.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
		
		var tween = Game.get_tree().create_tween()
		
		var central_coord = Game.board.central_coord
		var pc = Game.tilemap.map_to_local(central_coord)
		var had_coords = {}
		for x in cx:
			for y in cy:
				var cc = Vector2i(x - hf_cx, y - hf_cy) + central_coord
				var outline_sp = Sprite2D.new()
				outline_sp.texture = load("res://images/outline.png")
				outline_sp.position = Game.tilemap.map_to_local(cc)
				had_coords[cc] = 1
				Game.outlines_root.add_child(outline_sp)
		
		Game.board_size += 1
		cx = Game.board_size * 2 * cx_mult
		cy = Game.board_size * 2
		hf_cx = cx / 2
		hf_cy = cy / 2
		
		txt2.text = "Board Size: %dX%d" % [cx, cy]
		
		tween.tween_interval(0.5)
		tween.tween_callback(func():
			SSound.sfx_click.play()
			txt1.show()
			margin.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
		)
		tween.tween_interval(0.5)
		tween.tween_callback(func():
			SSound.sfx_click.play()
			txt2.show()
			margin.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
		)
		tween.tween_callback(func():
			for x in cx:
				for y in cy:
					var cc = Vector2i(x - hf_cx, y - hf_cy) + central_coord
					if !had_coords.has(cc):
						var tween2 = Game.get_tree().create_tween()
						var p1 = Game.tilemap.map_to_local(cc)
						var p0 = p1 + (p1 - pc).normalized() * 500.0
						var outline_sp = Sprite2D.new()
						outline_sp.texture = load("res://images/outline.png")
						outline_sp.position = p0
						Game.outlines_root.add_child(outline_sp)
						tween2.tween_property(outline_sp, "position", p1, 0.5)
		)
		tween.tween_interval(2.0)
		tween.tween_method(func(t : float):
			Game.outlines_root.modulate.a = t
			margin.modulate.a = t
		, 1.0, 0.0, 0.5)
		tween.tween_callback(func():
			margin.queue_free()
			Game.blocker_ui.exit()
			Game.outlines_root.modulate.a = 1.0
			Game.outlines_root.reparent(Game.game_root)
			Game.game_root.move_child(Game.outlines_root, 1)
			Game.board.cleanup()
		)
	)
