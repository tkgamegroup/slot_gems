extends PanelContainer

var float_island = FloatIsland.new()

func _ready() -> void:
	float_island.setup(self, 2.0, 0.1, 0.2)

func _process(delta: float) -> void:
	float_island.update(delta)
