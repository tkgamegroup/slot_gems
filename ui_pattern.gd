extends Control

@onready var tilemap : TileMapLayer = $TileMapLayer
@onready var exp_bar : ProgressBar = $ProgressBar

var pattern : Pattern = null
var coords : Array[Vector3i]
var no_exp_bar : bool

func setup(_pattern : Pattern, _no_exp_bar : bool = false):
	pattern = _pattern
	
	coords = pattern.get_ui_coords()
	no_exp_bar = _no_exp_bar

func _ready() -> void:
	for c in coords:
		var cc = Board.cube_to_oddq(c)
		tilemap.set_cell(cc, 0, Vector2i(0, 0))
	if no_exp_bar:
		exp_bar.hide()
	self.mouse_entered.connect(func():
		STooltip.show(pattern.get_tooltip())
	)
	self.mouse_exited.connect(func():
		STooltip.close()
	)
