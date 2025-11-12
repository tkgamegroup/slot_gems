extends Control

@onready var tilemap : TileMapLayer = $TileMapLayer
@onready var exp_bar : ProgressBar = $ProgressBar

var pattern : Pattern = null
var coord_groups : Array[Array]
var no_exp_bar : bool

func setup(_pattern : Pattern, _no_exp_bar : bool = false):
	pattern = _pattern
	
	coord_groups = pattern.get_ui_coords()
	no_exp_bar = _no_exp_bar

func _ready() -> void:
	for i in coord_groups.size():
		for c in coord_groups[i]:
			var cc = Board.cube_to_oddq(c)
			tilemap.set_cell(cc, 2 + i, Vector2i(0, 0))
	if no_exp_bar || true:
		exp_bar.hide()
