extends PanelContainer

@export var score_container : Control
@export var score_text : Label
@export var red_bouns_container : Control
@export var red_bouns_text : G.NumberText
@export var orange_bouns_container : Control
@export var orange_bouns_text : G.NumberText
@export var green_bouns_container : Control
@export var green_bouns_text : G.NumberText
@export var blue_bouns_container : Control
@export var blue_bouns_text : G.NumberText
@export var magenta_bouns_container : Control
@export var magenta_bouns_text : G.NumberText
@export var round_container : Control
@export var round_text : RichTextLabel
@export var round_target : RichTextLabel
@export var board_size_container : Control
@export var board_size_text : G.NumberText
@export var hand_container : Control
@export var hand_text : G.NumberText
@export var coins_container : Control
@export var coins_text : G.NumberText
@export var info_button : Button
@export var bag_button : Button
@export var gem_count_text : Label
@export var gem_count_limit_text : Label
@export var gear_button : Button
@export var guide_button : Button

func _ready() -> void:
	red_bouns_container.mouse_entered.connect(func():
		STooltip.show(red_bouns_container, 0, [Pair.new(tr("tt_red_base_score"), "%d" % G.attrs["red_bouns_i"])])
	)
	red_bouns_container.mouse_exited.connect(func():
		STooltip.close()
	)
	orange_bouns_container.mouse_entered.connect(func():
		STooltip.show(orange_bouns_container, 0, [Pair.new(tr("tt_orange_base_score"), "%d" % G.attrs["orange_bouns_i"])])
	)
	orange_bouns_container.mouse_exited.connect(func():
		STooltip.close()
	)
	green_bouns_container.mouse_entered.connect(func():
		STooltip.show(green_bouns_container, 0, [Pair.new(tr("tt_green_base_score"), "%d" % G.attrs["green_bouns_i"])])
	)
	green_bouns_container.mouse_exited.connect(func():
		STooltip.close()
	)
	blue_bouns_container.mouse_entered.connect(func():
		STooltip.show(blue_bouns_container, 0, [Pair.new(tr("tt_blue_base_score"), "%d" % G.attrs["blue_bouns_i"])])
	)
	blue_bouns_container.mouse_exited.connect(func():
		STooltip.close()
	)
	magenta_bouns_container.mouse_entered.connect(func():
		STooltip.show(magenta_bouns_container, 0, [Pair.new(tr("tt_magenta_base_score"), "%d" % G.attrs["magenta_bouns_i"])])
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
		STooltip.show(hand_container, 3, [Pair.new(tr("tt_game_hand_title"), tr("tt_game_hand_content") % G.hand_size)])
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
		STooltip.show(info_button, 3, [Pair.new(tr("tt_game_info_title"), "")])
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
			#G.put_to_bag(dragging.gem)
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
	guide_button.pressed.connect(func():
		SSound.se_click.play()
		G.screen_shake_strength = 8.0
		G.guide_ui.enter()
	)
	guide_button.mouse_entered.connect(func():
		STooltip.show(guide_button, 3, [Pair.new(tr("tt_game_guide"), "")])
	)
	guide_button.mouse_exited.connect(func():
		STooltip.close()
	)
