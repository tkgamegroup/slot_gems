extends Control

@onready var tilemap : TileMapLayer = $TileMapLayer
@onready var exp_bar : ProgressBar = $ProgressBar

var pattern : Pattern = null
var coords : Array[Vector3i]

func setup(_pattern : Pattern,):
	pattern = _pattern
	
	coords = pattern.get_ui_coords()

func _ready() -> void:
	for c in coords:
		var cc = Board.cube_to_oddq(c)
		tilemap.set_cell(cc, 0, Vector2i(0, 0))
	self.mouse_entered.connect(func():
		STooltip.show(pattern.get_tooltip())
	)
	self.mouse_exited.connect(func():
		STooltip.close()
	)
