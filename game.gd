extends Node

enum Stage
{
	None,
	Deploy,
	Rolling,
	Matching,
	GameOver,
	Settlement,
	Upgrade,
	Shopping
}

const object_type : int = C.ObjectType.Game

const version_major : int = 1
const version_minor : int = 0
const version_patch : int = 29

const MaxRelics : int = 5
const MaxPatterns : int = 4
 
const UiGem = preload("res://ui_gem.gd")
const UiRelic = preload("res://ui_relic.gd")
const UiPattern = preload("res://ui_pattern.gd")
const NumberText = preload("res://number_text.gd")
const UiRichButton = preload("res://rich_button.gd")
const UiGemSlot = preload("res://ui_gem_slot.gd")
const UiStagingSlot = preload("res://ui_staging_slot.gd")
const UiCraftSlot = preload("res://ui_craft_slot.gd")
const UiCell = preload("res://ui_cell.gd")
const UiTitle = preload("res://ui_title.gd")
const UiNewGame = preload("res://ui_new_game.gd")
const UiBoard = preload("res://ui_board.gd")
const UiProp = preload("res://ui_prop.gd")
const UiHandSlot = preload("res://ui_hand_slot.gd")
const UiHand = preload("res://ui_hand.gd")
const UiStatusBar = preload("res://ui_status_bar.gd")
const UiRelicsBar = preload("res://ui_relics_bar.gd")
const UiPatternsBar = preload("res://ui_patterns_bar.gd")
const UiControl = preload("res://ui_control.gd")
const UiShopItem = preload("res://ui_shop_item.gd")
const UiShop = preload("res://ui_shop.gd")
const UiGame = preload("res://ui_game.gd")
const UiCalculatorBar = preload("res://ui_calculate_bar.gd")
const UiBanner = preload("res://banner.gd")
const UiDialog = preload("res://ui_dialog.gd")
const UiOptions = preload("res://ui_options.gd")
const UiTest = preload("res://ui_test.gd")
const UiCollections = preload("res://ui_collections.gd")
const UiInGameMenu = preload("res://ui_in_game_menu.gd")
const UiGameOver = preload("res://ui_game_over.gd")
const UiSettlement = preload("res://ui_settlement.gd")
const UiUpgrade = preload("res://ui_upgrade.gd")
const UiChooseReward = preload("res://ui_choose_reward.gd")
const UiRunInfo = preload("res://ui_run_info.gd")
const UiBagViewer = preload("res://ui_bag_viewer.gd")
const UiGuide = preload("res://ui_guide.gd")
const UiTutorial = preload("res://ui_tutorial.gd")
const UiTutorialAction = preload("res://ui_tutorial_action.gd")
const UiTooltips = preload("res://ui_tooltips.gd")

@onready var gem_frames : SpriteFrames = load("res://images/gems.tres")
@onready var rune_frames : SpriteFrames = load("res://images/runes.tres")
@onready var relic_frames : SpriteFrames = load("res://images/relics.tres")
@onready var popup_txt_pb : PackedScene = load("res://popup_txt.tscn")
@onready var gem_ui_pb : PackedScene = load("res://ui_gem.tscn")
@onready var gem_slot_pb : PackedScene = load("res://ui_gem_slot.tscn")
@onready var trail_pb : PackedScene = load("res://trail.tscn")
@onready var cell_pb : PackedScene = load("res://ui_cell.tscn")
@onready var outline_pb : PackedScene = load("res://ui_outline.tscn")
@onready var active_effect_pb = load("res://ui_active_effect.tscn")
@onready var dashed_line_pb : PackedScene = load("res://dashed_line.tscn")
@onready var entangled_line_pb : PackedScene = load("res://entangled_line.tscn")
@onready var constellation_pb : PackedScene = load("res://ui_constellation.tscn")
@onready var hand_slot_pb : PackedScene = load("res://ui_hand_slot.tscn")
@onready var relic_ui_pb : PackedScene = load("res://ui_relic.tscn")
@onready var pattern_ui_pb : PackedScene = load("res://ui_pattern.tscn")
@onready var settlement_item_pb : PackedScene = load("res://ui_settlement_item.tscn")
@onready var reward_pb : PackedScene = load("res://ui_reward.tscn")
@onready var shop_item_pb : PackedScene = load("res://ui_shop_item.tscn")
@onready var craft_slot_pb : PackedScene = load("res://ui_craft_slot.tscn")
@onready var entangle_slots_pb : PackedScene = load("res://ui_entangle_slots.tscn")
@onready var tooltip_pb : PackedScene = load("res://tooltip.tscn")
@onready var contex_menu_pb : PackedScene = load("res://ui_context_menu.tscn")
@onready var tutorial_action_pb : PackedScene = load("res://ui_tutorial_action.tscn")
@onready var pointer_cursor : Texture = load("res://images/pointer.png")
@onready var pin_cursor : Texture = load("res://images/pin.png")
@onready var activate_cursor : Texture = load("res://images/magic_stick.png")
@onready var grab_cursor : Texture = load("res://images/grab.png")

@onready var background : Node2D = $/root/Main/SubViewportContainer/SubViewport/Background
@onready var crt : Control = $/root/Main/PostProcessing/ColorRect
@onready var trans_bg : Control = $/root/Main/TransBG
@onready var trans_bubbles : CPUParticles2D = $/root/Main/TransBubbles
@onready var subviewport_container : SubViewportContainer = $/root/Main/SubViewportContainer
@onready var subviewport : SubViewport = $/root/Main/SubViewportContainer/SubViewport
@onready var canvas : CanvasLayer = $/root/Main/SubViewportContainer/SubViewport/Canvas
@onready var title_ui : UiTitle = $/root/Main/SubViewportContainer/SubViewport/Canvas/Title
@onready var new_game_ui : UiNewGame = $/root/Main/SubViewportContainer/SubViewport/Canvas/NewGame
@onready var control_ui : UiControl = $/root/Main/SubViewportContainer/SubViewport/Canvas/GameControl
@onready var shop_ui : UiShop = $/root/Main/SubViewportContainer/SubViewport/Canvas/Shop
@onready var game_ui : UiGame = $/root/Main/SubViewportContainer/SubViewport/Canvas/GameUI
@onready var calculator_bar_ui : UiCalculatorBar = $/root/Main/SubViewportContainer/SubViewport/Canvas/CalculateBar
@onready var banner_ui : UiBanner = $/root/Main/SubViewportContainer/SubViewport/Canvas/Banner
@onready var dialog_ui : UiDialog = $/root/Main/SubViewportContainer/SubViewport/Canvas/Dialog
@onready var options_ui : UiOptions = $/root/Main/SubViewportContainer/SubViewport/Canvas/Options
@onready var test_ui : UiTest = $/root/Main/SubViewportContainer/SubViewport/Canvas/Test
@onready var collections_ui : UiCollections = $/root/Main/SubViewportContainer/SubViewport/Canvas/Collections
@onready var run_info_ui : UiRunInfo = $/root/Main/SubViewportContainer/SubViewport/Canvas/RunInfo
@onready var bag_viewer_ui : UiBagViewer = $/root/Main/SubViewportContainer/SubViewport/Canvas/BagViewer
@onready var guide_ui : UiGuide = $/root/Main/SubViewportContainer/SubViewport/Canvas/Guide
@onready var tutorial_ui : UiTutorial = $/root/Main/SubViewportContainer/SubViewport/Canvas/Tutorial
@onready var in_game_menu_ui : UiInGameMenu = $/root/Main/SubViewportContainer/SubViewport/Canvas/InGameMenu
@onready var game_over_ui : UiGameOver = $/root/Main/SubViewportContainer/SubViewport/Canvas/GameOver
@onready var settlement_ui : UiSettlement = $/root/Main/SubViewportContainer/SubViewport/Canvas/Settlement
@onready var upgrade_ui : UiUpgrade = $/root/Main/SubViewportContainer/SubViewport/Canvas/Upgrade
@onready var choose_reward_ui : UiChooseReward = $/root/Main/SubViewportContainer/SubViewport/Canvas/ChooseReward
@onready var command_line_edit : LineEdit = $/root/Main/SubViewportContainer/SubViewport/Canvas/CommandLine
@onready var blocker_ui : Control = $/root/Main/SubViewportContainer/SubViewport/Canvas/Blocker

const resolution : Vector2i = Vector2i(1920, 1080)
var mouse_pos : Vector2
var screen_offset : Vector2
var hovering_coord : Vector2i = Vector2i(-1, -1)
var game_tweens : Node = null
var base_speed : float = 1.0
var time_scale : float = 1.0 / base_speed
var staging_nodes : Array
var busy : bool = false

