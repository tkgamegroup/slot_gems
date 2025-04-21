extends Object

class_name Buff

enum Type
{
	None,
	ChangeColor,
	ValueModifier
}

enum Duration
{
	ThisMatching,
	ThisLevel,
	Eternal
}

var uid : int
var type : int
var host = null
var duration : int
var data : Dictionary

static var s_uid : int = 0

func die():
	match type:
		Type.ChangeColor: 
			host.type = data["original_color"]
			if host.coord.x != -1 && host.coord.y != -1:
				Game.get_cell_ui(host.coord).set_gem_image(host.type, host.rune)
		Type.ValueModifier:
			type = Type.None
			SUtils.calc_value_with_modifiers(host, data["target"], data["sub_attr"])

static func create(host, type : int, parms : Dictionary, duration : int = Duration.ThisMatching):
	var b = Buff.new()
	b.uid = s_uid
	s_uid += 1
	b.type = type
	b.host = host
	b.duration = duration
	match type:
		Type.ChangeColor: 
			b.data["original_color"] = host.type
			host.type = parms["color"]
			if host.coord.x != -1 && host.coord.y != -1:
				Game.get_cell_ui(host.coord).set_gem_image(host.type, host.rune)
		Type.ValueModifier:
			var target = parms["target"]
			var sub_attr = parms["sub_attr"] if parms.has("sub_attr") else ""
			var first = true
			for bb in host.buffs:
				if bb.type == Type.ValueModifier && bb.data["target"] == target && bb.data["sub_attr"] == sub_attr:
					first = false
					break
			if first:
				var bb = Buff.new()
				bb.uid = s_uid
				s_uid += 1
				bb.type = type
				bb.host = host
				bb.duration = Duration.Eternal
				bb.data["target"] = target
				bb.data["sub_attr"] = sub_attr
				if sub_attr == "":
					bb.data["set"] = host[target]
				else:
					bb.data["set"] = host[sub_attr][target]
				host.buffs.append(bb)
			if parms.has("set"):
				b.data["set"] = parms["set"]
			if parms.has("add"):
				b.data["add"] = parms["add"]
			if parms.has("mult"):
				b.data["mult"] = parms["mult"]
			b.data["target"] = target
			b.data["sub_attr"] = sub_attr
	host.buffs.append(b)
	if type == Type.ValueModifier:
		SUtils.calc_value_with_modifiers(host, b.data["target"], b.data["sub_attr"])
	return b.uid

static func find_typed(host, type : int):
	for b in host.buffs:
		if b.type == type:
			return b
	return null

static func clear(host, duration : int):
	SMath.remove_if(host.buffs, func(b : Buff):
		if b.duration == duration:
			b.die()
			return true
		return false
	)

static func clear_if_not(host, duration : int):
	SMath.remove_if(host.buffs, func(b : Buff):
		if b.duration != duration:
			b.die()
			return true
		return false
	)

static func remove_by_id(host, id : int):
	SMath.remove_if(host.buffs, func(b : Buff):
		if b.uid == id:
			b.die()
			return true
		return false
	)

static func remove_by_id_list(host, ids : Array):
	SMath.remove_if(host.buffs, func(b : Buff):
		if ids.has(b.uid):
			b.die()
			return true
		return false
	)
