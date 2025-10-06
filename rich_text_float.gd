extends RichTextEffect
class_name RichTextFloat

var bbcode = "float"

func _process_custom_fx(char_fx: CharFXTransform) -> bool:
	var i = char_fx.range.x
	var n = char_fx.glyph_count
	return true
