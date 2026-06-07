extends Control

@export var panel : Control
@export var swaps_text : G.NumberText
@export var play_button  : Button
@export var plays_text : Label
@export var undo_button : Button
@export var shuffle_button : Button
@export var expected_score_panel : Control
@export var expected_score_text : Label
@export var last_play : Control
@export var last_play_text : RichTextLabel
@export var props_bar : Control
@export var pin_ui : G.UiProp
@export var activate_ui : G.UiProp
@export var grab_ui : G.UiProp
@export var filling_times_container : Control
@export var filling_times_text : Label
@export var debug_text : Label

var filling_times_tween : Tween = null
var last_play_tween : Tween = null
var shake_strength : float = 0.0
var shake_coord : float = 0.0

var preview = MatchPreview.new()

func enter():
	self.show()

func exit():
	expected_score_panel.hide()
	self.hide()

func start_shake(strength : float, pos : float = 0.0):
	shake_strength = strength
	shake_coord = pos * PI

func update_preview():
	preview.find_all_matchings()
	for i in Hand.grabs.size():
		var g = Hand.grabs[i]
		var ui = Hand.ui.get_slot(i)
		ui.preview.find_missing_ones(g.type, g.rune)
	
	var base = 0
	for i in preview.matchings.size():
		var m = preview.matchings[i]
		for c in m.coords:
			var found = false
			for j in i:
				var mm = preview.matchings[j]
				for cc in mm.coords:
					if c == cc:
						found = true
						break
				if found:
					break
			if found:
				continue
			var g = Board.get_gem_at(c)
			if g && g.type >= Gem.ColorFirst && g.type <= Gem.ColorLast && g.rune >= Gem.RuneFirst && g.rune <= Gem.RuneLast:
				if !G.no_score_marks[g.type].front() && !G.no_score_marks[g.rune].front():
					base += g.get_score()
	expected_score_text.text = "%d" % base
	expected_score_panel.show()

func show_last_play():
	if last_play_tween:
		last_play_tween.kill()
		last_play_tween = null
	last_play.show()
	last_play.scale = Vector2(0.0, 0.0)
	last_play_tween = G.create_game_tween()
	last_play_tween.tween_property(last_play, "scale", Vector2(1.0, 1.0), 0.3)

func _ready() -> void:
	play_button.pressed.connect(func():
		SSound.se_click.play()
		G.screen_shake_strength = 8.0
		play_button.disabled = true
		play_button.mouse_exited.emit()
		var tween = G.create_game_tween()
		tween.tween_interval(0.5)
		tween.tween_callback(func():
			G.play()
		)
	)
	play_button.mouse_entered.connect(func():
		if !play_button.disabled:
			preview.show()
		
		STooltip.show(play_button, 1, [Pair.new(tr("tt_game_play_title"), tr("tt_game_play_content"))])
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
	undo_button.mouse_entered.connect(func():
		STooltip.show(undo_button, 0, [Pair.new(tr("tt_game_undo"), "")])
	)
	undo_button.mouse_exited.connect(func():
		STooltip.close()
	)
	shuffle_button.pressed.connect(func():
		SSound.se_click.play()
		G.screen_shake_strength = 8.0
		G.shuffle()
	)
	shuffle_button.mouse_entered.connect(func():
		STooltip.show(shuffle_button, 2, [Pair.new(tr("tt_game_shuffle_title"), tr("tt_game_shuffle_content"))])
	)
	shuffle_button.mouse_exited.connect(func():
		STooltip.close()
	)
	last_play_text.text = "[shake]%s[/shake]" % tr("ui_game_last_play")
	filling_times_container.mouse_entered.connect(func():
		STooltip.show(filling_times_container, 1, [Pair.new(tr("tt_game_filling_times_title"), tr("tt_game_filling_times_content"))])
	)
	filling_times_container.mouse_exited.connect(func():
		STooltip.close()
	)

func _process(delta: float) -> void:
	if !G.performance_mode:
		shake_coord += delta * PI
		position.y = sin(shake_coord) * shake_strength
		shake_strength *= 0.9
