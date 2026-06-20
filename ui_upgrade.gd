extends Control

@export var panel : Control
@export var upgrade_board_ui : Control
@export var new_pattern_ui : Control
@export var upgrade_pattern_ui : Control

func enter(tween : Tween = null):
	STooltip.close()
	
	upgrade_board_ui.hide()
	new_pattern_ui.hide()
	upgrade_pattern_ui.hide()
	
	if !tween:
		tween = G.create_game_tween()
	tween.tween_callback(func():
		self.show()
		panel.modulate.a = 0.0
		panel.show()
		G.stage = G.Stage.Upgrade
	)
	tween.tween_property(panel, "modulate:a", 1.0, 0.3)
	
	var idx = G.treasure_arrive_rounds.find(G.current_round)
	match idx:
		0:
			tween.tween_callback(func():
				upgrade_board_ui.show()
			)
		1:
			tween.tween_callback(func():
				new_pattern_ui.show()
			)
		2:
			tween.tween_callback(func():
				upgrade_board_ui.show()
			)
		3:
			tween.tween_callback(func():
				upgrade_pattern_ui.show()
			)
	tween.tween_callback(func():
		G.save_to_file()
	)

func exit(trans : bool = true):
	if trans:
		var tween = G.create_game_tween()
		tween.tween_callback(func():
			panel.hide()
			self.self_modulate.a = 1.0
		)
		tween.tween_property(self, "self_modulate:a", 0.0, 0.3)
		tween.tween_callback(func():
			self.hide()
			G.next_round()
		)
	else:
		self.hide()
		G.next_round()

func load_from_data(data : Dictionary):
	var list_data = data["upgrade_list"]

func save_to_data(data : Dictionary):
	var list_data = []
	data["upgrade_list"] = list_data

func _ready() -> void:
	pass
