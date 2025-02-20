extends RichTextLabel

class_name AdvancedLabel

var disabled : bool = false:
	set(v):
		disabled = v
		if disabled:
			change_color(Color(0.7, 0.7, 0.7, 1.0))
		else:
			change_color(Color(1.0, 1.0, 1.0, 1.0))

func change_color(col : Color):
	add_theme_color_override("default_color", col)
	
	var regex1 = RegEx.new()
	regex1.compile("\\[img([\\w\\s\\=]+)\\]")
	var regex2 = RegEx.new()
	regex2.compile("color\\=([\\w]+)")
	var temp_text = text
	var temp_str : String = ""
	var last_pos : int = 0
	for res in regex1.search_all(temp_text):
		var start = res.get_start()
		temp_str += temp_text.substr(last_pos, start - last_pos)
		var args = res.get_string(1)
		var r2 = regex2.search(args)
		if r2:
			args = args.substr(0, r2.get_start())
		args += " color=%s" % col.to_html()
		temp_str += "[img%s]" % args
		last_pos = res.get_end()
	temp_str += temp_text.substr(last_pos)
	text = temp_str
