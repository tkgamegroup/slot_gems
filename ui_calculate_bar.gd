extends Control

@export var panel : Control
@export var base_score_text : Label
@export var combos_text : Label
@export var mult_text : Label
@export var cross1 : Label
@export var cross2 : Label
@export var calculated_text : Label

signal finished

func appear():
	if !(STest.testing && STest.headless):
		panel.pivot_offset = Vector2(panel.size.x * 0.5, panel.size.y)
		panel.scale = Vector2(0.0, 0.0)
		
		base_score_text.text = "0"
		combos_text.text = "0X"
		mult_text.text = "1.0"
		cross1.scale.x = 0.0
		cross2.scale.x = 0.0
		
		var tween = G.create_game_tween()
		tween.tween_property(panel, "scale", Vector2(1.0, 1.0), 0.3 * G.speed).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)
		
		self.show()

func get_result(result : Dictionary):
	result["combo_mult"] = G.mult_from_combos(G.combos)
	result["value"] = int(G.base_score * result["combo_mult"] * G.score_mult)

func calculate_proc():
	var result = {}
	
	var tween = G.create_game_tween()
	if tween:
		tween.tween_interval(0.3)
		tween.tween_callback(func():
			get_result(result)
			
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
		tween.tween_property(calculated_text, "global_position", G.game_ui.status_bar.score_text.get_global_rect().get_center() + Vector2(-calculated_text.size.x * 0.5, 50), 0.5 * G.speed).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)
		
		var score0 = G.score
		tween.tween_callback(func():
			SSound.se_score_counting.pitch_scale = 1.0 / G.speed
			SSound.se_score_counting.play()
		)
		tween.tween_method(func(v):
			G.score = score0 + int(v * result["value"])
			calculated_text.text = "%d" % int((1.0 - v) * result["value"])
		, 0.0, 1.0, 0.5 * G.speed)
		tween.tween_callback(func():
			disappear()
			finished.emit()
		)
	else:
		get_result(result)
		G.score += result["value"]
		finished.emit()

func calculate():
	if G.base_score == 0:
		disappear()
		finished.emit()
		return
	
	var tween = G.create_game_tween()
	var preprocess = false
	var delay = 0.0
	for h in G.event_listeners:
		var sub = G.create_game_tween()
		if sub:
			sub.tween_interval(delay * G.speed)
		if h.host.on_event.call(C.Event.BeforeScoreCalculating, sub, null):
			if tween:
				tween.parallel()
				tween.tween_subtween(sub)
			preprocess = true
			delay += 0.2
	if preprocess && tween:
		tween.tween_callback(calculate_proc)
	else:
		calculate_proc()

func disappear():
	if !(STest.testing && STest.headless):
		calculated_text.hide()
		self.hide()
