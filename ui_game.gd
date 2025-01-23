extends Control

@onready var score_text : Label = $Label2
@onready var target_score_text : Label = $Label
@onready var combos_text : Label = $Control/Label3
@onready var status_text : Label = $Control2/Label
@onready var roll_panel : Control = $Panel
@onready var roll_button : Button = $Panel/Button
@onready var rolls_text : Label = $Panel/Label
@onready var rc_actions_text : Label = $Panel/Label2
@onready var rc_action_name_text : Label = $Panel/Label4
@onready var rc_action_tip_text : AdvancedLabel = $RcActionTip

func enter():
	self.show()
	var tween = get_tree().create_tween()
	var p0 = roll_panel.position
	roll_panel.position = p0 + Vector2(0, 100)
	tween.tween_property(roll_panel, "position", p0, 0.5)
	var p1 = target_score_text.position
	target_score_text.position = p1 - Vector2(0, 100)
	tween.parallel().tween_property(target_score_text, "position", p1, 0.5)
	var p2 = score_text.position
	score_text.position = p2 - Vector2(0, 100)
	tween.parallel().tween_property(score_text, "position", p2, 0.5)
	var p3 = rc_action_tip_text.position
	rc_action_tip_text.position = p3 + Vector2(0, 100)
	tween.parallel().tween_property(rc_action_tip_text, "position", p3, 0.5)

func _ready() -> void:
	roll_button.pressed.connect(func():
		Game.sound.sfx_slot_button.play()
		Game.sound.sfx_roll.play()
		Game.roll()
	)
	
	Game.protected_controls.append(roll_button)
	Game.protected_controls.append(rc_action_tip_text)
