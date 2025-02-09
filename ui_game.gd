extends Control

@onready var score_text : Label = $Label
@onready var combos_fire : Sprite2D = $Sprite2D
@onready var combos_fire_shader : ShaderMaterial = combos_fire.material
@onready var combos_text : Label = $Control/Label3
@onready var status_text : Label = $Control2/Label
@onready var roll_panel : Control = $Panel
@onready var roll_button : Button = $Panel/Button
@onready var rolls_text : Label = $Panel/Label
@onready var action_tip_text : AdvancedLabel = $ActionTip
@onready var props_bar : Control = $HBoxContainer
@onready var pin_button : Button = $HBoxContainer/Button2
@onready var pins_num_text : Label = $HBoxContainer/Button2/Label
@onready var activate_button : Button = $HBoxContainer/Button3
@onready var activates_num_text : Label = $HBoxContainer/Button3/Label
@onready var grab_button : Button = $HBoxContainer/Button4
@onready var grabs_num_text : Label = $HBoxContainer/Button4/Label

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
	roll_button.pressed.connect(func():
		Sounds.sfx_slot_button.play()
		Sounds.sfx_roll.play()
		Game.roll()
	)
	pin_button.pressed.connect(func():
		Sounds.sfx_click.play()
		Game.set_props(Game.Props.Pin)
	)
	activate_button.pressed.connect(func():
		Sounds.sfx_click.play()
		Game.set_props(Game.Props.Activate)
	)
	grab_button.pressed.connect(func():
		Sounds.sfx_click.play()
		Game.set_props(Game.Props.Grab)
	)
	
	Game.protected_controls.append(roll_button)
	Game.protected_controls.append(action_tip_text)
