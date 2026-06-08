extends RefCounted

class_name Buff

enum Type
{
	None,
	ChangeColor,
	ChangeRune,
	ValueModifier,
	Enchant
}

var uid : int
var type : int
var host = null
var caster = null
var duration : int
var data : Dictionary

static var s_uid : int = 0

static func on_value_changed(host, addr : String):
	SUtils.calc_value_with_attrs(host, addr)
	if host == G && addr.begins_with("attrs/"):
		G.on_attr_changed(addr.split("/")[1])

func die():
	match type:
		Type.ChangeColor: 
			host.type = data["original_color_i"]
			if host.coord.x != -1 && host.coord.y != -1:
				Board.ui.get_cell(host.coord).gem_ui.update(host)
		Type.ChangeRune: 
			host.rune = data["original_rune_i"]
			if host.coord.x != -1 && host.coord.y != -1:
				Board.ui.get_cell(host.coord).gem_ui.update(host)
		Type.ValueModifier:
			type = Type.None
			on_value_changed(host, data["addr"])

static func create(host, type : int, parms : Dictionary, duration : int = C.Duration.ThisMatching, caster = null) -> Buff:
	var b = Buff.new()
	b.uid = s_uid
	s_uid += 1
	b.type = type
	b.host = host
	b.duration = duration
	match type:
		Type.ChangeColor: 
			b.data["original_color_i"] = host.type
			host.type = parms["color"]
			if host.coord.x != -1 && host.coord.y != -1:
				Board.ui.get_cell(host.coord).gem_ui.update(host)
		Type.ChangeRune: 
			b.data["original_rune_i"] = host.type
			host.rune = parms["rune"]
			if host.coord.x != -1 && host.coord.y != -1:
				Board.ui.get_cell(host.coord).gem_ui.update(host)
		Type.ValueModifier:
			var first = true
			for bb in host.buffs:
				if bb.type == Type.ValueModifier && bb.data["addr"] == parms["addr"]:
					first = false
					break
			if first:
				var bb = Buff.new()
				bb.uid = s_uid
				s_uid += 1
				bb.type = type
				bb.host = host
				bb.duration = C.Duration.Eternal
				bb.data["addr"] = parms["addr"]
				bb.data["set"] = SUtils.get_value_by_addr(host, parms["addr"])
				host.buffs.append(bb)
			if parms.has("set"):
				b.data["set"] = parms["set"]
			if parms.has("add"):
				b.data["add"] = parms["add"]
			if parms.has("mult"):
				b.data["mult"] = parms["mult"]
			b.data["addr"] = parms["addr"]
		Type.Enchant:
			b.data["type"] = parms["type"]
			b.data["bid"] = parms["bid"]
	host.buffs.append(b)
	if type == Type.ValueModifier:
		on_value_changed(host, b.data["addr"])
	b.caster = caster
	return b

static func set_value(host, addr : String, v, duration : int = C.Duration.ThisMatching, caster = null) -> Buff:
	return create(host, Type.ValueModifier, {"addr":addr,"set":v}, duration, caster)

static func add_value(host, addr : String, v, duration : int = C.Duration.ThisMatching, caster = null) -> Buff:
	return create(host, Type.ValueModifier, {"addr":addr,"add":v}, duration, caster)

static func mult_value(host, addr : String, v, duration : int = C.Duration.ThisMatching, caster = null) -> Buff:
	return create(host, Type.ValueModifier, {"addr":addr,"mult":v}, duration, caster)

static func find_typed(host, type : int) -> Buff:
	for b in host.buffs:
		if b.type == type:
			return b
	return null

static func find_all_typed(host, type : int) -> Array[Buff]:
	var ret : Array[Buff] = []
	for b in host.buffs:
		if b.type == type:
			ret.append(b)
	return ret

static func clear(host, durations : Array[int]):
	SMath.remove_if(host.buffs, func(b : Buff):
		if durations.find(b.duration) != -1:
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

static func remove_by_caster(host, caster):
	SMath.remove_if(host.buffs, func(b : Buff):
		if b.caster == caster:
			b.die()
			return true
		return false
	)

static func load_from_data(host, d : Dictionary):
	var b = Buff.new()
	b.uid = d["uid"]
	b.type = int(d["type"])
	b.host = host
	b.duration = int(d["duration"])
	b.data = SUtils.read_dictionary(d["data"])
	host.buffs.append(b)
	return b

static func save_to_data(b : Buff, d : Dictionary):
	d["uid"] = b.uid
	d["type"] = b.type
	d["duration"] = b.duration
	d["data"] = SUtils.save_dictionary(b.data)