var stage : int = Stage.None
var game_rng : RandomNumberGenerator = RandomNumberGenerator.new()
var round_rng : RandomNumberGenerator = RandomNumberGenerator.new()
var shop_rng : RandomNumberGenerator = RandomNumberGenerator.new()
var swaps : int:
	set(v):
		swaps = v
		if !is_headless():
			control_ui.swaps_text.set_value(swaps)
			if control_ui.play_button.disabled == false && swaps == 0:
				control_ui.show_last_play()
			else:
				control_ui.last_play.hide()
var swaps_per_round : int
var plays : int:
	set(v):
		plays = v
		if !is_headless():
			control_ui.plays_text.text = "%d" % plays
var plays_per_round : int
var draws_per_roll : int
var next_roll_extra_draws : int = 0
var hand_size : int:
	set(v):
		hand_size = v
		if !is_headless():
			if Hand.ui:
				Hand.ui.resize()
				game_ui.status_bar.hand_text.set_value(hand_size)
var action_stack : Array[Pair]
var board_size : int = 3:
	set(v):
		board_size = v
		if !is_headless():
			game_ui.status_bar.board_size_text.set_value(board_size)
var patterns : Array[Pattern]
var gems : Array[Gem]
var bag_gems : Array[Gem] = []
var entangled_groups : Array[EntangledGroup] = []
var relics : Array[Relic]
var event_listeners : Array[Hook]
var current_round : int
var score : int:
	set(v):
		score = v
		if !is_headless():
			game_ui.status_bar.score_text.text = "%d" % score
var target_score : int
var reward : int
var current_curses : Array[Curse]
var round_curses : Array[Array]
var no_score_marks : Dictionary[int, Array]

var base_score_tween : Tween = null
var base_score : int:
	set(v):
		if !is_headless():
			if v > base_score:
				base_score = v
				if base_score_tween:
					base_score_tween.custom_step(100.0)
				calculator_bar_ui.base_score_text.position.y = 4
				calculator_bar_ui.base_score_text.text = "%d" % v
				base_score_tween = create_game_tween()
				base_score_tween.tween_property(calculator_bar_ui.base_score_text, "position:y", 0, 0.2 * time_scale)
				base_score_tween.tween_callback(func():
					base_score_tween = null
				)
			else:
				if base_score_tween:
					base_score_tween.kill()
					base_score_tween = null
				base_score = v
				calculator_bar_ui.base_score_text.text = "%d" % base_score
		else:
			base_score = v

var chains_tween : Tween
var chains : int = 0:
	set(v):
		chains = v
		if !is_headless():
			calculator_bar_ui.chains_text.set_value(chains)
			if chains < 2:
				calculator_bar_ui.chains_text.clear_animation()
			
			if chains >= 2:
				if chains_tween:
					chains_tween.custom_step(100.0)
					chains_tween = null
				game_ui.chains_label.show()
				game_ui.chains_label.pivot_offset = game_ui.chains_label.size * 0.5
				game_ui.chains_label.rotation_degrees = randf() * 20.0 - 10.0
				chains_tween = create_game_tween()
				chains_tween.tween_interval(0.5 * time_scale)
				chains_tween.tween_property(game_ui.chains_label, "modulate:a", 0.0, 0.3 * time_scale).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
				chains_tween.tween_callback(func():
					game_ui.chains_label.hide()
					game_ui.chains_label.modulate.a = 1.0
				)

const chains_to_mult_parm = 1.0 / log(2.0)
func mult_from_chains(chains : int):
	return log((chains + 1) * 1.0) * chains_to_mult_parm

var gain_scaler_tween : Tween = null
var gain_scaler : float = 1.0:
	set(v):
		gain_scaler = v
		
		if gain_scaler_tween:
			gain_scaler_tween.custom_step(100.0)
			gain_scaler_tween = null
		if gain_scaler == 1.0:
			game_ui.gain_scalar_label.hide()
		else:
			game_ui.gain_scalar_label.text = "%d%%" % int(gain_scaler * 100.0)
			game_ui.gain_scalar_label.show()
			game_ui.gain_scalar_label.pivot_offset = game_ui.gain_scalar_label.size * 0.5
			game_ui.gain_scalar_label.rotation_degrees = randf() * 20.0 - 10.0
			gain_scaler_tween = create_game_tween()

var score_mult_tween : Tween = null
var score_mult : float = 1.0:
	set(v):
		if !is_headless():
			if v > score_mult:
				score_mult = v
				if score_mult_tween:
					score_mult_tween.custom_step(100.0)
				calculator_bar_ui.mult_text.position.y = 4
				calculator_bar_ui.mult_text.text = "%.1f" % v
				score_mult_tween = create_game_tween()
				score_mult_tween.tween_property(calculator_bar_ui.mult_text, "position:y", 0, 0.2 * time_scale)
				score_mult_tween.tween_callback(func():
					score_mult_tween = null
				)
			else:
				if score_mult_tween:
					score_mult_tween.kill()
					score_mult_tween = null
				score_mult = v
				calculator_bar_ui.mult_text.text = "%.1f" % score_mult
		else:
			score_mult = v

var luck : int = 0

var filling_times : int = 0:
	set(v):
		filling_times = v
		if !is_headless():
			if filling_times >= C.REFILL_TIMES_TO_SHOW:
				if !control_ui.filling_times_container.visible:
					control_ui.filling_times_container.show()
					control_ui.filling_times_container.pivot_offset = control_ui.filling_times_container.size * 0.5
					control_ui.filling_times_container.scale = Vector2(0.0, 0.0)
					var tween = create_game_tween()
					tween.tween_property(control_ui.filling_times_container, "scale", Vector2(1.0, 1.0), 0.15).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUART)
				if control_ui.filling_times_tween:
					control_ui.filling_times_tween.custom_step(100.0)
					control_ui.filling_times_tween = null
				if control_ui.filling_times_container.visible:
					control_ui.filling_times_text.position.y = 0
					control_ui.filling_times_tween = create_game_tween()
					SAnimation.jump(control_ui.filling_times_tween, control_ui.filling_times_text, -0.0, 0.25 * time_scale, func():
						control_ui.filling_times_text.text = "%d" % filling_times
					)
					control_ui.filling_times_tween.tween_callback(func():
						control_ui.filling_times_tween = null
					)

var coins : int = 10:
	set(v):
		coins = v
		if !is_headless():
			game_ui.status_bar.coins_text.set_value(coins)

var buffs : Array[Buff]
var attrs : Dictionary
var game_over_mark : String = ""
var invincible : bool = false

var history : History = History.new()

signal swap_finished

var paint_mode : String = "off"
var paint_brush1 : int = Gem.ColorWhite
var paint_brush2 : int = Gem.ColorBlack
var paint_coord : Vector2i = Vector2i(-1, -1)

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

func is_headless():
	return STest.testing && (STest.headless && !STest.try_out)

func random_seeds():
	game_rng.seed = Time.get_ticks_usec()
	round_rng.seed = game_rng.seed + 1
	shop_rng.seed = game_rng.seed + 2

func add_gem(g : Gem):
	if g.on_event.is_valid():
		g.on_event.call(C.Event.GainGem, null, g)
	for h in event_listeners:
		if h.event == C.Event.GainGem || h.event == C.Event.Any:
			h.caster.on_event.call(C.Event.GainGem, null, g)
	
	gems.append(g)
	bag_gems.append(g)
	g.bag_stamp = current_round
	
	if !is_headless():
		game_ui.status_bar.gem_count_text.text = "%d" % gems.size()

func remove_gem(g : Gem):
	bag_gems.erase(g)
	gems.erase(g)
	
	var eg = find_entangled_group(g)
	if eg:
		eg.gems.erase(g)
		if eg.gems.size() <= 1:
			entangled_groups.erase(eg)
	
	if g.on_event.is_valid():
		g.on_event.call(C.Event.LostGem, null, g)
	for h in event_listeners:
		if h.event == C.Event.LostGem || h.event == C.Event.Any:
			h.caster.on_event.call(C.Event.LostGem, null, g)
	
	if !is_headless():
		game_ui.status_bar.gem_count_text.text = "%d" % gems.size()

func take_from_bag(g : Gem = null) -> Gem:
	if g:
		bag_gems.erase(g)
		return g
	if bag_gems.is_empty():
		return null
	return SMath.pick_and_remove(bag_gems, game_rng)

