extends Control

const UiGem = preload("res://ui_gem.gd")

@onready var gem_ui : UiGem = $UiGem
@onready var img_open : TextureRect = $Open
@onready var img_close : TextureRect = $Close
@onready var particles1 : CPUParticles2D = $CPUParticles2D
@onready var particles2 : CPUParticles2D = $CPUParticles2D2

var gem : Gem = null
var disabled : bool = false:
	set(v):
		disabled = v
		update_color(false)
var rc_to_unload : bool = true

signal on_load
signal on_unload

func update_color(hovering : bool):
	var v = 1.0
	if disabled:
		v = 0.7
	else:
		if hovering:
			v = 0.8
	img_open.modulate = Color(v, v, v, 1.0)
	img_close.modulate = Color(v, v, v, 1.0)

func load_gem(_gem : Gem):
	if _gem:
		on_load.emit(_gem)
		if gem:
			unload_gem()
		gem = _gem
		img_open.hide()
		img_close.show()
		gem_ui.update(gem)
		update_color(false)

func unload_gem():
	if gem:
		var g = gem
		img_open.show()
		img_close.hide()
		gem_ui.reset()
		gem = null
		update_color(false)
		on_unload.emit(g)

func _ready() -> void:
	Drag.add_target("gem", self, func(payload, ev : String, extra : Dictionary):
		if disabled:
			return false
		if ev == "peek":
			update_color(true)
		elif ev == "peek_exited":
			update_color(false)
		else:
			if !disabled:
				load_gem(payload.gem)
				return true
		return false
	)
	self.gui_input.connect(func(event : InputEvent):
		if disabled:
			return
		if event is InputEventMouseButton:
			if rc_to_unload && event.pressed && event.button_index == MOUSE_BUTTON_RIGHT:
				SSound.se_drag_item.play()
				unload_gem()
	)
	self.mouse_entered.connect(func():
		if gem:
			SSound.se_select.play()
			STooltip.show(self, 0, gem.get_tooltip())
	)
	self.mouse_exited.connect(func():
		STooltip.close()
	)
	update_color(false)

func _exit_tree() -> void:
	if gem:
		unload_gem()
	Drag.remove_target(self)
