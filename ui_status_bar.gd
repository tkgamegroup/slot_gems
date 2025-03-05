extends PanelContainer

@onready var level_text : Label = $MarginContainer/HBoxContainer/Label
@onready var coin_container : Control = $MarginContainer/HBoxContainer/HBoxContainer
@onready var coin_text : Label = $MarginContainer/HBoxContainer/HBoxContainer/Label2
@onready var bag_button : Button = $MarginContainer/HBoxContainer/HBoxContainer2/Button
@onready var gear_button : Button = $MarginContainer/HBoxContainer/HBoxContainer2/Button2

func appear():
	self.show()
	var tween = Game.get_tree().create_tween()
	var pos = self.position
	self.position = pos - Vector2(0, 100)
	tween.tween_property(self, "position", pos, 0.8)

func _ready() -> void:
	coin_container.mouse_entered.connect(func():
		STooltip.show([Pair.new("Your Coins", "")])
	)
	coin_container.mouse_exited.connect(func():
		STooltip.close()
	)
	bag_button.pressed.connect(func():
		SSound.sfx_click.play()
		Game.bag_viewer_ui.enter()
	)
	bag_button.mouse_entered.connect(func():
		STooltip.show([Pair.new("Your Bag", "Your gems and items.")])
	)
	bag_button.mouse_exited.connect(func():
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
