extends Control

@onready var title_txt : Label = $Label
var slot_uis : Array[Control]
@onready var next_button : Button = $Button

const item_pb = preload("res://ui_shop_item.tscn")

func buy_gem(g : Gem, img : AnimatedSprite2D):
	var tween = Game.get_tree().create_tween()
	var p0 = img.global_position
	var p2 = Game.bag_button.get_global_rect().get_center()
	var p1 = p2 + Vector2(0, 100)
	tween.tween_property(img, "scale", Vector2(1.0, 1.0), 0.5)
	tween.parallel().tween_method(func(t):
		img.global_position = Math.quadratic_bezier(p0, p1, p2, t)
	, 0.0, 1.0, 0.7)
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
	
	var list = Gem.get_name_list(5)
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
					if event.pressed:
						if Game.gold >= gold:
							Sounds.sfx_coin.play()
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
		Sounds.sfx_click.play()
		self.hide()
		Game.new_level()
	)
	#next_button.mouse_entered.connect(Sounds.sfx_select.play)
