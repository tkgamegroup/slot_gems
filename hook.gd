extends Object

class_name Hook

var event : int
var host
var host_type : int
var once : bool

func _init(_event : int, _host, _host_type : int, _once : bool) -> void:
	event = _event
	host = _host
	host_type = _host_type
	once = _once
