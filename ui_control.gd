extends Control

const NumberText = preload("res://number_text.gd")
const UiProp = preload("res://ui_prop.gd")

@onready var panel : Control = $Panel
@onready var roll_button : Button = $Panel/HBoxContainer/Roll
@onready var rolls_text : Label = $Panel/HBoxContainer/VBoxContainer/Rolls
@onready var swaps_text : NumberText = $Panel/HBoxContainer/VBoxContainer3/Swaps
@onready var play_button  : Button = $Panel/HBoxContainer/Play
@onready var plays_text : Label = $Panel/HBoxContainer/VBoxContainer2/Plays
@onready var expected_score_panel : Control = $Panel/HBoxContainer/Play/Control/PanelContainer
@onready var expected_score_text : Label = $Panel/HBoxContainer/Play/Control/PanelContainer/ExpectedScore
@onready var action_tip_text : AdvancedLabel = $ActionTip
@onready var props_bar : Control = $HBoxContainer
@onready var pin_ui : UiProp = $HBoxContainer/UiProp
@onready var activate_ui : UiProp = $HBoxContainer/UiProp2
@onready var grab_ui : UiProp = $HBoxContainer/UiProp3
@onready var undo_button : Button = $Undo
@onready var filling_times_text_container : Control = $PanelContainer
@onready var filling_times_text : Label = $PanelContainer/FillingTimes
var filling_times_tween : Tween = null
@onready var debug_text : Label = $DebugText

var preview_matchings : Array[Array]
var preview_lines : Array[Node2D]
var preview_tween : Tween = null

func enter():
	self.show()
	var tween = get_tree().create_tween()
	return tween

func exit():
	self.hide()

func update_preview():
	preview_matchings.clear()
	for y in Board.cy:
		for x in Board.cx:
			for p in Game.patterns:
				var res : Array[Vector2i] = p.match_with(Vector2i(x, y))
				if !res.is_empty():
					preview_matchings.append(res)
	
	var base = 0
	var combos = 0
	var mult = 1.0
	for m in preview_matchings:
		combos += 1
		for c in m:
			var g = Board.get_gem_at(c)
			if g:
				base += g.get_base_score()
				mult += g.mult
	expected_score_text.text = "%d" % int(base * Game.mult_from_combos(combos) * mult)
	

func _ready() -> void:
	roll_button.pressed.connect(func():
		SSound.se_click.play()
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
	play_button.pressed.connect(func():
		SSound.se_click.play()
		play_button.disabled = true
		play_button.mouse_exited.emit()
		Game.play()
	)
	play_button.mouse_entered.connect(func():
		if !play_button.disabled:
			for n in preview_lines:
				n.queue_free()
				Game.board_ui.overlay.remove_child(n)
			preview_lines.clear()
			if preview_tween:
				preview_tween.kill()
				preview_tween = null
			preview_tween = get_tree().create_tween()
			var idx = 0
			for res in preview_matchings:
				var gs = []
				for c in res:
					var ok = false
					for g in gs:
						if g.is_empty():
							g.append(c)
							ok = true
							break
						for cc in g:
							if Board.offset_neighbors(cc, false).has(c):
								g.append(c)
								ok = true
								break
					if !ok:
						var g : Array[Vector2i] = []
						g.append(c)
						gs.append(g)
				for g in gs:
					var pts = SMath.weld_lines(SUtils.get_cells_border(g), 5.0)
					var c = Vector2(0.0, 0.0)
					for pt in pts:
						c += pt
					c /= pts.size()
					for i in pts.size():
						pts[i] = pts[i] - c
					var l = Line2D.new()
					l.default_color = Color(0.0, 0.0, 0.0, 1.0)
					l.width = 3
					l.points = pts
					l.modulate.a = 0.0
					l.scale = Vector2(2.0, 2.0)
					l.position = c
					var subtween = get_tree().create_tween()
					subtween.tween_interval(0.05 * idx)
					subtween.tween_property(l, "scale", Vector2(1.0, 1.0), 0.2)
					subtween.parallel().tween_property(l, "modulate:a", 1.0, 0.5)
					preview_tween.parallel()
					preview_tween.tween_subtween(subtween)
					preview_lines.append(l)
					Game.board_ui.overlay.add_child(l)
				idx += 1
			preview_tween.tween_callback(func():
				preview_tween = null
			)
		
		STooltip.show([Pair.new(tr("tt_game_match_title"), tr("tt_game_match_content"))])
	)
	play_button.mouse_exited.connect(func():
		STooltip.close()
		for n in preview_lines:
			n.queue_free()
			Game.board_ui.overlay.remove_child(n)
		if preview_tween:
			preview_tween.kill()
			preview_tween = null
		preview_lines.clear()
	)
	pin_ui.button.pressed.connect(func():
		SSound.se_click.play()
		Game.set_props(Game.Props.Pin)
	)
	activate_ui.button.pressed.connect(func():
		SSound.se_click.play()
		Game.set_props(Game.Props.Activate)
	)
	grab_ui.button.pressed.connect(func():
		SSound.se_click.play()
		Game.set_props(Game.Props.Grab)
	)
	undo_button.pressed.connect(func():
		SSound.se_click.play()
		if !Game.action_stack.is_empty():
			var p = Game.action_stack.back()
			Hand.erase(Hand.find(p.second))
			Hand.swap(p.first, p.second)
			Game.swaps += 1
			Game.action_stack.pop_back()
			if Game.action_stack.is_empty():
				undo_button.hide()
			update_preview()
	)
	filling_times_text_container.mouse_entered.connect(func():
		STooltip.show([Pair.new(tr("tt_game_filling_times_title"), tr("tt_game_filling_times_content"))])
	)
	filling_times_text_container.mouse_exited.connect(func():
		STooltip.close()
	)