func put_to_bag(g : Gem):
	g.bonus_score = 0
	g.coord = Vector2i(-1, -1)
	g.bag_stamp = current_round
	Buff.clear(g, [C.Duration.ThisChain, C.Duration.ThisMatching, C.Duration.OnBoard])
	bag_gems.append(g)

func sort_gems():
	gems.sort_custom(func(a, b):
		return a.get_rank() < b.get_rank()
	)

func find_entangled_group(g : Gem):
	for gp in entangled_groups:
		if gp.gems.has(g):
			return gp
	return null

func on_attr_changed(name):
	if name == "base_chain_i":
		chains = max(chains, attrs["base_chain_i"])
	elif name == "red_bouns_i":
		if !is_headless():
			game_ui.status_bar.red_bouns_text.set_value(attrs["red_bouns_i"])
	elif name == "orange_bouns_i":
		if !is_headless():
			game_ui.status_bar.orange_bouns_text.set_value(attrs["orange_bouns_i"])
	elif name == "green_bouns_i":
		if !is_headless():
			game_ui.status_bar.green_bouns_text.set_value(attrs["green_bouns_i"])
	elif name == "blue_bouns_i":
		if !is_headless():
			game_ui.status_bar.blue_bouns_text.set_value(attrs["blue_bouns_i"])
	elif name == "magenta_bouns_i":
		if !is_headless():
			game_ui.status_bar.magenta_bouns_text.set_value(attrs["magenta_bouns_i"])
	for h in event_listeners:
		if h.event == C.Event.ModifierChanged || h.event == C.Event.Any:
			h.caster.on_event.call(C.Event.ModifierChanged, null, {"name":name,"value":attrs[name]})

func set_attr(name : String, v):
	attrs[name] = v
	on_attr_changed(name)

func change_attr(name : String, v):
	attrs[name] += v
	on_attr_changed(name)

func gem_add_base_score(g : Gem, v : int):
	for h in event_listeners:
		if h.event == C.Event.GemBaseScoreChanged || h.event == C.Event.Any:
			h.caster.on_event.call(C.Event.GemBaseScoreChanged, null, {"gem":g,"value":v})
	g.base_score += v
	return v

func gem_add_bonus_score(g : Gem, v : int):
	for h in event_listeners:
		if h.event == C.Event.GemBonusScoreChanged || h.event == C.Event.Any:
			h.caster.on_event.call(C.Event.GemBonusScoreChanged, null, {"gem":g,"value":v})
	g.bonus_score += v
	return 

func add_pattern(p : Pattern):
	for h in event_listeners:
		if h.event == C.Event.GainPattern || h.event == C.Event.Any:
			h.caster.on_event.call(C.Event.GainPattern, null, p)
	
	patterns.append(p)
	if !is_headless():
		game_ui.patterns_bar.add_ui(p)

func add_relic(r : Relic):
	if r.on_event.is_valid():
		r.on_event.call(C.Event.GainRelic, null, r)
	for h in event_listeners:
		if h.event == C.Event.GainRelic || h.event == C.Event.Any:
			h.caster.on_event.call(C.Event.GainRelic, null, r)
	
	relics.append(r)
	if !is_headless():
		game_ui.relics_bar.add_ui(r)

func remove_relic(r : Relic):
	relics.erase(r)
	if !is_headless():
		game_ui.relics_bar.remove_ui(r)
	
	if r.on_event.is_valid():
		r.on_event.call(C.Event.LostRelic, null, r)
	for h in event_listeners:
		if h.event == C.Event.LostRelic || h.event == C.Event.Any:
			h.caster.on_event.call(C.Event.LostRelic, null, r)
	
	SUtils.remove_event_listeners(G, r)
	SUtils.remove_event_listeners(Board, r)

func has_relic(n : String):
	for r in relics:
		if r.name == n:
			return true
	return false

func add_chain():
	chains += 1
	var buffs_to_clear = []
	for b in self.buffs:
		if b.duration == C.Duration.ThisChain:
			buffs_to_clear.append(b.uid)
	Board.on_chain()
	Buff.remove_by_id_list(self, buffs_to_clear)

func create_game_tween() -> Tween:
	if !is_headless():
		return game_tweens.create_tween()
	return null

func float_text(txt : String, pos : Vector2):
	pos += Vector2(randf() * 10.0 - 5.0, randf() * 10.0 - 5.0)
	var ui = popup_txt_pb.instantiate()
	ui.position = pos
	var lb : RichTextLabel = ui.get_child(0)
	lb.text = txt
	ui.z_index = 4
	Board.ui.overlay.add_child(ui)
	var tween = ui.create_tween()
	tween.tween_property(ui, "position", pos - Vector2(0, 20), 0.5)
	tween.tween_callback(func():
		ui.queue_free()
	)

func add_score(value : int, pos : Vector2):
	value = round(value * gain_scaler)
	var crit = (game_rng.randi_range(0, 99) < luck)
	if crit:
		value *= 2
	if !is_headless():
		var ui = popup_txt_pb.instantiate()
		pos += Vector2(randf() * 6.0 - 3.0, randf() * 6.0 - 3.0)
		ui.position = pos
		var lb : RichTextLabel = ui.get_child(0)
		if crit:
			ui.scale = Vector2(1.8, 1.8)
			lb.text = "[color=gold]%d[/color]" % value
		else:
			ui.scale = Vector2(1.5, 1.5)
			lb.text = "%d" % value
		ui.z_index = 8
		game_ui.game_overlay.add_child(ui)
	
		var tween = ui.create_tween()
		tween.tween_property(ui, "position:y", pos.y - (30 if crit else 20), 0.1 * time_scale)
		tween.tween_property(ui, "position:y", pos.y, 0.2 * time_scale).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
		tween.tween_callback(func():
			G.base_score += value
			ui.queue_free()
		)
	else:
		G.base_score += value

var status_tween : Tween
func float_status_text(s : String, col : Color):
	control_ui.status_text.show()
	control_ui.status_text.text = s
	var parent = control_ui.status_text.get_parent()
	parent.scale = Vector2(1.3, 1.3)
	control_ui.status_text.add_theme_color_override("font_color", col)
	if status_tween:
		status_tween.kill()
	status_tween = create_game_tween()
	status_tween.tween_method(func(t):
		parent.rotation_degrees = sin(t * PI * 10.0) * t * 10.0
	, 1.0, 0.0, 1.0)
	status_tween.parallel().tween_property(parent, "scale", Vector2(1.0, 1.0), 1.0)
	status_tween.tween_interval(0.5)
	status_tween.tween_callback(func():
		control_ui.status_text.hide()
		status_tween = null
	)

func create_gem_ui(g : Gem, pos : Vector2):
	var ui = gem_ui_pb.instantiate()
	ui.update(g)
	ui.global_position = pos
	game_ui.game_overlay.add_child(ui)
	return ui

func delete_gem(tween : Tween, g : Gem, ui, from : String = "hand"):
	var old_coord = g.coord
	SSound.se_trash.play()
	ui.dissolve(0.5)
	if !tween:
		tween = create_game_tween()
	tween.tween_interval(0.5)
	tween.tween_callback(func():
		if from == "hand":
			Hand.erase(Hand.find(g))
		remove_gem(g)
		if gems.size() < Board.curr_min_gem_num:
			game_over_mark = "not_enough_gems"
			lose()
		else:
			if from == "hand" || from == "craft_slot":
				Hand.draw(false)
			elif from == "board":
				Board.set_gem_at(old_coord, null)
				Board.fill_blanks()
	)

func copy_gem(src : Gem, dst : Gem):
	dst.name = src.name
	if dst.name != "":
		dst.setup(dst.name)
	dst.type = src.type
	dst.rune = src.rune
	dst.base_score = src.base_score
	dst.bonus_score = src.bonus_score
	dst.score_mult = src.score_mult
	for b in src.buffs:
		var new_b = Buff.new()
		new_b.uid = Buff.s_uid
		Buff.s_uid += 1
		new_b.type = b.type
		new_b.host = dst
		new_b.duration = b.duration
		new_b.data = b.data.duplicate(true)
		dst.buffs.append(new_b)

func duplicate_gem(tween : Tween, g : Gem, ui, from : String = "hand"):
	SSound.se_enchant.play()
	var new_ui = create_gem_ui(g, ui.global_position)
	if from == "hand":
		new_ui.position += Vector2(16.0, 16.0)
	if !tween:
		tween = create_game_tween()
	tween.tween_property(new_ui, "position", new_ui.position + Vector2(0.0, -40.0), 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)
	tween.tween_callback(func():
		new_ui.add_child(trail_pb.instantiate())
	)
	tween.tween_property(new_ui, "position", game_ui.status_bar.bag_button.get_global_rect().get_center(), 0.5).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUART)
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
		bid = Buff.create(g, Buff.Type.ValueModifier, {"addr":"base_score","add":200}, C.Duration.Eternal)
	elif type == "w_enchant_sharp":
		bid = Buff.create(g, Buff.Type.ValueModifier, {"addr":"score_mult","mult":2.0}, C.Duration.Eternal)
	Buff.create(g, Buff.Type.Enchant, {"type":type,"bid":bid}, C.Duration.Eternal)

