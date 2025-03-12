extends Control

const UiProp = preload("res://ui_prop.gd")

@onready var score_text : Label = $Label
@onready var combos_fire : Sprite2D = $Sprite2D
@onready var combos_fire_shader : ShaderMaterial = combos_fire.material
@onready var combos_text : Label = $Control/Combo
@onready var status_text : Label = $Control2/Status
@onready var roll_panel : Control = $Panel
@onready var roll_button : Button = $Panel/HBoxContainer/Roll
@onready var rolls_text : Label = $Panel/HBoxContainer/VBoxContainer/Rolls
@onready var play_button  : Button = $Panel/HBoxContainer/Play
@onready var action_tip_text : AdvancedLabel = $ActionTip
@onready var props_bar : Control = $HBoxContainer
@onready var pin_ui : UiProp = $HBoxContainer/UiProp
@onready var activate_ui : UiProp = $HBoxContainer/UiProp2
@onready var grab_ui : UiProp = $HBoxContainer/UiProp3
@onready var debug_text : Label = $DebugText

var preview_matchings : Array[Node2D]
var preview_tween : Tween = null

func enter():
	self.show()
	var tween = get_tree().create_tween()
	var p0 = roll_panel.position
	roll_panel.position = p0 + Vector2(0, 400)
	tween.tween_property(roll_panel, "position", p0, 0.8)
	var p1 = score_text.position
	score_text.position = p1 - Vector2(0, 400)
	tween.parallel().tween_property(score_text, "position", p1, 0.8)
	var p2 = action_tip_text.position
	action_tip_text.position = p2 + Vector2(0, 400)
	tween.parallel().tween_property(action_tip_text, "position", p2, 0.8)
	var p3 = props_bar.position
	props_bar.position = p3 + Vector2(0, 400)
	tween.parallel().tween_property(props_bar, "position", p3, 0.8)

func exit():
	Game.board.cleanup()
	Game.game_root.hide()
	self.hide()

func _ready() -> void:
	score_text.mouse_entered.connect(func():
		STooltip.show([Pair.new("Score", "Current: %d\nTarget: %d\nMultipler: %.1f" % [Game.score, Game.target_score, Game.score_mult])])
	)
	score_text.mouse_exited.connect(func():
		STooltip.close()
	)
	roll_button.pressed.connect(func():
		SSound.sfx_slot_button.play()
		SSound.sfx_roll.play()
		roll_button.disabled = true
		Game.roll()
	)
	roll_button.mouse_entered.connect(func():
		STooltip.show([Pair.new("Roll", "Roll the board! New gems will fill in the board, old gems except pinned ones will dispear.")])
	)
	roll_button.mouse_exited.connect(func():
		STooltip.close()
	)
	play_button.pressed.connect(func():
		#SSound.sfx_click.play()
		play_button.disabled = true
		Game.play()
	)
	play_button.mouse_entered.connect(func():
		STooltip.show([Pair.new("Play", "Start matching stage. When there is no patterns, matching stage stops.")])
		for n in preview_matchings:
			n.queue_free()
			Game.overlay.remove_child(n)
		preview_matchings.clear()
		if preview_tween:
			preview_tween.kill()
			preview_tween = null
		preview_tween = get_tree().create_tween()
		for y in Game.board.cy:
			for x in Game.board.cx:
				for p in Game.patterns:
					var res : Array[Vector2i] = p.match_with(Game.board, Vector2i(x, y))
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
						Game.overlay.add_child(n)
		preview_tween.tween_callback(func():
			preview_tween = null
		)
	)
	play_button.mouse_exited.connect(func():
		STooltip.close()
		for n in preview_matchings:
			n.queue_free()
			Game.overlay.remove_child(n)
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
