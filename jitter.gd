extends RefCounted

class_name Jitter

var noise : Noise
var coord : Vector2
var value : Vector2

func setup(freq : float):
	noise = FastNoiseLite.new()
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	noise.fractal_type = FastNoiseLite.FRACTAL_FBM
	noise.frequency = freq
	noise.seed = randi()

func update():
	var t = Time.get_ticks_msec() / 1000.0
	coord += Vector2(noise.get_noise_2d(17.1, t), noise.get_noise_2d(97.9, t)) * 0.15
	value = Vector2(sin(coord.x), sin(coord.y))
	
