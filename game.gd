extends Node

enum Stage
{
	Deploy,
	Rolling,
	Matching,
	LevelOver
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
const UiLevelClear = preload("res://ui_level_clear.gd")
const UiChooseReward = preload("res://ui_choose_reward.gd")
const UiBagViewer = preload("res://ui_bag_viewer.gd")
const UiTutorial = preload("res://ui_tutorial.gd")
const gem_ui = preload("res://ui_gem.tscn")
const popup_txt_pb = preload("res://popup_txt.tscn")
const trail_pb = preload("res://trail.tscn")
const craft_slot_pb = preload("res://craft_slot.tscn")
const shop_item_pb = preload("res://ui_shop_item.tscn")
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
@onready var title_ui : UiTitle = $/root/Main/SubViewportContainer/SubViewport/Canvas/Title
@onready var control_ui : UiControl = $/root/Main/SubViewportContainer/SubViewport/Canvas/Control
@onready var shop_ui : UiShop = $/root/Main/SubViewportContainer/SubViewport/Canvas/Shop
@onready var game_ui : Control = $/root/Main/SubViewportContainer/SubViewport/Canvas/Game
@onready var status_bar_ui : UiStatusBar = $/root/Main/SubViewportContainer/SubViewport/Canvas/Game/VBoxContainer/MarginContainer/TopBar/VBoxContainer/MarginContainer/StatusBar
@onready var relics_bar_ui : UiRelicsBar = $/root/Main/SubViewportContainer/SubViewport/Canvas/Game/VBoxContainer/Control/MarginContainer/RelicsBar
@onready var patterns_bar_ui : UiPatternsBar = $/root/Main/SubViewportContainer/SubViewport/Canvas/Game/VBoxContainer/Control/MarginContainer2/PatternsBar
@onready var calculator_bar_ui : UiCalculatorBar = $/root/Main/SubViewportContainer/SubViewport/Canvas/CalculateBar
@onready var banner_ui : UiBanner = $/root/Main/SubViewportContainer/SubViewport/Canvas/Banner
@onready var dialog_ui : UiDialog = $/root/Main/SubViewportContainer/SubViewport/Canvas/Dialog
@onready var options_ui : UiOptions = $/root/Main/SubViewportContainer/SubViewport/Canvas/Options
@onready var collections_ui : UiCollections = $/root/Main/SubViewportContainer/SubViewport/Canvas/Collections
@onready var bag_viewer_ui : UiBagViewer = $/root/Main/SubViewportContainer/SubViewport/Canvas/BagViewer
@onready var tutorial_ui : UiTutorial = $/root/Main/SubViewportContainer/SubViewport/Canvas/Tutorial
@onready var in_game_menu_ui : UiInGameMenu = $/root/Main/SubViewportContainer/SubViewport/Canvas/InGameMenu
@onready var game_over_ui : UiGameOver = $/root/Main/SubViewportContainer/SubViewport/Canvas/GameOver
@onready var level_clear_ui : UiLevelClear = $/root/Main/SubViewportContainer/SubViewport/Canvas/LevelClear
@onready var choose_reward_ui : UiChooseReward = $/root/Main/SubViewportContainer/SubViewport/Canvas/ChooseReward
@onready var command_line_edit : LineEdit = $/root/Main/SubViewportContainer/SubViewport/Canvas/CommandLine
@onready var blocker_ui : Control = $/root/Main/SubViewportContainer/SubViewport/Canvas/Blocker

var stage : int = Stage.Deploy
var rng : RandomNumberGenerator = RandomNumberGenerator.new()
var rolls : int:
	set(v):
		rolls = v
		control_ui.rolls_text.text = "%d" % rolls
var rolls_per_level : int
var swaps : int:
	set(v):
		swaps = v
		control_ui.swaps_text.set_value(swaps)
var swaps_per_level : int
var plays : int:
	set(v):
		plays = v
		control_ui.plays_text.text = "%d" % plays
var plays_per_level : int
var draws_per_roll : int
var next_roll_extra_draws : int = 0
var max_hand_grabs : int:
	set(v):
		max_hand_grabs = v
		if Hand.ui:
			status_bar_ui.hand_text.set_value(Game.max_hand_grabs)
var pins_num : int:
	set(v):
		pins_num = v
		if pins_num > 0:
			control_ui.pin_ui.show()
			control_ui.pin_ui.num.text = "%d" % pins_num
		else:
			control_ui.pin_ui.hide()
var pins_num_per_level : int
var activates_num : int:
	set(v):
		activates_num = v
		if activates_num > 0:
			control_ui.activate_ui.show()
			control_ui.activate_ui.num.text = "%d" % activates_num
		else:
			control_ui.activate_ui.hide()
var activates_num_per_level : int
var grabs_num : int = 5:
	set(v):
		grabs_num = v
		if grabs_num > 0:
			control_ui.grab_ui.show()
			control_ui.grab_ui.num.text = "%d" % grabs_num
		else:
			control_ui.grab_ui.hide()
var grabs_num_per_level : int
var action_stack : Array[Pair]
var board_size : int = 3:
	set(v):
		board_size = v
		status_bar_ui.board_size_text.set_value(board_size)
var patterns : Array[Pattern]
var gems : Array[Gem]
var bag_gems : Array[Gem] = []
var items : Array[Item]
var bag_items : Array[Item] = []
var relics : Array[Relic]
var event_listeners : Array[Hook]
var level : int
var score : int:
	set(v):
		score = v
		status_bar_ui.score_text.text = "%d" % score
var target_score : int
var reward : int
var current_curses : Array[Curse]
var level_curses : Array[Array]
var base_score_tween : Tween = null
var base_score : int:
	set(v):
		if v > base_score:
			base_score = v
			if base_score_tween:
				base_score_tween.custom_step(100.0)
			calculator_bar_ui.base_score_text.position.y = 4
			calculator_bar_ui.base_score_text.text = "%d" % v
			base_score_tween = get_tree().create_tween()
			base_score_tween.tween_property(calculator_bar_ui.base_score_text, "position:y", 0, 0.2 * Game.speed)
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
				combos_tween = get_tree().create_tween()
				SAnimation.jump(combos_tween, calculator_bar_ui.combos_text, -0.0, 0.25 * Game.speed, func():
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
			score_mult_tween = get_tree().create_tween()
			score_mult_tween.tween_property(calculator_bar_ui.mult_text, "position:y", 0, 0.2 * Game.speed)
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
				var tween = get_tree().create_tween()
				tween.tween_property(control_ui.filling_times_text_container, "scale", Vector2(1.0, 1.0), 0.15).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUART)
			if control_ui.filling_times_tween:
				control_ui.filling_times_tween.custom_step(100.0)
				control_ui.filling_times_tween = null
			if control_ui.filling_times_text_container.visible:
				control_ui.filling_times_text.position.y = 0
				control_ui.filling_times_tween = get_tree().create_tween()
				SAnimation.jump(control_ui.filling_times_tween, control_ui.filling_times_text, -0.0, 0.25 * Game.speed, func():
					control_ui.filling_times_text.text = "%d" % filling_times
				)
				control_ui.filling_times_tween.tween_callback(func():
					control_ui.filling_times_tween = null
				)
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
	return SMath.pick_and_remove(bag_gems, Game.rng)

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
	elif name == "purple_bouns_i":
		status_bar_ui.purple_bouns_text.set_value(modifiers["purple_bouns_i"])
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
	var tween = get_tree().create_tween()
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
	
