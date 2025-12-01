extends Node

enum Stage
{
	Deploy,
	Rolling,
	Matching,
	GameOver,
	Settlement,
	Upgrade,
	Shopping
}

const version_major : int = 1
const version_minor : int = 0
const version_patch : int = 4

const MaxRelics : int = 5
const MaxPatterns : int = 4

const UiGem = preload("res://ui_gem.gd")
const UiCell = preload("res://ui_cell.gd")
const UiTitle = preload("res://ui_title.gd")
const UiControl = preload("res://ui_control.gd")
const UiShop = preload("res://ui_shop.gd")
const UiShopItem = preload("res://ui_shop_item.gd")
const CraftSlot = preload("res://craft_slot.gd")
const UiStatusBar = preload("res://ui_status_bar.gd")
const UiRelicsBar = preload("res://ui_relics_bar.gd")
const UiPatternsBar = preload("res://ui_patterns_bar.gd")
const UiCalculatorBar = preload("res://ui_calculate_bar.gd")
const UiBanner = preload("res://banner.gd")
const UiDialog = preload("res://ui_dialog.gd")
const UiOptions = preload("res://ui_options.gd")
const UiCollections = preload("res://ui_collections.gd")
const UiInGameMenu = preload("res://ui_in_game_menu.gd")
const UiGameOver = preload("res://ui_game_over.gd")
const UiSettlement = preload("res://ui_settlement.gd")
const UiUpgrade = preload("res://ui_upgrade.gd")
const UiChooseReward = preload("res://ui_choose_reward.gd")
const UiBagViewer = preload("res://ui_bag_viewer.gd")
const UiTutorial = preload("res://ui_tutorial.gd")
const gem_ui = preload("res://ui_gem.tscn")
const popup_txt_pb = preload("res://popup_txt.tscn")
const trail_pb = preload("res://trail.tscn")
const craft_slot_pb = preload("res://craft_slot.tscn")
const shop_item_pb = preload("res://ui_shop_item.tscn")
const settlement_item_pb = preload("res://ui_settlement_item.tscn")
const mask_shader = preload("res://materials/mask.gdshader")
const pointer_cursor = preload("res://images/pointer.png")
const pin_cursor = preload("res://images/pin.png")
const activate_cursor = preload("res://images/magic_stick.png")
const grab_cursor = preload("res://images/grab.png")

@onready var background : Node2D = $/root/Main/SubViewportContainer/SubViewport/Background
@onready var crt : Control = $/root/Main/PostProcessing/ColorRect
@onready var trans_bg : Control = $/root/Main/TransBG
@onready var trans_sp : AnimatedSprite2D = $/root/Main/TransBG/Control/AnimatedSprite2D
@onready var subviewport_container : SubViewportContainer = $/root/Main/SubViewportContainer
@onready var subviewport : SubViewport = $/root/Main/SubViewportContainer/SubViewport
@onready var canvas : CanvasLayer = $/root/Main/SubViewportContainer/SubViewport/Canvas
@onready var game_tweens : Node2D = $/root/Main/SubViewportContainer/SubViewport/Canvas/GameTweens
@onready var title_ui : UiTitle = $/root/Main/SubViewportContainer/SubViewport/Canvas/Title
@onready var control_ui : UiControl = $/root/Main/SubViewportContainer/SubViewport/Canvas/GameControl
@onready var shop_ui : UiShop = $/root/Main/SubViewportContainer/SubViewport/Canvas/Shop
@onready var game_ui : Control = $/root/Main/SubViewportContainer/SubViewport/Canvas/GameUI
@onready var game_overlay : Control = $/root/Main/SubViewportContainer/SubViewport/Canvas/GameUI/Overlay
@onready var status_bar_ui : UiStatusBar = $/root/Main/SubViewportContainer/SubViewport/Canvas/GameUI/VBoxContainer/MarginContainer/TopBar/VBoxContainer/MarginContainer/StatusBar
@onready var relics_bar_ui : UiRelicsBar = $/root/Main/SubViewportContainer/SubViewport/Canvas/GameUI/VBoxContainer/Control/MarginContainer/RelicsBar
@onready var patterns_bar_ui : UiPatternsBar = $/root/Main/SubViewportContainer/SubViewport/Canvas/GameUI/VBoxContainer/Control/MarginContainer2/PatternsBar
@onready var calculator_bar_ui : UiCalculatorBar = $/root/Main/SubViewportContainer/SubViewport/Canvas/CalculateBar
@onready var banner_ui : UiBanner = $/root/Main/SubViewportContainer/SubViewport/Canvas/Banner
@onready var dialog_ui : UiDialog = $/root/Main/SubViewportContainer/SubViewport/Canvas/Dialog
@onready var options_ui : UiOptions = $/root/Main/SubViewportContainer/SubViewport/Canvas/Options
@onready var collections_ui : UiCollections = $/root/Main/SubViewportContainer/SubViewport/Canvas/Collections
@onready var bag_viewer_ui : UiBagViewer = $/root/Main/SubViewportContainer/SubViewport/Canvas/BagViewer
@onready var tutorial_ui : UiTutorial = $/root/Main/SubViewportContainer/SubViewport/Canvas/Tutorial
@onready var in_game_menu_ui : UiInGameMenu = $/root/Main/SubViewportContainer/SubViewport/Canvas/InGameMenu
@onready var game_over_ui : UiGameOver = $/root/Main/SubViewportContainer/SubViewport/Canvas/GameOver
@onready var settlement_ui : UiSettlement = $/root/Main/SubViewportContainer/SubViewport/Canvas/Settlement
@onready var upgrade_ui : UiUpgrade = $/root/Main/SubViewportContainer/SubViewport/Canvas/Upgrade
@onready var choose_reward_ui : UiChooseReward = $/root/Main/SubViewportContainer/SubViewport/Canvas/ChooseReward
@onready var command_line_edit : LineEdit = $/root/Main/SubViewportContainer/SubViewport/Canvas/CommandLine
@onready var blocker_ui : Control = $/root/Main/SubViewportContainer/SubViewport/Canvas/Blocker

var stage : int = Stage.Deploy
var game_rng : RandomNumberGenerator = RandomNumberGenerator.new()
var round_rng : RandomNumberGenerator = RandomNumberGenerator.new()
var shop_rng : RandomNumberGenerator = RandomNumberGenerator.new()
var rolls : int:
	set(v):
		rolls = v
		control_ui.rolls_text.text = "%d" % rolls
var rolls_per_round : int
var swaps : int:
	set(v):
		swaps = v
		control_ui.swaps_text.set_value(swaps)
var swaps_per_round : int
var plays : int:
	set(v):
		plays = v
		control_ui.plays_text.text = "%d" % plays
var plays_per_round : int
var draws_per_roll : int
var next_roll_extra_draws : int = 0
var max_hand_grabs : int:
	set(v):
		max_hand_grabs = v
		if Hand.grabs.size() < max_hand_grabs:
			for i in (max_hand_grabs - Hand.grabs.size()):
				Hand.draw()
		if Hand.ui:
			Hand.ui.resize()
			status_bar_ui.hand_text.set_value(App.max_hand_grabs)
var pins_num : int:
	set(v):
		pins_num = v
		if pins_num > 0:
			control_ui.pin_ui.show()
			control_ui.pin_ui.num.text = "%d" % pins_num
		else:
			control_ui.pin_ui.hide()
var pins_num_per_round : int
var activates_num : int:
	set(v):
		activates_num = v
		if activates_num > 0:
			control_ui.activate_ui.show()
			control_ui.activate_ui.num.text = "%d" % activates_num
		else:
			control_ui.activate_ui.hide()
var activates_num_per_round : int
var grabs_num : int = 5:
	set(v):
		grabs_num = v
		if grabs_num > 0:
			control_ui.grab_ui.show()
			control_ui.grab_ui.num.text = "%d" % grabs_num
		else:
			control_ui.grab_ui.hide()
var grabs_num_per_round : int
var action_stack : Array[Pair]
var board_size : int = 3:
	set(v):
		board_size = v
		status_bar_ui.board_size_text.set_value(board_size)
var patterns : Array[Pattern]
var gems : Array[Gem]
var bag_gems : Array[Gem] = []
var items : Array[Item]
var relics : Array[Relic]
var event_listeners : Array[Hook]
var round : int
var score : int:
	set(v):
		score = v
		status_bar_ui.score_text.text = "%d" % score
