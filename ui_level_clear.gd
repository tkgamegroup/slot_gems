extends Control

const ui_settlement = preload("res://ui_settlement.tscn")

@onready var title : RichTextLabel = $VBoxContainer/Label
@onready var continue_button : Button = $VBoxContainer/Button
@onready var settlement_list : VBoxContainer = $VBoxContainer
@onready var particles = $CPUParticles2D
var rewards_count = 0
var gold = 0

func enter():
	Sounds.sfx_level_clear.play()
	Game.ui_blocker.show()
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
		var ui_s = ui_settlement.instantiate()
		ui_s.name_str = "Level Rewards"
		ui_s.value_str = "5G"
		settlement_list.add_child(ui_s)
		settlement_list.move_child(ui_s, settlement_list.get_child_count() - 2)
	)
	gold += 5
	tween.tween_interval(0.6)
	tween.tween_callback(func():
		var ui_s = ui_settlement.instantiate()
		ui_s.name_str = "Rolls"
		ui_s.value_str = "%dG" % Game.rolls
		settlement_list.add_child(ui_s)
		settlement_list.move_child(ui_s, settlement_list.get_child_count() - 2)
	)
	gold += Game.rolls
	tween.tween_interval(0.5)
	tween.tween_callback(func():
		rewards_count += 1
		var reward_btn = Button.new()
		reward_btn.text = "Take %dG" % gold
		reward_btn.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
		settlement_list.add_child(reward_btn)
		settlement_list.move_child(reward_btn, settlement_list.get_child_count() - 2)
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
		reward_btn.text = "Select a Gem"
		reward_btn.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
		settlement_list.add_child(reward_btn)
		settlement_list.move_child(reward_btn, settlement_list.get_child_count() - 2)
		reward_btn.pressed.connect(func():
			reward_btn.get_parent().remove_child(reward_btn)
			reward_btn.queue_free()
			rewards_count -= 1
			if rewards_count == 0:
				continue_button.disabled = false
			
			var names = Gem.get_name_list(5)
			var arr : Array[Dictionary] = []
			for i in 3:
				var g = Gem.new()
				g.setup(names.pick_random())
				var r = {}
				r.icon = g.image_id
				r.title = g.display_name
				r.description = g.description
				r.category = g.category
				r.gem = g
				arr.append(r)
			Game.choose_reward_ui.enter(arr, func(idx : int, tween : Tween, img : AnimatedSprite2D):
				if idx != -1:
					tween.tween_property(img, "scale", Vector2(1.0, 1.0), 0.5)
					var p0 = img.global_position
					var p2 = Game.bag_button.get_global_rect().get_center()
					var p1 = p2 + Vector2(0, 100)
					tween.parallel().tween_method(func(t):
						img.global_position = Math.quadratic_bezier(p0, p1, p2, t)
					, 0.0, 1.0, 0.7)
					tween.tween_callback(func():
						Game.gems.append(arr[idx].gem)
					)
			)
		)
	)
	tween.tween_interval(0.3)
	tween.tween_callback(func():
		continue_button.show()
	)

func _ready() -> void:
	continue_button.pressed.connect(func():
		Sounds.sfx_click.play()
		for t in get_tree().get_processed_tweens():
			t.kill()
		Game.ui_blocker.hide()
		Game.game_ui.exit()
		self.hide()
		Game.shop_ui.enter()
	)
	#continue_button.mouse_entered.connect(Sounds.sfx_select.play)
