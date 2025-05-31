extends Control

const UiProp = preload("res://ui_prop.gd")

@onready var base_score : Label = $Control/HBoxContainer/BaseScore
@onready var combos : Label = $Control/HBoxContainer/Combos
@onready var mult : Label = $Control/HBoxContainer/Mult
@onready var roll_panel : Control = $Panel
@onready var roll_button : Button = $Panel/HBoxContainer/Roll
@onready var rolls_text : Label = $Panel/HBoxContainer/VBoxContainer/Rolls
@onready var match_button  : Button = $Panel/HBoxContainer/Match
@onready var matches_text : Label = $Panel/HBoxContainer/VBoxContainer2/Matches
@onready var action_tip_text : AdvancedLabel = $ActionTip
@onready var props_bar : Control = $HBoxContainer
@onready var pin_ui : UiProp = $HBoxContainer/UiProp
@onready var activate_ui : UiProp = $HBoxContainer/UiProp2
@onready var grab_ui : UiProp = $HBoxContainer/UiProp3
@onready var debug_text : Label = $DebugText

var preview_matchings : Array[Node2D]
var preview_tween : Tween = null

func enter():
	Game.board_ui.enter()
	self.show()
	var tween = get_tree().create_tween()
	return tween

func exit():
	Board.cleanup()
	Game.board_ui.hide()
	Game.hand_ui.cleanup()
	self.hide()

func _ready() -> void:
	roll_button.pressed.connect(func():
		SSound.sfx_click.play()
		roll_button.disabled = true
		Game.roll()
	)
	roll_button.mouse_entered.connect(func():
		var desc = tr("tt_game_roll_content")
		if Game.next_roll_extra_draws > 0:
			desc += "\nDraw %d extra item(s)." % Game.next_roll_extra_draws
		STooltip.show([Pair.new(tr("tt_game_roll_title"), desc)])
	)
	roll_button.mouse_exited.connect(func():
		STooltip.close()
	)
	match_button.pressed.connect(func():
		SSound.sfx_click.play()
		match_button.disabled = true
		match_button.mouse_exited.emit()
		Game.play()
	)
	match_button.mouse_entered.connect(func():
		if !match_button.disabled:
			for n in preview_matchings:
				n.queue_free()
				Game.board_ui.overlay.remove_child(n)
			preview_matchings.clear()
			if preview_tween:
				preview_tween.kill()
				preview_tween = null
			preview_tween = get_tree().create_tween()
			for y in Board.cy:
				for x in Board.cx:
					for p in Game.patterns:
						var res : Array[Vector2i] = p.match_with(Vector2i(x, y))
						if !res.is_empty():
							var n = Node2D.new()
							var pts = SUtils.get_cells_border(res)
							for i in range(0, pts.size(), 2):
								var l = Line2D.new()
								l.default_color = Color(0.0, 0.0, 0.0, 1.0)
								l.width = 3
								l.points = [pts[i], pts[i + 1]]
								n.add_child(l)
								n.modulate.a = 0.0
							preview_tween.tween_property(n, "modulate:a", 1.0, 0.2)
							preview_matchings.append(n)
							Game.board_ui.overlay.add_child(n)
			preview_tween.tween_callback(func():
				preview_tween = null
			)
		
		var desc = tr("tt_game_match_content")
		if match_button.disabled && !roll_button.disabled:
			desc += "\n[color=yellow](Roll the Board first)[/color]"
		elif !match_button.disabled && preview_matchings.is_empty():
			desc += "\n[color=red](No match found)[/color]"
		STooltip.show([Pair.new(tr("tt_game_match_title"), desc)])
	)
	match_button.mouse_exited.connect(func():
		STooltip.close()
		for n in preview_matchings:
			n.queue_free()
			Game.board_ui.overlay.remove_child(n)
		if preview_tween:
			preview_tween.kill()
			preview_tween = null
		preview_matchings.clear()
	)
	pin_ui.button.pressed.connect(func():
		SSound.sfx_click.play()
		Game.set_props(Game.Props.Pin)
	)
	activate_ui.button.pressed.connect(func():
		SSound.sfx_click.play()
		Game.set_props(Game.Props.Activate)
	)
	grab_ui.button.pressed.connect(func():
		SSound.sfx_click.play()
		Game.set_props(Game.Props.Grab)
	)
