extends Control

@onready var panel = $PanelContainer
@onready var tab_container : TabContainer = $PanelContainer/VBoxContainer/TabContainer
@onready var round1_title = $PanelContainer/VBoxContainer/TabContainer/Stage/VBoxContainer/HBoxContainer/PanelContainer/VBoxContainer/Label
@onready var round2_title = $PanelContainer/VBoxContainer/TabContainer/Stage/VBoxContainer/HBoxContainer/PanelContainer2/VBoxContainer/Label
@onready var round3_title = $PanelContainer/VBoxContainer/TabContainer/Stage/VBoxContainer/HBoxContainer/PanelContainer3/VBoxContainer/Label
@onready var round1_desc = $PanelContainer/VBoxContainer/TabContainer/Stage/VBoxContainer/HBoxContainer/PanelContainer/VBoxContainer/Label2
@onready var round2_desc = $PanelContainer/VBoxContainer/TabContainer/Stage/VBoxContainer/HBoxContainer/PanelContainer2/VBoxContainer/Label2
@onready var round3_desc = $PanelContainer/VBoxContainer/TabContainer/Stage/VBoxContainer/HBoxContainer/PanelContainer3/VBoxContainer/Label2
@onready var close_button : Button = $PanelContainer/VBoxContainer/Button

func enter():
	self.self_modulate.a = 0.0
	self.show()
	panel.show()
	
	var tween = App.create_tween()
	tween.tween_property(self, "self_modulate:a", 1.0, 0.3)
	
	var r = App.round
	if !App.shop_ui.visible:
		r -= 1
	r = int(r / 3) * 3 + 1
	round1_title.text = tr("ui_game_round") % r
	round1_desc.text = App.get_round_desc(App.get_round_score(r), App.get_round_reward(r), App.round_curses[r - 1] if !App.round_curses.is_empty() else ([] as Array[Curse]))
	r += 1
	round2_title.text = tr("ui_game_round") % r
	round2_desc.text = App.get_round_desc(App.get_round_score(r), App.get_round_reward(r), App.round_curses[r - 1] if !App.round_curses.is_empty() else ([] as Array[Curse]))
	r += 1
	round3_title.text = tr("ui_game_round") % r
	round3_desc.text = App.get_round_desc(App.get_round_score(r), App.get_round_reward(r), App.round_curses[r - 1] if !App.round_curses.is_empty() else ([] as Array[Curse]))

func exit():
	panel.hide()
	
	self.self_modulate.a = 1.0
	var tween = App.create_tween()
	tween.tween_property(self, "self_modulate:a", 0.0, 0.3)
	tween.tween_callback(func():
		self.hide()
	)
	
func _ready() -> void:
	tab_container.set_tab_title(0, tr("ui_stage"))
	close_button.pressed.connect(func():
		exit()
	)
