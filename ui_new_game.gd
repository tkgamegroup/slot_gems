extends Panel

@export var panel : PanelContainer
@export var list : ItemList
@export var seed_edit : LineEdit
@export var start_button : Button
@export var close_button : Button

func exit(tween : Tween = null, no_trans : bool = false) -> Tween:
	panel.hide()
	if !tween:
		tween = G.create_tween()
	if !no_trans:
		self.self_modulate.a = 1.0
		tween.tween_property(self, "self_modulate:a", 0.0, 0.3)
	tween.tween_callback(func():
		self.hide()
	)
	return tween

func enter():
	STooltip.close()
	
	self.show()
	panel.show()
	
	var sel = list.get_selected_items()
	if sel.is_empty():
		for i in list.item_count:
			if !list.is_item_disabled(i):
				list.select(i)
				break
	
	var tween = G.create_tween()
	tween.tween_property(panel, "position:y", panel.position.y, 0.5).from(panel.position.y + 100).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	self.self_modulate.a = 0.0
	tween.parallel().tween_property(self, "self_modulate:a", 1.0, 0.3)

func start_new_game():
	var sel = list.get_selected_items()
	if sel.is_empty():
		return
	if sel[0] == 0:
		seed_edit.text = "566DC5"
	G.begin_busy()
	var tween = G.create_tween()
	exit(tween, true)
	G.title_ui.exit(tween)
	tween.tween_callback(func():
		G.new_game({"seed":seed_edit.text.hex_to_int()})
	)
	G.begin_transition(tween)
	tween.tween_callback(func():
		G.enter_game()
	)
	G.end_transition(tween)
	tween.tween_interval(0.8)
	tween.tween_callback(func():
		G.start_first_round()
	)
	if sel[0] == 0:
		tween.tween_callback(func():
			G.tutorial_ui.start()
		)

func _ready() -> void:
	start_button.pressed.connect(func():
		SSound.se_click.play()
		SSound.music_more_clear()
		G.screen_shake_strength = 8.0
		
		start_new_game()
		#G.dialog_ui.open("Warning", "Overwrite the save?", 2, start_new_game)
	)
	start_button.mouse_entered.connect(SSound.se_select.play)
	close_button.pressed.connect(func():
		SSound.se_click.play()
		SSound.music_more_clear()
		G.screen_shake_strength = 8.0
		
		exit()
	)
	close_button.mouse_entered.connect(SSound.se_select.play)
