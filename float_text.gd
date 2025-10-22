extends Control

@onready var text_lb : RichTextLabel = $Text
@onready var shadow_lb : Label = $Shadow

@export var text : String:
	set(v):
		text = v
		update_text()
@export var font_size : int = 22:
	set(v):
		font_size = v
		update_font_size()
@export var offset : int = 3:
	set(v):
		offset = v
		update_offset()
@export var freq : float = 0.37

func update_text():
	if text_lb:
		if is_visible_in_tree():
			var tween = get_tree().create_tween()
			tween.tween_callback(func():
				text_lb.text = "[my_wave amp=%.1f freq=%.1f off=%.1f]%s[/my_wave]" % [float(offset) * 0.5, freq, global_position.x + global_position.y, text]
			)
		else:
			text_lb.text = text
	if shadow_lb:
		shadow_lb.text = text

func update_font_size():
	if text_lb:
		text_lb.add_theme_font_size_override("normal_font_size", font_size)
	if shadow_lb:
		shadow_lb.add_theme_font_size_override("font_size", font_size)

func update_offset():
	if shadow_lb:
		shadow_lb.add_theme_constant_override("shadow_offset_y", offset)

func _ready() -> void:
	shadow_lb.add_theme_font_override("font", text_lb.get_theme_font("normal_font"))
	update_font_size()
	update_text()
	update_offset()
	visibility_changed.connect(func():
		update_text()
	)
