extends PanelContainer

@onready var list : Control = $MarginContainer/VBoxContainer

func appear():
	self.show()
	var tween = Game.get_tree().create_tween()
	var pos = self.position
	self.position = pos + Vector2(100, 0)
	tween.tween_property(self, "position", pos, 0.8)

func clear():
	if list:
		for n in list.get_children():
			n.queue_free()
			list.remove_child(n)
