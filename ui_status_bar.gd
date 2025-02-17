extends PanelContainer

func appear():
	self.show()
	var tween = Game.get_tree().create_tween()
	var pos = self.position
	self.position = pos - Vector2(0, 100)
	tween.tween_property(self, "position", pos, 0.8)