var target_score : int
var reward : int
var current_curses : Array[Curse]
var round_curses : Array[Array]
var no_score_marks : Dictionary[int, Array]
var base_score_tween : Tween = null
var base_score : int:
	set(v):
		if v > base_score:
			base_score = v
			if base_score_tween:
				base_score_tween.custom_step(100.0)
			calculator_bar_ui.base_score_text.position.y = 4
			calculator_bar_ui.base_score_text.text = "%d" % v
			base_score_tween = App.create_tween()
			base_score_tween.tween_property(calculator_bar_ui.base_score_text, "position:y", 0, 0.2 * App.speed)
			base_score_tween.tween_callback(func():
				base_score_tween = null
			)
		else:
			if base_score_tween:
				base_score_tween.kill()
				base_score_tween = null
			base_score = v
			calculator_bar_ui.base_score_text.text = "%d" % base_score
var staging_scores : Array[Pair]
var staging_mults : Array[Pair]
var combos_tween : Tween
var combos : int = 0:
	set(v):
		if v > combos:
			combos = v
			if combos_tween:
				combos_tween.custom_step(100.0)
				combos_tween = null
			if calculator_bar_ui.visible:
				calculator_bar_ui.combos_text.position.y = 0
				combos_tween = App.create_tween()
				SAnimation.jump(combos_tween, calculator_bar_ui.combos_text, -0.0, 0.25 * App.speed, func():
					calculator_bar_ui.combos_text.text = "%dX" % v
				)
				combos_tween.tween_callback(func():
					combos_tween = null
				)
		else:
			if combos_tween:
				combos_tween.kill()
				combos_tween = null
			combos = v
			calculator_bar_ui.combos_text.text = "%dX" % combos
const one_over_log1_5 = 1.0 / log(1.5)
func mult_from_combos(combos : int):
	return log((combos + 1) * 1.0) * one_over_log1_5
var gain_scaler : float = 1.0
var score_mult_tween : Tween = null
var score_mult : float = 1.0:
	set(v):
		if v > score_mult:
			score_mult = v
			if score_mult_tween:
				score_mult_tween.custom_step(100.0)
			calculator_bar_ui.mult_text.position.y = 4
			calculator_bar_ui.mult_text.text = "%.1f" % v
			score_mult_tween = App.create_tween()
			score_mult_tween.tween_property(calculator_bar_ui.mult_text, "position:y", 0, 0.2 * App.speed)
			score_mult_tween.tween_callback(func():
				score_mult_tween = null
			)
		else:
			if score_mult_tween:
				score_mult_tween.kill()
				score_mult_tween = null
			score_mult = v
			calculator_bar_ui.mult_text.text = "%.1f" % score_mult
var game_over_mark : String = ""
var coins : int = 10:
	set(v):
		coins = v
		status_bar_ui.coins_text.set_value(coins)
var buffs : Array[Buff]
var history : History = History.new()

var modifiers : Dictionary

var base_speed : float = 1.0
var speed : float = 1.0 / base_speed
const FillingTimesToShow = 10
const FillingTimesToWin = 60
var filling_times : int = 0:
	set(v):
		filling_times = v
		if filling_times >= FillingTimesToShow:
			if !control_ui.filling_times_text_container.visible:
				control_ui.filling_times_text_container.show()
				control_ui.filling_times_text_container.pivot_offset = control_ui.filling_times_text_container.size * 0.5
				control_ui.filling_times_text_container.scale = Vector2(0.0, 0.0)
				var tween = App.create_tween()
				tween.tween_property(control_ui.filling_times_text_container, "scale", Vector2(1.0, 1.0), 0.15).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUART)
			if control_ui.filling_times_tween:
				control_ui.filling_times_tween.custom_step(100.0)
				control_ui.filling_times_tween = null
			if control_ui.filling_times_text_container.visible:
				control_ui.filling_times_text.position.y = 0
				control_ui.filling_times_tween = App.create_tween()
				SAnimation.jump(control_ui.filling_times_tween, control_ui.filling_times_text, -0.0, 0.25 * App.speed, func():
					control_ui.filling_times_text.text = "%d" % filling_times
				)
				control_ui.filling_times_tween.tween_callback(func():
					control_ui.filling_times_tween = null
				)

const resolution : Vector2i = Vector2i(1920, 1080)
var crt_mode : bool = true:
	set(v):
		if crt_mode != v:
			crt_mode = v
			if crt_mode && !performance_mode:
				crt.show()
			else:
				crt.hide()
var screen_shake_strength : float = 0.0
var screen_shake_noise : Noise
var screen_shake_noise_coord : float
var mouse_pos : Vector2
var screen_offset : Vector2
var performance_mode : bool = false:
	set(v):
		if performance_mode != v:
			performance_mode = v
			if !performance_mode:
				background.show()
			else:
				background.hide()
			if crt_mode && !performance_mode:
				crt.show()
			else:
				crt.hide()
var invincible : bool = false

func add_gem(g : Gem, boardcast : bool = true):
	if boardcast:
		for h in event_listeners:
			if h.event == Event.GainGem:
				h.host.on_event.call(Event.GainGem, null, g)
	gems.append(g)
	bag_gems.append(g)
	
	status_bar_ui.gem_count_text.text = "%d" % gems.size()

func remove_gem(g : Gem, boardcast : bool = true):
	bag_gems.erase(g)
	gems.erase(g)
	
	if boardcast:
		for h in event_listeners:
			if h.event == Event.GainGem:
				h.host.on_event.call(Event.LostGem, null, g)
	
	status_bar_ui.gem_count_text.text = "%d" % gems.size()

func get_gem(g : Gem = null) -> Gem:
	if g:
		bag_gems.erase(g)
		return g
	if bag_gems.is_empty():
		return null
	return SMath.pick_and_remove(bag_gems, App.game_rng)

func release_gem(g : Gem):
	g.bonus_score = 0
	g.coord = Vector2i(-1, -1)
	Buff.clear(g, [Buff.Duration.ThisCombo, Buff.Duration.ThisMatching, Buff.Duration.OnBoard])
	bag_gems.append(g)

func sort_gems():
	gems.sort_custom(func(a, b):
		return a.get_rank() < b.get_rank()
	)

func on_modifier_changed(name):
	if name == "base_combo_i":
		combos = max(combos, modifiers["base_combo_i"])
	elif name == "red_bouns_i":
		status_bar_ui.red_bouns_text.set_value(modifiers["red_bouns_i"])
	elif name == "orange_bouns_i":
		status_bar_ui.orange_bouns_text.set_value(modifiers["orange_bouns_i"])
	elif name == "green_bouns_i":
		status_bar_ui.green_bouns_text.set_value(modifiers["green_bouns_i"])
	elif name == "blue_bouns_i":
		status_bar_ui.blue_bouns_text.set_value(modifiers["blue_bouns_i"])
	elif name == "magenta_bouns_i":
		status_bar_ui.magenta_bouns_text.set_value(modifiers["magenta_bouns_i"])
	for h in event_listeners:
		if h.event == Event.ModifierChanged:
			h.host.on_event.call(Event.ModifierChanged, null, {"name":name,"value":modifiers[name]})

func set_modifier(name : String, v):
	modifiers[name] = v
	on_modifier_changed(name)

func change_modifier(name : String, v):
	modifiers[name] += v
	on_modifier_changed(name)

func gem_add_base_score(g : Gem, v : int):
	for h in event_listeners:
		if h.event == Event.GainGem:
			h.host.on_event.call(Event.GemBaseScoreChanged, null, {"gem":g,"value":v})
	g.base_score += v
	return v

func gem_add_bonus_score(g : Gem, v : int):
	for h in event_listeners:
		if h.event == Event.GainGem:
			h.host.on_event.call(Event.GemBonusScoreChanged, null, {"gem":g,"value":v})
	g.bonus_score += v
	return 

func add_pattern(p : Pattern, boardcast : bool = true):
	if boardcast:
		for h in event_listeners:
			if h.event == Event.GainPattern:
				h.host.on_event.call(Event.GainPattern, null, p)
	patterns.append(p)
	patterns_bar_ui.add_ui(p)

func add_relic(r : Relic, boardcast : bool = true):
	if boardcast:
		if r.on_event.is_valid():
			r.on_event.call(Event.GainRelic, null, r)
		for h in event_listeners:
			if h.event == Event.GainRelic:
				h.host.on_event.call(Event.GainRelic, null, r)
	relics.append(r)
	relics_bar_ui.add_ui(r)

