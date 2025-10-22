extends RichTextEffect

class_name RichTextMyWave

var bbcode = "my_wave"

func _process_custom_fx(char_fx: CharFXTransform) -> bool:
	var off = char_fx.env.get("off", 0.0)
	var freq = char_fx.env.get("freq", 1.0)
	var amp = char_fx.env.get("amp", 15.0)
	var t = char_fx.elapsed_time + (off * 100.0 + char_fx.transform.get_origin().x * 15.0) / Game.resolution.x
	var offset_y = sin(t * freq * TAU) * amp
	char_fx.offset.y -= offset_y
	return true
