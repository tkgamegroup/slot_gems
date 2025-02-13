extends Control

@onready var runes_list = $VBoxContainer/HBoxContainer

var skill : Skill

func setup(_skill : Skill):
	skill = _skill

func _ready() -> void:
	for p in skill.requirements:
		for i in p.second:
			var ctrl = Control.new()
			ctrl.custom_minimum_size = Vector2(24, 24)
			ctrl.mouse_filter = Control.MOUSE_FILTER_PASS
			var sp = AnimatedSprite2D.new()
			sp.sprite_frames = Gem.runes_frames
			sp.frame = p.first
			sp.centered = false
			sp.scale = Vector2(0.75, 0.75)
			ctrl.add_child(sp)
			runes_list.add_child(ctrl)
	self.mouse_entered.connect(func():
		Tooltip.show("Skill", "When you finished a pattern, and have enough runes (%s), spawn a %s." % [skill.get_requirement_icons(16), skill.spawn_name])
	)
	self.mouse_exited.connect(func():
		Tooltip.close()
	)
