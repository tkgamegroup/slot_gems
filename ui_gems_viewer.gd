extends Control

@onready var list = $VBoxContainer/List
@onready var close_button = $VBoxContainer/Button

func clear():
	for n in list.get_children():
		n.queue_free()
		list.remove_child(n)

func enter():
	self.show()
	var x = 0
	var y = 0
	for g in Game.gems:
		var ctrl = Control.new()
		ctrl.position = Vector2(x * 16, y * 16)
		ctrl.size = Vector2(16, 16)
		ctrl.mouse_entered.connect(func():
			Sounds.sfx_select.play()
			Tooltip.show(g.display_name, "Base Score: %d\n%s" % [g.get_base_score(), g.description])
		)
		ctrl.mouse_exited.connect(func():
			Tooltip.close()
		)
		var sp = AnimatedSprite2D.new()
		sp.sprite_frames = Gem.gem_frames
		sp.frame = g.image_id
		sp.scale = Vector2(0.5, 0.5)
		sp.centered = false
		x += 1
		if x >= 50:
			x = 0
			y += 1
		ctrl.add_child(sp)
		list.add_child(ctrl)
		
func _ready() -> void:
	close_button.pressed.connect(func():
		Sounds.sfx_click.play()
		Game.ui_blocker.hide()
		self.hide()
	)
