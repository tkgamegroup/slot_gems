extends Control

@onready var panel : Control = $Panel
@onready var base_score_text : Label = $Panel/HBoxContainer/Panel/BaseScore
@onready var combos_text : Label = $Panel/HBoxContainer/Panel2/Combos
@onready var mult_text : Label = $Panel/HBoxContainer/Panel3/Mult
@onready var cross1 : Label = $Panel/HBoxContainer/Control/Label
@onready var cross2 : Label = $Panel/HBoxContainer/Control2/Label
@onready var calculated_text : Label = $Calculated

func appear():
	panel.pivot_offset = Vector2(panel.size.x * 0.5, panel.size.y)
	panel.scale = Vector2(0.0, 0.0)
	var tween = get_tree().create_tween()
	tween.tween_property(panel, "scale", Vector2(1.0, 1.0), 0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)
	
	self.show()

func calculate():
	var tween = get_tree().create_tween()
	tween.tween_interval(0.3)
	var combos_mult = log(Game.combos * 1.0) / log(1.5)
	var add_value = int(Game.base_score * combos_mult * Game.score_mult)
	SAnimation.jump(tween, combos_text, 4, 0.2, func():
		combos_text.text = "%.2f" % combos_mult
	)
	tween.tween_property(cross1, "scale:x", 1.0, 0.3)
	tween.parallel().tween_property(cross2, "scale:x", 1.0, 0.3)
	tween.tween_interval(0.3)
	SAnimation.jump(tween, base_score_text, 4, 0.2, Callable(), false)
	tween.parallel()
	SAnimation.jump(tween, combos_text, 4, 0.2, Callable(), false)
	tween.parallel()
	SAnimation.jump(tween, mult_text, 4, 0.2, Callable(), false)
	
	tween.tween_callback(func():
		base_score_text.text = "0"
		combos_text.text = "0"
		mult_text.text = "0"
		
		calculated_text.show()
		calculated_text.text = "%d" % add_value
		calculated_text.position = Vector2((1280 - calculated_text.size.x) * 0.5, 180)
	)
	SAnimation.jump(tween, calculated_text, 8, 0.5, Callable(), true, false)
	tween.tween_property(panel, "scale", Vector2(0.0, 0.0), 0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)
	tween.tween_property(calculated_text, "global_position", Game.status_bar_ui.score_text.get_global_rect().get_center() + Vector2(-calculated_text.size.x * 0.5, 50), 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)
	
	var score0 = Game.score
	tween.tween_method(func(v):
		Game.score = score0 + (add_value - v)
		calculated_text.text = "%d" % v
	, add_value, 0, 1.0)
	tween.tween_callback(func():
		disappear()
	)

func disappear():
	calculated_text.hide()
	self.hide()
