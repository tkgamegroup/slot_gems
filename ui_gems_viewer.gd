extends Control

@onready var list = $VBoxContainer/ScrollContainer/List
@onready var close_button = $VBoxContainer/Button

const gem_ui = preload("res://ui_gem.tscn")

func clear():
	for n in list.get_children():
		n.queue_free()
		list.remove_child(n)

func enter():
	self.show()
	for g in Game.gems:
		var ctrl = Control.new()
		ctrl.custom_minimum_size = Vector2(32, 32)
		ctrl.mouse_entered.connect(func():
			Sounds.sfx_select.play()
			Tooltip.show(g.name, g.get_description())
		)
		ctrl.mouse_exited.connect(func():
			Tooltip.close()
		)
		var ui = gem_ui.instantiate()
		ui.position = Vector2(16, 16)
		ui.set_image(g.type, g.rune, g.image_id)
		ctrl.add_child(ui)
		list.add_child(ctrl)
		
func _ready() -> void:
	close_button.pressed.connect(func():
		Sounds.sfx_click.play()
		Game.ui_blocker.hide()
		self.hide()
	)