func entangle_gems(g1 : Gem, g2 : Gem):
	var gp1 = find_entangled_group(g1)
	var gp2 = find_entangled_group(g2)
	if gp1 == null && gp2 == null:
		var new_gp = EntangledGroup.new()
		new_gp.gems.append(g1)
		new_gp.gems.append(g2)
		entangled_groups.append(new_gp)
	elif gp1 == null && gp2 != null:
		gp2.gems.append(g1)
	elif gp1 != null && gp2 == null:
		gp1.gems.append(g2)
	elif gp1 != gp2:
		for g in gp2.gems:
			gp1.gems.append(g)
		entangled_groups.erase(gp2)

func swap_hand_and_board(slot1 : Control, coord : Vector2i, reason : String = "swap"):
	var tween = create_game_tween()
	var g1 = slot1.gem
	var g2 = Board.get_gem_at(coord)
	var cell_pos = Board.get_pos(coord)
	var mpos = get_viewport().get_mouse_position()
	var hf_sz = Vector2(C.BOARD_TILE_SZ, C.BOARD_TILE_SZ) * 0.5
	begin_busy()
	slot1.elastic = -1.0
	slot1.z_index = 10
	tween.tween_interval(0.1)
	tween.tween_callback(func():
		SSound.se_drop_item.play()
		Board.set_gem_at(coord, null)
		
		take_from_bag(g2)
		var slot2 = Hand.add_gem(g2, -1)
		slot2.global_position = cell_pos - hf_sz
		slot2.elastic = -1.0
		
		var sub1 = create_game_tween()
		var sub2 = create_game_tween()
		var dir = mpos - cell_pos
		var sec = 1 if reason == "undo" else SUtils.hex_section(rad_to_deg(dir.angle()))
		dir = Vector2.from_angle(deg_to_rad(sec * 60.0 + 30.0))
		sub1.tween_property(slot1, "global_position", cell_pos - hf_sz + dir * C.BOARD_TILE_SZ * 0.75, 0.15).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)
		sub1.tween_property(slot1, "global_position", cell_pos - hf_sz, 0.2)
		sub2.tween_interval(0.1)
		sub2.tween_property(slot2.gem_ui, "angle", SUtils.hex_quadrant(sec) * Vector2(75.0, 30.0), 0.07)
		sub2.tween_property(slot2, "global_position", cell_pos - hf_sz - dir * C.BOARD_TILE_SZ * 0.75, 0.15).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)
		sub2.parallel().tween_property(slot2.gem_ui, "angle", Vector2(0.0, 0.0), 0.07)
		sub2.tween_property(slot2, "elastic", 1.0, 0.2).from(0.0)
		
		var tween2 = create_game_tween()
		tween2.tween_subtween(sub1)
		tween2.parallel().tween_subtween(sub2)
		tween2.tween_callback(func():
			Hand.erase(slot1.get_index())
			Board.set_gem_at(coord, g1)
			control_ui.update_preview()
			end_busy()
			swap_finished.emit()
		)
	)

func add_new_gem_from(tween : Tween, g : Gem, coord : Vector2i):
	var pos = Board.get_pos(coord) - Vector2(C.BOARD_TILE_SZ, C.BOARD_TILE_SZ) * 0.5
	var ui = create_gem_ui(g, pos)
	ui.hide()
	if !tween:
		tween = create_game_tween()
	tween.tween_callback(func():
		ui.show()
	)
	tween.tween_property(ui, "scale", Vector2(0.75, 0.75), 0.4 * time_scale)
	tween.parallel()
	SAnimation.cubic_curve_to(tween, ui, game_ui.status_bar.bag_button.get_global_rect().get_center(), Vector2(0.1, 0.2), Vector2(0.9, 0.2), 0.5 * time_scale)
	tween.tween_callback(func():
		add_gem(g)
		sort_gems()
		ui.queue_free()
	)

static func read_coord(s : String):
	if s.length() == 6:
		return Vector2i(int(s.substr(0, 3)), int(s.substr(3, 6)))
	return Vector2i(-1, -1)

var cli_history : Array[String]
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
		if cmd == "win":
			win()
		elif cmd == "lose":
			lose()
		elif cmd == "shop":
			shop_ui.enter()
		elif cmd == "freeze":
			var coord = read_coord(tokens[1])
			Board.freeze(coord)
		elif cmd == "unfreeze":
			var coord = read_coord(tokens[1])
			Board.unfreeze(coord)
		elif cmd == "swaps":
			swaps = int(tokens[1])
		elif cmd == "draw":
			Hand.draw()
		elif cmd == "board_size" || cmd == "bs":
			var size = int(tokens[1])
			board_size = size
			Board.resize(size, null)
		elif cmd == "gold":
			coins += int(tokens[1])
		elif cmd == "add_gem" || cmd == "ag":
			var num = 1
			var tt = tokens[1]
			if tt.is_valid_int():
				num = int(tt)
				tt = tokens[2]
			for j in num:
				var g = Gem.new()
				g.setup(tt)
				add_gem(g)
		elif cmd == "add_relic" || cmd == "ar":
			var r = Relic.new()
			r.setup(tokens[1])
			add_relic(r)
		elif cmd == "remove_relic" || cmd == "rr":
			var idx = int(tokens[1])
			remove_relic(relics[idx])
		elif cmd == "swap":
			var coord1 = read_coord(tokens[1])
			var coord2 = read_coord(tokens[2])
			Board.effect_swap(coord1, coord2, null)
		elif cmd == "backup":
			DirAccess.copy_absolute("user://save1.json", "res://save_%s.txt" % SUtils.get_formated_datetime())
		elif cmd == "restore":
			DirAccess.copy_absolute("res://%s.txt" % tokens[1], "user://save1.json")
		elif cmd == "test":
			STest.start()
		elif cmd == "paint":
			if tokens.size() >= 2:
				var t1 = tokens[1]
				if t1 == "cell":
					if tokens.size() >= 4:
						Board.effect_change_color(read_coord(tokens[2]), Gem.name_to_type(tokens[3]), Gem.None, null)
				elif t1 == "clear":
					var color = Gem.ColorBlack
					if tokens.size() >= 3:
						color = Gem.name_to_type(tokens[2])
					var tween = create_game_tween()
					var delay = 0.0
					for y in Board.cy:
						for x in Board.cx:
							var sub = create_game_tween()
							sub.tween_interval(delay)
							Board.effect_change_color(Vector2i(x, y), color, Gem.None, sub)
							tween.tween_subtween(sub)
							tween.parallel()
							delay += 0.01
					Painting.clear_lines()
				elif t1 == "mode":
					if paint_mode == "on":
						paint_mode = "off"
						paint_coord = Vector2i(-1, -1)
					else:
						paint_mode = "on"
						paint_coord = Vector2i(-1, -1)
				elif t1 == "brush":
					if tokens.size() >= 3:
						paint_brush1 = Gem.name_to_type(tokens[2])
				elif t1 == "brush1":
					if tokens.size() >= 3:
						paint_brush1 = Gem.name_to_type(tokens[2])
				elif t1 == "brush2":
					if tokens.size() >= 3:
						paint_brush2 = Gem.name_to_type(tokens[2])
				elif t1 == "save":
					if tokens.size() >= 3:
						var name = tokens[2]
						Painting.save_to_file(name)
				elif t1 == "load":
					if tokens.size() >= 3:
						var name = tokens[2]
						var content = Painting.load_from_file(name)
						if !content.is_empty():
							var colors = content.colors
							var lines = content.lines
							var center = Board.offset_to_cube(Board.center)
							var tween = create_game_tween()
							var delay = 0.0
							for col in colors.keys():
								for cc in colors[col]:
									var oc = Board.cube_to_offset(center + cc)
									var g = Board.get_gem_at(oc)
									if g && g.name == "":
										var sub = create_game_tween()
										sub.tween_interval(delay)
										Board.effect_change_color(oc, col, Gem.None, sub)
										tween.tween_subtween(sub)
										tween.parallel()
										delay += 0.01
							for l in lines:
								var sub = create_game_tween()
								sub.tween_interval(delay)
								sub.tween_callback(func():
									Painting.add_line(Board.cube_to_offset(center + l[0]), Board.cube_to_offset(center + l[1]))
								)
								tween.tween_subtween(sub)
								tween.parallel()
								delay += 0.01
				elif t1 == "image":
					if tokens.size() >= 3:
						Painting.set_board_to_image(tokens[2])
	
	for c in cli_history:
		if c == cl:
			cli_history.erase(c)
			break
	cli_history.append(cl)

