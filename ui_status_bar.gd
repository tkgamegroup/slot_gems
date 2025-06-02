extends PanelContainer

@onready var score_text : Label = $HBoxContainer/VBoxContainer/Score
@onready var red_bouns_text : Label = $HBoxContainer/VBoxContainer2/HBoxContainer/HBoxContainer/Label2
@onready var orange_bouns_text : Label = $HBoxContainer/VBoxContainer2/HBoxContainer/HBoxContainer2/Label2
@onready var green_bouns_text : Label = $HBoxContainer/VBoxContainer2/HBoxContainer/HBoxContainer3/Label2
@onready var blue_bouns_text : Label = $HBoxContainer/VBoxContainer2/HBoxContainer2/HBoxContainer/Label2
@onready var pink_bouns_text : Label = $HBoxContainer/VBoxContainer2/HBoxContainer2/HBoxContainer2/Label2
@onready var level_text : Label = $HBoxContainer/VBoxContainer4/Level
@onready var level_target : RichTextLabel = $HBoxContainer/VBoxContainer4/Target
@onready var board_size_container : Control = $HBoxContainer/HBoxContainer
@onready var board_size_text : Label = $HBoxContainer/HBoxContainer/BoardSize
@onready var hand_metrics_container : Control = $HBoxContainer/HBoxContainer4
@onready var hand_metrics_text : Label = $HBoxContainer/HBoxContainer4/HandMetrics
@onready var coin_container : Control = $HBoxContainer/HBoxContainer2
@onready var coin_text : Label = $HBoxContainer/HBoxContainer2/Coin
@onready var bag_button : Button = $HBoxContainer/HBoxContainer3/Bag
@onready var gear_button : Button = $HBoxContainer/HBoxContainer3/Gear

func _ready() -> void:
	board_size_container.mouse_entered.connect(func():
		STooltip.show([Pair.new(tr("tt_game_board_size_title"), tr("tt_game_board_size_content"))])
	)
	hand_metrics_container.mouse_entered.connect(func():
		STooltip.show([Pair.new(tr("tt_game_hand_metrics_title"), tr("tt_game_hand_metrics_content") % [Game.draws_per_roll, Game.max_hand_grabs])])
	)
	coin_container.mouse_entered.connect(func():
		STooltip.show([Pair.new(tr("tt_game_coins_title"), "")])
	)
	coin_container.mouse_exited.connect(func():
		STooltip.close()
	)
	bag_button.pressed.connect(func():
		if !Game.bag_viewer_ui.visible:
			STooltip.close()
			SSound.sfx_open_bag.play()
			Game.bag_viewer_ui.enter()
		else:
			SSound.sfx_close_bag.play()
			Game.bag_viewer_ui.exit()
	)
	bag_button.mouse_entered.connect(func():
		if Game.hand_ui && Game.hand_ui.dragging && Game.hand_ui.dragging.item.tradeable:
			Game.hand_ui.dragging.action.show()
			STooltip.show([Pair.new(tr("tt_game_bag_title"), tr("tt_game_bag_trade_content"))])
		else:
			STooltip.show([Pair.new(tr("tt_game_bag_title"), tr("tt_game_bag_content"))])
	)
	bag_button.mouse_exited.connect(func():
		if Game.hand_ui && Game.hand_ui.dragging:
			Game.hand_ui.dragging.action.hide()
		STooltip.close()
	)
	gear_button.pressed.connect(func():
		SSound.sfx_click.play()
		Game.toggle_in_game_menu()
	)
	gear_button.mouse_entered.connect(func():
		STooltip.show([Pair.new(tr("tt_game_menu_title"), "")])
	)
	gear_button.mouse_exited.connect(func():
		STooltip.close()
	)
