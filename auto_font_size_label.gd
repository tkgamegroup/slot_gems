extends Label

var base_font_size : int
var base_size : Vector2

func _enter_tree():
	base_size = self.size
	base_font_size = self.get_theme_font_size("font_size")
	self.resized.connect(set_text_size)
	
func _exit_tree():
	self.resized.disconnect(set_text_size)
	
func set_text_size():
	var new_size = self.size;
	var scl = new_size.x / base_size.x;
	var scaled_size = floor(base_font_size * scl);
	if scaled_size > 4096:
		return
	self.add_theme_font_size_override("font_scale", scaled_size);