func remove_relic(r : Relic):
	if r.on_event.is_valid():
		r.on_event.call(Event.LostRelic, null, r)
	for h in event_listeners:
		if h.event == Event.LostRelic:
			h.host.on_event.call(Event.LostRelic, null, r)
	relics.erase(r)
	relics_bar_ui.remove_ui(r)

func has_relic(n : String):
	for r in relics:
		if r.name == n:
			return true
	return false

func add_combo():
	combos += 1
	Buff.clear(self, [Buff.Duration.ThisCombo])
	Board.on_combo()

func float_text(txt : String, pos : Vector2, color : Color = Color(1.0, 1.0, 1.0, 1.0), font_size : int = 16):
	pos += Vector2(randf() * 10.0 - 5.0, randf() * 10.0 - 5.0)
	var ui = popup_txt_pb.instantiate()
	ui.position = pos
	var lb : Label = ui.get_child(0)
	lb.text = txt
	lb.add_theme_color_override("font_color", color)
	lb.add_theme_font_size_override("font_size", font_size)
	ui.z_index = 4
	Board.ui.overlay.add_child(ui)
	var tween = App.create_tween()
	tween.tween_property(ui, "position", pos - Vector2(0, 20), 0.5)
	tween.tween_callback(func():
		ui.queue_free()
	)

var add_score_dir : int = 1
func add_score(value : int, pos : Vector2):
	value = int(value * gain_scaler)
	pos += Vector2(randf() * 4.0 - 2.0, randf() * 4.0 - 2.0)
	var ui = popup_txt_pb.instantiate()
	ui.position = pos
	ui.scale = Vector2(1.5, 1.5)
	var lb : Label = ui.get_child(0)
	lb.text = "%d" % value
	ui.z_index = 8
	Board.ui.overlay.add_child(ui)
	
	staging_scores.append(Pair.new(ui, value))
	
	var tween = App.create_tween()
	tween.tween_property(ui, "position:y", pos.y - 20, 0.1)
	tween.tween_property(ui, "position:x", pos.x + add_score_dir * 5, 0.2)
	tween.parallel().tween_property(ui, "position:y", pos.y, 0.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween.tween_callback(func():
		lb.hide()
	)
	
	add_score_dir *= -1

var add_mult_dir : int = 1
func add_mult(value : float, pos : Vector2):
	value = value * gain_scaler
	pos += Vector2(randf() * 4.0 - 2.0, randf() * 4.0 - 2.0)
	var ui = popup_txt_pb.instantiate()
	ui.position = pos
	ui.scale = Vector2(1.3, 1.3)
	var lb : Label = ui.get_child(0)
	lb.text = "%.2f" % value
	lb.add_theme_color_override("font_color", Color(1.0, 0.8, 0.3))
	ui.z_index = 6
	Board.ui.overlay.add_child(ui)
	
	staging_mults.append(Pair.new(ui, value))
	
	var tween = App.create_tween()
	tween.tween_property(ui, "position:y", pos.y - 20, 0.1)
	tween.tween_property(ui, "position:x", pos.x + add_mult_dir * 5, 0.2)
	tween.parallel().tween_property(ui, "position:y", pos.y, 0.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween.tween_callback(func():
		lb.hide()
	)
	
	add_mult_dir *= -1

var status_tween : Tween
func float_status_text(s : String, col : Color):
	control_ui.status_text.show()
	control_ui.status_text.text = s
	var parent = control_ui.status_text.get_parent()
	parent.scale = Vector2(1.3, 1.3)
	control_ui.status_text.add_theme_color_override("font_color", col)
	if status_tween:
		status_tween.kill()
	status_tween = App.create_tween()
	status_tween.tween_method(func(t):
		parent.rotation_degrees = sin(t * PI * 10.0) * t * 10.0
	, 1.0, 0.0, 1.0)
	status_tween.parallel().tween_property(parent, "scale", Vector2(1.0, 1.0), 1.0)
	status_tween.tween_interval(0.5)
	status_tween.tween_callback(func():
		control_ui.status_text.hide()
		status_tween = null
	)

func create_gem_ui(g : Gem, pos : Vector2, need_trail : bool = false):
	var ui = gem_ui.instantiate()
	ui.update(g)
	ui.global_position = pos
	if need_trail:
		var trail = trail_pb.instantiate()
		trail.setup(10.0, Gem.type_color(g.type))
		ui.add_child(trail)
	App.game_overlay.add_child(ui)
	return ui

func delete_gem(g : Gem, ui, from : String = "hand"):
	var old_coord = g.coord
	SSound.se_trash.play()
	ui.dissolve(0.5)
	var tween = App.game_tweens.create_tween()
	tween.tween_interval(0.5)
	tween.tween_callback(func():
		if from == "hand":
			Hand.erase(Hand.find(g))
		remove_gem(g)
		if App.gems.size() < Board.curr_min_gem_num:
			App.game_over_mark = "not_enough_gems"
			App.lose()
		else:
			if from == "hand" || from == "craft_slot":
				Hand.draw(false)
			elif from == "board":
				Board.set_gem_at(old_coord, null)
				Board.fill_blanks()
	)

func copy_gem(src : Gem, dst : Gem):
	dst.type = src.type
	dst.rune = src.rune
	dst.base_score = src.base_score
	dst.bonus_score = src.bonus_score
	dst.base_mult = src.base_mult
	dst.bonus_mult = src.bonus_mult
	for b in src.buffs:
		var new_b = Buff.new()
		new_b.uid = Buff.s_uid
		Buff.s_uid += 1
		new_b.type = b.type
		new_b.host = dst
		new_b.duration = b.duration
		new_b.data = b.data.duplicate(true)
		dst.buffs.append(new_b)

func duplicate_gem(g : Gem, ui, from : String = "hand"):
	SSound.se_enchant.play()
	var new_ui = create_gem_ui(g, ui.global_position)
	if from == "hand":
		new_ui.position += Vector2(16.0, 16.0)
	var tween = App.game_tweens.create_tween()
	tween.tween_property(new_ui, "position", new_ui.position + Vector2(0.0, -40.0), 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)
	tween.tween_callback(func():
		new_ui.add_child(trail_pb.instantiate())
	)
	tween.tween_property(new_ui, "position", status_bar_ui.bag_button.get_global_rect().get_center(), 0.5).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUART)
	tween.parallel().tween_property(new_ui, "scale", Vector2(0.2, 0.2), 0.5).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUART)
	tween.tween_callback(func():
		new_ui.queue_free()
		var new_g = Gem.new()
		copy_gem(g, new_g)
		add_gem(new_g)
		sort_gems()
	)

func enchant_gem(g : Gem, type : String):
	var bid = -1
	if type == "w_enchant_charming":
		bid = Buff.create(g, Buff.Type.ValueModifier, {"target":"base_score","add":200}, Buff.Duration.Eternal)
	elif type == "w_enchant_sharp":
		bid = Buff.create(g, Buff.Type.ValueModifier, {"target":"base_mult","add":1.5}, Buff.Duration.Eternal)
	Buff.create(g, Buff.Type.Enchant, {"type":type,"bid":bid}, Buff.Duration.Eternal)