	var tween = get_tree().create_tween()
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
	
	var tween = get_tree().create_tween()
	tween.tween_property(ui, "position:y", pos.y - 20, 0.1)
	tween.tween_property(ui, "position:x", pos.x + add_mult_dir * 5, 0.2)
	tween.parallel().tween_property(ui, "position:y", pos.y, 0.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween.tween_callback(func():
		lb.hide()
	)
	
	add_mult_dir *= -1

var status_tween : Tween
func add_status(s : String, col : Color):
	control_ui.status_text.show()
	control_ui.status_text.text = s
	var parent = control_ui.status_text.get_parent()
	parent.scale = Vector2(1.3, 1.3)
	control_ui.status_text.add_theme_color_override("font_color", col)
	if status_tween:
		status_tween.kill()
	status_tween = get_tree().create_tween()
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
	Game.game_ui.add_child(ui)
	return ui

func delete_gem(g : Gem, ui, from : String = "hand"):
	var old_coord = g.coord
	SSound.se_trash.play()
	ui.dissolve(0.5)
	var tween = get_tree().create_tween()
	tween.tween_interval(0.5)
	tween.tween_callback(func():
		if from == "hand":
			Hand.erase(Hand.find(g))
		remove_gem(g)
		if Game.gems.size() < Board.curr_min_gem_num:
			Game.game_over_mark = "not_enough_gems"
			Game.lose()
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
	var tween = get_tree().create_tween()
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

func swap_hand_and_board(slot1 : Control, coord : Vector2i):
	var tween = get_tree().create_tween()
	var g1 = slot1.gem
	var g2 = Board.get_gem_at(coord)
	var pos = Board.get_pos(coord) - Vector2(Board.tile_sz, Board.tile_sz) * 0.5
	Game.begin_busy()
	slot1.elastic = -1.0
	var slot2 = Hand.add_gem(g2)
	slot2.global_position = pos
	slot2.elastic = -1.0
	tween.tween_callback(func():
		slot1.z_index = 10
	)
	tween.tween_interval(0.1)
	tween.tween_callback(func():
		SSound.se_drop_item.play()
		Board.set_gem_at(coord, null)
	)
	var sub1 = get_tree().create_tween()
	var sub2 = get_tree().create_tween()
	sub1.tween_property(slot1, "global_position", pos + Vector2(0, Board.tile_sz * 0.75), 0.15).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)
	sub1.tween_property(slot1, "global_position", pos, 0.2)
	sub2.tween_interval(0.1)
	sub2.tween_property(slot2, "global_position", pos + Vector2(0.0, -Board.tile_sz * 0.75), 0.15).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)
	sub2.tween_property(slot2, "elastic", 1.0, 0.2).from(0.0)
	tween.tween_subtween(sub1)
	tween.parallel().tween_subtween(sub2)
		
