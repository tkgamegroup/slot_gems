extends AnimatedSprite2D

@onready var burn : Sprite2D = $Burn
@onready var text : Label = $Control/Label
@onready var pin : Sprite2D = $Pin

const rim_mat : ShaderMaterial = preload("res://rim_mat.tres")

var is_active : bool = false
var active_serial : int

func set_active(v : bool):
	if v:
		is_active = true
		active_serial = Game.board.active_serial
		var sp = AnimatedSprite2D.new()
		sp.sprite_frames = self.sprite_frames
		sp.frame = self.frame
		sp.scale = Vector2(1.5, 1.5)
		sp.modulate.a = 0.0
		self.add_child(sp)
		var tween = Game.get_tree().create_tween()
		tween.tween_property(sp, "scale", Vector2(1.0, 1.0), 0.5)
		tween.parallel().tween_property(sp, "modulate:a", 1.0, 0.5)
		tween.tween_callback(func():
			sp.queue_free()
			self.scale = Vector2(1.25, 1.25)
			self.material = rim_mat
			text.text = "%d" % active_serial
			text.show()
		)
	else:
		is_active = false
		self.scale = Vector2(1.0, 1.0)
		self.material = null
		text.text = ""
		text.hide()

func _process(delta: float) -> void:
	if is_active:
		var t = Time.get_ticks_msec() / 1000.0
		t = fmod(t, 2.0)
		if t < 0.5:
			self.rotation_degrees = sin((0.5 + 8.0 * t) * PI) * 5.0