func swap_hand_and_board(slot1 : Control, coord : Vector2i, reason : String = "swap"):
	var tween = App.game_tweens.create_tween()
	var g1 = slot1.gem
	var g2 = Board.get_gem_at(coord)
	var cell_pos = Board.get_pos(coord)
	var mpos = get_viewport().get_mouse_position()
	var hf_sz = Vector2(Board.tile_sz, Board.tile_sz) * 0.5
	App.begin_busy()
	slot1.elastic = -1.0
	var slot2 = Hand.add_gem(g2)
	slot2.global_position = cell_pos - hf_sz
	slot2.elastic = -1.0
	tween.tween_callback(func():
		slot1.z_index = 10
	)
	tween.tween_interval(0.1)
	tween.tween_callback(func():
		SSound.se_drop_item.play()
		Board.set_gem_at(coord, null)
	)
	var sub1 = App.game_tweens.create_tween()
	var sub2 = App.game_tweens.create_tween()
	var dir = mpos - cell_pos
	var a = 0.0
	var sec = 0
	if reason == "undo":
		a = 90.0
		sec = 1
	else:
		a = rad_to_deg(dir.angle())
		if a < 0.0:
			a += 360.0
		sec = int(a / 60.0)
		a = sec * 60.0 + 30.0
	dir = Vector2.from_angle(deg_to_rad(a))
	sub1.tween_property(slot1, "global_position", cell_pos - hf_sz + dir * Board.tile_sz * 0.75, 0.15).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)
	sub1.tween_property(slot1, "global_position", cell_pos - hf_sz, 0.2)
	sub2.tween_interval(0.1)
	var rot = Vector2(0.0, 0.0)
	match sec:
		0: rot = Vector2(-75.0, 30.0)
		1: rot = Vector2(-75.0, 0.0)
		2: rot = Vector2(-75.0, -30.0)
		3: rot = Vector2(75.0, -30.0)
		4: rot = Vector2(75.0, 0.0)
		5: rot = Vector2(75.0, 30.0)
	sub2.tween_property(slot2.gem_ui, "angle", rot, 0.07)
	sub2.tween_property(slot2, "global_position", cell_pos - hf_sz - dir * Board.tile_sz * 0.75, 0.15).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)
	sub2.parallel().tween_property(slot2.gem_ui, "angle", Vector2(0.0, 0.0), 0.07)
	sub2.tween_property(slot2, "elastic", 1.0, 0.2).from(0.0)
	tween.tween_subtween(sub1)
	tween.parallel().tween_subtween(sub2)
	
	tween.tween_callback(func():
		Board.set_gem_at(coord, g1)
		Hand.erase(slot1.get_index())
		control_ui.update_preview()
		App.end_busy()
	)

func process_command_line(cl : String):
	var tokens = []
	var lq = -1
	var rt = 0
	for i in cl.length():
		var ch = cl[i]
		if ch == "\"":
			if lq != -1:
				tokens.append(cl.substr(lq, i - lq))
				lq = -1
				rt = i + 1
			else:
				tokens.append_array(cl.substr(rt, i - rt).split(" ", false))
				lq = i + 1
		else:
			if i == cl.length() - 1:
				tokens.append_array(cl.substr(rt).split(" ", false))
	if !tokens.is_empty():
		var cmd = tokens[0]
		for i in tokens.size():
			var t = tokens[i]
			if t.length() >= 2 && t[0] == '"' && t[t.length() - 1] == '"':
				tokens[i] = t.substr(1, t.length() - 2)
		if cmd == "test_matching":
			var tokens2 = tokens[1].split(",")
			var coord = Vector2i(int(tokens2[0]), int(tokens2[1]))
			for p in App.patterns:
				p.match_with(coord)
		elif cmd == "win":
			App.win()
		elif cmd == "lose":
			App.lose()
		elif cmd == "shop":
			App.shop_ui.enter()
		elif cmd == "swap":
			App.swaps += int(tokens[1])
		elif cmd == "gold":
			App.coins += int(tokens[1])
		elif cmd == "ai":
			var num = 1
			var tt = tokens[1]
			if tt.is_valid_int():
				num = int(tt)
				tt = tokens[2]
			for j in num:
				var i = Item.new()
				i.setup(tt)
				App.add_item(i)
		elif cmd == "ar":
			var r = Relic.new()
			r.setup(tokens[1])
			App.add_relic(r)
		elif cmd == "dhg":
			var idx = int(tokens[1])
			delete_gem(Hand.grabs[idx], Hand.ui.get_slot(idx).gem_ui)
		elif cmd == "backup":
			DirAccess.copy_absolute("user://save1.json", "res://save_%s.txt" % SUtils.get_formated_datetime())
		elif cmd == "restore":
			DirAccess.copy_absolute("res://%s.txt" % tokens[1], "user://save1.json")
		elif cmd == "test":
			var mode = 0
			var round_count = 1
			var task_count = 1
			var saving = ""
			var additional_patterns = []
			var additional_relics = []
			var additional_enchants = []
			var enable_shopping = false
			for i in range(1, tokens.size()):
				var t = tokens[i]
				if t == "-m":
					mode = int(tokens[i + 1])
					i += 1
				elif t == "-r":
					round_count = int(tokens[i + 1])
					i += 1
				elif t == "-t":
					task_count = int(tokens[i + 1])
					i += 1
				elif t == "-s":
					saving = tokens[i + 1]
					i += 1
				elif t == "-ap":
					var num = 1
					var tt = tokens[i + 1]
					i += 1
					if tt.is_valid_int():
						num = int(tt)
						tt = tokens[i + 1]
						i += 1
					for j in num:
						additional_patterns.append(tt)
				elif t == "-ar":
					var num = 1
					var tt = tokens[i + 1]
					i += 1
					if tt.is_valid_int():
						num = int(tt)
						tt = tokens[i + 1]
						i += 1
					for j in num:
						additional_relics.append(tt)
				elif t == "-ae":
					additional_enchants.append(tokens[i + 1])
					i += 1
				elif t == "-es":
					enable_shopping = true
			STest.start_test(mode, round_count, task_count, "", saving, additional_patterns, additional_relics, additional_enchants, true, enable_shopping)

func get_round_score(lv : int):
	if lv <= 10:
		return lv * (2 * 300 + (lv - 1) * 100) / 2
	elif lv <= 20:
		var a = get_round_score(10)
		var n = lv - 10
		for i in n:
			var x = lerp(0.1, 0.3, i / 9.0)
			var c = lerp(1000, 10000, i / 9.0)
			a = (1.0 + x) * a + c
		a = int(a / 500) * 500
		return a
	elif lv <= 24:
		var a = get_round_score(20)
		var n = lv - 10
		for i in n:
			var x = 0.5
			var c = 30000
			a = (1.0 + x) * a + c
		a = int(a / 1000) * 1000
		return a
	else:
		return 1000000000

func get_round_reward(lv : int):
	if lv % 3 == 0:
		return 10
	elif lv % 3 == 1:
		return 5
	elif lv % 3 == 2:
		return 7
	return 0

func set_lang(lang : String):
	if lang.begins_with("en"):
		TranslationServer.set_locale("en")
	elif lang.begins_with("zh"):
		TranslationServer.set_locale("zh")
	if round > 0:
		update_round_text(round)
	if options_ui.visible:
		options_ui.lang_changed()

func set_fullscreen(v : bool):
	pass

func begin_busy():
	control_ui.roll_button.disabled = true
	control_ui.play_button.disabled = true
	Hand.ui.disabled = true
	Drag.release()

func end_busy():
	if !shop_ui.visible:
		if rolls > 0:
			control_ui.roll_button.disabled = false
		control_ui.play_button.disabled = false
	Hand.ui.disabled = false

func begin_transition(tween : Tween):
	blocker_ui.show()
	trans_sp.sprite_frames = null
	trans_sp.frame = 0
	tween.tween_property(subviewport_container.material, "shader_parameter/offset", 1.0, 0.4).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)

func end_transition(tween : Tween):
	tween.tween_callback(func():
		match randi() % 2:
			0: 
				trans_sp.sprite_frames = Gem.item_frames
				trans_sp.frame = randi_range(1, 41)
			1: 
				trans_sp.sprite_frames = Relic.relic_frames
				trans_sp.frame = randi_range(1, 14)
		trans_sp.scale = Vector2(0.0, 0.0)
	)
	tween.tween_property(trans_sp, "scale", Vector2(3.0, 3.0), 0.2).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(subviewport_container.material, "shader_parameter/offset", 2.0, 0.4).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_callback(func():
		blocker_ui.hide()
	)

