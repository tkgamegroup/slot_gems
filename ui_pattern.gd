extends Control

@onready var tilemap : TileMapLayer = $TileMapLayer
@onready var exp_bar : ProgressBar = $ProgressBar

var pattern : Pattern = null
var coords : Array[Vector3i]

func setup(_pattern : Pattern):
	pattern = _pattern
	
	var y_min = 4
	var y_max = 0
	for c in pattern.coords:
		y_min = min(y_min, c.y)
		y_max = min(y_max, c.y)
	coords = pattern.coords.duplicate()
	if y_min < 0:
		for i in coords.size():
			coords[i].y += -y_min
			coords[i].z += y_min

func _ready() -> void:
	for c in coords:
		var cc = Board.cube_to_offset(c)
		tilemap.set_cell(cc, 0, Vector2i(0, 0))
	self.mouse_entered.connect(func():
		STooltip.show([Pair.new("Pattern", "LV: %d\nExp: %d/%d\nMult: %d" % [pattern.lv, pattern.exp, pattern.max_exp, pattern.mult])], 0.05)
	)
	self.mouse_exited.connect(func():
		STooltip.close()
	)
