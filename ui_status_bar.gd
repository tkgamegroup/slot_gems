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
@onready var purple_bouns_container : Control = $HBoxContainer/VBoxContainer2/HBoxContainer2/HBoxContainer2
@onready var purple_bouns_text : NumberText = $HBoxContainer/VBoxContainer2/HBoxContainer2/HBoxContainer2/NumberText
@onready var level_container : Control = $HBoxContainer/VBoxContainer4
@onready var level_text : Label = $HBoxContainer/VBoxContainer4/Level
@onready var level_target : RichTextLabel = $HBoxContainer/VBoxContainer4/Target
@onready var cluster_level1_ctrl : Control = $HBoxContainer/VBoxContainer4/HBoxContainer2/Control
@onready var cluster_level1_sp : AnimatedSprite2D = $HBoxContainer/VBoxContainer4/HBoxContainer2/Control/AnimatedSprite2D
@onready var cluster_level2_ctrl : Control = $HBoxContainer/VBoxContainer4/HBoxContainer2/Control2
@onready var cluster_level2_sp : AnimatedSprite2D = $HBoxContainer/VBoxContainer4/HBoxContainer2/Control2/AnimatedSprite2D
@onready var cluster_level3_ctrl : Control = $HBoxContainer/VBoxContainer4/HBoxContainer2/Control3
@onready var cluster_level3_sp : AnimatedSprite2D = $HBoxContainer/VBoxContainer4/HBoxContainer2/Control3/AnimatedSprite2D
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
@onready var tutorial_button : Button = $HBoxContainer/HBoxContainer3/Tutorial

func _ready() -> void:
	red_bouns_container.mouse_entered.connect(func():
		STooltip.show([Pair.new(tr("tt_red_base_score"), "%d" % Game.modifiers["red_bouns_i"])])
	)
	red_bouns_container.mouse_exited.connect(func():
		STooltip.close()
	)
	orange_bouns_container.mouse_entered.connect(func():
		STooltip.show([Pair.new(tr("tt_orange_base_score"), "%d" % Game.modifiers["orange_bouns_i"])])
	)
	orange_bouns_container.mouse_exited.connect(func():
		STooltip.close()
	)
	green_bouns_container.mouse_entered.connect(func():
		STooltip.show([Pair.new(tr("tt_green_base_score"), "%d" % Game.modifiers["green_bouns_i"])])
	)
	green_bouns_container.mouse_exited.connect(func():
		STooltip.close()
	)
	blue_bouns_container.mouse_entered.connect(func():
		STooltip.show([Pair.new(tr("tt_blue_base_score"), "%d" % Game.modifiers["blue_bouns_i"])])
	)
	blue_bouns_container.mouse_exited.connect(func():
		STooltip.close()
	)
	purple_bouns_container.mouse_entered.connect(func():
		STooltip.show([Pair.new(tr("tt_purple_base_score"), "%d" % Game.modifiers["purple_bouns_i"])])
	)
	purple_bouns_container.mouse_exited.connect(func():
		STooltip.close()
	)
	score_container.mouse_entered.connect(func():
		STooltip.close()
	)
	level_container.mouse_entered.connect(func():
		STooltip.close()
	)
	cluster_level1_ctrl.mouse_entered.connect(func():
		var lv = Game.level
		if !Game.shop_ui.visible:
			lv -= 1
		lv = int(lv / 3) * 3 + 1
		STooltip.show([Pair.new(tr("ui_game_level") % lv, Game.get_level_desc(Game.get_level_score(lv), Game.get_level_reward(lv)))])
	)
	cluster_level1_ctrl.mouse_exited.connect(func():
		STooltip.close()
	)
	cluster_level2_ctrl.mouse_entered.connect(func():
		var lv = Game.level
		if !Game.shop_ui.visible:
			lv -= 1
		lv = int(lv / 3) * 3 + 2
		STooltip.show([Pair.new(tr("ui_game_level") % lv, Game.get_level_desc(Game.get_level_score(lv), Game.get_level_reward(lv)))])
	)
	cluster_level2_ctrl.mouse_exited.connect(func():
		STooltip.close()
	)
	cluster_level3_ctrl.mouse_entered.connect(func():
		var lv = Game.level
		if !Game.shop_ui.visible:
			lv -= 1
		lv = int(lv / 3) * 3 + 3
		STooltip.show([Pair.new(tr("ui_game_level") % lv, Game.get_level_desc(Game.get_level_score(lv), Game.get_level_reward(lv)))])
	)
	cluster_level3_ctrl.mouse_exited.connect(func():
		STooltip.close()
	)
	board_size_container.mouse_entered.connect(func():
		STooltip.show([Pair.new(tr("tt_game_board_size_title"), tr("tt_game_board_size_content"))])
	)
	hand_container.mouse_entered.connect(func():
		STooltip.show([Pair.new(tr("tt_game_hand_title"), tr("tt_game_hand_content") % Game.max_hand_grabs)])
	)
	coins_container.mouse_entered.connect(func():
		STooltip.show([Pair.new(tr("tt_game_coins_title"), "%d" % Game.coins)])
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
		STooltip.show([Pair.new(tr("tt_game_gem_number"), "%d" % Game.gems.size())])
	)
	gem_count_text.mouse_exited.connect(func():
		STooltip.close()
	)
	gem_count_limit_text.mouse_entered.connect(func():
		STooltip.show([Pair.new("", tr("tt_game_upgrade_number_and_min_number") % [Board.next_min_gem_num, Board.curr_min_gem_num])])
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
	tutorial_button.pressed.connect(func():
		SSound.se_click.play()
		Game.tutorial_ui.enter()
	)
	tutorial_button.mouse_entered.connect(func():
		STooltip.show([Pair.new(tr("tt_game_tutorial"), "")])
	)
	tutorial_button.mouse_exited.connect(func():
		STooltip.close()
	)
