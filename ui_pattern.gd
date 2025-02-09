extends Control

@onready var tilemap : TileMapLayer = $TileMapLayer

var coords : Array[Vector3i]

func setup(_coords : Array[Vector3i]):
	var y_min = 4
	var y_max = 0
	for c in _coords:
		y_min = min(y_min, c.y)
		y_max = min(y_max, c.y)
	coords = _coords
	if y_min < 0:
		for i in coords.size():
			coords[i].y += -y_min
			coords[i].z += y_min

func _ready() -> void:
	for c in coords:
		var cc = Board.cube_to_offset(c)
		tilemap.set_cell(cc, 0, Vector2i(0, 0))
