extends RefCounted

class_name Hook

var event : int
var caster
var caster_type : int
var once : bool

func _init(_event : int, _caster, _caster_type : int, _once : bool) -> void:
	event = _event
	caster = _caster
	caster_type = _caster_type
	once = _once
