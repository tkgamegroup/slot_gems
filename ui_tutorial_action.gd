extends Control

var type : int
var n : int

func setup(_rect : Rect2, _type : int, _n : int = 1):
	type = _type
	n = _n
	self.position = _rect.position
	self.size = _rect.size

func on_swap():
	n -= 1
	if n == 0:
		achieve()

func achieve():
	if type == C.TutorialAction.Swap:
		G.swap_finished.disconnect(on_swap)
	queue_free()
	
	G.tutorial_ui.waiting_actions -= 1

func _input(event: InputEvent) -> void:
	if type == C.TutorialAction.Hover:
		if event is InputEventMouse:
			var mpos = self.get_local_mouse_position()
			var sz = self.get_global_rect().size
			if mpos.x > 0 && mpos.y > 0 && mpos.x < sz.x && mpos.y < sz.y:
				achieve()
	elif type == C.TutorialAction.Click:
		if event is InputEventMouseButton:
			if event.pressed:
				if event.button_index == MOUSE_BUTTON_LEFT:
					var mpos = self.get_local_mouse_position()
					var sz = self.get_global_rect().size
					if mpos.x > 0 && mpos.y > 0 && mpos.x < sz.x && mpos.y < sz.y:
							achieve()

func _ready() -> void:
	if type == C.TutorialAction.Swap:
		G.swap_finished.connect(on_swap)
