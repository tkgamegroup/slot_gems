extends PanelContainer

const NumberText = preload("res://number_text.gd")

@onready var score_container : Control = $HBoxContainer/VBoxContainer
@onready var score_text : Label = $HBoxContainer/VBoxContainer/Score
@onready var red_bouns_container : Control = $HBoxContainer/VBoxContainer2/HBoxContainer/HBoxContainer
@onready var red_bouns_text : NumberText = $HBoxContainer/VBoxContainer2/HBoxContainer/HBoxContainer/NumberText
@onready var orange_bouns_container : Control = $HBoxContainer/VBoxContainer2/HBoxContainer/HBoxContainer2
@onready var orange_bouns_text : NumberText = $HBoxContainer/VBoxContainer2/HBoxContainer/HBoxContainer2/NumberText
@onready var green_bouns_container : Control = $HBoxContainer/VBoxContainer2/HBoxContainer/HBoxContainer3
@onready var green_bouns_text : NumberText = $HBoxContainer/VBoxContainer2/HBoxContainer/HBoxContainer3/NumberText
@onready var blue_bouns_container : Control = $HBoxContainer/VBoxContainer2/HBoxContainer2/HBoxContainer
@onready var blue_bouns_text : NumberText = $HBoxContainer/VBoxContainer2/HBoxContainer2/HBoxContainer/NumberText
@onready var magenta_bouns_container : Control = $HBoxContainer/VBoxContainer2/HBoxContainer2/HBoxContainer2
@onready var magenta_bouns_text : NumberText = $HBoxContainer/VBoxContainer2/HBoxContainer2/HBoxContainer2/NumberText
@onready var round_container : Control = $HBoxContainer/VBoxContainer4
@onready var round_text : RichTextLabel = $HBoxContainer/VBoxContainer4/Round
@onready var round_target : RichTextLabel = $HBoxContainer/VBoxContainer4/Target
@onready var cluster_round1_ctrl : Control = $HBoxContainer/VBoxContainer4/HBoxContainer2/Control
@onready var cluster_round1_sp : AnimatedSprite2D = $HBoxContainer/VBoxContainer4/HBoxContainer2/Control/AnimatedSprite2D
@onready var cluster_round2_ctrl : Control = $HBoxContainer/VBoxContainer4/HBoxContainer2/Control2
@onready var cluster_round2_sp : AnimatedSprite2D = $HBoxContainer/VBoxContainer4/HBoxContainer2/Control2/AnimatedSprite2D
@onready var cluster_round3_ctrl : Control = $HBoxContainer/VBoxContainer4/HBoxContainer2/Control3
@onready var cluster_round3_sp : AnimatedSprite2D = $HBoxContainer/VBoxContainer4/HBoxContainer2/Control3/AnimatedSprite2D
@onready var cluster_round_ctrls = [cluster_round1_ctrl, cluster_round2_ctrl, cluster_round3_ctrl] 
@onready var cluster_round_sps = [cluster_round1_sp, cluster_round2_sp, cluster_round3_sp] 
@onready var board_size_container : Control = $HBoxContainer/VBoxContainer3/HBoxContainer
@onready var board_size_text : NumberText = $HBoxContainer/VBoxContainer3/HBoxContainer/BoardSize
@onready var hand_container : Control = $HBoxContainer/VBoxContainer3/HBoxContainer4
@onready var hand_text : NumberText = $HBoxContainer/VBoxContainer3/HBoxContainer4/Hand
@onready var coins_container : Control = $HBoxContainer/HBoxContainer2
@onready var coins_text : NumberText = $HBoxContainer/HBoxContainer2/Coins
@onready var bag_button : Button = $HBoxContainer/HBoxContainer3/Control/Bag
@onready var gem_count_text : Label = $HBoxContainer/HBoxContainer3/Control/VBoxContainer/Label
@onready var gem_count_limit_text : Label = $HBoxContainer/HBoxContainer3/Control/VBoxContainer/Label2
@onready var gear_button : Button = $HBoxContainer/HBoxContainer3/Gear
@onready var tutorial_button : Button = $HBoxContainer/HBoxContainer3/Tutorial