func start_game(saving : String = ""):
	patterns.clear()
	patterns_bar_ui.clear()
	relics.clear()
	relics_bar_ui.clear()
	gems.clear()
	bag_gems.clear()
	items.clear()
	
	Board.clear()
	Hand.clear()
	
	Buff.clear(App, [Buff.Duration.ThisCombo, Buff.Duration.ThisMatching, Buff.Duration.ThisRound, Buff.Duration.Eternal])
	event_listeners.clear()
	Board.event_listeners.clear()
	modifiers.clear()
	modifiers["red_bouns_i"] = 0
	modifiers["orange_bouns_i"] = 0
	modifiers["green_bouns_i"] = 0
	modifiers["blue_bouns_i"] = 0
	modifiers["magenta_bouns_i"] = 0
	modifiers["played_i"] = 0
	modifiers["base_combo_i"] = 0
	modifiers["board_upper_lower_connected_i"] = 0
	modifiers["explode_range_i"] = 0
	modifiers["explode_power_i"] = 0
	modifiers["half_price_i"] = 0
	
	status_bar_ui.board_size_text.show_change = false
	status_bar_ui.hand_text.show_change = false
	status_bar_ui.coins_text.show_change = false
	
	if saving == "":
		game_rng.seed = Time.get_ticks_usec()
		round_rng.seed = game_rng.seed + 1
		shop_rng.seed = game_rng.seed + 2
		
		score = 0
		base_score = 0
		target_score = 0
		reward = 0
		current_curses.clear()
		round_curses.clear()
		score_mult = 1.0
		gain_scaler = 1.0
		combos = 0
		round = 0
		board_size = 3
		rolls_per_round = 0
		swaps_per_round = 5
		plays_per_round = 0
		draws_per_roll = 5
		max_hand_grabs = 5
		pins_num_per_round = 0
		activates_num_per_round = 0
		grabs_num_per_round = 0
		coins = 10
		update_round_text(round, 0, 0)
		
		for i in 1:
			var p = Pattern.new()
			p.setup("\\")
			add_pattern(p)
		for i in 1:
			var p = Pattern.new()
			p.setup("|")
			add_pattern(p)
		for i in 1:
			var p = Pattern.new()
			p.setup("/")
			add_pattern(p)
		'''
		for i in 1:
			var p = Pattern.new()
			p.setup("Island")
			add_pattern(p)
		for i in 1:
			var p = Pattern.new()
			p.setup("Y")
			add_pattern(p)
		'''
		
		for i in 0:
			var r = Relic.new()
			r.setup("Libra")
			add_relic(r)
		
		for i in 16:
			var g = Gem.new()
			g.type = Gem.ColorRed
			g.rune = Gem.Runewave
			g.setup("Bomb")
			add_gem(g)
		for i in 16:
			var g = Gem.new()
			g.type = Gem.ColorRed
			g.rune = Gem.RunePalm
			add_gem(g)
		for i in 16:
			var g = Gem.new()
			g.type = Gem.ColorRed
			g.rune = Gem.RuneStarfish
			add_gem(g)
		for i in 16:
			var g = Gem.new()
			g.type = Gem.ColorOrange
			g.rune = Gem.Runewave
			add_gem(g)
		for i in 16:
			var g = Gem.new()
			g.type = Gem.ColorOrange
			g.rune = Gem.RunePalm
			add_gem(g)
		for i in 16:
			var g = Gem.new()
			g.type = Gem.ColorOrange
			g.rune = Gem.RuneStarfish
			add_gem(g)
		for i in 16:
			var g = Gem.new()
			g.type = Gem.ColorGreen
			g.rune = Gem.Runewave
			add_gem(g)
		for i in 16:
			var g = Gem.new()
			g.type = Gem.ColorGreen
			g.rune = Gem.RunePalm
			add_gem(g)
		for i in 16:
			var g = Gem.new()
			g.type = Gem.ColorGreen
			g.rune = Gem.RuneStarfish
			add_gem(g)
		for i in 16:
			var g = Gem.new()
			g.type = Gem.ColorBlue
			g.rune = Gem.Runewave
			add_gem(g)
		for i in 16:
			var g = Gem.new()
			g.type = Gem.ColorBlue
			g.rune = Gem.RunePalm
			add_gem(g)
		for i in 16:
			var g = Gem.new()
			g.type = Gem.ColorBlue
			g.rune = Gem.RuneStarfish
			add_gem(g)
		for i in 16:
			var g = Gem.new()
			g.type = Gem.ColorMagenta
			g.rune = Gem.Runewave
			add_gem(g)
		for i in 16:
			var g = Gem.new()
			g.type = Gem.ColorMagenta
			g.rune = Gem.RunePalm
			add_gem(g)
		for i in 16:
			var g = Gem.new()
			g.type = Gem.ColorMagenta
			g.rune = Gem.RuneStarfish
			add_gem(g)
		'''
		for i in 1:
			var item = Item.new()
			item.setup("Color Palette")
			add_item(item)
		for i in 1:
			var item = Item.new()
			item.setup("Minefield")
			add_item(item)
		for i in 7:
			var item = Item.new()
			item.setup("Bomb")
			add_item(item)
		'''
	
		Board.setup(board_size)
		history.init()
		control_ui.enter()
		
		# setting here so that text positions will be all right
		status_bar_ui.round_text.modulate.a = 0.0
		status_bar_ui.round_target.modulate.a = 0.0
		begin_busy()
		var tween = App.game_tweens.create_tween()
		tween.tween_interval(1.1)
		tween.tween_callback(func():
			Board.ui.enter(null, false)
			begin_busy()
			Board.fill_blanks()
			for i in min(max_hand_grabs, bag_gems.size()):
				Hand.draw()
			next_round(null)
		)
	else:
		status_bar_ui.round_text.modulate.a = 1.0
		status_bar_ui.round_target.modulate.a = 1.0
		load_from_file(saving)
		history.init()
		refresh_cluster_rounds()
	
	status_bar_ui.board_size_text.show_change = true
	status_bar_ui.hand_text.show_change = true
	status_bar_ui.coins_text.show_change = true
	game_ui.show()

func exit_game():
	for t in get_tree().get_processed_tweens():
		t.kill()
	for n in Board.ui.underlay.get_children():
		game_overlay.remove_child(n)
		n.queue_free()
	for n in Board.ui.overlay.get_children():
		game_overlay.remove_child(n)
		n.queue_free()
	for n in game_overlay.get_children():
		game_overlay.remove_child(n)
		n.queue_free()
	if Board.ui.visible:
		Board.ui.hide()
	if App.shop_ui.visible:
		App.shop_ui.exit(null, false)
	if App.settlement_ui.visible:
		App.settlement_ui.exit(false)
	if App.upgrade_ui.visible:
		App.upgrade_ui.exit(false)
	App.control_ui.exit()
	App.game_ui.hide()

func get_round_title(lv : int, reward : int):
	return tr("ui_game_round") % [lv, reward]

func get_round_desc(target : int, curses : Array[Curse] = []):
	var ret = tr("ui_game_target_score") % target
	if !curses.is_empty():
		var cates = {}
		for c in curses:
			if cates.has(c.type):
				cates[c.type] += 1
			else:
				cates[c.type] = 1
		var text = ""
		for k in cates.keys():
			#text = (tr(k) % cates[k]) + text
			text = tr(k) + text
		ret += " %s" % text
	return ret

func update_round_text(round : int, target : int = -1, reward : int = -1, curses : Array[Curse] = []):
	status_bar_ui.round_text.text = tr("ui_game_round") % [round, reward]
	if target == -1:
		target = get_round_score(round)
	if reward == -1:
		reward = get_round_reward(round)
	status_bar_ui.round_target.text = "[wave amp=20.0 freq=-3.0]%s[/wave]" % SUtils.format_text(get_round_desc(target, curses), true, true)

var cluster_round_tween : Tween = null

func change_cluster_round_img(target : int, frame : int):
	var sp = status_bar_ui.cluster_round_sps[target]
	if frame == 2:
		if sp.frame != 2:
			if cluster_round_tween:
				cluster_round_tween.custom_step(100.0)
			cluster_round_tween = App.create_tween()
			cluster_round_tween.tween_property(sp, "scale", Vector2(0.8, 0.8), 0.2)
			cluster_round_tween.tween_callback(func():
				sp.frame = 2
			)
			cluster_round_tween.tween_property(sp, "scale", Vector2(1.0, 1.0), 0.1)
			cluster_round_tween.tween_callback(func():
				cluster_round_tween = null
			)
	else:
		sp.frame = frame

func refresh_cluster_rounds():
	if settlement_ui.visible:
		var r0 = int((round - 1) / 3) * 3
		for i in 3:
			if r0 + i + 1 <= round:
				change_cluster_round_img(i, 2)
			else:
				change_cluster_round_img(i, 0)
	elif shop_ui.visible:
		var r0 = int(round / 3) * 3
		for i in 3:
			if r0 + i + 1 <= round:
				change_cluster_round_img(i, 2)
			elif r0 + i + 1 == round + 1:
				change_cluster_round_img(i, 1)
			else:
				change_cluster_round_img(i, 0)
	else:
		var r0 = int((round - 1) / 3) * 3
		for i in 3:
			if r0 + i + 1 < round:
				change_cluster_round_img(i, 2)
			elif r0 + i + 1 == round:
				change_cluster_round_img(i, 1)
			else:
				change_cluster_round_img(i, 0)

