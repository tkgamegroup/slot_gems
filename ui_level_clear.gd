extends Control

const settlement_ui = preload("res://ui_settlement.tscn")
const gem_ui = preload("res://ui_gem.tscn")

@onready var title : RichTextLabel = $VBoxContainer/Label
@onready var continue_button : Button = $VBoxContainer/Button
@onready var settlement_list : VBoxContainer = $VBoxContainer
@onready var particles = $CPUParticles2D
var rewards_count = 0
var gold = 0

func enter():
	Sounds.sfx_level_clear.play()
	Tooltip.close()
	Game.blocker_ui.enter()
	self.show()
	gold = 0
	while settlement_list.get_child_count() > 2:
		var n = settlement_list.get_child(1)
		settlement_list.remove_child(n)
		n.queue_free()
	continue_button.disabled = true
	continue_button.hide()
	title.text = "[popup span=12.0 dura=1.2]Level Clear![/popup]"
	particles.emitting = true
	var tween = get_tree().create_tween()
	tween.tween_interval(0.6)
	tween.tween_callback(func():
		var ui_s = settlement_ui.instantiate()
		ui_s.name_str = "Level Rewards"
		ui_s.value_str = "5[img]res://images/coin.png[/img]"
		settlement_list.add_child(ui_s)
		settlement_list.move_child(ui_s, settlement_list.get_child_count() - 2)
	)
	gold += 5
	tween.tween_interval(0.6)
	tween.tween_callback(func():
		var ui_s = settlement_ui.instantiate()
		ui_s.name_str = "Rolls"
		ui_s.value_str = "%d[img]res://images/coin.png[/img]" % Game.rolls
		settlement_list.add_child(ui_s)
		settlement_list.move_child(ui_s, settlement_list.get_child_count() - 2)
	)
	gold += Game.rolls
	tween.tween_interval(0.5)
	tween.tween_callback(func():
		rewards_count += 1
		var reward_btn = Button.new()
		reward_btn.text = " "
		var rich_txt = RichTextLabel.new()
		rich_txt.bbcode_enabled = true
		rich_txt.fit_content = true
		rich_txt.autowrap_mode = TextServer.AUTOWRAP_OFF
		rich_txt.text = "Take %d[img]res://images/coin.png[/img]" % gold
		rich_txt.mouse_filter = Control.MOUSE_FILTER_IGNORE
		reward_btn.add_child(rich_txt)
		reward_btn.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
		settlement_list.add_child(reward_btn)
		settlement_list.move_child(reward_btn, settlement_list.get_child_count() - 2)
		rich_txt.set_anchors_and_offsets_preset(Control.PRESET_CENTER, Control.PRESET_MODE_KEEP_SIZE)
		reward_btn.pressed.connect(func():
			Sounds.sfx_coin.play()
			reward_btn.get_parent().remove_child(reward_btn)
			reward_btn.queue_free()
			rewards_count -= 1
			if rewards_count == 0:
				continue_button.disabled = false
			
			Game.gold += gold
		)
	)
	tween.tween_interval(0.5)
	tween.tween_callback(func():
		rewards_count += 1
		var reward_btn = Button.new()
		reward_btn.text = "Select a Reward"
		reward_btn.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
		settlement_list.add_child(reward_btn)
		settlement_list.move_child(reward_btn, settlement_list.get_child_count() - 2)
		reward_btn.pressed.connect(func():
			reward_btn.get_parent().remove_child(reward_btn)
			reward_btn.queue_free()
			rewards_count -= 1
			if rewards_count == 0:
				continue_button.disabled = false
			
			var rewards = []
			
			var r1 = {}
			r1.icon = "res://images/add_gems.png"
			r1.title = "Add Gems"
			r1.description = "Add 5 gems with 4 base score. You can choose what color to add."
			rewards.append(r1)
			
			var r2 = {}
			r2.icon = "res://images/trash_bin.png"
			r2.title = "Remove Gems"
			r2.description = "Remove up to 5 basic gems. You can choose what color to remove."
			rewards.append(r2)
			
			Game.blocker_ui.move(get_index())
			Game.choose_reward_ui.enter(rewards, func(idx : int, tween : Tween, img : Sprite2D):
				if idx == 0:
					tween.tween_callback(func():
						var arr = []
						for i in Gem.Type.Count:
							var r = {}
							var name = Gem.type_name(i + 1)
							r.icon = Gem.type_img(i + 1)
							r.title = name + " x5"
							r.description = "Add 5 %s gems, the runes are random. They have 4 base score." % name
							arr.append(r)
						var tween2 = get_tree().create_tween()
						tween2.tween_callback(func():
							Game.choose_reward_ui.enter(arr, func(idx : int, tween3 : Tween, img : Sprite2D):
								if idx != -1:
									tween3.tween_property(img, "scale", Vector2(1.0, 1.0), 0.5)
									tween3.parallel()
									Animations.curve_to(tween3, img, Game.bag_button.get_global_rect().get_center(), 0.1, Vector2(0, 150), 0.9, Vector2(0, 100), 0.7)
									tween3.tween_callback(func():
										for i in 5:
											var g = Gem.new()
											g.setup(Gem.type_name(idx + 1))
											g.rune = randi_range(1, Gem.Rune.Count)
											g.base_score = 4
											Game.gems.append(g)
										Game.sort_gems()
										Game.blocker_ui.move(-1)
									)
							)
						)
					)
				elif idx == 1:
					tween.tween_callback(func():
						Game.gems_viewer_ui.enter(5, "Select up to 5 gems to Remove", func(gems):
							var bag_pos = Game.bag_button.get_global_rect().get_center()
							var base_pos = self.get_global_rect().get_center() + Vector2(-16 * (gems.size() - 1), 200)
							var uis = []
							for g in gems:
								var ui = gem_ui.instantiate()
								ui.set_image(g.type, g.rune, g.image_id)
								Game.blocker_ui.add_child(ui)
								ui.global_position = bag_pos
								ui.hide()
								uis.append(ui)
							var tween2 = get_tree().create_tween()
							for i in gems.size():
								tween2.tween_interval(0.2)
								tween2.tween_callback(func():
									var ui = uis[i]
									ui.show()
									var tween3 = get_tree().create_tween()
									Animations.curve_to(tween3, ui, base_pos + i * Vector2(32, 0), 0.1, Vector2(0, 100), 0.9, Vector2(0, 150), 0.7)
								)
							tween2.tween_interval(1.0)
							tween2.tween_callback(func():
								for ui in uis:
									ui.dissolve(0.5)
							)
							tween2.tween_interval(0.5)
							tween2.tween_callback(func():
								for ui in uis:
									ui.queue_free()
								for g in gems:
									Game.gems.erase(g)
								Game.blocker_ui.move(-1)
							)
						)
					)
			)
		)
	)
	tween.tween_interval(0.3)
	tween.tween_callback(func():
		continue_button.show()
	)

func exit():
	Game.blocker_ui.exit()
	self.hide()

func _ready() -> void:
	continue_button.pressed.connect(func():
		Sounds.sfx_click.play()
		for t in get_tree().get_processed_tweens():
			t.kill()
		exit()
		Game.game_ui.exit()
		Game.shop_ui.enter()
	)
	#continue_button.mouse_entered.connect(Sounds.sfx_select.play)
