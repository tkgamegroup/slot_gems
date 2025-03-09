extends Node

@onready var sfx_bus_index = AudioServer.get_bus_index("SFX")
@onready var music_bus_index = AudioServer.get_bus_index("Music")

@onready var sfx_select : AudioStreamPlayer = $/root/Main/SFX/Select
@onready var sfx_click : AudioStreamPlayer = $/root/Main/SFX/Click
@onready var sfx_board_setup : AudioStreamPlayer = $/root/Main/SFX/BoardSetup
@onready var sfx_slot_button : AudioStreamPlayer = $/root/Main/SFX/Slot
@onready var sfx_roll : AudioStreamPlayer = $/root/Main/SFX/Roll
@onready var sfx_coin : AudioStreamPlayer = $/root/Main/SFX/Coin
@onready var sfx_tom : AudioStreamPlayer = $/root/Main/SFX/Tom
@onready var sfx_zap : AudioStreamPlayer = $/root/Main/SFX/Zap
@onready var sfx_brush : AudioStreamPlayer = $/root/Main/SFX/Brush
@onready var sfx_vibra : AudioStreamPlayer = $/root/Main/SFX/Vibra
@onready var sfx_bubble : AudioStreamPlayer = $/root/Main/SFX/Bubble
@onready var sfx_explode : AudioStreamPlayer = $/root/Main/SFX/Explode
@onready var sfx_lightning_connect : AudioStreamPlayer = $/root/Main/SFX/LightningConnect
@onready var sfx_lightning_fail : AudioStreamPlayer = $/root/Main/SFX/LightningFail
@onready var sfx_start_buring : AudioStreamPlayer = $/root/Main/SFX/StartBurning
@onready var sfx_end_buring : AudioStreamPlayer = $/root/Main/SFX/EndBurning
@onready var sfx_level_clear : AudioStreamPlayer = $/root/Main/SFX/LevelClear
@onready var music : AudioStreamPlayer = $/root/Main/Music

func _ready() -> void:
	music.finished.connect(func():
		music.play()
	)
