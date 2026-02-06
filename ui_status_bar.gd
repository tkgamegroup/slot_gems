extends PanelContainer

const NumberText = preload("res://number_text.gd")

@onready var score_container : Control = $HBoxContainer/VBoxContainer
@onready var score_text : Label = $HBoxContainer/VBoxContainer/Score
@onready var red_bouns_container : Control = $HBoxContainer/HBoxContainer/Control
@onready var red_bouns_text : NumberText = $HBoxContainer/HBoxContainer/Control/NumberText
@onready var orange_bouns_container : Control = $HBoxContainer/HBoxContainer/Control2
@onready var orange_bouns_text : NumberText = $HBoxContainer/HBoxContainer/Control2/NumberText
@onready var green_bouns_container : Control = $HBoxContainer/HBoxContainer/Control3
@onready var green_bouns_text : NumberText = $HBoxContainer/HBoxContainer/Control3/NumberText
@onready var blue_bouns_container : Control = $HBoxContainer/HBoxContainer/Control4
@onready var blue_bouns_text : NumberText = $HBoxContainer/HBoxContainer/Control4/NumberText
@onready var magenta_bouns_container : Control = $HBoxContainer/HBoxContainer/Control5
@onready var magenta_bouns_text : NumberText = $HBoxContainer/HBoxContainer/Control5/NumberText
@onready var round_container : Control = $HBoxContainer/VBoxContainer4
@onready var round_text : RichTextLabel = $HBoxContainer/VBoxContainer4/Round
@onready var round_target : RichTextLabel = $HBoxContainer/VBoxContainer4/Target
@onready var board_size_container : Control = $HBoxContainer/HBoxContainer4
@onready var board_size_text : NumberText = $HBoxContainer/HBoxContainer4/BoardSize
@onready var hand_container : Control = $HBoxContainer/HBoxContainer5
@onready var hand_text : NumberText = $HBoxContainer/HBoxContainer5/Hand
@onready var coins_container : Control = $HBoxContainer/HBoxContainer2
@onready var coins_text : NumberText = $HBoxContainer/HBoxContainer2/Coins
@onready var info_button : Button = $HBoxContainer/HBoxContainer3/Info
@onready var bag_button : Button = $HBoxContainer/HBoxContainer3/HBoxContainer/Bag
@onready var gem_count_text : Label = $HBoxContainer/HBoxContainer3/HBoxContainer/VBoxContainer/Label
@onready var gem_count_limit_text : Label = $HBoxContainer/HBoxContainer3/HBoxContainer/VBoxContainer/Label2
@onready var gear_button : Button = $HBoxContainer/HBoxContainer3/Gear
@onready var tutorial_button : Button = $HBoxContainer/HBoxContainer3/Tutorial