#const curse_types = ["lust", "gluttony", "greed", "sloth", "wrath", "envy", "pride"]
const curse_types = ["red_no_score", "orange_no_score", "green_no_score", "blue_no_score", "magenta_no_score", "wave_no_score", "palm_no_score", "starfish_no_score"]
func build_round_curses():
	var build_times = round + 3 - round_curses.size()
	for i in build_times:
		var curses : Array[Curse] = []
		var type = SMath.pick_random(curse_types, round_rng)
		var num = 0
		match (round + i) % 3:
			2:
				num = 1
				match type:
					"lust": num = 4
					"gluttony": num = 5
					"greed": num = 5
					"sloth": num = 30
					"wrath": num = 8
					"envy": num = 3
					"pride": num = 20
		for j in num:
			var c = Curse.new()
			c.type = "curse_" + type
			curses.append(c)
		round_curses.append(curses)

func remove_curse(c : Curse):
	c.remove()
	current_curses.erase(c)

func next_round(tween : Tween = null):
	build_round_curses()
	
	if !tween:
		tween = App.game_tweens.create_tween()
	
	tween.tween_callback(func():
		score = 0
		round += 1
		target_score = get_round_score(round) * 1
		reward = get_round_reward(round)
		game_over_mark = ""
		history.round_reset()
		current_curses.clear()
		for c in round_curses[round - 1]:
			var cc = Curse.new()
			cc.type = c.type
			current_curses.append(cc)
		update_round_text(round, target_score, reward, current_curses)
		refresh_cluster_rounds()
		
		rolls = rolls_per_round
		swaps = swaps_per_round
		plays = plays_per_round
		modifiers["played_i"] = 0
		
		if settlement_ui.visible:
			settlement_ui.exit()
		if game_over_ui.visible:
			game_over_ui.exit()
		
		for h in event_listeners:
			if h.event == Event.RoundBegan:
				h.host.on_event.call(Event.RoundBegan, null, null)
	)
	if !STest.testing:
		tween.tween_property(status_bar_ui.round_text, "modulate:a", 1.0, 0.5).from(0.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)
		tween.parallel().tween_property(status_bar_ui.round_target, "modulate:a", 1.0, 0.5).from(0.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)
		tween.tween_callback(func():
			Curse.pick_targets()
			for c in current_curses:
				var coord = c.coord
				if c.afflicted_gem:
					coord = c.afflicted_gem.coord
				SEffect.add_leading_line(Vector2(640.0, 224.0), Board.get_pos(coord))
		)
		tween.tween_interval(0.3)
		tween.tween_callback(func():
			Curse.apply_curses()
		)
		if round == 0:
			tween.tween_callback(func():
				tutorial_ui.enter()
			)
	else:
		Curse.pick_targets()
		Curse.apply_curses()
	tween.tween_callback(func():
		stage = Stage.Deploy
		save_to_file()
		control_ui.update_preview()
		control_ui.expected_score_panel.show()
		end_busy()
	)

func round_end():
	Board.clear_active_effects()
	calculator_bar_ui.disappear()
	control_ui.swaps_text.show_change = false
	swaps = 0
	control_ui.swaps_text.show_change = true
	action_stack.clear()
	control_ui.undo_button.disabled = true
	control_ui.expected_score_panel.hide()
	for c in current_curses:
		c.remove()
	current_curses.clear()
	Buff.clear(self, [Buff.Duration.ThisRound])
	for g in gems:
		Buff.clear(g, [Buff.Duration.ThisRound])

func win():
	round_end()
	stage = Stage.Settlement
	settlement_ui.enter()
	refresh_cluster_rounds()

func lose():
	round_end()
	stage = Stage.GameOver
	game_over_ui.enter()

# abandon
func roll():
	#if rolls > 0:
		stage = Stage.Rolling
		rolls -= 1
		Board.roll()
		var draw_num = draws_per_roll
		draw_num = min(draw_num, bag_gems.size())
		for i in draw_num:
			Hand.draw()
		begin_busy()
		history.rolls += 1

func play():
	#if plays > 0:
		stage = Stage.Matching
		#plays -= 1
		modifiers["played_i"] = 1
	
		base_score = 0
		combos = modifiers["base_combo_i"]
		score_mult = 1.0
		speed = 1.0 / base_speed
		
		action_stack.clear()
		control_ui.undo_button.disabled = true
		control_ui.expected_score_panel.hide()
		
		calculator_bar_ui.appear()
		begin_busy()
		filling_times = 0
		Board.matching()

func toggle_in_game_menu():
	if !in_game_menu_ui.visible:
		STooltip.close()
		in_game_menu_ui.enter()
	else:
		SSound.music_more_clear()
		in_game_menu_ui.exit()

func save_to_file(name : String = "1"):
	if STest.testing:
		return
	
	var save_buff = func(b : Buff, d : Dictionary):
		d["uid"] = b.uid
		d["type"] = b.type
		d["duration"] = b.duration
		d["data"] = b.data.duplicate(true)
	var save_hook = func(h : Hook, d : Dictionary):
		d["event"] = h.event
		d["host_type"] = h.host_type
		match h.host_type:
			HostType.Gem: d["host"] = App.gems.find(h.host)
			HostType.Relic: d["host"] = App.relics.find(h.host)
		d["once"] = h.once
	
	var data = {}
	data["game_rng_seed"] = App.game_rng.seed
	data["game_rng_state"] = App.game_rng.state
	data["round_rng_seed"] = App.round_rng.seed
	data["round_rng_state"] = App.round_rng.state
	data["shop_rng_seed"] = App.shop_rng.seed
	data["shop_rng_state"] = App.shop_rng.state
	data["round"] = App.round
	data["board_size"] = App.board_size
	data["rolls_per_round"] = App.rolls_per_round
	data["swaps_per_round"] = App.swaps_per_round
	data["plays_per_round"] = App.plays_per_round
	data["draws_per_roll"] = App.draws_per_roll
	data["max_hand_grabs"] = App.max_hand_grabs
	data["coins"] = App.coins
	data["rolls"] = App.rolls
	data["swaps"] = App.swaps
	data["plays"] = App.plays
	data["score"] = App.score
	data["target_score"] = App.target_score
	data["reward"] = App.reward
	var current_curses = []
	for c in App.current_curses:
		var curse = {}
		curse["type"] = c.type
		curse["coord"] = c.coord
		current_curses.append(curse)
	data["current_curses"] = current_curses
	var round_curses = []
	for lc in App.round_curses:
		var round_curse = []
		for c in lc:
			var curse = {}
			curse["type"] = c.type
			curse["coord"] = c.coord
			round_curse.append(curse)
		round_curses.append(round_curse)
	data["round_curses"] = round_curses
	data["combos"] = App.combos
	data["score_mult"] = App.score_mult
	var game_buffs = []
	for b in App.buffs:
		var buff = {}
		save_buff.call(b, buff)
		game_buffs.append(buff)
	data["buffs"] = game_buffs
	var game_event_listeners = []
	for h in App.event_listeners:
		var hook = {}
		save_hook.call(h, hook)
		game_event_listeners.append(hook)
	data["event_listeners"] = game_event_listeners
	data["modifiers"] = App.modifiers.duplicate()
	var board_event_listeners = []
	for h in Board.event_listeners:
		var hook = {}
		save_hook.call(h, hook)
		board_event_listeners.append(hook)
	data["cx"] = Board.cx
	data["cy"] = Board.cy
	data["board_event_listeners"] = board_event_listeners
	var gems = []
	for g in App.gems:
		var gem = {}
		gem["name"] = g.name
		gem["type"] = g.type
		gem["rune"] = g.rune
		gem["base_score"] = g.base_score
		gem["bonus_score"] = g.bonus_score
		gem["base_mult"] = g.base_mult
		gem["bonus_mult"] = g.bonus_mult
		gem["coord"] = g.coord
		var buffs = []
		for b in g.buffs:
			var buff = {}
			save_buff.call(b, buff)
			buffs.append(buff)
		gem["buffs"] = buffs
		gems.append(gem)
	data["gems"] = gems
	var bag_gems = []
	for g in App.bag_gems:
		bag_gems.append(App.gems.find(g))
	data["bag_gems"] = bag_gems
	var patterns = []
	for p in App.patterns:
		var pattern = {}
		pattern["name"] = p.name
		pattern["mult"] = p.mult
		pattern["lv"] = p.lv
		pattern["exp"] = p.exp
		pattern["max_exp"] = p.max_exp
		patterns.append(pattern)
	data["patterns"] = patterns
	var relics = []
	for r in App.relics:
		var relic = {}
		relic["name"] = r.name
		relic["extra"] = r.extra.duplicate()
		relics.append(relic)
	data["relics"] = relics
	var hand = []
	for g in Hand.grabs:
		hand.append(App.gems.find(g))
	data["hand"] = hand
	var cells = []
	for c in Board.cells:
		var cell = {}
		cell["coord"] = c.coord
		cell["gem"] = App.gems.find(c.gem)
		cell["state"] = c.state
		cell["pinned"] = c.pinned
		cell["frozen"] = c.frozen
		cell["nullified"] = c.nullified
		var event_listeners = []
		for h in c.event_listeners:
			var hook = {}
			save_hook.call(h, hook)
			event_listeners.append(hook)
		cell["event_listeners"] = event_listeners
		cells.append(cell)
	data["cells"] = cells
	if App.stage == Stage.Settlement:
		data["stage"] = "settlement"
		data["settlement_rewards"] = App.settlement_ui.rewards
		var list = []
		for s in settlement_ui.list.get_children():
			var item = {}
			item["name"] = s.name_str
			item["value"] = s.value_str
			list.append(item)
		data["settlement_list"] = list
	elif App.stage == Stage.Upgrade:
		data["stage"] = "upgrade"
		var list = []
		for n in upgrade_ui.list.get_children():
			var ui = n as UiShopItem
			var item = {}
			item["cate"] = ui.cate
			if ui.cate == "pattern":
				var p = ui.object as Pattern
				var object = {}
				object["name"] = p.name
				item["object"] = object
			item["price"] = ui.price
			list.append(item)
		data["upgrade_list"] = list
	elif App.stage == Stage.Shopping:
		data["stage"] = "shopping"
		data["shop_refresh_price"] = shop_ui.refresh_price
		data["shop_expand_board_price"] = shop_ui.expand_board_price
		var list1 = []
		for n in shop_ui.list1.get_children():
			var ui = n as UiShopItem
			var item = {}
			item["cate"] = ui.cate
			if ui.cate == "gem":
				var g = ui.object as Gem
				var object = {}
				object["type"] = g.type
				object["rune"] = g.rune
				object["base_score"] = g.base_score
				var buffs = []
				for b in g.buffs:
					var buff = {}
					save_buff.call(b, buff)
					buffs.append(buff)
				object["buffs"] = buffs
				item["object"] = object
			elif ui.cate == "relic":
				var r = ui.object as Relic
				var object = {}
				object["name"] = r.name
				item["object"] = object
			item["price"] = ui.price
			list1.append(item)
		data["shop_list1"] = list1
		var list2 = []
		for n in shop_ui.list2.get_children():
			var ui = n as CraftSlot
			var slot = {}
			slot["type"] = ui.type
			slot["thing"] = ui.thing
			slot["price"] = ui.price
			list2.append(slot)
		data["shop_list2"] = list2
	
	var file = FileAccess.open("user://save%s.json" % name, FileAccess.WRITE)
	file.store_string(JSON.stringify(data, "\t", false))
	file.close()

