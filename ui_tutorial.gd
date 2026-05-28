extends Control

@export var mask_left : Control
@export var mask_top : Control
@export var mask_right : Control
@export var mask_bottom : Control
@export var dialog : Control
@export var dialog_text : RichTextLabel
@export var dialog_arrow : Sprite2D
@export var timer : Timer

var script_id : int = 0
var script_type : int = 0
var waiting_actions : int = 0

var tween : Tween = null

func show_dialog(tween : Tween, text : String, pos : Vector2):
	dialog.position = pos
	dialog_text.text = text
	dialog_text.visible_ratio = 0.0
	var t = dialog_text.text.length() * 0.03
	tween.tween_property(dialog_text, "visible_ratio", 1.0, t)
	dialog.show()
	return t

func reset_masks():
	mask_left.position = Vector2(0.0, 0.0)
	mask_left.size = Vector2(C.RESOLUTION)
	mask_left.modulate.a = 0.0
	mask_top.position = Vector2(0.0, 0.0)
	mask_top.size = Vector2(0.0, 0.0)
	mask_top.modulate.a = 0.0
	mask_right.position = Vector2(0.0, 0.0)
	mask_right.size = Vector2(0.0, 0.0)
	mask_right.modulate.a = 0.0
	mask_bottom.position = Vector2(0.0, 0.0)
	mask_bottom.size = Vector2(0.0, 0.0)
	mask_bottom.modulate.a = 0.0

func focus_target(tween : Tween, rect : Rect2):
	var res = Vector2(C.RESOLUTION)
	mask_left.position = Vector2(0.0, 0.0)
	mask_left.size = Vector2(0.0, res.y)
	mask_left.modulate.a = 0.3
	mask_top.position = Vector2(0.0, 0.0)
	mask_top.size = Vector2(res.x, 0.0)
	mask_top.modulate.a = 0.3
	mask_right.position = Vector2(res.x, 0.0)
	mask_right.size = Vector2(0.0, res.y)
	mask_right.modulate.a = 0.3
	mask_bottom.position = Vector2(0.0, res.y)
	mask_bottom.size = Vector2(res.x, 0.0)
	mask_bottom.modulate.a = 0.3
	var sub = G.create_tween()
	sub.parallel().tween_property(mask_left, "size", Vector2(rect.position.x, rect.end.y), 0.5)
	sub.parallel().tween_property(mask_top, "position", Vector2(rect.position.x, 0.0), 0.5)
	sub.parallel().tween_property(mask_top, "size", Vector2(res.x - rect.position.x, rect.position.y), 0.5)
	sub.parallel().tween_property(mask_right, "position", Vector2(rect.end.x, rect.position.y), 0.5)
	sub.parallel().tween_property(mask_right, "size", Vector2(res.x - rect.end.x, res.y - rect.position.y), 0.5)
	sub.parallel().tween_property(mask_bottom, "position", Vector2(0.0, rect.end.y), 0.5)
	sub.parallel().tween_property(mask_bottom, "size", Vector2(rect.end.x, res.y - rect.end.y), 0.5)
	tween.tween_subtween(sub)

func get_action_types():
	var types = {}
	for c in get_children():
		if c is G.UiTutorialAction:
			types[c.type] = 1
	return types.keys()

func start():
	script_id = 1
	waiting_actions = 0
	
	timer.start()
	reset_masks()
	self.show()

func stop():
	timer.stop()
	self.hide()
	
	G.exit_game()
	
	var tween = G.create_tween()
	G.begin_transition(tween)
	tween.tween_callback(func():
		G.title_ui.enter()
	)
	G.end_transition(tween)

