extends Control

@export var panel : Control
@export var tab_container : TabContainer
@export var round1_title : Label
@export var round2_title : Label
@export var round3_title : Label
@export var round1_desc : RichTextLabel
@export var round2_desc : RichTextLabel
@export var round3_desc : RichTextLabel
@export var close_button : Button

func enter():
	self.self_modulate.a = 0.0
	self.show()
	panel.show()
	
	var tween = G.create_tween()
	tween.tween_property(self, "self_modulate:a", 1.0, 0.3)
	
	var r = G.current_round
	if !G.shop_ui.visible:
		r -= 1
	r = int(r / 3) * 3 + 1
	round1_title.text = tr("ui_game_round") % r
	round1_desc.text = G.get_round_desc(r)
	r += 1
	round2_title.text = tr("ui_game_round") % r
	round2_desc.text = G.get_round_desc(r)
	r += 1
	round3_title.text = tr("ui_game_round") % r
	round3_desc.text = G.get_round_desc(r)

func exit():
	panel.hide()
	
	self.self_modulate.a = 1.0
	var tween = G.create_tween()
	tween.tween_property(self, "self_modulate:a", 0.0, 0.3)
	tween.tween_callback(func():
		self.hide()
	)
	
func _ready() -> void:
	tab_container.set_tab_title(0, tr("ui_stage"))
	close_button.pressed.connect(func():
		exit()
	)