func _ready() -> void:
	red_bouns_container.mouse_entered.connect(func():
		STooltip.show(red_bouns_container, 0, [Pair.new(tr("tt_red_base_score"), "%d" % G.modifiers["red_bouns_i"])])
	)
	red_bouns_container.mouse_exited.connect(func():
		STooltip.close()
	)
	orange_bouns_container.mouse_entered.connect(func():
		STooltip.show(orange_bouns_container, 0, [Pair.new(tr("tt_orange_base_score"), "%d" % G.modifiers["orange_bouns_i"])])
	)
	orange_bouns_container.mouse_exited.connect(func():
		STooltip.close()
	)
	green_bouns_container.mouse_entered.connect(func():
		STooltip.show(green_bouns_container, 0, [Pair.new(tr("tt_green_base_score"), "%d" % G.modifiers["green_bouns_i"])])
	)
	green_bouns_container.mouse_exited.connect(func():
		STooltip.close()
	)
	blue_bouns_container.mouse_entered.connect(func():
		STooltip.show(blue_bouns_container, 0, [Pair.new(tr("tt_blue_base_score"), "%d" % G.modifiers["blue_bouns_i"])])
	)
	blue_bouns_container.mouse_exited.connect(func():
		STooltip.close()
	)
	magenta_bouns_container.mouse_entered.connect(func():
		STooltip.show(magenta_bouns_container, 0, [Pair.new(tr("tt_magenta_base_score"), "%d" % G.modifiers["magenta_bouns_i"])])
	)
	magenta_bouns_container.mouse_exited.connect(func():
		STooltip.close()
	)
	score_container.mouse_entered.connect(func():
		STooltip.close()
	)
	round_container.mouse_entered.connect(func():
		STooltip.close()
	)
	board_size_container.mouse_entered.connect(func():
		STooltip.show(board_size_container, 3, [Pair.new(tr("tt_game_board_size_title"), tr("tt_game_board_size_content"))])
	)
	hand_container.mouse_entered.connect(func():
		STooltip.show(hand_container, 3, [Pair.new(tr("tt_game_hand_title"), tr("tt_game_hand_content") % G.max_hand_grabs)])
	)
	coins_container.mouse_entered.connect(func():
		STooltip.show(coins_container, 3, [Pair.new(tr("tt_game_coins_title"), "%d" % G.coins)])
	)
	coins_container.mouse_exited.connect(func():
		STooltip.close()
	)
	info_button.pressed.connect(func():
		SSound.se_click.play()
		G.screen_shake_strength = 8.0
		G.run_info_ui.enter()
	)
	info_button.mouse_entered.connect(func():
		STooltip.show(bag_button, 3, [Pair.new(tr("tt_game_info_title"), "")])
	)
	info_button.mouse_exited.connect(func():
		STooltip.close()
	)
	bag_button.pressed.connect(func():
		if !G.bag_viewer_ui.visible:
			STooltip.close()
			SSound.se_open_bag.play()
			G.screen_shake_strength = 8.0
			G.bag_viewer_ui.enter()
		else:
			SSound.se_close_bag.play()
			G.bag_viewer_ui.exit()
	)
	bag_button.mouse_entered.connect(func():
		STooltip.show(bag_button, 3, [Pair.new(tr("tt_game_bag_title"), tr("tt_game_bag_content"))])
	)
	bag_button.mouse_exited.connect(func():
		STooltip.close()
	)
	Drag.add_target("gem", bag_button, func(payload, ev : String, extra : Dictionary):
		if ev == "peek":
			#Drag.ui.action.show()
			STooltip.show(bag_button, 3, [Pair.new(tr("tt_game_bag_title"), tr("tt_game_bag_trade_content"))])
		elif ev == "peek_exited":
			#if Drag.ui:
			#	Drag.ui.action.hide()
			STooltip.close()
		else:
			pass
			# trade
			#G.put_back_gem_to_bag(dragging.gem)
			#Hand.draw()
	)
	gem_count_text.mouse_entered.connect(func():
		STooltip.show(gem_count_text, 3, [Pair.new(tr("tt_game_gem_number"), "%d" % G.gems.size())])
	)
	gem_count_text.mouse_exited.connect(func():
		STooltip.close()
	)
	gem_count_limit_text.mouse_entered.connect(func():
		STooltip.show(gem_count_limit_text, 3, [Pair.new("", tr("tt_game_upgrade_number_and_min_number") % [Board.next_min_gem_num, Board.curr_min_gem_num])])
	)
	gem_count_limit_text.mouse_exited.connect(func():
		STooltip.close()
	)
	gear_button.pressed.connect(func():
		SSound.se_click.play()
		G.screen_shake_strength = 8.0
		G.toggle_in_game_menu()
	)
	gear_button.mouse_entered.connect(func():
		STooltip.show(gear_button, 3, [Pair.new(tr("tt_game_menu_title"), "")])
	)
	gear_button.mouse_exited.connect(func():
		STooltip.close()
	)
	tutorial_button.pressed.connect(func():
		SSound.se_click.play()
		G.screen_shake_strength = 8.0
		G.tutorial_ui.enter()
	)
	tutorial_button.mouse_entered.connect(func():
		STooltip.show(tutorial_button, 3, [Pair.new(tr("tt_game_tutorial"), "")])
	)
	tutorial_button.mouse_exited.connect(func():
		STooltip.close()
	)
