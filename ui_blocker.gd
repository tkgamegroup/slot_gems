extends Panel

var show_num : int = 0
var original_index : int

func enter():
	show_num += 1
	if show_num > 0:
		self.show()

func exit():
	show_num -= 1
	if show_num <= 0:
		self.hide()

func move(idx : int = -1):
	if idx == -1:
		idx = original_index
	get_parent().move_child(self, idx)

func _ready() -> void:
	original_index = get_index()