func load_from_file(name : String = "1"):
	print("load save %s\n" % name)
	
	var file = FileAccess.open("user://save%s.json" % name, FileAccess.READ)
	var data = JSON.parse_string(file.get_as_text())
	file.close()
	
	var load_buff = func(d : Dictionary, host):
		var b = Buff.new()
		b.uid = d["uid"]
		b.type = int(d["type"])
		b.host = host
		b.duration = int(d["duration"])
		b.data = SUtils.read_dictionary(d["data"])
		host.buffs.append(b)
		return b
	var load_hook = func(d : Dictionary):
		var host_type = int(d["host_type"])
		var host_idx = int(d["host"])
		var host = null
		match host_type:
			HostType.Gem: host = App.gems[host_idx]
			HostType.Relic: host = App.relics[host_idx]
		var h = Hook.new(int(d["event"]), host, host_type, d["once"])
		return h
	
	App.game_rng.seed = int(data["game_rng_seed"])
	App.game_rng.state = int(data["game_rng_state"])
	App.round_rng.seed = int(data["round_rng_seed"])
	App.round_rng.state = int(data["round_rng_state"])
	App.shop_rng.seed = int(data["shop_rng_seed"])
	App.shop_rng.state = int(data["shop_rng_state"])
	App.board_size = int(data["board_size"])
	App.rolls_per_round = int(data["rolls_per_round"])
	App.swaps_per_round = int(data["swaps_per_round"])
	App.plays_per_round = int(data["plays_per_round"])
	App.draws_per_roll = int(data["draws_per_roll"])
	App.max_hand_grabs = int(data["max_hand_grabs"])
	App.rolls = int(data["rolls"])
	App.swaps = int (data["swaps"])
	App.plays = int(data["plays"])
	App.round = int(data["round"])
	App.score = int(data["score"])
	App.target_score = int(data["target_score"])
	App.reward = int(data["reward"])
	App.current_curses.clear()
	var current_curses = data["current_curses"]
	for curse in current_curses:
		var c = Curse.new()
		c.type = curse["type"]
		c.coord = str_to_var("Vector2i" + curse["coord"])
		App.current_curses.append(c)
	App.round_curses.clear()
	var round_curses = data["round_curses"]
	for d in round_curses:
		var lc = []
		for curse in d:
			var c = Curse.new()
			c.type = curse["type"]
			c.coord = str_to_var("Vector2i" + curse["coord"])
			lc.append(c)
		App.round_curses.append(lc)
	App.combos = int(data["combos"])
	App.score_mult = data["score_mult"]
	update_round_text(round, target_score, reward, App.current_curses)
	var game_buffs = data["buffs"]
	for buff in game_buffs:
		load_buff.call(buff, App)
	var saved_modifiers = SUtils.read_dictionary(data["modifiers"])
	for k in saved_modifiers:
		App.set_modifier(k, saved_modifiers[k])
	App.coins = int(data["coins"])
	
	Board.cx = int(data["cx"])
	Board.cy = int(data["cy"])
	
	var gems = data["gems"]
	for gem in gems:
		var g = Gem.new()
		g.name = gem["name"]
		if g.name != "":
			g.setup(g.name)
		g.type = int(gem["type"])
		g.rune = int(gem["rune"])
		g.base_score = int(gem["base_score"])
		g.bonus_score = int(gem["bonus_score"])
		g.base_mult = gem["base_mult"]
		g.bonus_mult = gem["bonus_mult"]
		g.coord = str_to_var("Vector2i" + gem["coord"])
		var buffs = gem["buffs"]
		for buff in buffs:
			load_buff.call(buff, g)
		add_gem(g, false)
	var bag_gems = data["bag_gems"]
	for idx in bag_gems:
		App.bag_gems.append(App.gems[idx])
	var patterns = data["patterns"]
	for pattern in patterns:
		var p = Pattern.new()
		p.setup(pattern["name"])
		p.mult = int(pattern["mult"])
		p.lv = int(pattern["lv"])
		p.exp = int(pattern["exp"])
		p.max_exp = int(pattern["max_exp"])
		add_pattern(p, false)
	var relics = data["relics"]
	for relic in relics:
		var r = Relic.new()
		r.setup(relic["name"])
		r.extra = SUtils.read_dictionary(relic["extra"])
		add_relic(r, false)
	var game_event_listeners = data["event_listeners"]
	for hook in game_event_listeners:
		var h = load_hook.call(hook)
		App.event_listeners.append(h)
	var board_event_listeners = data["board_event_listeners"]
	for hook in board_event_listeners:
		var h = load_hook.call(hook)
		Board.event_listeners.append(h)
	var hand = data["hand"]
	for idx in hand:
		var g = App.gems[int(idx)]
		Hand.grabs.append(g)
		Hand.ui.add_slot(g)
	var cells = data["cells"]
	for cell in cells:
		var coord = str_to_var("Vector2i" + cell["coord"])
		var c = Board.add_cell(coord)
		var ui = Board.ui.get_cell(coord)
		var gem_idx = cell["gem"]
		if gem_idx != -1:
			var g = App.gems[gem_idx]
			c.gem = g
			Board.ui.update_cell(coord)
		var state = cell["state"]
		if state != Cell.State.Normal:
			Board.set_state_at(coord, state)
		if cell["pinned"]:
			Board.pin(coord)
		if cell["frozen"]:
			Board.freeze(coord)
		if cell["nullified"]:
			Board.nullify(coord)
	Board.update_gem_quantity_limit()
	
	control_ui.enter()
	
	var stage = data["stage"]
	if stage == "":
		App.stage = Stage.Deploy
		Board.ui.enter(null, false)
		control_ui.update_preview()
		control_ui.expected_score_panel.show()
	else:
		if stage == "settlement":
			App.stage = Stage.Settlement
			Board.ui.enter(null, false)
			App.settlement_ui.clear()
			App.settlement_ui.button_text.text = "%s[img]res://images/coin.png[/img]" % (tr("ui_settlement_cash_out") % int(data["settlement_rewards"]))
			App.settlement_ui.button.disabled = false
			var list = data["settlement_list"]
			for item in list:
				var ui = settlement_item_pb.instantiate()
				ui.name_str = item["name"]
				ui.value_str = item["value"]
				App.settlement_ui.list.add_child(ui)
			App.settlement_ui.show()
		elif stage == "upgrade":
			App.stage = Stage.Upgrade
			Board.ui.enter(null, false)
			App.upgrade_ui.clear()
			var list = data["upgrade_list"]
			for item in list:
				var ui = shop_item_pb.instantiate()
				var cate = item["cate"]
				if cate == "pattern":
					var object = item["object"]
					var p = Pattern.new()
					p.setup(object["name"])
					ui.setup("pattern", p, item["price"], 1, true)
				else:
					ui.setup(cate, null, item["price"], 1, true)
				App.upgrade_ui.setup_item_listener(ui)
				App.upgrade_ui.list.add_child(ui)
			App.upgrade_ui.show()
		elif stage == "shopping":
			App.stage = Stage.Shopping
			shop_ui.refresh_price = int(data["shop_refresh_price"])
			shop_ui.expand_board_price = data["shop_expand_board_price"]
			shop_ui.clear()
			var list1 = data["shop_list1"]
			for item in list1:
				var ui = shop_item_pb.instantiate()
				var cate = item["cate"]
				if cate == "gem":
					var object = item["object"]
					var g = Gem.new()
					g.type = object["type"]
					g.rune = object["rune"]
					g.base_score = int(object["base_score"])
					var buffs = object["buffs"]
					for buff in buffs:
						load_buff.call(buff, g)
					ui.setup("gem", g, item["price"])
				elif cate == "relic":
					var object = item["object"]
					var r = Relic.new()
					r.setup(object["name"])
					ui.setup("relic", r, item["price"])
				shop_ui.list1.add_child(ui)
			var list2 = data["shop_list2"]
			for slot in list2:
				var ui = craft_slot_pb.instantiate()
				ui.setup(slot["type"], slot["thing"], slot["price"])
				shop_ui.list2.add_child(ui)
			shop_ui.enter(null, false)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == MOUSE_BUTTON_RIGHT:
				pass
	elif event is InputEventMouseMotion:
		mouse_pos = event.position

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.is_pressed():
			if event.keycode == KEY_ESCAPE:
				SSound.se_click.play()
				App.screen_shake_strength = 8.0
				if options_ui.visible:
					options_ui.exit()
				elif bag_viewer_ui.visible:
					bag_viewer_ui.exit()
				elif tutorial_ui.visible:
					tutorial_ui.exit()
				elif control_ui.visible:
					App.screen_shake_strength = 8.0
					toggle_in_game_menu()
			elif event.keycode == KEY_F3:
				command_line_edit.visible = !command_line_edit.visible
				if command_line_edit.visible:
					command_line_edit.grab_focus()
	elif event is InputEventMouseMotion:
		if Board.ui.visible:
			var c = Board.ui.hover_coord(true)
			if Board.is_valid(c):
				var cc = Board.offset_to_cube(c)
				control_ui.debug_text.text = "(%d,%d) (%d,%d,%d)" % [c.x, c.y, cc.x, cc.y, cc.z]
				var contents : Array[Pair] = []
				var cell = Board.get_cell(c)
				if cell.nullified:
					contents.append(Pair.new(tr("tt_cell_nullified"), tr("tt_cell_nullified_content")))
				if cell.in_mist:
					contents.append(Pair.new(tr("tt_cell_in_mist"), tr("tt_cell_in_mist_content")))
				var g = Board.get_gem_at(c)
				if g:
					var cell_ui = Board.ui.get_cell(c)
					if STooltip.node != cell_ui:
						contents.append_array(g.get_tooltip())
						var dir = 0
						var hcx = Board.cx / 2
						var hcy = Board.cy / 2
						if c.x <= hcx:
							if c.y <= hcy:
								dir = 0
							else:
								dir = 1
						else:
							if c.y <= hcy:
								dir = 3
							else:
								dir = 2
						STooltip.show(cell_ui, dir, contents)
			else:
				control_ui.debug_text.text = ""
				STooltip.close()

