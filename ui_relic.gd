extends Control

@export var sp : AnimatedSprite2D
@export var sockets_bar : Control

const gem_slot_pb = preload("res://ui_gem_slot.tscn")

var relic : Relic
var tt_dir : int = 0
var elastic : float = 1.0

func setup(_relic : Relic, _tt_dir : int = 0):
	relic = _relic
	tt_dir = _tt_dir

func build_sockets():
	for i in relic.sockets.size():
		var g = relic.sockets[i]
		var ui = gem_slot_pb.instantiate()
		ui.right_click_to_unload = false
		ui.allow_change = false
		ui.on_load.connect(func(g : Gem):
			if g.coord.x != -1 && g.coord.y == -1:
				Hand.draw()
			relic.on_socket.call(i, g)
			relic.sockets[i] = g
		)
		if g:
			ui.load_gem(g)
		sockets_bar.add_child(ui)

func _ready() -> void:
	sp.frame = relic.image_id
	self.mouse_entered.connect(func():
		SSound.se_select.play()
		STooltip.show(self, tt_dir, relic.get_tooltip())
	)
	self.mouse_exited.connect(func():
		STooltip.close()
	)
	sockets_bar.mouse_entered.connect(func():
		if Drag.ui:
			Drag.ui.scale = Drag.ui_scaling * 0.26
	)
	sockets_bar.mouse_exited.connect(func():
		if Drag.ui:
			Drag.ui.scale = Drag.ui_scaling
	)
