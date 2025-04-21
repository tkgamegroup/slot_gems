extends Panel

var show_num : int = 0
var original_index : int

func enter(fade : float = 0.0):
	show_num += 1
	if show_num > 0:
		self.show()
		if fade > 0.0:
			SAnimation.fade_in(self, null, 1.0, 1.0, fade)

func exit(fade : float = 0.0):
	show_num -= 1
	if show_num <= 0:
		if fade > 0.0:
			var tween : Tween = SAnimation.fade_out(self, null, 1.0, 1.0, fade)
			tween.tween_callback(self.hide)
		else:
			self.hide()

func move(idx : int = -1):
	if idx == -1:
		idx = original_index
	get_parent().move_child(self, idx)

func _ready() -> void:
	original_index = get_index()
	self.mouse_entered.connect(func():
		STooltip.close()
	)
