extends Object

class_name SUtils

static func get_formated_datetime() -> String:
	var datetime = Time.get_datetime_string_from_system(false, true)
	datetime = datetime.replace("-", "_")
	datetime = datetime.replace(":", "_")
	datetime = datetime.replace(" ", "_")
	return datetime

static func replacing_gem_tag(text : String, with_color : bool, with_url : bool, used_gems : Array = []) -> String:
	var ret = ""
	var regex = RegEx.new()
	regex.compile(r"\[gem_([A-Za-z0-9]+)\]")
	var last_end = 0
	var matches = regex.search_all(text)
	for m in matches:
		var start = m.get_start()
		var end = m.get_end()
		ret += text.substr(last_end, start - last_end)
		var gem_name = m.get_string(1)
		if with_color:
			if with_url:
				ret += " [color=cyan][url=gem_%s]%s[/url][/color]" % [gem_name, App.tr("gem_name_" + gem_name)]
			else:
				ret += " [color=cyan]%s[/color]" % App.tr("gem_name_" + gem_name)
		else:
			ret += " " + App.tr("gem_name_" + gem_name)
		used_gems.append(gem_name)
		last_end = end
	ret += text.substr(last_end)
	return ret

static func replacing_number_tag(text : String, with_color : bool) -> String:
	var ret = ""
	var regex = RegEx.new()
	regex.compile(r"\[n_([0-9]+)\]")
	var last_end = 0
	var matches = regex.search_all(text)
	for m in matches:
		var start = m.get_start()
		var end = m.get_end()
		ret += text.substr(last_end, start - last_end)
		var value = m.get_string(1)
		if with_color:
			ret += "[color=cyan]%s[/color]" % value
		else:
			ret += "%s" % value
		last_end = end
	ret += text.substr(last_end)
	return ret

const words = ["w_wild", "w_omni", "w_eliminate", "w_active", "w_trigger", "w_place", "w_quick", "w_consumed", "w_aura", "w_range", "w_power", "w_tradable", "w_mount", "w_nullified", "w_in_mist"]
static func format_text(text : String, with_color : bool, with_url : bool, used_words : Array = [], used_gems : Array = []) -> String:
	var ret = ""
	ret = replacing_gem_tag(text, with_color, with_url, used_gems)
	ret = replacing_number_tag(ret, with_color)
	
	for w in words:
		if text.find(w) != -1:
			if with_color:
				if with_url:
					ret = ret.replace(w, "[url=%s][color=cyan]%s[/color][/url]" % [w, App.tr(w)])
				else:
					ret = ret.replace(w, "[color=cyan]%s[/color]" % App.tr(w))
			else:
				ret = ret.replace(w, App.tr(w))
			used_words.append(w)
	
	return ret

static func read_dictionary(d : Dictionary):
	var ret = {}
	for k in d:
		if k.ends_with("_i"):
			ret[k] = int(d[k])
		elif k.ends_with("_f"):
			ret[k] = d[k]
		elif k.ends_with("_2i"):
			ret[k] = str_to_var("Vector2i" + d[k])
		else:
			ret[k] = d[k]
	return ret

static func calc_value_with_modifiers(obj : Object, target : String, sub_attr : String = ""):
	var v = 0
	for b in obj.buffs:
		if b.type == Buff.Type.ValueModifier && b.data["target"] == target && b.data["sub_attr"] == sub_attr:
			if b.data.has("set"):
				v = b.data["set"]
			if b.data.has("add"):
				v += b.data["add"]
			if b.data.has("mult"):
				v *= b.data["mult"]
	if sub_attr == "":
		obj[target] = v
	else:
		obj[sub_attr][target] = v

static func get_cells_border(coords : Array[Vector2i]):
	var ret = []
	var ccords = []
	for c in coords:
		ccords.append(Board.offset_to_cube(c))
	const size = C.BOARD_TILE_SZ * 0.5
	var w = size * 2.0
	var h = size * sqrt(3.0)
	for i in coords.size():
		var p = Board.get_pos(coords[i])
		var cc = ccords[i]
		if !ccords.has(cc + Vector3i(0, -1, +1)):
			# up
			ret.append(p + Vector2(w * -0.25, h * -0.5 - 2))
			ret.append(p + Vector2(w * +0.25, h * -0.5 - 2))
		if !ccords.has(cc + Vector3i(0, +1, -1)):
			# down
			ret.append(p + Vector2(w * -0.25, h * +0.5 + 2))
			ret.append(p + Vector2(w * +0.25, h * +0.5 + 2))
		if !ccords.has(cc + Vector3i(-1, 0, +1)):
			# lt
			ret.append(p + Vector2(w * -0.5, 0.0))
			ret.append(p + Vector2(w * -0.25, h * -0.5 - 2))
		if !ccords.has(cc + Vector3i(+1, -1, 0)):
			# rt
			ret.append(p + Vector2(w * +0.25, h * -0.5 - 2))
			ret.append(p + Vector2(w * +0.5, 0.0))
		if !ccords.has(cc + Vector3i(-1, +1, 0)):
			# lb
			ret.append(p + Vector2(w * -0.25, h * +0.5 + 2))
			ret.append(p + Vector2(w * -0.5, 0.0))
		if !ccords.has(cc + Vector3i(+1, 0, -1)):
			# rb
			ret.append(p + Vector2(w * +0.25, h * +0.5 + 2))
			ret.append(p + Vector2(w * +0.5, 0.0))
	return ret
