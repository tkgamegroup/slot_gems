extends Control

@onready var bg : Control = $TextureRect
@onready var text1 : Label = $VBoxContainer/Label
@onready var text2 : Label = $VBoxContainer/Label2

var show_tip_tween : Tween = null

func appear(_text1 : String, _text2 : String, tween : Tween = null):
	var vp = get_viewport_rect().size
	self.position = Vector2(vp.x, (vp.y - self.size.y) / 5.0)
	self.modulate.a = 1.0
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

func disappear(tween : Tween = null, hide_text : bool = false):
	if !tween:
		tween = get_tree().create_tween()
	if hide_text:
		text1.hide()
		text2.hide()
		tween.tween_property(bg, "modulate:a", 0.0, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)
	else:
		tween.tween_property(self, "modulate:a", 0.0, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)
		tween.tween_callback(self.hide)
	return tween

func show_tip(_text1 : String, _text2 : String, duration : float):
	if show_tip_tween:
		show_tip_tween.kill()
		show_tip_tween = null
	show_tip_tween = get_tree().create_tween()
	appear(_text1, _text2, show_tip_tween)
	show_tip_tween.tween_interval(duration)
	disappear(show_tip_tween)
	show_tip_tween.tween_callback(func():
		show_tip_tween = null
	)
