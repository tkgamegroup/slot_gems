extends RichTextEffect

class_name RichTextPopup

var bbcode = "popup"

func _process_custom_fx(char_fx: CharFXTransform) -> bool:
	var dura = char_fx.env.get("dura", 1.0)
	var span = char_fx.env.get("span", 10.0)
	if char_fx.elapsed_time <= dura:
		var t = span * char_fx.elapsed_time / dura
		var i = char_fx.relative_index
		if t >= i && t < i + 1:
			char_fx.offset.y = -10
	return true