func get_round_score(r : int):
	if r <= 24:
		match r:
			1: return 250
			2: return 400
			3: return 750
			4: return 1000
			5: return 1500
			6: return 2500
			7: return 3250
			8: return 4500
			9: return 6500
			10: return 7500
			11: return 9250
			12: return 12000
			13: return 13250
			14: return 15500
			15: return 19000
			16: return 20500
			17: return 23500
			18: return 28000
			19: return 30000
			20: return 34000
			21: return 40000
			22: return 42500
			23: return 47500
			24: return 55000
	else:
		return 1000000000

func get_round_reward(r : int):
	if r % 3 == 0:
		return 10
	elif r % 3 == 1:
		return 5
	elif r % 3 == 2:
		return 7
	return 0

func set_lang(lang : String):
	if lang.begins_with("en"):
		TranslationServer.set_locale("en")
	elif lang.begins_with("zh"):
		TranslationServer.set_locale("zh")
	if current_round > 0:
		update_round_text(current_round)
	if options_ui.visible:
		options_ui.lang_changed()

func begin_busy():
	if !is_headless():
		control_ui.shuffle_button.disabled = true
		control_ui.undo_button.disabled = true
		control_ui.play_button.disabled = true
		control_ui.last_play.hide()
		Hand.ui.disabled = true
		Drag.release()
	busy = true

func end_busy():
	if !is_headless():
		if swaps > 0:
			if !tutorial_ui.visible:
				control_ui.shuffle_button.disabled = false
		if !action_stack.is_empty():
			if !tutorial_ui.visible:
				control_ui.undo_button.disabled = false
		if !shop_ui.visible:
			if !tutorial_ui.visible:
				control_ui.play_button.disabled = false
			if swaps == 0:
				control_ui.show_last_play()
		if !tutorial_ui.visible || tutorial_ui.get_action_types().has(C.TutorialAction.Swap):
			Hand.ui.disabled = false
		if Board.ui.visible:
			Board.ui.show_entangled_lines()
	busy = false

func begin_transition(tween : Tween):
	blocker_ui.show()
	tween.tween_callback(func():
		SSound.se_bubble_transition.play()
		trans_bubbles.emitting = true
	)
	tween.tween_interval(0.4)
	tween.tween_callback(func():
		trans_bubbles.emitting = false
	)

func end_transition(tween : Tween):
	tween.tween_interval(0.4)
	tween.tween_callback(func():
		blocker_ui.hide()
	)

var modifier_defaults : Dictionary = {"red_bouns_i":0,"orange_bouns_i":0,"green_bouns_i":0,
"blue_bouns_i":0,"magenta_bouns_i":0,"max_fatigue_i":40,"base_chain_i":0,
"board_upper_lower_connected_i":0,"extra_range_i":0,"extra_explode_range_i":0,"extra_explode_power_i":0,
"additional_active_times_i":0,"not_consume_repeat_count_chance_i":0,"additional_targets_i":0,"half_price_i":0}

func cleanup():
	if !is_headless():
		self.remove_child(game_tweens)
		game_tweens.queue_free()
		game_tweens = Node.new()
		self.add_child(game_tweens)
		for n in Board.ui.underlay.get_children():
			Board.ui.underlay.remove_child(n)
			n.queue_free()
		for n in Board.ui.overlay.get_children():
			Board.ui.overlay.remove_child(n)
			n.queue_free()
		for n in game_ui.game_overlay.get_children():
			game_ui.game_overlay.remove_child(n)
			n.queue_free()
	
	Board.clear()
	Hand.clear()
	
	if !is_headless():
		game_ui.relics_bar.clear()
		game_ui.patterns_bar.clear()
	patterns.clear()
	relics.clear()
	bag_gems.clear()
	gems.clear()
	
	Buff.clear(G, [C.Duration.ThisChain, C.Duration.ThisMatching, C.Duration.ThisRound, C.Duration.Eternal])
	event_listeners.clear()
	Board.event_listeners.clear()
	attrs.clear()
	for m in modifier_defaults:
		attrs[m] = modifier_defaults[m]
	
	no_score_marks[Gem.None] = []
	no_score_marks[Gem.None].push_front(false)
	for i in Gem.ColorCount:
		no_score_marks[Gem.ColorFirst + i] = []
		no_score_marks[Gem.ColorFirst + i].push_front(false)
	for i in Gem.RuneCount:
		no_score_marks[Gem.RuneFirst + i] = []
		no_score_marks[Gem.RuneFirst + i].push_front(false)

func add_all_kinds_of_gems(num : int):
	for i in num:
		var g = Gem.new()
		g.type = Gem.ColorRed
		g.rune = Gem.RuneWave
		add_gem(g)
	for i in num:
		var g = Gem.new()
		g.type = Gem.ColorRed
		g.rune = Gem.RuneCircle
		add_gem(g)
	for i in num:
		var g = Gem.new()
		g.type = Gem.ColorRed
		g.rune = Gem.RuneStar
		add_gem(g)
	for i in num:
		var g = Gem.new()
		g.type = Gem.ColorOrange
		g.rune = Gem.RuneWave
		add_gem(g)
	for i in num:
		var g = Gem.new()
		g.type = Gem.ColorOrange
		g.rune = Gem.RuneCircle
		add_gem(g)
	for i in num:
		var g = Gem.new()
		g.type = Gem.ColorOrange
		g.rune = Gem.RuneStar
		add_gem(g)
	for i in num:
		var g = Gem.new()
		g.type = Gem.ColorGreen
		g.rune = Gem.RuneWave
		add_gem(g)
	for i in num:
		var g = Gem.new()
		g.type = Gem.ColorGreen
		g.rune = Gem.RuneCircle
		add_gem(g)
	for i in num:
		var g = Gem.new()
		g.type = Gem.ColorGreen
		g.rune = Gem.RuneStar
		add_gem(g)
	for i in num:
		var g = Gem.new()
		g.type = Gem.ColorBlue
		g.rune = Gem.RuneWave
		add_gem(g)
	for i in num:
		var g = Gem.new()
		g.type = Gem.ColorBlue
		g.rune = Gem.RuneCircle
		add_gem(g)
	for i in num:
		var g = Gem.new()
		g.type = Gem.ColorBlue
		g.rune = Gem.RuneStar
		add_gem(g)
	for i in num:
		var g = Gem.new()
		g.type = Gem.ColorMagenta
		g.rune = Gem.RuneWave
		add_gem(g)
	for i in num:
		var g = Gem.new()
		g.type = Gem.ColorMagenta
		g.rune = Gem.RuneCircle
		add_gem(g)
	for i in num:
		var g = Gem.new()
		g.type = Gem.ColorMagenta
		g.rune = Gem.RuneStar
		add_gem(g)

func new_game(parms : Dictionary):
	stage = Stage.None
	cleanup()
		
	var seed = parms.get("seed", 0)
	if seed == 0:
		random_seeds()
	else:
		game_rng.seed = seed
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
	chains = 0
	current_round = 0
	board_size = parms.get("board_size", 3)
	swaps_per_round = parms.get("swaps_per_round", 5)
	plays_per_round = 0
	draws_per_roll = 5
	hand_size = parms.get("hand_size", 5)
	coins = parms.get("coins", 10)
	
	for m in parms.get("attrs", []):
		set_attr(m.name, m.value)
	
	var no_default_patterns = parms.get("no_default_patterns", 0)
	if !no_default_patterns:
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
		r.setup("Aries")
		add_relic(r)
	for i in 0:
		var r = Relic.new()
		r.setup("Sandcastle")
		add_relic(r)
	
	var default_gem_num = parms.get("default_gem_num", 12)
	add_all_kinds_of_gems(default_gem_num)
	
	for i in 0:
		var g = Gem.new()
		g.setup("Ruby")
		add_gem(g)
	for i in 0:
		var g = Gem.new()
		g.setup("Bomb")
		add_gem(g)

	Board.setup(board_size)
	Board.update_gem_quantity_limit()
	history.init()

