extends Control

var type : String
var payload = null
var ui : Control
var release_cb : Callable
var targets : Array[Triple]
var processing : bool = false

func add_target(_type : String, node, cb : Callable):
	var t = Triple.new(_type, node, cb)
	targets.append(t)
	if node != Game.board_ui:
		node.mouse_entered.connect(func():
			if type == _type:
				cb.call(payload, "peek", {})
		)
		node.mouse_exited.connect(func():
			if type == _type:
				cb.call(null, "peek_exited", {})
		)

func remove_target(node):
	var t = null
	for _t in targets:
		if _t.second == node:
			t = _t
			break
	if t:
		targets.erase(t)

func start(_type : String, _payload, _ui : Control, _release_cb : Callable):
	type = _type
	payload = _payload
	ui = _ui
	ui.z_index = 10
	release_cb = _release_cb

func release(target = null, extra : Dictionary = {}):
	if processing:
		return
	if ui:
		processing = true
		var ok = false
		if target:
			ok = target.third.call(payload, "dropped", extra)
			if ok:
				target.third.call(null, "peek_exited", {})
		if release_cb.is_valid():
			release_cb.call(target.second if ok && target else null)
		type = ""
		payload = null
		if ui:
			ui.z_index = 0
			ui = null
		release_cb = Callable()
		processing = false

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == MOUSE_BUTTON_RIGHT:
				release()
		if event.is_released():
			if event.button_index == MOUSE_BUTTON_LEFT:
				if ui:
					var target = null
					var extra = {}
					# drop on target
					for t in targets:
						if t.first == type:
							if t.second == Game.board_ui:
								var c = Game.board_ui.hover_coord(true)
								if Board.is_valid(c):
									target = t
									extra["coord"] = c
									break
							else:
								var pos = t.second.get_local_mouse_position()
								var rect = t.second.get_rect()
								if pos.x >= 0 && pos.y >= 0 && pos.x < rect.size.x && pos.y < rect.size.y:
									target = t
									break
					release(target, extra)
	elif event is InputEventMouseMotion:
		if ui: # hover target
			pass

func _process(delta: float) -> void:
	if ui:
		ui.global_position = get_global_mouse_position() - (ui.size * 0.5)
