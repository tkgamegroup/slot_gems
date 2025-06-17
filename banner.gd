extends Control

@onready var bg : Control = $TextureRect
@onready var text1 : Label = $VBoxContainer/Label
@onready var text2 : Label = $VBoxContainer/Label2

func appear(_text1 : String, _text2 : String, tween : Tween = null):
	var vp = get_viewport_rect().size
	self.position = Vector2(vp.x, (vp.y - self.size.y) / 4.0)
	bg.modulate.a = 1.0
	text1.text = _text1
	text2.text = _text2
	text1.modulate.a = 1.0
	text2.modulate.a = 1.0
	text1.show()
	text2.show()
	self.show()
	
	if !tween:
		tween = get_tree().create_tween()
	tween.tween_property(self, "position:x", (vp.x - self.size.x) * 0.5, 0.5).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUART)
	return tween

func disappear():
	text1.hide()
	text2.hide()
	var tween = get_tree().create_tween()
	tween.tween_property(bg, "modulate:a", 0.0, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)