func start_game(saving : String, parms : Dictionary):
	begin_busy()
	var tween = G.create_tween()
	tween.tween_callback(func():
		if saving == "":
			new_game(parms)
		else:
			load_from_file(saving)
	)
	if !is_headless():
		tween.tween_callback(func():
			enter_game()
		)
	if saving != "":
		tween.tween_interval(0.4)
		tween.tween_callback(func():
			start_first_round()
		)
	else:
		tween.tween_callback(func():
			end_busy()
		)

func start_first_round():
	Board.down_proc()
	for i in hand_size:
		Hand.draw()
	next_round(null)

func enter_game():
	Board.ui.enter(null, false)
	game_ui.status_bar.gem_count_text.text = "%d" % gems.size()
	game_ui.status_bar.board_size_text.clear_animation()
	game_ui.status_bar.hand_text.clear_animation()
	game_ui.status_bar.coins_text.clear_animation()
	game_ui.show()
	control_ui.swaps_text.clear_animation()
	control_ui.undo_button.disabled = true
	control_ui.enter()

func exit_game():
	if Board.ui.visible:
		Board.ui.exit(null, false)
	if calculator_bar_ui.visible:
		calculator_bar_ui.disappear()
	if shop_ui.visible:
		shop_ui.exit(null, false)
	if settlement_ui.visible:
		settlement_ui.exit(false)
	if upgrade_ui.visible:
		upgrade_ui.exit(false)
	
	control_ui.exit()
	game_ui.status_bar.round_text.modulate.a = 0.0
	game_ui.status_bar.round_target.modulate.a = 0.0
	game_ui.hide()
	
	cleanup()

func get_round_desc(r : int):
	var t = target_score if r == current_round else get_round_score(r)
	var rw = reward if r == current_round else get_round_reward(r)
	var ret = tr("ui_game_round_target") % [t, rw]
	var cs = current_curses if r == current_round else round_curses[r - 1]
	if !cs.is_empty():
		var cates = {}
		for c in cs:
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

func update_round_text(r : int):
	game_ui.status_bar.round_text.text = tr("ui_game_round") % r
	game_ui.status_bar.round_target.text = "[wave amp=20.0 freq=-3.0]%s[/wave]" % SUtils.format_text(get_round_desc(r), true, true)

#const curse_types = ["lust", "gluttony", "greed", "sloth", "wrath", "envy", "pride"]
const curse_types = ["red_no_score", "orange_no_score", "green_no_score", "blue_no_score", "magenta_no_score", "wave_no_score", "circle_no_score", "star_no_score"]
func build_round_curses():
	var build_times = current_round + 3 - round_curses.size()
	for i in build_times:
		var curses : Array[Curse] = []
		var type = SMath.pick_random(curse_types, round_rng)
		var num = 0
		match (current_round + i) % 3:
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
		num = 0 # TODO
		for j in num:
			var c = Curse.new()
			c.type = "curse_" + type
			curses.append(c)
		round_curses.append(curses)

func remove_curse(c : Curse):
	c.remove()
	current_curses.erase(c)

func round_begin():
	score = 0
	current_round += 1
	target_score = get_round_score(current_round)
	reward = get_round_reward(current_round)
	game_over_mark = ""
	history.round_reset()
	current_curses.clear()
	for c in round_curses[current_round - 1]:
		var cc = Curse.new()
		cc.type = c.type
		current_curses.append(cc)
	
	if !is_headless():
		update_round_text(current_round)
	
	swaps = swaps_per_round
	plays = plays_per_round
	
	if !is_headless():
		if settlement_ui.visible:
			settlement_ui.exit()
		if game_over_ui.visible:
			game_over_ui.exit()
	
	for h in event_listeners:
		if h.event == C.Event.RoundBegin || h.event == C.Event.Any:
			h.caster.on_event.call(C.Event.RoundBegin, null, null)

func next_round(tween : Tween = null):
	build_round_curses()
	
	if !is_headless():
		if !tween:
			begin_busy()
			tween = create_game_tween()
		tween.tween_callback(func():
			round_begin()
		)
		tween.tween_property(game_ui.status_bar.round_text, "modulate:a", 1.0, 0.5).from(0.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)
		tween.parallel().tween_property(game_ui.status_bar.round_target, "modulate:a", 1.0, 0.5).from(0.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)
		tween.tween_callback(func():
			for c in current_curses:
				var coord = c.coord
				SEffect.add_leading_line(Vector2(640.0, 224.0), Board.get_pos(coord))
		)
		tween.tween_interval(0.3)
		tween.tween_callback(func():
			Curse.apply_curses()
		)
		if false && current_round == 0:
			tween.tween_callback(func():
				guide_ui.enter()
			)
		tween.tween_callback(func():
			stage = Stage.Deploy
			save_to_file()
			control_ui.update_preview()
			end_busy()
		)
	else:
		round_begin()
		Curse.apply_curses()
		stage = Stage.Deploy
		save_to_file()

func round_end():
	action_stack.clear()
	if !is_headless():
		Board.clear_active_effects()
	for c in current_curses:
		c.remove()
	current_curses.clear()
	Buff.clear(self, [C.Duration.ThisRound])
	for g in gems:
		Buff.clear(g, [C.Duration.ThisRound])
	if !is_headless():
		Board.ui.hide_entangled_lines()
	for h in event_listeners:
		if h.event == C.Event.RoundEnd || h.event == C.Event.Any:
			h.caster.on_event.call(C.Event.RoundEnd, null, null)
	if !is_headless():
		calculator_bar_ui.disappear()
		control_ui.undo_button.disabled = true
		control_ui.expected_score_panel.hide()

func win():
	round_end()
	stage = Stage.Settlement
	settlement_ui.enter()

func lose():
	round_end()
	stage = Stage.GameOver
	game_over_ui.enter()

func calc_game_state():
	if STest.testing && !STest.try_out:
		end_busy()
		return
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
			end_busy()

func roll():
		stage = Stage.Rolling
		Board.roll()
		var draw_num = draws_per_roll
		draw_num = min(draw_num, bag_gems.size())
		for i in draw_num:
			Hand.draw()
		begin_busy()

func play():
	stage = Stage.Matching

	base_score = 0
	chains = attrs["base_chain_i"]
	score_mult = 1.0
	filling_times = 0
	time_scale = 1.0 / base_speed
	
	if !is_headless():
		control_ui.expected_score_panel.hide()
		calculator_bar_ui.appear()
	
	action_stack.clear()
	begin_busy()
	Board.matching()

