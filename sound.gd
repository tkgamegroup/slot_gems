extends Node

@onready var sfx_bus_index = AudioServer.get_bus_index("SFX")
@onready var music_bus_index = AudioServer.get_bus_index("Music")

@onready var sfx_select : AudioStreamPlayer = $Select
@onready var sfx_click : AudioStreamPlayer = $Click
@onready var sfx_board_setup : AudioStreamPlayer = $BoardSetup
@onready var sfx_slot_button : AudioStreamPlayer = $Slot
@onready var sfx_roll : AudioStreamPlayer = $Roll
@onready var sfx_tom : AudioStreamPlayer = $Tom
@onready var sfx_zap : AudioStreamPlayer = $Zap
@onready var sfx_brush : AudioStreamPlayer = $Brush
@onready var sfx_vibra : AudioStreamPlayer = $Vibra
@onready var sfx_explode : AudioStreamPlayer = $Explode
@onready var sfx_lighting_connect : AudioStreamPlayer = $LightingConnect
@onready var sfx_lighting_fail : AudioStreamPlayer = $LightingFail
@onready var sfx_start_buring : AudioStreamPlayer = $StartBurning
@onready var sfx_end_buring : AudioStreamPlayer = $EndBurning
@onready var sfx_level_clear : AudioStreamPlayer = $LevelClear
@onready var music : AudioStreamPlayer = $Music

func _ready() -> void:
	music.finished.connect(func():
		music.play()
	)
