extends Control

var noise : Noise = FastNoiseLite.new()
var time : float = 0.0
var strength : float = 5.0

func _process(delta: float) -> void:
	time += delta * 100.0
	position = Vector2(noise.get_noise_1d(time), noise.get_noise_1d(time + 117.377)) * strength