func shuffle():
	if G.swaps == 0:
		return
	G.swaps -= 1
	
	if !is_headless():
		control_ui.expected_score_panel.hide()
	
	action_stack.clear()
	G.begin_busy()
	Board.shuffle()

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
	
	var save_hook = func(h : Hook, d : Dictionary):
		d["event"] = h.event
		d["caster_type"] = h.caster_type
		match h.caster_type:
			C.ObjectType.Gem: d["caster"] = G.gems.find(h.caster)
			C.ObjectType.Relic: d["caster"] = G.relics.find(h.caster)
		d["once"] = h.once
	
	var data = {}
	data["stage"] = ""
	data["game_rng_seed"] = G.game_rng.seed
	data["game_rng_state"] = G.game_rng.state
	data["round_rng_seed"] = G.round_rng.seed
	data["round_rng_state"] = G.round_rng.state
	data["shop_rng_seed"] = G.shop_rng.seed
	data["shop_rng_state"] = G.shop_rng.state
	data["current_round"] = G.current_round
	data["board_size"] = G.board_size
	data["swaps_per_round"] = G.swaps_per_round
	data["plays_per_round"] = G.plays_per_round
	data["draws_per_roll"] = G.draws_per_roll
	data["hand_size"] = G.hand_size
	data["coins"] = G.coins
	data["swaps"] = G.swaps
	data["plays"] = G.plays
	data["current_round"] = G.current_round
	data["score"] = G.score
	data["target_score"] = G.target_score
	data["reward"] = G.reward
	var current_curses = []
	for c in G.current_curses:
		var curse = {}
		curse["type"] = c.type
		curse["coord"] = c.coord
		current_curses.append(curse)
	data["current_curses"] = current_curses
	var round_curses = []
	for lc in G.round_curses:
		var round_curse = []
		for c in lc:
			var curse = {}
			curse["type"] = c.type
			curse["coord"] = c.coord
			round_curse.append(curse)
		round_curses.append(round_curse)
	data["round_curses"] = round_curses
	data["chains"] = G.chains
	data["score_mult"] = G.score_mult
	var game_buffs = []
	for b in G.buffs:
		var buff = {}
		Buff.save_to_data(b, buff)
		game_buffs.append(buff)
	data["buffs"] = game_buffs
	var game_event_listeners = []
	for h in G.event_listeners:
		var hook = {}
		save_hook.call(h, hook)
		game_event_listeners.append(hook)
	data["event_listeners"] = game_event_listeners
	data["attrs"] = SUtils.save_dictionary(G.attrs) 
	var board_event_listeners = []
	for h in Board.event_listeners:
		var hook = {}
		save_hook.call(h, hook)
		board_event_listeners.append(hook)
	data["cx"] = Board.cx
	data["cy"] = Board.cy
	data["board_event_listeners"] = board_event_listeners
	var gems = []
	for g in G.gems:
		var gem = {}
		gem["name"] = g.name
		gem["type"] = g.type
		gem["rune"] = g.rune
		gem["base_score"] = g.base_score
		gem["bonus_score"] = g.bonus_score
		gem["score_mult"] = g.score_mult
		gem["coord"] = g.coord
		gem["board_stamp"] = g.board_stamp
		gem["bag_stamp"] = g.bag_stamp
		var buffs = []
		for b in g.buffs:
			var buff = {}
			Buff.save_to_data(b, buff)
			buffs.append(buff)
		gem["buffs"] = buffs
		gem["extra"] = SUtils.save_dictionary(g.extra)
		gems.append(gem)
	data["gems"] = gems
	var bag_gems = []
	for g in G.bag_gems:
		bag_gems.append(G.gems.find(g))
	data["bag_gems"] = bag_gems
	var patterns = []
	for p in G.patterns:
		var pattern = {}
		pattern["name"] = p.name
		pattern["mult"] = p.mult
		pattern["lv"] = p.lv
		pattern["exp"] = p.exp
		pattern["max_exp"] = p.max_exp
		patterns.append(pattern)
	data["patterns"] = patterns
	var relics = []
	for r in G.relics:
		var relic = {}
		relic["name"] = r.name
		relic["extra"] = SUtils.save_dictionary(r.extra)
		relics.append(relic)
	data["relics"] = relics
	var hand = []
	for g in Hand.gems:
		hand.append(G.gems.find(g))
	data["hand"] = hand
	var cells = []
	for c in Board.cells:
		var cell = {}
		cell["coord"] = c.coord
		cell["gem"] = G.gems.find(c.gem)
		cell["consumed"] = c.consumed
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
	if G.stage == Stage.Settlement:
		data["stage"] = "settlement"
		settlement_ui.save_to_data(data)
	elif G.stage == Stage.Upgrade:
		data["stage"] = "upgrade"
		upgrade_ui.save_to_data(data)
	elif G.stage == Stage.Shopping:
		data["stage"] = "shopping"
		shop_ui.save_to_data(data)
	
	var file = FileAccess.open("user://save%s.json" % name, FileAccess.WRITE)
	file.store_string(JSON.stringify(data, "\t", false))
	file.close()

func load_hook(d : Dictionary):
	var caster_type = int(d["caster_type"])
	var caster_idx = int(d["caster"])
	var caster = null
	match caster_type:
		C.ObjectType.Game: caster = G
		C.ObjectType.Gem: caster = G.gems[caster_idx]
		C.ObjectType.Relic: caster = G.relics[caster_idx]
		C.ObjectType.Pattern: caster = G.patterns[caster_idx]
	var h = Hook.new(int(d["event"]), caster, caster_type, d["once"])
	return h