func _ready() -> void:
	randomize()
	
	no_score_marks[Gem.None] = []
	no_score_marks[Gem.None].push_front(false)
	for i in Gem.ColorCount:
		no_score_marks[Gem.ColorRed + i] = []
		no_score_marks[Gem.ColorRed + i].push_front(false)
	for i in Gem.RuneCount:
		no_score_marks[Gem.Runewave + i] = []
		no_score_marks[Gem.Runewave + i].push_front(false)
	
	Board.ui = $/root/Main/SubViewportContainer/SubViewport/Canvas/Board
	Board.rolling_finished.connect(func():
		var processed = false
		for h in event_listeners:
			if h.event == Event.RollingFinished:
				processed = h.host.on_event.call(Event.RollingFinished, null, null)
				if processed:
					break
		if !processed:
			pass
	)
	Board.filling_finished.connect(func():
		var processed = false
		for h in event_listeners:
			if h.event == Event.FillingFinished:
				processed = h.host.on_event.call(Event.FillingFinished, null, null)
				if processed:
					break
		if !processed:
			if modifiers["played_i"] > 0:
				filling_times += 1
				if filling_times >= FillingTimesToWin:
					win()
				else:
					Board.matching()
			else:
				control_ui.update_preview()
	)
	Board.matching_finished.connect(func():
		var processed = false
		for h in event_listeners:
			if h.event == Event.MatchingFinished:
				processed = h.host.on_event.call(Event.MatchingFinished, null, null)
				if processed:
					break
		if !processed:
			control_ui.filling_times_text_container.hide()
			calculator_bar_ui.calculate()
	)
	Hand.ui = $/root/Main/SubViewportContainer/SubViewport/Canvas/GameControl/HBoxContainer2/Panel/HBoxContainer/Hand
	calculator_bar_ui.finished.connect(func():
		history.update()
		stage = Stage.Deploy
		speed = 1.0 / base_speed
		save_to_file()
		
		Buff.clear(self, [Buff.Duration.ThisMatching, Buff.Duration.ThisCombo])
		for y in Board.cy:
			for x in Board.cx:
				var c = Vector2i(x, y)
				var g = Board.get_gem_at(c)
				if g:
					Buff.clear(g, [Buff.Duration.ThisMatching, Buff.Duration.ThisCombo])
		
		if game_over_mark != "":
			lose()
		else:
			if swaps == 0 && score < target_score:
				if invincible:
					win()
				else:
					game_over_mark = "not_reach_score"
					lose()
			elif score >= target_score:
				win()
			else:
				control_ui.update_preview()
				control_ui.expected_score_panel.show()
				end_busy()
	)
	command_line_edit.text_submitted.connect(func(cl : String):
		App.process_command_line(cl)
		command_line_edit.clear()
		command_line_edit.hide()
	)
	
	screen_shake_noise = FastNoiseLite.new()
	screen_shake_noise.noise_type = FastNoiseLite.TYPE_PERLIN
	screen_shake_noise.fractal_type = FastNoiseLite.FRACTAL_FBM
	screen_shake_noise.frequency = 0.2
	screen_shake_noise.seed = randi()
	
	trans_bg.size = resolution
	background.scale = resolution
	subviewport.size = resolution
	crt.material.set_shader_parameter("resolution", resolution)
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)

func _process(delta: float) -> void:
	if canvas:
		screen_shake_strength = lerp(screen_shake_strength, 0.0, 5.0 * delta)
		screen_shake_noise_coord += 30.0 * delta
		screen_offset = lerp(screen_offset, (mouse_pos - subviewport.size * 0.5) * 0.007, 0.05)
		canvas.offset = screen_offset + Vector2(screen_shake_noise.get_noise_2d(17.0, screen_shake_noise_coord), screen_shake_noise.get_noise_2d(93.0, screen_shake_noise_coord)) * screen_shake_strength
