extends Object

class_name FloatIsland

var target
var move_strength : float
var rotate_strength : float
var noise : Noise
var noise_coord : float = 0.0
var wave_coord : Vector2
var offset : Vector2
var enable : bool = false

func setup(_target, _move_strength : float, _rotate_strength : float, freq : float):
	target = _target
	move_strength = _move_strength
	rotate_strength = _rotate_strength
	
	noise = FastNoiseLite.new()
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	noise.fractal_type = FastNoiseLite.FRACTAL_FBM
	noise.frequency = freq
	noise.seed = Time.get_ticks_msec()
	
	target.visibility_changed.connect(func():
		if target.is_visible_in_tree():
			var job = func():
				offset = target.position
				target.pivot_offset = target.size / 2.0
				enable = true
			job.call_deferred()
	)

func update(delta: float):
	if enable && !Game.performance_mode:
		noise_coord += 1.0 * delta
		wave_coord += Vector2(delta, delta) + Vector2(noise.get_noise_2d(17.1, noise_coord), noise.get_noise_2d(97.9, noise_coord)) * 0.15
		var value = Vector2(sin(wave_coord.x), sin(wave_coord.y))
		target.position = offset + value * move_strength
		target.rotation_degrees = value.y * rotate_strength
