extends Object

class_name Buff

enum Type
{
	None,
	ChangeColor,
	ValueModifier,
	Custom
}

enum Duration
{
	ThisMatchingStage,
	ThisLevel
}

var id : int
var type : int
var host = null
var data : Dictionary

var on_remove : Callable

static var uid : int = 0

func die():
	if type == Type.Custom:
		on_remove.call(host, data)
	else:
		match type:
			Type.ChangeColor: 
				host.type = data["original_color"]
				if host.coord.x != -1 && host.coord.y != -1:
					Game.get_cell_ui(host.coord).set_gem_image(host.type, host.rune)
			Type.ValueModifier:
				type = Type.None
				SUtils.calc_value_with_modifiers(host, data["target"])

static func create(host, type : int, parms : Dictionary):
	var b = Buff.new()
	b.type = type
	b.host = host
	host.buffs.append(b)
	uid += 1
	match type:
		Type.ChangeColor: 
			b.data["original_color"] = host.type
			host.type = parms["color"]
			if host.coord.x != -1 && host.coord.y != -1:
				Game.get_cell_ui(host.coord).set_gem_image(host.type, host.rune)
		Type.ValueModifier:
			if parms.has("modify_add"):
				b.data["modify_add"] = parms["modify_add"]
			if parms.has("modify_mult"):
				b.data["modify_mult"] = parms["modify_mult"]
			b.data["target"] = parms["target"]
			SUtils.calc_value_with_modifiers(host, parms["target"])
	return uid

static func create_custom(host, _on_gain : Callable, _on_remove : Callable):
	var b = Buff.new()
	b.type = Type.Custom
	b.host = host
	_on_gain.call(host, b.data)
	b.on_remove = _on_remove
	host.buffs.append(b)
	uid += 1
	return uid

static func find_typed_buff(host, type : int):
	for b in host.buffs:
		if b.type == type:
			return b
	return null
