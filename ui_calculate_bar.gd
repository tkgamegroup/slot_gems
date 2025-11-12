extends Control

@onready var panel : Control = $Panel
@onready var base_score_text : Label = $Panel/HBoxContainer/Panel/BaseScore
@onready var combos_text : Label = $Panel/HBoxContainer/Panel2/Combos
@onready var mult_text : Label = $Panel/HBoxContainer/Panel3/Mult
@onready var cross1 : Label = $Panel/HBoxContainer/Control/Label
@onready var cross2 : Label = $Panel/HBoxContainer/Control2/Label
@onready var calculated_text : Label = $Calculated

signal finished

func appear():
	panel.pivot_offset = Vector2(panel.size.x * 0.5, panel.size.y)
	panel.scale = Vector2(0.0, 0.0)
	
	base_score_text.text = "0"
	combos_text.text = "0X"
	mult_text.text = "1.0"
	cross1.scale.x = 0.0
	cross2.scale.x = 0.0
	
	var tween = get_tree().create_tween()
	tween.tween_property(panel, "scale", Vector2(1.0, 1.0), 0.3 * Game.speed).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)
	
	self.show()

func calculate():
	if Game.base_score == 0:
		disappear()
		finished.emit()
		return
	
	var tween = get_tree().create_tween()
	tween.tween_interval(0.3)
	
	var result = {}
	result["combo_mult"] = Game.mult_from_combos(Game.combos)
	tween.tween_callback(func():
		SSound.se_calc1.pitch_scale = 1.0 / Game.speed
		SSound.se_calc1.play()
	)
	SAnimation.jump(tween, combos_text, 4, 0.2, func():
		combos_text.text = "%.2f" % result["combo_mult"]
		result["value"] = int(Game.base_score * result["combo_mult"] * Game.score_mult)
	)
	tween.tween_property(cross1, "scale:x", 1.0, 0.3 * Game.speed)
	tween.parallel().tween_property(cross2, "scale:x", 1.0, 0.3 * Game.speed)
	tween.tween_interval(0.3 * Game.speed)
	tween.tween_callback(func():
		SSound.se_calc2.pitch_scale = 1.0 / Game.speed
		SSound.se_calc2.play()
	)
	SAnimation.jump(tween, base_score_text, 4, 0.2 * Game.speed, Callable(), false)
	SAnimation.jump(tween, combos_text, 4, 0.2 * Game.speed, Callable(), false)
	SAnimation.jump(tween, mult_text, 4, 0.2 * Game.speed, Callable(), false)
	
	tween.tween_interval(0.3 * Game.speed)
	tween.tween_callback(func():
		calculated_text.show()
		calculated_text.text = "%d" % result["value"]
		calculated_text.position = Vector2((Game.resolution.x - calculated_text.size.x) * 0.5, 220)
	)
	SAnimation.jump(tween, calculated_text, 8, 0.5 * Game.speed, Callable(), true, false)
	tween.tween_property(panel, "scale", Vector2(0.0, 0.0), 0.3 * Game.speed).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)
	tween.tween_property(calculated_text, "global_position", Game.status_bar_ui.score_text.get_global_rect().get_center() + Vector2(-calculated_text.size.x * 0.5, 50), 0.5 * Game.speed).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)
	
	var score0 = Game.score
	tween.tween_callback(func():
		SSound.se_score_counting.pitch_scale = 1.0 / Game.speed
		SSound.se_score_counting.play()
	)
	tween.tween_method(func(v):
		Game.score = score0 + int(v * result["value"])
		calculated_text.text = "%d" % int((1.0 - v) * result["value"])
	, 0.0, 1.0, 0.5 * Game.speed)
	tween.tween_callback(func():
		disappear()
		finished.emit()
	)

func disappear():
	calculated_text.hide()
	self.hide()
