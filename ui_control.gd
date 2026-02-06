extends Control

const NumberText = preload("res://number_text.gd")
const UiProp = preload("res://ui_prop.gd")

@onready var panel : Control = $MarginContainer2/HBoxContainer2/Panel
@onready var swaps_text : NumberText = $MarginContainer2/HBoxContainer2/Panel/HBoxContainer/VBoxContainer3/Swaps
@onready var play_button  : Button = $MarginContainer2/HBoxContainer2/Panel/HBoxContainer/Play
@onready var plays_text : Label = $MarginContainer2/HBoxContainer2/Panel/HBoxContainer/VBoxContainer2/Plays
@onready var expected_score_panel : Control = $MarginContainer2/HBoxContainer2/Panel/HBoxContainer/Play/Control/PanelContainer
@onready var expected_score_text : Label = $MarginContainer2/HBoxContainer2/Panel/HBoxContainer/Play/Control/PanelContainer/ExpectedScore
@onready var props_bar : Control = $HBoxContainer
@onready var pin_ui : UiProp = $HBoxContainer/UiProp
@onready var activate_ui : UiProp = $HBoxContainer/UiProp2
@onready var grab_ui : UiProp = $HBoxContainer/UiProp3
@onready var undo_button : Button = $MarginContainer2/HBoxContainer2/Panel/HBoxContainer/Undo
@onready var filling_times_text_container : Control = $PanelContainer
@onready var filling_times_text : Label = $PanelContainer/FillingTimes
var filling_times_tween : Tween = null
@onready var debug_text : Label = $MarginContainer/DebugText

var shake_strength : float = 0.0
var shake_coord : float = 0.0

var preview = MatchPreview.new()

func enter():
	self.show()

func exit():
	self.hide()

func start_shake(strength : float, pos : float = 0.0):
	shake_strength = strength
	shake_coord = pos * PI

func update_preview():
	preview.find_all_matchings()
	
	var base = 0
	var combos = 0
	var mult = 1.0
	for m in preview.matchings:
		combos += 1
		for c in m:
			var g = Board.get_gem_at(c)
			if g && g.type >= Gem.ColorFirst && g.type <= Gem.ColorLast && g.rune >= Gem.RuneFirst && g.rune <= Gem.RuneLast:
				if !G.no_score_marks[g.type].front() && !G.no_score_marks[g.rune].front():
					base += g.get_score()
	expected_score_text.text = "%d" % int(base * G.mult_from_combos(combos) * mult)

func _ready() -> void:
	play_button.pressed.connect(func():
		SSound.se_click.play()
		G.screen_shake_strength = 8.0
		play_button.disabled = true
		play_button.mouse_exited.emit()
		G.play()
	)
	play_button.mouse_entered.connect(func():
		if !play_button.disabled:
			preview.show()
		
		STooltip.show(play_button, 1, [Pair.new(tr("tt_game_match_title"), tr("tt_game_match_content"))])
	)
	play_button.mouse_exited.connect(func():
		STooltip.close()
		preview.clear()
	)
	pin_ui.button.pressed.connect(func():
		SSound.se_click.play()
		G.screen_shake_strength = 8.0
		G.set_props(G.Props.Pin)
	)
	activate_ui.button.pressed.connect(func():
		SSound.se_click.play()
		G.screen_shake_strength = 8.0
		G.set_props(G.Props.Activate)
	)
	grab_ui.button.pressed.connect(func():
		SSound.se_click.play()
		G.screen_shake_strength = 8.0
		G.set_props(G.Props.Grab)
	)
	undo_button.pressed.connect(func():
		SSound.se_click.play()
		G.screen_shake_strength = 8.0
		if !G.action_stack.is_empty():
			G.swaps += 1
			
			var p = G.action_stack.back()
			G.swap_hand_and_board(Hand.ui.get_slot(Hand.find(p.second)), p.first, "undo")
			G.action_stack.pop_back()
			if G.action_stack.is_empty():
				undo_button.disabled = true
	)
	filling_times_text_container.mouse_entered.connect(func():
		STooltip.show(filling_times_text_container, 1, [Pair.new(tr("tt_game_filling_times_title"), tr("tt_game_filling_times_content"))])
	)
	filling_times_text_container.mouse_exited.connect(func():
		STooltip.close()
	)

func _process(delta: float) -> void:
	if !G.performance_mode:
		shake_coord += delta * PI
		position.y = sin(shake_coord) * shake_strength
		shake_strength *= 0.9
