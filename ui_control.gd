extends Control

const NumberText = preload("res://number_text.gd")
const UiProp = preload("res://ui_prop.gd")

@onready var panel : Control = $HBoxContainer2/Panel
@onready var roll_button : Button = $HBoxContainer2/Panel/HBoxContainer/Roll
@onready var rolls_text : Label = $HBoxContainer2/Panel/HBoxContainer/VBoxContainer/Rolls
@onready var swaps_text : NumberText = $HBoxContainer2/Panel/HBoxContainer/VBoxContainer3/Swaps
@onready var play_button  : Button = $HBoxContainer2/Panel/HBoxContainer/Play
@onready var plays_text : Label = $HBoxContainer2/Panel/HBoxContainer/VBoxContainer2/Plays
@onready var expected_score_panel : Control = $HBoxContainer2/Panel/HBoxContainer/Play/Control/PanelContainer
@onready var expected_score_text : Label = $HBoxContainer2/Panel/HBoxContainer/Play/Control/PanelContainer/ExpectedScore
@onready var props_bar : Control = $HBoxContainer
@onready var pin_ui : UiProp = $HBoxContainer/UiProp
@onready var activate_ui : UiProp = $HBoxContainer/UiProp2
@onready var grab_ui : UiProp = $HBoxContainer/UiProp3
@onready var undo_button : Button = $HBoxContainer2/Undo
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
			if g:
				if !App.no_score_marks[g.type].front() && !App.no_score_marks[g.rune].front():
					base += g.get_score()
					mult += g.get_mult()
	expected_score_text.text = "%d" % int(base * App.mult_from_combos(combos) * mult)

func _ready() -> void:
	roll_button.pressed.connect(func():
		SSound.se_click.play()
		App.screen_shake_strength = 8.0
		roll_button.disabled = true
		App.roll()
	)
	roll_button.mouse_entered.connect(func():
		var desc = tr("tt_game_roll_content")
		if App.next_roll_extra_draws > 0:
			desc += "\nDraw %d extra item(s)." % App.next_roll_extra_draws
		STooltip.show(roll_button, 1, [Pair.new(tr("tt_game_roll_title"), desc)])
	)
	roll_button.mouse_exited.connect(func():
		STooltip.close()
	)
	play_button.pressed.connect(func():
		SSound.se_click.play()
		App.screen_shake_strength = 8.0
		play_button.disabled = true
		play_button.mouse_exited.emit()
		App.play()
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
		App.screen_shake_strength = 8.0
		App.set_props(App.Props.Pin)
	)
	activate_ui.button.pressed.connect(func():
		SSound.se_click.play()
		App.screen_shake_strength = 8.0
		App.set_props(App.Props.Activate)
	)
	grab_ui.button.pressed.connect(func():
		SSound.se_click.play()
		App.screen_shake_strength = 8.0
		App.set_props(App.Props.Grab)
	)
	undo_button.pressed.connect(func():
		SSound.se_click.play()
		App.screen_shake_strength = 8.0
		if !App.action_stack.is_empty():
			App.swaps += 1
			
			var p = App.action_stack.back()
			App.swap_hand_and_board(Hand.ui.get_slot(Hand.find(p.second)), p.first, "undo")
			App.action_stack.pop_back()
			if App.action_stack.is_empty():
				undo_button.disabled = true
	)
	filling_times_text_container.mouse_entered.connect(func():
		STooltip.show(filling_times_text_container, 1, [Pair.new(tr("tt_game_filling_times_title"), tr("tt_game_filling_times_content"))])
	)
	filling_times_text_container.mouse_exited.connect(func():
		STooltip.close()
	)

func _process(delta: float) -> void:
	if !App.performance_mode:
		shake_coord += delta * PI
		position.y = sin(shake_coord) * shake_strength
		shake_strength *= 0.9
