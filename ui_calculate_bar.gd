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
	
	var tween = G.game_tweens.create_tween()
	tween.tween_property(panel, "scale", Vector2(1.0, 1.0), 0.3 * G.speed).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)
	
	self.show()

func calculate_proc():
	var tween = G.game_tweens.create_tween()
	Board.collect_scores(tween)
	tween.tween_interval(0.3)
	
	var result = {}
	result["combo_mult"] = G.mult_from_combos(G.combos)
	result["value"] = int(G.base_score * result["combo_mult"] * G.score_mult)
	if !STest.testing:
		tween.tween_callback(func():
			SSound.se_calc1.pitch_scale = 1.0 / G.speed
			SSound.se_calc1.play()
		)
		SAnimation.jump(tween, combos_text, 4, 0.2, func():
			combos_text.text = "%.2f" % result["combo_mult"]
		)
		tween.tween_property(cross1, "scale:x", 1.0, 0.3 * G.speed)
		#tween.parallel().tween_property(cross2, "scale:x", 1.0, 0.3 * G.speed)
		tween.tween_interval(0.3 * G.speed)
		tween.tween_callback(func():
			SSound.se_calc2.pitch_scale = 1.0 / G.speed
			SSound.se_calc2.play()
		)
		SAnimation.jump(tween, base_score_text, 4, 0.2 * G.speed, Callable(), false)
		SAnimation.jump(tween, combos_text, 4, 0.2 * G.speed, Callable(), false)
		#SAnimation.jump(tween, mult_text, 4, 0.2 * G.speed, Callable(), false)
		tween.tween_interval(0.3 * G.speed)
		tween.tween_callback(func():
			calculated_text.show()
			calculated_text.text = "%d" % result["value"]
			calculated_text.position = Vector2((G.resolution.x - calculated_text.size.x) * 0.5, 220)
		)
		SAnimation.jump(tween, calculated_text, 8, 0.5 * G.speed, Callable(), true, false)
		tween.tween_property(panel, "scale", Vector2(0.0, 0.0), 0.3 * G.speed).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)
		tween.tween_property(calculated_text, "global_position", G.status_bar_ui.score_text.get_global_rect().get_center() + Vector2(-calculated_text.size.x * 0.5, 50), 0.5 * G.speed).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)
		
		var score0 = G.score
		tween.tween_callback(func():
			SSound.se_score_counting.pitch_scale = 1.0 / G.speed
			SSound.se_score_counting.play()
		)
		tween.tween_method(func(v):
			G.score = score0 + int(v * result["value"])
			calculated_text.text = "%d" % int((1.0 - v) * result["value"])
		, 0.0, 1.0, 0.5 * G.speed)
	else:
		tween.tween_callback(func():
			G.score += result["value"]
		)
	tween.tween_callback(func():
		disappear()
		finished.emit()
	)

func calculate():
	if G.base_score == 0:
		disappear()
		finished.emit()
		return
	
	var tween = G.game_tweens.create_tween()
	var preprocess = false
	var delay = 0.0
	for h in G.event_listeners:
		var sub = G.game_tweens.create_tween()
		sub.tween_interval(delay * G.speed)
		if h.host.on_event.call(C.Event.BeforeScoreCalculating, sub, null):
			tween.parallel()
			tween.tween_subtween(sub)
			preprocess = true
			delay += 0.2
	if preprocess:
		tween.tween_callback(calculate_proc)
	else:
		calculate_proc()

func disappear():
	calculated_text.hide()
	self.hide()