func _ready() -> void:
	red_bouns_container.mouse_entered.connect(func():
		STooltip.show(red_bouns_container, 0, [Pair.new(tr("tt_red_base_score"), "%d" % App.modifiers["red_bouns_i"])])
	)
	red_bouns_container.mouse_exited.connect(func():
		STooltip.close()
	)
	orange_bouns_container.mouse_entered.connect(func():
		STooltip.show(orange_bouns_container, 0, [Pair.new(tr("tt_orange_base_score"), "%d" % App.modifiers["orange_bouns_i"])])
	)
	orange_bouns_container.mouse_exited.connect(func():
		STooltip.close()
	)
	green_bouns_container.mouse_entered.connect(func():
		STooltip.show(green_bouns_container, 0, [Pair.new(tr("tt_green_base_score"), "%d" % App.modifiers["green_bouns_i"])])
	)
	green_bouns_container.mouse_exited.connect(func():
		STooltip.close()
	)
	blue_bouns_container.mouse_entered.connect(func():
		STooltip.show(blue_bouns_container, 0, [Pair.new(tr("tt_blue_base_score"), "%d" % App.modifiers["blue_bouns_i"])])
	)
	blue_bouns_container.mouse_exited.connect(func():
		STooltip.close()
	)
	magenta_bouns_container.mouse_entered.connect(func():
		STooltip.show(magenta_bouns_container, 0, [Pair.new(tr("tt_magenta_base_score"), "%d" % App.modifiers["magenta_bouns_i"])])
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
	cluster_round1_ctrl.mouse_entered.connect(func():
		var r = App.round
		if !App.shop_ui.visible:
			r -= 1
		r = int(r / 3) * 3 + 1
		STooltip.show(cluster_round1_ctrl, 0, [Pair.new(App.get_round_title(r, App.get_round_reward(r)), App.get_round_desc(App.get_round_score(r), App.round_curses[r - 1] if !App.round_curses.is_empty() else ([] as Array[Curse])))])
	)
	cluster_round1_ctrl.mouse_exited.connect(func():
		STooltip.close()
	)
	cluster_round2_ctrl.mouse_entered.connect(func():
		var r = App.round
		if !App.shop_ui.visible:
			r -= 1
		r = int(r / 3) * 3 + 2
		STooltip.show(cluster_round2_ctrl, 0, [Pair.new(App.get_round_title(r, App.get_round_reward(r)), App.get_round_desc(App.get_round_score(r), App.round_curses[r - 1] if !App.round_curses.is_empty() else ([] as Array[Curse])))])
	)
	cluster_round2_ctrl.mouse_exited.connect(func():
		STooltip.close()
	)
	cluster_round3_ctrl.mouse_entered.connect(func():
		var r = App.round
		if !App.shop_ui.visible:
			r -= 1
		r = int(r / 3) * 3 + 3
		STooltip.show(cluster_round3_ctrl, 0, [Pair.new(App.get_round_title(r, App.get_round_reward(r)), App.get_round_desc(App.get_round_score(r), App.round_curses[r - 1] if !App.round_curses.is_empty() else ([] as Array[Curse])))])
	)
	cluster_round3_ctrl.mouse_exited.connect(func():
		STooltip.close()
	)
	board_size_container.mouse_entered.connect(func():
		STooltip.show(board_size_container, 3, [Pair.new(tr("tt_game_board_size_title"), tr("tt_game_board_size_content"))])
	)
	hand_container.mouse_entered.connect(func():
		STooltip.show(hand_container, 3, [Pair.new(tr("tt_game_hand_title"), tr("tt_game_hand_content") % App.max_hand_grabs)])
	)
	coins_container.mouse_entered.connect(func():
		STooltip.show(coins_container, 3, [Pair.new(tr("tt_game_coins_title"), "%d" % App.coins)])
	)
	coins_container.mouse_exited.connect(func():
		STooltip.close()
	)
	bag_button.pressed.connect(func():
		if !App.bag_viewer_ui.visible:
			STooltip.close()
			SSound.se_open_bag.play()
			App.screen_shake_strength = 8.0
			App.bag_viewer_ui.enter()
		else:
			SSound.se_close_bag.play()
			App.bag_viewer_ui.exit()
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
			#App.release_gem(dragging.gem)
			#Hand.draw()
	)
	gem_count_text.mouse_entered.connect(func():
		STooltip.show(gem_count_text, 3, [Pair.new(tr("tt_game_gem_number"), "%d" % App.gems.size())])
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
		App.screen_shake_strength = 8.0
		App.toggle_in_game_menu()
	)
	gear_button.mouse_entered.connect(func():
		STooltip.show(gear_button, 3, [Pair.new(tr("tt_game_menu_title"), "")])
	)
	gear_button.mouse_exited.connect(func():
		STooltip.close()
	)
	tutorial_button.pressed.connect(func():
		SSound.se_click.play()
		App.screen_shake_strength = 8.0
		App.tutorial_ui.enter()
	)
	tutorial_button.mouse_entered.connect(func():
		STooltip.show(tutorial_button, 3, [Pair.new(tr("tt_game_tutorial"), "")])
	)
	tutorial_button.mouse_exited.connect(func():
		STooltip.close()
	)
