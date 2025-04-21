extends PanelContainer

@onready var score_text : Label = $MarginContainer/HBoxContainer/Score
@onready var level_text : Label = $MarginContainer/HBoxContainer/Level
@onready var board_size_container : Control = $MarginContainer/HBoxContainer/HBoxContainer
@onready var board_size_text : Label = $MarginContainer/HBoxContainer/HBoxContainer/BoardSize
@onready var coin_container : Control = $MarginContainer/HBoxContainer/HBoxContainer2
@onready var coin_text : Label = $MarginContainer/HBoxContainer/HBoxContainer2/Coin
@onready var bag_button : Button = $MarginContainer/HBoxContainer/HBoxContainer3/Bag
@onready var gear_button : Button = $MarginContainer/HBoxContainer/HBoxContainer3/Gear

func _ready() -> void:
	score_text.mouse_entered.connect(func():
		STooltip.show([Pair.new("Score", "Current: %d\nTarget: %d\nMultipler: %.1f" % [Game.score, Game.target_score, Game.score_mult])])
	)
	score_text.mouse_exited.connect(func():
		STooltip.close()
	)
	board_size_container.mouse_entered.connect(func():
		STooltip.show([Pair.new("Board Size", "The horizontal cells would be Board Size x6, the vertical cells would be Board Size x2")])
	)
	coin_container.mouse_entered.connect(func():
		STooltip.show([Pair.new("Your Coins", "")])
	)
	coin_container.mouse_exited.connect(func():
		STooltip.close()
	)
	bag_button.pressed.connect(func():
		SSound.sfx_click.play()
		if !Game.bag_viewer_ui.visible:
			STooltip.close()
			Game.bag_viewer_ui.enter()
		else:
			Game.bag_viewer_ui.exit()
	)
	bag_button.mouse_entered.connect(func():
		if Game.hand_ui && Game.hand_ui.dragging && Game.hand_ui.dragging.item.tradeable:
			Game.hand_ui.dragging.action.show()
			STooltip.show([Pair.new("Your Bag", "Drop the item here to exchange another item.")])
		else:
			STooltip.show([Pair.new("Your Bag", "Your gems and items.")])
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
		STooltip.show([Pair.new("Game Menu", "")])
	)
	gear_button.mouse_exited.connect(func():
		STooltip.close()
	)
