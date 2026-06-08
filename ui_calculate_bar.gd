extends Control

@export var panel : Control
@export var base_score_text : Label
@export var chains_text : G.NumberText
@export var mult_text : Label
@export var cross1 : Label
@export var cross2 : Label
@export var calculated_text : Label

signal finished

func appear():
	if G.is_headless():
		return
	panel.pivot_offset = Vector2(panel.size.x * 0.5, panel.size.y)
	panel.scale = Vector2(0.0, 0.0)
	
	base_score_text.text = "0"
	chains_text.set_value(0)
	mult_text.text = "1.0"
	cross1.scale.x = 0.0
	cross2.scale.x = 0.0
	
	var tween = G.create_game_tween()
	tween.tween_property(panel, "scale", Vector2(1.0, 1.0), 0.3 * G.time_scale).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)
	
	self.show()

func get_result(result : Dictionary):
	result["chain_mult"] = G.mult_from_chains(G.chains)
	result["value"] = int(round(G.base_score * result["chain_mult"] * G.score_mult))

func calculate_proc():
	var result = {}
	
	var tween = G.create_game_tween()
	if tween:
		tween.tween_interval(0.3 * G.time_scale)
		tween.tween_callback(func():
			get_result(result)
			
			SSound.se_calc1.pitch_scale = 1.0 / G.time_scale
			SSound.se_calc1.play()
		)
		SAnimation.jump(tween, chains_text, 4, 0.4 * G.time_scale, func():
			chains_text.text.text = "%.2f" % result["chain_mult"]
		)
		tween.tween_property(cross1, "scale:x", 1.0, 0.1 * G.time_scale).from(0.0)
		tween.tween_interval(0.3 * G.time_scale)
		tween.tween_callback(func():
			SSound.se_calc1.pitch_scale = 1.0 / G.time_scale
			SSound.se_calc1.play()
			calculated_text.show()
			calculated_text.text = "%d" % result["value"]
			calculated_text.position = Vector2((G.resolution.x - calculated_text.size.x) * 0.5, 220)
		)
		SAnimation.jump(tween, calculated_text, 8, 0.5 * G.time_scale, Callable(), true, false)
		tween.tween_property(panel, "scale", Vector2(0.0, 0.0), 0.3 * G.time_scale).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)
		tween.tween_property(calculated_text, "global_position", G.game_ui.status_bar.score_text.get_global_rect().get_center() + Vector2(-calculated_text.size.x * 0.5, 50), 0.5 * G.time_scale).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)
		
		var score0 = G.score
		tween.tween_callback(func():
			SSound.se_score_counting.pitch_scale = 1.0 / G.time_scale
			SSound.se_score_counting.play()
		)
		tween.tween_method(func(v):
			G.score = score0 + int(v * result["value"])
			calculated_text.text = "%d" % int((1.0 - v) * result["value"])
		, 0.0, 1.0, 0.5 * G.time_scale)
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
			sub.tween_interval(delay * G.time_scale)
		if h.caster.on_event.call(C.Event.BeforeScoreCalculating, sub, null):
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
	if G.is_headless():
		return
	calculated_text.hide()
	self.hide()