	tween.tween_callback(func():
		Board.set_gem_at(coord, g1)
		Hand.erase(slot1.get_index())
		control_ui.update_preview()
		Game.end_busy()
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
			for p in Game.patterns:
				p.match_with(coord)
		elif cmd == "win":
			Game.win()
		elif cmd == "lose":
			Game.lose()
		elif cmd == "shop":
			Game.shop_ui.enter()
		elif cmd == "swap":
			Game.swaps += int(tokens[1])
		elif cmd == "gold":
			Game.coins += int(tokens[1])
		elif cmd == "ai":
			var num = 1
			var tt = tokens[1]
			if tt.is_valid_int():
				num = int(tt)
				tt = tokens[2]
			for j in num:
				var i = Item.new()
				i.setup(tt)
				Game.add_item(i)
		elif cmd == "ar":
			var r = Relic.new()
			r.setup(tokens[1])
			Game.add_relic(r)
		elif cmd == "dhg":
			var idx = int(tokens[1])
			delete_gem(Hand.grabs[idx], Hand.ui.get_slot(idx).gem_ui)
		elif cmd == "backup":
			DirAccess.copy_absolute("user://save1.json", "res://save_%s.txt" % SUtils.get_formated_datetime())
		elif cmd == "restore":
			DirAccess.copy_absolute("res://%s.txt" % tokens[1], "user://save1.json")
		elif cmd == "test":
			var mode = 0
			var level_count = 1
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
				elif t == "-l":
					level_count = int(tokens[i + 1])
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
			STest.start_test(mode, level_count, task_count, "", saving, additional_patterns, additional_relics, additional_enchants, true, enable_shopping)

func get_level_score(lv : int):
	if lv <= 10:
		return lv * (2 * 300 + (lv - 1) * 100) / 2
	elif lv <= 20:
		var a = get_level_score(10)
		var n = lv - 10
		for i in n:
			var x = lerp(0.1, 0.3, i / 9.0)
			var c = lerp(1000, 10000, i / 9.0)
			a = (1.0 + x) * a + c
		a = int(a / 500) * 500
		return a
	elif lv <= 24:
		var a = get_level_score(20)
		var n = lv - 10
		for i in n:
			var x = 0.5
			var c = 30000
			a = (1.0 + x) * a + c
		a = int(a / 1000) * 1000
		return a
	else:
		return 1000000000

func get_level_reward(lv : int):
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
	if level > 0:
		update_level_text(level)

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
	tween.tween_property(subviewport_container.material, "shader_parameter/radius", 3.2, 0.5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)

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
	tween.tween_property(trans_sp, "scale", Vector2(3.0, 3.0), 0.4).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(subviewport_container.material, "shader_parameter/radius", 0.0, 0.7).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
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
	bag_items.clear()
	
	Board.clear()
	Hand.clear()
	
	Buff.clear(Game, [Buff.Duration.ThisCombo, Buff.Duration.ThisMatching, Buff.Duration.ThisLevel, Buff.Duration.Eternal])
	event_listeners.clear()
	Board.event_listeners.clear()
	modifiers.clear()
	modifiers["red_bouns_i"] = 0
	modifiers["orange_bouns_i"] = 0
	modifiers["green_bouns_i"] = 0
	modifiers["blue_bouns_i"] = 0
	modifiers["purple_bouns_i"] = 0
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
		rng.seed = Time.get_ticks_msec()
		
		score = 0
		base_score = 0
		target_score = 0
		reward = 0
		current_curses.clear()
		level_curses.clear()
		score_mult = 1.0
		gain_scaler = 1.0
		combos = 0
		level = 0
		board_size = 3
		rolls_per_level = 0
		swaps_per_level = 5
		plays_per_level = 0
		draws_per_roll = 5
		max_hand_grabs = 5
		pins_num_per_level = 0
		activates_num_per_level = 0
		grabs_num_per_level = 0
		coins = 10
		update_level_text(level, 0, 0)
		
		for i in 1:
			var p = Pattern.new()
			p.setup("\\")
			add_pattern(p)
		for i in 1:
			var p = Pattern.new()
			p.setup("I")
			add_pattern(p)
		for i in 1:
			var p = Pattern.new()
			p.setup("/")
			add_pattern(p)
		'''
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
			g.type = Gem.Type.Red
			g.rune = Gem.Rune.Destroy
			g.setup("Bomb")
			add_gem(g)
		for i in 16:
			var g = Gem.new()
			g.type = Gem.Type.Red
			g.rune = Gem.Rune.Wisdom
			add_gem(g)
		for i in 16:
			var g = Gem.new()
			g.type = Gem.Type.Red
			g.rune = Gem.Rune.Grow
			add_gem(g)
		for i in 16:
			var g = Gem.new()
			g.type = Gem.Type.Orange
			g.rune = Gem.Rune.Destroy
			add_gem(g)
		for i in 16:
			var g = Gem.new()
			g.type = Gem.Type.Orange
			g.rune = Gem.Rune.Wisdom
			add_gem(g)
		for i in 16:
			var g = Gem.new()
			g.type = Gem.Type.Orange
			g.rune = Gem.Rune.Grow
			add_gem(g)
		for i in 16:
			var g = Gem.new()
			g.type = Gem.Type.Green
			g.rune = Gem.Rune.Destroy
			add_gem(g)
		for i in 16:
			var g = Gem.new()
			g.type = Gem.Type.Green
			g.rune = Gem.Rune.Wisdom
			add_gem(g)
		for i in 16:
			var g = Gem.new()
			g.type = Gem.Type.Green
			g.rune = Gem.Rune.Grow
			add_gem(g)
		for i in 16:
			var g = Gem.new()
			g.type = Gem.Type.Blue
			g.rune = Gem.Rune.Destroy
			add_gem(g)
		for i in 16:
			var g = Gem.new()
			g.type = Gem.Type.Blue
			g.rune = Gem.Rune.Wisdom
			add_gem(g)
		for i in 16:
			var g = Gem.new()
			g.type = Gem.Type.Blue
			g.rune = Gem.Rune.Grow
			add_gem(g)
		for i in 16:
			var g = Gem.new()
			g.type = Gem.Type.Purple
			g.rune = Gem.Rune.Destroy
			add_gem(g)
		for i in 16:
			var g = Gem.new()
			g.type = Gem.Type.Purple
			g.rune = Gem.Rune.Wisdom
			add_gem(g)
		for i in 16:
			var g = Gem.new()
			g.type = Gem.Type.Purple
			g.rune = Gem.Rune.Grow
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
		status_bar_ui.level_text.modulate.a = 0.0
		status_bar_ui.level_target.modulate.a = 0.0
		begin_busy()
		var tween = get_tree().create_tween()
		tween.tween_interval(1.1)
		tween.tween_callback(func():
			Board.ui.enter(null, false)
			begin_busy()
			Board.fill_blanks()
			for i in min(draws_per_roll, bag_gems.size()):
				Hand.draw()
			new_level(null)
		)
	else:
		status_bar_ui.level_text.modulate.a = 1.0
		status_bar_ui.level_target.modulate.a = 1.0
		load_from_file(saving)
		history.init()
		refresh_cluster_levels()
	
	status_bar_ui.board_size_text.show_change = true
	status_bar_ui.hand_text.show_change = true
	status_bar_ui.coins_text.show_change = true
	game_ui.show()

func get_level_title(lv : int, reward : int):
	return tr("ui_game_level") % [lv, reward]

func get_level_desc(target : int, curses : Array[Curse] = []):
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
			text = (tr(k) % cates[k]) + text
		ret += " [color=red]%s[/color]" % text
	return ret

func update_level_text(lv : int, target : int = -1, reward : int = -1, curses : Array[Curse] = []):
	status_bar_ui.level_text.text = tr("ui_game_level") % [lv, reward]
	if target == -1:
		target = get_level_score(lv)
	if reward == -1:
		reward = get_level_reward(lv)
	status_bar_ui.level_target.text = "[wave amp=10.0 freq=-1.0]%s[/wave]" % SUtils.format_text(get_level_desc(target, curses), true, true)

var cluster_level_tween : Tween = null

func change_cluster_level_frame(target : int, frame : int):
	var sp = status_bar_ui.cluster_level_sps[target]
	if frame == 2:
		if sp.frame != 2:
			if cluster_level_tween:
				cluster_level_tween.custom_step(100.0)
			cluster_level_tween = get_tree().create_tween()
			cluster_level_tween.tween_property(sp, "scale", Vector2(0.8, 0.8), 0.2)
			cluster_level_tween.tween_callback(func():
				sp.frame = 2
			)
			cluster_level_tween.tween_property(sp, "scale", Vector2(1.0, 1.0), 0.1)
			cluster_level_tween.tween_callback(func():
				cluster_level_tween = null
			)
	else:
		sp.frame = frame

func refresh_cluster_levels():
	if level_clear_ui.visible:
		var lv0 = int((level - 1) / 3) * 3
		for i in 3:
			if lv0 + i + 1 <= level:
				change_cluster_level_frame(i, 2)
			else:
				change_cluster_level_frame(i, 0)
	elif shop_ui.visible:
		var lv0 = int(level / 3) * 3
		for i in 3:
			if lv0 + i + 1 <= level:
				change_cluster_level_frame(i, 2)
			elif lv0 + i + 1 == level + 1:
				change_cluster_level_frame(i, 1)
			else:
				change_cluster_level_frame(i, 0)
	else:
		var lv0 = int((level - 1) / 3) * 3
		for i in 3:
			if lv0 + i + 1 < level:
				change_cluster_level_frame(i, 2)
			elif lv0 + i + 1 == level:
				change_cluster_level_frame(i, 1)
			else:
				change_cluster_level_frame(i, 0)

const curse_types = ["lust", "gluttony", "greed", "sloth", "wrath", "envy", "pride"]
func build_level_curses():
	for i in level + 3 - level_curses.size():
		var curses : Array[Curse] = []
		var type = SMath.pick_random(curse_types)
		type = "lust"
		var num = 0
		match (level + i) % 3:
			1:
				match type:
					"lust": num = 2
					"gluttony": num = 2
					"greed": num = 3
					"sloth": num = 10
					"wrath": num = 3
					"envy": num = 1
					"pride": num = 5
			2:
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
		level_curses.append(curses)

func remove_curse(c : Curse):
	c.remove()
	current_curses.erase(c)

func new_level(tween : Tween = null):
	build_level_curses()
	
	if !tween:
		tween = get_tree().create_tween()
	
	tween.tween_callback(func():
		score = 0
		level += 1
		target_score = get_level_score(level) * 1
		reward = get_level_reward(level)
		game_over_mark = ""
		history.level_reset()
		current_curses.clear()
		for c in level_curses[level - 1]:
			var cc = Curse.new()
			cc.type = c.type
			current_curses.append(cc)
		update_level_text(level, target_score, reward, current_curses)
		refresh_cluster_levels()
		
		rolls = rolls_per_level
		swaps = swaps_per_level
		plays = plays_per_level
		modifiers["played_i"] = 0
		
		if level_clear_ui.visible:
			level_clear_ui.exit()
		if game_over_ui.visible:
			game_over_ui.exit()
		
		for h in event_listeners:
			if h.event == Event.LevelBegan:
				h.host.on_event.call(Event.LevelBegan, null, null)
		
		save_to_file()
	)
	if !STest.testing:
		tween.tween_interval(1.0)
		banner_ui.appear(get_level_title(level + 1, get_level_reward(level + 1)), SUtils.format_text(get_level_desc(get_level_score(level + 1), Game.level_curses[level] if !Game.level_curses.is_empty() else ([] as Array[Curse])), true, false), tween)
		var temp_text1 = banner_ui.text1.duplicate()
		var temp_text2 = banner_ui.text2.duplicate()
		temp_text1.size = status_bar_ui.level_text.size
		temp_text2.size = status_bar_ui.level_target.size
		tween.tween_interval(0.5)
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
			banner_ui.disappear(null, true)
			banner_ui.add_child(temp_text1)
			banner_ui.add_child(temp_text2)
		)
		tween.tween_property(temp_text1, "global_position", status_bar_ui.level_text.global_position, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)
		tween.parallel().tween_property(temp_text2, "global_position", status_bar_ui.level_target.global_position, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)
		tween.tween_callback(func():
			banner_ui.hide()
			temp_text1.queue_free()
			temp_text2.queue_free()
		)
		if level == 0:
			tween.tween_callback(func():
				tutorial_ui.enter()
			)
	else:
		Curse.pick_targets()
		Curse.apply_curses()
	tween.tween_callback(func():
		status_bar_ui.level_text.modulate.a = 1.0
		status_bar_ui.level_target.modulate.a = 1.0
	)
	tween.tween_callback(func():
		stage = Stage.Deploy
		end_busy()
		control_ui.update_preview()
		control_ui.expected_score_panel.show()
	)

func level_end():
	Board.clear_active_effects()
	calculator_bar_ui.disappear()
	stage = Stage.LevelOver
	control_ui.swaps_text.show_change = false
	swaps = 0
	control_ui.swaps_text.show_change = true
	action_stack.clear()
	control_ui.undo_button.disabled = true
	control_ui.expected_score_panel.hide()
	for c in current_curses:
		c.remove()
	current_curses.clear()
	Buff.clear(self, [Buff.Duration.ThisLevel])
	for g in gems:
		Buff.clear(g, [Buff.Duration.ThisLevel])

func win():
	level_end()
	level_clear_ui.enter()
	refresh_cluster_levels()

func lose():
	level_end()
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
		Game.screen_shake_strength = 8.0
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
			HostType.Gem: d["host"] = Game.gems.find(h.host)
			HostType.Relic: d["host"] = Game.relics.find(h.host)
		d["once"] = h.once
	
	var data = {}
	data["seed"] = Game.rng.seed
	data["rng_state"] = Game.rng.state
	data["level"] = Game.level
	data["board_size"] = Game.board_size
	data["rolls_per_level"] = Game.rolls_per_level
	data["swaps_per_level"] = Game.swaps_per_level
	data["plays_per_level"] = Game.plays_per_level
	data["draws_per_roll"] = Game.draws_per_roll
	data["max_hand_grabs"] = Game.max_hand_grabs
	data["coins"] = Game.coins
	data["rolls"] = Game.rolls
	data["swaps"] = Game.swaps
	data["plays"] = Game.plays
	data["score"] = Game.score
	data["target_score"] = Game.target_score
	data["reward"] = Game.reward
	var current_curses = []
	for c in Game.current_curses:
		var curse = {}
		curse["type"] = c.type
		curse["coord"] = c.coord
		current_curses.append(curse)
	data["current_curses"] = current_curses
	var level_curses = []
	for lc in Game.level_curses:
		var level_curse = []
		for c in lc:
			var curse = {}
			curse["type"] = c.type
			curse["coord"] = c.coord
			level_curse.append(curse)
		level_curses.append(level_curse)
	data["level_curses"] = level_curses
	data["combos"] = Game.combos
	data["score_mult"] = Game.score_mult
	var game_buffs = []
	for b in Game.buffs:
		var buff = {}
		save_buff.call(b, buff)
		game_buffs.append(buff)
	data["buffs"] = game_buffs
	var game_event_listeners = []
	for h in Game.event_listeners:
		var hook = {}
		save_hook.call(h, hook)
		game_event_listeners.append(hook)
	data["event_listeners"] = game_event_listeners
	data["modifiers"] = Game.modifiers.duplicate()
	var board_event_listeners = []
	for h in Board.event_listeners:
		var hook = {}
		save_hook.call(h, hook)
		board_event_listeners.append(hook)
	data["cx"] = Board.cx
	data["cy"] = Board.cy
	data["board_event_listeners"] = board_event_listeners
	var gems = []
	for g in Game.gems:
		var gem = {}
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
	for g in Game.bag_gems:
		bag_gems.append(Game.gems.find(g))
	data["bag_gems"] = bag_gems
	var patterns = []
	for p in Game.patterns:
		var pattern = {}
		pattern["name"] = p.name
		pattern["mult"] = p.mult
		pattern["lv"] = p.lv
		pattern["exp"] = p.exp
		pattern["max_exp"] = p.max_exp
		patterns.append(pattern)
	data["patterns"] = patterns
	var relics = []
	for r in Game.relics:
		var relic = {}
		relic["name"] = r.name
		relic["extra"] = r.extra.duplicate()
		relics.append(relic)
	data["relics"] = relics
	var hand = []
	for g in Hand.grabs:
		hand.append(Game.gems.find(g))
	data["hand"] = hand
	var cells = []
	for c in Board.cells:
		var cell = {}
		cell["coord"] = c.coord
		cell["gem"] = Game.gems.find(c.gem)
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
	data["shopping"] = shop_ui.visible
	if shop_ui.visible:
		data["shop_refresh_price"] = shop_ui.refresh_price
		data["shop_enable_expand_board"] = !shop_ui.expand_board_button.button.disabled
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
			HostType.Gem: host = Game.gems[host_idx]
			HostType.Relic: host = Game.relics[host_idx]
		var h = Hook.new(int(d["event"]), host, host_type, d["once"])
		return h
	
	Game.rng.seed = int(data["seed"])
	Game.rng.state = int(data["rng_state"])
	Game.board_size = int(data["board_size"])
	Game.rolls_per_level = int(data["rolls_per_level"])
	Game.swaps_per_level = int(data["swaps_per_level"])
	Game.plays_per_level = int(data["plays_per_level"])
	Game.draws_per_roll = int(data["draws_per_roll"])
	Game.max_hand_grabs = int(data["max_hand_grabs"])
	Game.rolls = int(data["rolls"])
	Game.swaps = int (data["swaps"])
	Game.plays = int(data["plays"])
	Game.level = int(data["level"])
	Game.score = int(data["score"])
	Game.target_score = int(data["target_score"])
	Game.reward = int(data["reward"])
	Game.current_curses.clear()
	var current_curses = data["current_curses"]
	for curse in current_curses:
		var c = Curse.new()
		c.type = curse["type"]
		c.coord = str_to_var("Vector2i" + curse["coord"])
		Game.current_curses.append(c)
	Game.level_curses.clear()
	var level_curses = data["level_curses"]
	for level_data in level_curses:
		var lc = []
		for curse in level_data:
			var c = Curse.new()
			c.type = curse["type"]
			c.coord = str_to_var("Vector2i" + curse["coord"])
			lc.append(c)
		Game.level_curses.append(lc)
	Game.combos = int(data["combos"])
	Game.score_mult = data["score_mult"]
	update_level_text(level, target_score, reward, Game.current_curses)
	var game_buffs = data["buffs"]
	for buff in game_buffs:
		load_buff.call(buff, Game)
	var saved_modifiers = SUtils.read_dictionary(data["modifiers"])
	for k in saved_modifiers:
		Game.set_modifier(k, saved_modifiers[k])
	Game.coins = int(data["coins"])
	
	Board.cx = int(data["cx"])
	Board.cy = int(data["cy"])
	
	var gems = data["gems"]
	for gem in gems:
		var g = Gem.new()
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
		Game.bag_gems.append(Game.gems[idx])
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
		Game.event_listeners.append(h)
	var board_event_listeners = data["board_event_listeners"]
	for hook in board_event_listeners:
		var h = load_hook.call(hook)
		Board.event_listeners.append(h)
	var hand = data["hand"]
	for idx in hand:
		var g = Game.gems[int(idx)]
		Hand.grabs.append(g)
		Hand.ui.add_slot(g)
	var cells = data["cells"]
	for cell in cells:
		var coord = str_to_var("Vector2i" + cell["coord"])
		var c = Board.add_cell(coord)
		var ui = Game.Board.ui.get_cell(coord)
		var gem_idx = cell["gem"]
		if gem_idx != -1:
			var g = Game.gems[gem_idx]
			c.gem = g
			ui.gem_ui.reset(g.type, g.rune)
		var state = cell["state"]
		if state != Cell.State.Normal:
			Board.set_state_at(coord, state)
		if cell["pinned"]:
			Board.pin(coord)
		if cell["frozen"]:
			Board.freeze(coord)
		if cell["nullified"]:
			Board.nullify(coord)
	
	control_ui.enter()
	
	var shopping = data["shopping"]
	if shopping:
		shop_ui.refresh_price = int(data["shop_refresh_price"])
		shop_ui.expand_board_button.button.disabled = !data["shop_enable_expand_board"]
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
	else:
		Board.ui.enter(null, false)
		control_ui.update_preview()
		control_ui.expected_score_panel.show()

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
				Game.screen_shake_strength = 8.0
				if options_ui.visible:
					options_ui.exit()
				elif bag_viewer_ui.visible:
					bag_viewer_ui.exit()
				elif tutorial_ui.visible:
					tutorial_ui.exit()
				elif control_ui.visible:
					toggle_in_game_menu()
			elif event.keycode == KEY_F3:
				command_line_edit.visible = !command_line_edit.visible
				if command_line_edit.visible:
					command_line_edit.grab_focus()
	elif event is InputEventMouseButton:
		if event.is_pressed():
			pass
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
					contents.append_array(g.get_tooltip())
					STooltip.show(contents, 0.3)
			else:
				control_ui.debug_text.text = ""
				STooltip.close()

func _ready() -> void:
	randomize()
	
	subviewport.size = get_viewport().size
	
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
	Hand.ui = $/root/Main/SubViewportContainer/SubViewport/Canvas/Control/HBoxContainer2/Panel/HBoxContainer/Hand
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
		Game.process_command_line(cl)
		command_line_edit.clear()
		command_line_edit.hide()
	)
	
	screen_shake_noise = FastNoiseLite.new()
	screen_shake_noise.noise_type = FastNoiseLite.TYPE_PERLIN
	screen_shake_noise.fractal_type = FastNoiseLite.FRACTAL_FBM
	screen_shake_noise.frequency = 0.2
	screen_shake_noise.seed = randi()
	
	var window_size = Vector2(DisplayServer.window_get_size())
	trans_bg.size = window_size
	background.scale = window_size
	subviewport.size = window_size
	crt.material.set_shader_parameter("resolution", window_size)
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)

func _process(delta: float) -> void:
	if canvas:
		screen_shake_strength = lerp(screen_shake_strength, 0.0, 5.0 * delta)
		screen_shake_noise_coord += 30.0 * delta
		screen_offset = lerp(screen_offset, (mouse_pos - subviewport.size * 0.5) * 0.007, 0.05)
		canvas.offset = screen_offset + Vector2(screen_shake_noise.get_noise_2d(17.0, screen_shake_noise_coord), screen_shake_noise.get_noise_2d(93.0, screen_shake_noise_coord)) * screen_shake_strength
