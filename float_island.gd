extends Object

class_name FloatIsland

var noise : Noise
var noise_coord : float = 0.0

func _init() -> void:
	noise = FastNoiseLite.new()
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	noise.fractal_type = FastNoiseLite.FRACTAL_FBM
	noise.frequency = 0.2
	noise.seed = randi()

func update(n, strength : float, delta: float) -> void:
	noise_coord += 1.0 * delta
	n.position = Vector2(noise.get_noise_2d(17.1, noise_coord), noise.get_noise_2d(97.9, noise_coord)) * strength