func load_from_file(name : String = "1"):
	print("load save %s\n" % name)
	
	var file = FileAccess.open("user://save%s.json" % name, FileAccess.READ)
	var data = JSON.parse_string(file.get_as_text())
	file.close()
	
	stage = Stage.None
	cleanup()
	
	G.game_rng.seed = int(data["game_rng_seed"])
	G.game_rng.state = int(data["game_rng_state"])
	G.round_rng.seed = int(data["round_rng_seed"])
	G.round_rng.state = int(data["round_rng_state"])
	G.shop_rng.seed = int(data["shop_rng_seed"])
	G.shop_rng.state = int(data["shop_rng_state"])
	G.board_size = int(data["board_size"])
	G.swaps_per_round = int(data["swaps_per_round"])
	G.plays_per_round = int(data["plays_per_round"])
	G.draws_per_roll = int(data["draws_per_roll"])
	G.hand_size = int(data["hand_size"])
	G.swaps = int (data["swaps"])
	G.plays = int(data["plays"])
	G.current_round = int(data["current_round"])
	G.score = int(data["score"])
	G.target_score = int(data["target_score"])
	G.reward = int(data["reward"])
	G.current_curses.clear()
	for d in data["current_curses"]:
		var c = Curse.new()
		c.type = d["type"]
		c.coord = str_to_var("Vector2i" + d["coord"])
		G.current_curses.append(c)
	G.round_curses.clear()
	for d in data["round_curses"]:
		var lc = []
		for curse in d:
			var c = Curse.new()
			c.type = curse["type"]
			c.coord = str_to_var("Vector2i" + curse["coord"])
			lc.append(c)
		G.round_curses.append(lc)
	G.chains = int(data["chains"])
	G.score_mult = data["score_mult"]
	update_round_text(current_round)
	for d in data["buffs"]:
		Buff.load_from_data(G, d)
	var attrs_data = SUtils.read_dictionary(data["attrs"])
	for k in attrs_data:
		G.set_attr(k, attrs_data[k])
	G.coins = int(data["coins"])
	
	Board.set_cx_cy(int(data["cx"]), int(data["cy"]))
	
	for d in data["gems"]:
		var g = Gem.new()
		g.name = d["name"]
		if g.name != "":
			g.setup(g.name)
		g.type = int(d["type"])
		g.rune = int(d["rune"])
		g.base_score = int(d["base_score"])
		g.bonus_score = int(d["bonus_score"])
		g.score_mult = d["score_mult"]
		g.coord = str_to_var("Vector2i" + d["coord"])
		g.board_stamp = int(d["board_stamp"])
		g.bag_stamp = int(d["bag_stamp"])
		for dd in d["buffs"]:
			Buff.load_from_data(g, dd)
		g.extra = SUtils.read_dictionary(d["extra"])
		G.gems.append(g)
	for idx in data["bag_gems"]:
		G.bag_gems.append(G.gems[idx])
	for d in data["patterns"]:
		var p = Pattern.new()
		p.setup(d["name"])
		p.mult = int(d["mult"])
		p.lv = int(d["lv"])
		p.exp = int(d["exp"])
		p.max_exp = int(d["max_exp"])
		G.patterns.append(p)
		game_ui.patterns_bar.add_ui(p)
	for d in data["relics"]:
		var r = Relic.new()
		r.setup(d["name"])
		r.extra = SUtils.read_dictionary(d["extra"])
		G.relics.append(r)
		game_ui.relics_bar.add_ui(r)
	for hook in data["event_listeners"]:
		var h = load_hook(hook)
		G.event_listeners.append(h)
	for hook in data["board_event_listeners"]:
		var h = load_hook(hook)
		Board.event_listeners.append(h)
	for idx in data["hand"]:
		var g = G.gems[int(idx)]
		Hand.gems.append(g)
		Hand.ui.add_slot(g)
	for d in data["cells"]:
		var coord = str_to_var("Vector2i" + d["coord"])
		var c = Board.add_cell(coord)
		var ui = Board.ui.get_cell(coord)
		var gem_idx = int(d["gem"])
		if gem_idx != -1:
			var g = G.gems[gem_idx]
			c.gem = g
		if d["consumed"]:
			Board.consume(coord)
		if d["pinned"]:
			Board.pin(coord)
		if d["frozen"] > 0:
			Board.freeze(coord)
		if d["nullified"]:
			Board.nullify(coord)
		Board.ui.update_cell(coord)
	
	var stage = data["stage"]
	if stage == "":
		G.stage = Stage.Deploy
		if !is_headless():
			control_ui.update_preview()
			control_ui.play_button.disabled = false
			if swaps == 0:
				control_ui.show_last_play()
	else:
		if stage == "settlement":
			G.stage = Stage.Settlement
			settlement_ui.load_from_data(data)
			if !is_headless():
				settlement_ui.show()
		elif stage == "upgrade":
			G.stage = Stage.Upgrade
			upgrade_ui.load_from_data(data)
			if !is_headless():
				upgrade_ui.show()
		elif stage == "shopping":
			G.stage = Stage.Shopping
			shop_ui.load_from_data(data)
			if !is_headless():
				shop_ui.enter(null, false)
	
	Board.update_gem_quantity_limit()
	history.init()
	
	if !is_headless():
		game_ui.status_bar.round_text.modulate.a = 1.0
		game_ui.status_bar.round_target.modulate.a = 1.0

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == MOUSE_BUTTON_RIGHT:
				pass
	elif event is InputEventMouseMotion:
		mouse_pos = event.position
		#print("%.1f %.1f" % [mouse_pos.x, mouse_pos.y])
		if Board && Board.ui.visible:
			var c = Board.ui.hover_coord()
			var cc = c + Board.center - C.UI_BOARD_CENTER
			if Board.is_valid(cc):
				Board.ui.hover_ui.show()
				Board.ui.hover_ui.position = Board.ui.get_pos(c)
			else:
				Board.ui.hover_ui.hide()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.is_pressed():
			if event.keycode == KEY_ESCAPE:
				SSound.se_click.play()
				G.screen_shake_strength = 8.0
				if options_ui.visible:
					options_ui.exit()
				elif bag_viewer_ui.visible:
					bag_viewer_ui.exit()
				elif guide_ui.visible:
					guide_ui.exit()
				elif control_ui.visible:
					G.screen_shake_strength = 8.0
					toggle_in_game_menu()
			elif event.keycode == KEY_F3:
				command_line_edit.visible = !command_line_edit.visible
				if command_line_edit.visible:
					command_line_edit.grab_focus()
			if paint_mode != "off":
				if event.keycode == KEY_1:
					if event.shift_pressed:
						paint_brush2 = Gem.ColorRed
					elif event.alt_pressed:
						paint_mode = "pencil"
					else:
						paint_brush1 = Gem.ColorRed
				elif event.keycode == KEY_2:
					if event.shift_pressed:
						paint_brush2 = Gem.ColorOrange
					elif event.alt_pressed:
						paint_mode = "line"
					else:
						paint_brush1 = Gem.ColorOrange
				elif event.keycode == KEY_3:
					if !event.shift_pressed:
						paint_brush1 = Gem.ColorGreen
					else:
						paint_brush2 = Gem.ColorGreen
				elif event.keycode == KEY_4:
					if event.shift_pressed:
						paint_brush2 = Gem.ColorBlue
					else:
						paint_brush1 = Gem.ColorBlue
				elif event.keycode == KEY_5:
					if event.shift_pressed:
						paint_brush2 = Gem.ColorMagenta
					else:
						paint_brush1 = Gem.ColorMagenta
				elif event.keycode == KEY_6:
					if event.shift_pressed:
						paint_brush2 = Gem.ColorWhite
					else:
						paint_brush1 = Gem.ColorWhite
				elif event.keycode == KEY_7:
					if event.shift_pressed:
						paint_brush2 = Gem.ColorBlack
					else:
						paint_brush1 = Gem.ColorBlack
	elif event is InputEventMouseMotion:
		if Board.ui.visible && !run_info_ui.visible && !bag_viewer_ui.visible && !in_game_menu_ui.visible && !options_ui.visible && !guide_ui.visible && !test_ui.visible:
			var c = Board.ui.hover_coord(true)
			if Board.is_valid(c):
				var cc = Board.offset_to_cube(c)
				hovering_coord = c
				control_ui.debug_text.text = "(%d,%d) (%d,%d,%d)" % [c.x, c.y, cc.x, cc.y, cc.z]
				var contents : Array[Pair] = []
				var cell = Board.get_cell(c)
				if cell.frozen > 0:
					contents.append(Pair.new(tr("tt_cell_frozen") % cell.frozen, tr("tt_cell_frozen_content")))
				if cell.nullified:
					contents.append(Pair.new(tr("tt_cell_nullified"), tr("tt_cell_nullified_content")))
				if cell.in_mist:
					contents.append(Pair.new(tr("tt_cell_in_mist"), tr("tt_cell_in_mist_content")))
				if cell.floating:
					contents.append(Pair.new(tr("tt_cell_floating"), tr("tt_cell_floating_content")))
				var g = Board.get_gem_at(c)
				if g:
					var cell_ui = Board.ui.get_cell(c)
					if STooltip.node != cell_ui:
						contents.append_array(g.get_tooltip())
						var dir = 0
						if c.x <= Board.hfcx:
							if c.y <= Board.hfcy:
								dir = 0
							else:
								dir = 1
						else:
							if c.y <= Board.hfcy:
								dir = 3
							else:
								dir = 2
						STooltip.show(cell_ui, dir, contents)
				else:
					STooltip.close()
			else:
				hovering_coord = Vector2i(-1, -1)
				control_ui.debug_text.text = ""
				STooltip.close()
	elif event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == MOUSE_BUTTON_LEFT:
				if paint_mode == "on":
					if hovering_coord.x != -1 && hovering_coord.y != -1:
						paint_coord = hovering_coord
			elif event.button_index == MOUSE_BUTTON_RIGHT:
				if paint_mode == "on":
					if hovering_coord.x != -1 && hovering_coord.y != -1:
						paint_coord = hovering_coord
		else:
			if event.button_index == MOUSE_BUTTON_LEFT:
				if paint_mode == "on":
					if hovering_coord.x != -1 && hovering_coord.y != -1:
						if paint_coord == hovering_coord:
							Board.effect_change_color(hovering_coord, paint_brush1, Gem.None, null)
						else:
							Painting.add_line(paint_coord, hovering_coord)
			elif event.button_index == MOUSE_BUTTON_RIGHT:
				if paint_mode == "on":
					if hovering_coord.x != -1 && hovering_coord.y != -1:
						if paint_coord == hovering_coord:
							Board.effect_change_color(hovering_coord, paint_brush2, Gem.None, null)
						else:
							Painting.remove_line(paint_coord, hovering_coord)

func _ready() -> void:
	randomize()
	
	game_tweens = Node.new()
	self.add_child(game_tweens)
	
	trans_bubbles.position = Vector2(0, resolution.y)
	
	Board.ui = $/root/Main/SubViewportContainer/SubViewport/Canvas/Board
	Board.elimination_finished.connect(func():
		if !is_headless():
			Board.ui.hide_entangled_lines()
		filling_times += 1
		if gems.size() < Board.curr_min_gem_num:
			game_over_mark = "not_enough_gems"
			lose()
		else:
			Board.fill_blanks()
	)
	Board.filling_finished.connect(func():
		if !is_headless():
			Board.ui.show_entangled_lines()
		Board.matching()
	)
	Board.playing_finished.connect(func():
		Buff.clear(self, [C.Duration.ThisMatching, C.Duration.ThisChain])
		for y in Board.cy:
			for x in Board.cx:
				var c = Vector2i(x, y)
				var g = Board.get_gem_at(c)
				if g:
					Buff.clear(g, [C.Duration.ThisMatching, C.Duration.ThisChain])
		var processed = false
		for h in event_listeners:
			if h.event == C.Event.MatchingFinished || h.event == C.Event.Any:
				processed = h.caster.on_event.call(C.Event.MatchingFinished, null, null)
				if processed:
					break
		if !processed:
			if !is_headless():
				control_ui.filling_times_container.hide()
			calculator_bar_ui.calculate()
	)
	Board.shuffle_finished.connect(func():
		end_busy()
		if !is_headless():
			control_ui.update_preview()
	)
	Hand.ui = $/root/Main/SubViewportContainer/SubViewport/Canvas/GameControl/MarginContainer2/HBoxContainer2/Panel/HBoxContainer/Hand
	STooltip.ui = $/root/Main/SubViewportContainer/SubViewport/Canvas/Tooltips
	calculator_bar_ui.finished.connect(func():
		history.update()
		stage = Stage.Deploy
		time_scale = 1.0 / base_speed
		save_to_file()
		
		filling_times = 0
		Board.down_proc()
		
		calc_game_state()
	)
	
	command_line_edit.text_submitted.connect(func(cl : String):
		process_command_line(cl)
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

func _process(delta: float) -> void:
	if canvas && !performance_mode:
		screen_shake_strength = lerp(screen_shake_strength, 0.0, 5.0 * delta)
		screen_shake_noise_coord += 30.0 * delta
		screen_offset = lerp(screen_offset, (mouse_pos - subviewport.size * 0.5) * 0.007, 0.05)
		var off = screen_offset + Vector2(screen_shake_noise.get_noise_2d(17.0, screen_shake_noise_coord), screen_shake_noise.get_noise_2d(93.0, screen_shake_noise_coord)) * screen_shake_strength
		canvas.offset = round(off)
		#background.material.set_shader_parameter("offset", Vector2(off.x * 2.0 / resolution.x, off.y * 2.0 / resolution.y))
