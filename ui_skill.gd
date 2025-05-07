extends Control

@onready var container = $VBoxContainer
@onready var runes_list = $VBoxContainer/HBoxContainer
@onready var image : AnimatedSprite2D = $VBoxContainer/Control/AnimatedSprite2D

var skill : Skill

func setup(_skill : Skill):
	skill = _skill

func _ready() -> void:
	for r in skill.requirements:
		var ctrl = Control.new()
		ctrl.custom_minimum_size = Vector2(12, 12)
		ctrl.mouse_filter = Control.MOUSE_FILTER_PASS
		var sp = AnimatedSprite2D.new()
		sp.sprite_frames = Gem.rune_frames
		sp.frame = r
		sp.centered = false
		sp.scale = Vector2(0.6, 0.6)
		ctrl.add_child(sp)
		runes_list.add_child(ctrl)
	image.frame = skill.image_id
	self.mouse_entered.connect(func():
		STooltip.show(skill.get_tooltip())
	)
	self.mouse_exited.connect(func():
		STooltip.close()
	)
