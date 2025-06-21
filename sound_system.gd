extends Node

@onready var se_bus_index = AudioServer.get_bus_index("SFX")
@onready var music_bus_index = AudioServer.get_bus_index("Music")

@onready var se_select : AudioStreamPlayer = $/root/Main/SFX/Select
@onready var se_click : AudioStreamPlayer = $/root/Main/SFX/Click
@onready var se_board_setup : AudioStreamPlayer = $/root/Main/SFX/BoardSetup
@onready var se_slot_button : AudioStreamPlayer = $/root/Main/SFX/Slot
@onready var se_roll : AudioStreamPlayer = $/root/Main/SFX/Roll
@onready var se_coin : AudioStreamPlayer = $/root/Main/SFX/Coin
@onready var se_tom : AudioStreamPlayer = $/root/Main/SFX/Tom
@onready var se_zap : AudioStreamPlayer = $/root/Main/SFX/Zap
@onready var se_brush : AudioStreamPlayer = $/root/Main/SFX/Brush
@onready var se_vibra : AudioStreamPlayer = $/root/Main/SFX/Vibra
@onready var se_bubble : AudioStreamPlayer = $/root/Main/SFX/Bubble
@onready var se_calc1 : AudioStreamPlayer = $/root/Main/SFX/Calc1
@onready var se_calc2 : AudioStreamPlayer = $/root/Main/SFX/Calc2
@onready var se_score_counting : AudioStreamPlayer = $/root/Main/SFX/ScoreCounting
@onready var se_enchant : AudioStreamPlayer = $/root/Main/SFX/Enchant
@onready var se_trash : AudioStreamPlayer = $/root/Main/SFX/Trash
@onready var se_open_bag : AudioStreamPlayer = $/root/Main/SFX/OpenBag
@onready var se_close_bag : AudioStreamPlayer = $/root/Main/SFX/CloseBag
@onready var se_drag_item : AudioStreamPlayer = $/root/Main/SFX/DragItem
@onready var se_drop_item : AudioStreamPlayer = $/root/Main/SFX/DropItem
@onready var se_skill : AudioStreamPlayer = $/root/Main/SFX/Skill
@onready var se_explode : AudioStreamPlayer = $/root/Main/SFX/Explode
@onready var se_lightning_connect : AudioStreamPlayer = $/root/Main/SFX/LightningConnect
@onready var se_lightning_fail : AudioStreamPlayer = $/root/Main/SFX/LightningFail
@onready var se_start_buring : AudioStreamPlayer = $/root/Main/SFX/StartBurning
@onready var se_end_buring : AudioStreamPlayer = $/root/Main/SFX/EndBurning
@onready var se_level_clear : AudioStreamPlayer = $/root/Main/SFX/LevelClear
@onready var se_well_done : AudioStreamPlayer = $/root/Main/SFX/WellDone
@onready var music : AudioStreamPlayer = $/root/Main/Music

var se_marimba_scale : Array[AudioStreamPlayer]

func _ready() -> void:
	se_marimba_scale.append($/root/Main/SFX/Marimba1)
	se_marimba_scale.append($/root/Main/SFX/Marimba2)
	se_marimba_scale.append($/root/Main/SFX/Marimba3)
	se_marimba_scale.append($/root/Main/SFX/Marimba4)
	se_marimba_scale.append($/root/Main/SFX/Marimba5)
	se_marimba_scale.append($/root/Main/SFX/Marimba6)
	se_marimba_scale.append($/root/Main/SFX/Marimba7)
	se_marimba_scale.append($/root/Main/SFX/Marimba8)
	music.finished.connect(func():
		music.play()
	)