func timeout():
	if waiting_actions > 0:
		return
	if G.stage != G.Stage.Deploy:
		return
	if G.busy:
		return
	var script_name = "tutorial_script_%d" % script_id
	var script = tr(script_name)
	if script == script_name:
		stop()
		return
	script_id += 1
	script_type = C.TutorialScript.None
	var pairs = SUtils.parse_tagged_string(script)
	if tween:
		tween.custom_step(100.0)
		tween = null
	tween = G.create_tween()
	for p in pairs:
		var pos = Vector2(0.0, 0.0)
		var size = Vector2(0.0, 0.0)
		var num = 1
		var target_name = ""
		var lineno = -1
		var condition = ""
		var seed = 0
		for t in p.first:
			if t.begins_with("H:") || t.begins_with("V:"):
				var s = t.substr(2)
				if s == "M":
					if t[0] == "H":
						pos.x = (C.RESOLUTION.x - dialog.size.x) * 0.5
					elif t[0] == "V":
						pos.y = (C.RESOLUTION.y - dialog.size.y) * 0.5
				elif s.ends_with("%"):
					s = s.left(-1)
					if t[0] == "H":
						pos.x = C.RESOLUTION.x * (int(s) / 100.0) - dialog.size.x * 0.5
					elif t[0] == "V":
						pos.y = C.RESOLUTION.y * (int(s) / 100.0) - dialog.size.y * 0.5
				else:
					if t[0] == "H":
						pos.x = int(s)
					elif t[0] == "V":
						pos.y = int(s)
			elif t.begins_with("PX:"):
				var s = t.substr(3)
				pos.x = int(s)
			elif t.begins_with("PY:"):
				var s = t.substr(3)
				pos.y = int(s)
			elif t.begins_with("SX:"):
				var s = t.substr(3)
				size.x = int(s)
			elif t.begins_with("SY:"):
				var s = t.substr(3)
				size.y = int(s)
			elif t.begins_with("N:"):
				var s = t.substr(2)
				num = int(s)
			elif t.begins_with("T:"):
				var s = t.substr(2)
				target_name = s
			elif t.begins_with("LINE:"):
				var s = t.substr(5)
				lineno = int(s)
			elif t.begins_with("COND:"):
				var s = t.substr(5)
				condition = s
			elif t.begins_with("SEED:"):
				var s = t.substr(5)
				seed = s.hex_to_int()
		if !p.second.is_empty():
			if p.second == "HOVER":
				var rect = Rect2(pos, size)
				if !target_name.is_empty():
					var target = G.canvas.find_child(target_name, true, false)
					if target:
						rect = target.get_global_rect()
				tween.tween_callback(func():
					var ui = G.tutorial_action_pb.instantiate()
					ui.setup(rect, C.TutorialAction.Hover)
					self.add_child(ui)
				)
				script_type = C.TutorialScript.Actions
				waiting_actions += 1
			elif p.second == "CLICK":
				var rect = Rect2(pos, size)
				if !target_name.is_empty():
					var target = G.canvas.find_child(target_name, true, false)
					if target:
						rect = target.get_global_rect()
				tween.tween_callback(func():
					var ui = G.tutorial_action_pb.instantiate()
					ui.setup(rect, C.TutorialAction.Click)
					self.add_child(ui)
				)
				script_type = C.TutorialScript.Actions
				waiting_actions += 1
			elif p.second == "SWAP":
				tween.tween_callback(func():
					var ui = G.tutorial_action_pb.instantiate()
					ui.setup(Rect2(0, 0, 0, 0), C.TutorialAction.Swap, num)
					self.add_child(ui)
				)
				script_type = C.TutorialScript.Actions
				waiting_actions += 1
			elif p.second == "FOCUS":
				var rect = Rect2(pos, size)
				if !target_name.is_empty():
					var target = G.canvas.find_child(target_name, true, false)
					if target:
						rect = target.get_global_rect()
				focus_target(tween, rect)
				tween.tween_interval(0.5)
			elif p.second == "RESET_MASKS":
				tween.tween_callback(func():
					reset_masks()
				)
			elif p.second == "DISABLE":
				if !target_name.is_empty():
					var target = G.control_ui.find_child(target_name, true, false)
					if target:
						tween.tween_callback(func():
							target.disabled = true
						)
			elif p.second == "ENABLE":
				if !target_name.is_empty():
					var target = G.control_ui.find_child(target_name, true, false)
					if target:
						tween.tween_callback(func():
							target.disabled = false
						)
			elif p.second == "IF":
				if !condition.is_empty():
					var ok = false
					if condition == "HAS_MATCHED_PATTERNS":
						ok = !G.control_ui.preview.matchings.is_empty()
					elif condition == "HAS_CHAINS":
						var board = SUtils.get_board_data()
						if SUtils.temp_board_matched_cells(board).size() > 0:
							SUtils.temp_board_clear_matcheds(board)
							if SUtils.temp_board_matched_cells(board).size() > 0:
								ok = true
					if ok:
						script_id = lineno
					if script_type == C.TutorialScript.None:
						script_type = C.TutorialScript.Logic
			elif p.second == "GOTO":
				script_id = lineno
				if script_type == C.TutorialScript.None:
					script_type = C.TutorialScript.Logic
			elif p.second == "NEW_GAME":
				G.start_game("", {"seed":seed})
				if script_type == C.TutorialScript.None:
					script_type = C.TutorialScript.Logic
			else:
				var t = show_dialog(tween, p.second, pos)
				tween.tween_interval(t)
	if script_type == C.TutorialScript.None && dialog.visible:
		script_type = C.TutorialScript.Dialog
		waiting_actions = 1
		dialog_arrow.show()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed:
			if event.button_index == MOUSE_BUTTON_LEFT:
				if tween && tween.is_running():
					tween.custom_step(100.0)
					tween = null

func _ready() -> void:
	timer.timeout.connect(timeout)
	dialog.gui_input.connect(func(event : InputEvent):
		if script_type == C.TutorialScript.Dialog:
			if event is InputEventMouseButton:
				if event.pressed:
					if event.button_index == MOUSE_BUTTON_LEFT:
						if tween && tween.is_running():
							tween.custom_step(100.0)
							tween = null
						else:
							waiting_actions -= 1
							dialog.hide()
							dialog_arrow.hide()
	)
