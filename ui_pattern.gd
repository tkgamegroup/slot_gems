extends Control

@onready var tilemap : TileMapLayer = $TileMapLayer
@onready var exp_bar : ProgressBar = $ProgressBar

var pattern : Pattern = null
var coord_groups : Array[Array]
var no_exp_bar : bool
var tt_dir : int = 0
var elastic : float = 1.0

func setup(_pattern : Pattern, _no_exp_bar : bool = false, _tt_dir : int = 0):
	pattern = _pattern
	
	coord_groups = pattern.get_ui_coords()
	no_exp_bar = _no_exp_bar
	tt_dir = _tt_dir

func _ready() -> void:
	for i in coord_groups.size():
		for c in coord_groups[i]:
			var cc = Board.cube_to_oddq(c)
			tilemap.set_cell(cc, 2 + i, Vector2i(0, 0))
	if no_exp_bar || true:
		exp_bar.hide()
	self.mouse_entered.connect(func():
		SSound.se_select.play()
		STooltip.show(self, tt_dir, pattern.get_tooltip())
	)
	self.mouse_exited.connect(func():
		STooltip.close()
	)
