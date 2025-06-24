extends PanelContainer

const NumberText = preload("res://number_text.gd")

@onready var score_container : Control = $HBoxContainer/VBoxContainer
@onready var score_text : Label = $HBoxContainer/VBoxContainer/Score
@onready var red_bouns_container : Control = $HBoxContainer/VBoxContainer2/HBoxContainer/HBoxContainer
@onready var red_bouns_text : Label = $HBoxContainer/VBoxContainer2/HBoxContainer/HBoxContainer/Label2
@onready var orange_bouns_container : Control = $HBoxContainer/VBoxContainer2/HBoxContainer/HBoxContainer2
@onready var orange_bouns_text : Label = $HBoxContainer/VBoxContainer2/HBoxContainer/HBoxContainer2/Label2
@onready var green_bouns_container : Control = $HBoxContainer/VBoxContainer2/HBoxContainer/HBoxContainer3
@onready var green_bouns_text : Label = $HBoxContainer/VBoxContainer2/HBoxContainer/HBoxContainer3/Label2
@onready var blue_bouns_container : Control = $HBoxContainer/VBoxContainer2/HBoxContainer2/HBoxContainer
@onready var blue_bouns_text : Label = $HBoxContainer/VBoxContainer2/HBoxContainer2/HBoxContainer/Label2
@onready var pink_bouns_container : Control = $HBoxContainer/VBoxContainer2/HBoxContainer2/HBoxContainer2
@onready var pink_bouns_text : Label = $HBoxContainer/VBoxContainer2/HBoxContainer2/HBoxContainer2/Label2
@onready var level_container : Control = $HBoxContainer/VBoxContainer4
@onready var level_text : Label = $HBoxContainer/VBoxContainer4/Level
@onready var level_target : RichTextLabel = $HBoxContainer/VBoxContainer4/Target
@onready var board_size_container : Control = $HBoxContainer/HBoxContainer
@onready var board_size_text : NumberText = $HBoxContainer/HBoxContainer/BoardSize
@onready var hand_container : Control = $HBoxContainer/HBoxContainer4
@onready var hand_text : NumberText = $HBoxContainer/HBoxContainer4/Hand
@onready var coins_container : Control = $HBoxContainer/HBoxContainer2
@onready var coins_text : NumberText = $HBoxContainer/HBoxContainer2/Coins
@onready var bag_button : Button = $HBoxContainer/HBoxContainer3/Control/Bag
@onready var gem_count_text : Label = $HBoxContainer/HBoxContainer3/Control/VBoxContainer/Label
@onready var gem_count_limit_text : Label = $HBoxContainer/HBoxContainer3/Control/VBoxContainer/Label2
@onready var gear_button : Button = $HBoxContainer/HBoxContainer3/Gear

func _ready() -> void:
	red_bouns_container.mouse_entered.connect(func():
		STooltip.show([Pair.new("Red Bouns", "%d" % Game.modifiers["red_bouns_i"])])
	)
	red_bouns_container.mouse_exited.connect(func():
		STooltip.close()
	)
	orange_bouns_container.mouse_entered.connect(func():
		STooltip.show([Pair.new("Orange Bouns", "%d" % Game.modifiers["orange_bouns_i"])])
	)
	orange_bouns_container.mouse_exited.connect(func():
		STooltip.close()
	)
	green_bouns_container.mouse_entered.connect(func():
		STooltip.show([Pair.new("Green Bouns", "%d" % Game.modifiers["green_bouns_i"])])
	)
	green_bouns_container.mouse_exited.connect(func():
		STooltip.close()
	)
	blue_bouns_container.mouse_entered.connect(func():
		STooltip.show([Pair.new("Blue Bouns", "%d" % Game.modifiers["blue_bouns_i"])])
	)
	blue_bouns_container.mouse_exited.connect(func():
		STooltip.close()
	)
	pink_bouns_container.mouse_entered.connect(func():
		STooltip.show([Pair.new("Pink Bouns", "%d" % Game.modifiers["pink_bouns_i"])])
	)
	pink_bouns_container.mouse_exited.connect(func():
		STooltip.close()
	)
	score_container.mouse_entered.connect(func():
		STooltip.close()
	)
	level_container.mouse_entered.connect(func():
		STooltip.close()
	)
	board_size_container.mouse_entered.connect(func():
		STooltip.show([Pair.new(tr("tt_game_board_size_title"), tr("tt_game_board_size_content"))])
	)
	hand_container.mouse_entered.connect(func():
		STooltip.show([Pair.new(tr("tt_game_hand_title"), tr("tt_game_hand_content") % Game.max_hand_grabs)])
	)
	coins_container.mouse_entered.connect(func():
		STooltip.show([Pair.new(tr("tt_game_coins_title"), "")])
	)
	coins_container.mouse_exited.connect(func():
		STooltip.close()
	)
	bag_button.pressed.connect(func():
		if !Game.bag_viewer_ui.visible:
			STooltip.close()
			SSound.se_open_bag.play()
			Game.bag_viewer_ui.enter()
		else:
			SSound.se_close_bag.play()
			Game.bag_viewer_ui.exit()
	)
	bag_button.mouse_entered.connect(func():
		STooltip.show([Pair.new(tr("tt_game_bag_title"), tr("tt_game_bag_content"))])
	)
	bag_button.mouse_exited.connect(func():
		STooltip.close()
	)
	Drag.add_target("gem", bag_button, func(payload, ev : String, extra : Dictionary):
		if ev == "peek":
			#Drag.ui.action.show()
			STooltip.show([Pair.new(tr("tt_game_bag_title"), tr("tt_game_bag_trade_content"))])
		elif ev == "peek_exited":
			#if Drag.ui:
			#	Drag.ui.action.hide()
			STooltip.close()
		else:
			pass
			# trade
			#Game.release_gem(dragging.gem)
			#Hand.draw()
	)
	gem_count_text.mouse_entered.connect(func():
		STooltip.show([Pair.new("Gem Count", "%d" % Game.gems.size())])
	)
	gem_count_text.mouse_exited.connect(func():
		STooltip.close()
	)
	gem_count_limit_text.mouse_entered.connect(func():
		STooltip.show([Pair.new("Gem Count Limit", "Upgrade Board Need Gems: %d\nMinimum Gems: %d" % [Board.next_min_gem_num, Board.curr_min_gem_num])])
	)
	gem_count_limit_text.mouse_exited.connect(func():
		STooltip.close()
	)
	gear_button.pressed.connect(func():
		SSound.se_click.play()
		Game.toggle_in_game_menu()
	)
	gear_button.mouse_entered.connect(func():
		STooltip.show([Pair.new(tr("tt_game_menu_title"), "")])
	)
	gear_button.mouse_exited.connect(func():
		STooltip.close()
	)
