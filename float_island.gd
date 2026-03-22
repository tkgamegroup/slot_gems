extends RefCounted

class_name FloatIsland

var target
var move_strength : float
var rotate_strength : float
var jitter : Jitter = Jitter.new()
var offset : Vector2
var enable : bool = false

func setup(_target, _move_strength : float, _rotate_strength : float, freq : float):
	target = _target
	move_strength = _move_strength
	rotate_strength = _rotate_strength
	
	jitter.setup(freq)
	
	target.visibility_changed.connect(func():
		if target.is_visible_in_tree():
			var job = func():
				offset = target.position
				target.pivot_offset = target.size / 2.0
				enable = true
			job.call_deferred()
	)

func update():
	if enable && !G.performance_mode:
		jitter.update()
		target.position = round(offset + jitter.value * move_strength)
		target.rotation_degrees = jitter.value.y * rotate_strength
