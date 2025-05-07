extends Node

enum Stage
{
	Preparing,
	Deploy,
	Rolling,
	Matching
}

enum Props
{
	None,
	Pin,
	Activate,
	Grab
}

enum Event
{
	GainGem,
	LostGem,
	GainItem,
	LostItem,
	GainRelic,
	LostRelic,
	GemBaseScoreChanged,
	GemBonusScoreChanged
}

const UiCell = preload("res://ui_cell.gd")
const UiTitle = preload("res://ui_title.gd")
const UiBoard = preload("res://ui_board.gd")
const UiControl = preload("res://ui_control.gd")
const UiHand = preload("res://ui_hand.gd")
const UiShop = preload("res://ui_shop.gd")
const UiStatusBar = preload("res://ui_status_bar.gd")
const UiSkillsBar = preload("res://ui_skills_bar.gd")
const UiPatternsBar = preload("res://ui_patterns_bar.gd")
const UiBlocker = preload("res://ui_blocker.gd")
const UiDialog = preload("res://ui_dialog.gd")
const UiOptions = preload("res://ui_options.gd")
const UiInGameMenu = preload("res://ui_in_game_menu.gd")
const UiGameOver = preload("res://ui_game_over.gd")
const UiLevelClear = preload("res://ui_level_clear.gd")
const UiChooseReward = preload("res://ui_choose_reward.gd")
const UiBagViewer = preload("res://ui_bag_viewer.gd")
const popup_txt_pb = preload("res://popup_txt.tscn")
const relic_ui = preload("res://ui_relic.tscn")
const pointer_cursor = preload("res://images/pointer.png")
const pin_cursor = preload("res://images/pin.png")
const activate_cursor = preload("res://images/magic_stick.png")
const grab_cursor = preload("res://images/grab.png")

@onready var background = $/root/Main/Background
@onready var bg_shader : ShaderMaterial = background.material
@onready var subviewport_container = $/root/Main/SubViewportContainer
@onready var mask_shader : ShaderMaterial = subviewport_container.material
@onready var subviewport = $/root/Main/SubViewportContainer/SubViewport
@onready var board_ui : UiBoard = $/root/Main/SubViewportContainer/SubViewport/UI/Board
@onready var title_ui : UiTitle = $/root/Main/SubViewportContainer/SubViewport/UI/Title
@onready var control_ui : UiControl = $/root/Main/SubViewportContainer/SubViewport/UI/Control
@onready var hand_ui : UiHand = $/root/Main/SubViewportContainer/SubViewport/UI/Control/Panel/HBoxContainer/Hand
@onready var shop_ui : UiShop = $/root/Main/SubViewportContainer/SubViewport/UI/Shop
@onready var game_ui : Control = $/root/Main/SubViewportContainer/SubViewport/UI/Game
@onready var status_bar_ui : UiStatusBar = $/root/Main/SubViewportContainer/SubViewport/UI/Game/VBoxContainer/MarginContainer/TopBar/VBoxContainer/MarginContainer/StatusBar
@onready var relics_bar_ui : Control = $/root/Main/SubViewportContainer/SubViewport/UI/Game/VBoxContainer/MarginContainer/TopBar/VBoxContainer/MarginContainer2/RelicsBar
@onready var skills_bar_ui : UiSkillsBar = $/root/Main/SubViewportContainer/SubViewport/UI/Game/VBoxContainer/Control/MarginContainer/SkillsBar
@onready var patterns_bar_ui : UiPatternsBar = $/root/Main/SubViewportContainer/SubViewport/UI/Game/VBoxContainer/Control/MarginContainer2/PatternsBar
@onready var blocker_ui : UiBlocker = $/root/Main/SubViewportContainer/SubViewport/UI/Blocker
@onready var dialog_ui : UiDialog = $/root/Main/SubViewportContainer/SubViewport/UI/Dialog
@onready var options_ui : UiOptions = $/root/Main/SubViewportContainer/SubViewport/UI/Options
@onready var in_game_menu_ui : UiInGameMenu = $/root/Main/SubViewportContainer/SubViewport/UI/InGameMenu
@onready var game_over_ui : UiGameOver = $/root/Main/SubViewportContainer/SubViewport/UI/GameOver
@onready var level_clear_ui : UiLevelClear = $/root/Main/SubViewportContainer/SubViewport/UI/LevelClear
@onready var choose_reward_ui : UiChooseReward = $/root/Main/SubViewportContainer/SubViewport/UI/ChooseReward
@onready var bag_viewer_ui : UiBagViewer = $/root/Main/SubViewportContainer/SubViewport/UI/BagViewer

var stage : int = Stage.Deploy
var rolls : int:
	set(v):
		rolls = v
		control_ui.rolls_text.text = "%d" % rolls
var rolls_per_level : int
var after_rolled_eliminate_one_rune : int = 0
var after_rolled_eliminate_processing : bool = false
var after_rolled_roll_and_match : int = 0
var after_rolled_roll_and_match_processing : bool = false
var after_rolled_roll_and_match_processed : bool = false
var next_roll_extra_draws : int = 0
var matches : int:
	set(v):
		matches = v
		control_ui.matches_text.text = "%d" % matches
var matches_per_level : int
var startup_draws : int:
	set(v):
		startup_draws = v
		if hand_ui:
			status_bar_ui.hand_metrics_text.text = "%d/%d/%d" % [startup_draws, draws_per_roll, 8]
var draws_per_roll : int:
	set(v):
		draws_per_roll = v
		if hand_ui:
			status_bar_ui.hand_metrics_text.text = "%d/%d/%d" % [startup_draws, draws_per_roll, 8]
var props = Props.None
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
var grabs_num : int:
	set(v):
		grabs_num = v
		if grabs_num > 0:
			control_ui.grab_ui.show()
			control_ui.grab_ui.num.text = "%d" % grabs_num
		else:
			control_ui.grab_ui.hide()
var grabs_num_per_level : int
var board_size : int = 0:
	set(v):
		board_size = v
		status_bar_ui.board_size_text.text = "%d" % board_size
var skills : Array[Skill]
var patterns : Array[Pattern]
var gems : Array[Gem]
var unused_gems : Array[Gem] = []
var items : Array[Item]
var unused_items : Array[Item] = []
var relics : Array[Relic]
var score : int:
	set(v):
		score = v
		status_bar_ui.score_text.text = "%d" % score
var target_score : int:
	set(v):
		target_score = v
		status_bar_ui.level_target.text = "Score at least %d" % target_score
var combos_tween : Tween
var combos : int = 0:
	set(v):
		combos = v
		
		status_bar_ui.combos_text.text = "%dX" % combos
		if combos_tween:
			combos_tween.kill()
		combos_tween = get_tree().create_tween()
		combos_tween.tween_callback(func():
			combos_tween = null
		)

var score_mult : float = 1.0:
	set(v):
		score_mult = v
		#update_score_text()
var level : int:
	set(v):
		level = v
		status_bar_ui.level_text.text = "Level %d" % level
var coins : int:
	set(v):
		coins = v
		status_bar_ui.coin_text.text = "%d" % coins
var buffs : Array[Buff]
var history : History = History.new()

var modifiers : Dictionary

var base_animation_speed = 1.0
var animation_speed = base_animation_speed

func set_props(t : int):
	props = t
	for n in control_ui.props_bar.get_children():
		n.select.hide()
	if props == Props.None:
		control_ui.action_tip_text.text = ""
		Input.set_custom_mouse_cursor(pointer_cursor, Input.CURSOR_ARROW, Vector2(15, 4))
	elif props == Props.Pin:
		control_ui.pin_ui.select.show()
		control_ui.action_tip_text.text = "[img width=32]res://images/mouse_left_button.png[/img]To Pin[img width=32]res://images/mouse_right_button.png[/img]Cancel"
		Input.set_custom_mouse_cursor(pin_cursor, Input.CURSOR_ARROW, Vector2(7, 30))
	elif props == Props.Activate:
		control_ui.activate_ui.select.show()
		control_ui.action_tip_text.text = "[img width=32]res://images/mouse_left_button.png[/img]To Activate[img width=32]res://images/mouse_right_button.png[/img]Cancel"
		Input.set_custom_mouse_cursor(activate_cursor, Input.CURSOR_ARROW, Vector2(5, 5))
	elif props == Props.Grab:
		control_ui.grab_ui.select.show()
		control_ui.action_tip_text.text = "[img width=32]res://images/mouse_left_button.png[/img]To Drag Around[img width=32]res://images/mouse_right_button.png[/img]Cancel"
		Input.set_custom_mouse_cursor(grab_cursor, Input.CURSOR_ARROW, Vector2(5, 20))

func get_word_descriptions(arr : Array[Pair]):
	pass

func get_cell_ui(c : Vector2i) -> UiCell:
	return board_ui.cells_root.get_child(c.y * Board.cx + c.x)

func add_gem(g : Gem):
	for r in relics:
		if r.on_event.is_valid():
			r.on_event.call(Event.GainGem, null, g)
	gems.append(g)

func get_gem(g : Gem = null):
	if g:
		unused_gems.erase(g)
		return g
	return SMath.pick_and_remove(unused_gems)

func release_gem(g : Gem):
	g.bonus_score = 0
	g.coord = Vector2i(-1, -1)
	Buff.clear_if_not(g, Buff.Duration.Eternal)
	unused_gems.append(g)

func gem_add_base_score(g : Gem, v : int):
	for r in relics:
		v = r.on_event.call(Event.GemBaseScoreChanged, null, {"gem":g,"value":v})
	g.base_score += v
	return v

func gem_add_bonus_score(g : Gem, v : int):
	for r in relics:
		v = r.on_event.call(Event.GemBonusScoreChanged, null, {"gem":g,"value":v})
	g.bonus_score += v
	return 

func add_item(i : Item):
	for r in relics:
		if r.on_event.is_valid():
			r.on_event.call(Event.GainItem, null, i)
	items.append(i)

func get_item(i : Item = null):
	if i:
		unused_items.erase(i)
		return i
	return SMath.pick_and_remove(unused_items)

func release_item(i : Item):
	if i.is_duplicant:
		return
	if i.mounted:
		release_item(i.mounted)
		i.mounted = null
	i.coord = Vector2i(-1, -1)
	Buff.clear_if_not(i, Buff.Duration.Eternal)
	unused_items.append(i)

func add_relic(r : Relic):
	if r.on_event.is_valid():
		r.on_event.call(Event.GainRelic, null, r)
	var ui = relic_ui.instantiate()
	ui.setup(r)
	relics_bar_ui.add_child(ui)

func has_relic(n : String):
	for r in relics:
		if r.name == n:
			return true
	return false

func add_combo():
	combos += 1
	Board.on_combo()
	Buff.clear(self, [Buff.Duration.ThisCombo])

func float_text(txt : String, pos : Vector2, color : Color = Color(1.0, 1.0, 1.0, 1.0)):
	var ui = popup_txt_pb.instantiate()
	ui.position = pos
	ui.scale = Vector2(1.5, 1.5)
	var lb : Label = ui.get_child(0)
	lb.text = txt
	lb.add_theme_color_override("font_color", color)
	ui.z_index = 10
	board_ui.overlay.add_child(ui)
	var tween = get_tree().create_tween()
	tween.tween_property(ui, "position", pos - Vector2(0, 20), 0.5)
	tween.parallel().tween_property(ui, "scale", Vector2(0.8, 0.8), 0.5)
	tween.tween_callback(func():
		ui.queue_free()
	)

func add_score(base : int, pos : Vector2, affected_by_combos : bool = true):
	var mult = int(combos * score_mult)
	var ui = popup_txt_pb.instantiate()
	ui.position = pos
	ui.scale = Vector2(1.5, 1.5)
	var lb : Label = ui.get_child(0)
	if affected_by_combos:
		lb.text = "%dx%d" % [base, mult]
	else:
		lb.text = "%d" % int(base * score_mult)
	ui.z_index = 10
	board_ui.overlay.add_child(ui)
	var tween = get_tree().create_tween()
	if affected_by_combos:
		tween.tween_method(func(t):
			ui.rotation_degrees = sin(t * PI * 10.0) * t * 30.0
		, 1.0, 0.0, 1.0)
		tween.parallel().tween_property(ui, "scale", Vector2(1.0, 1.0), 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		tween.tween_callback(func():
			var s = base * mult
			lb.text = "%d" % s
			score += s
		)
	else:
		score += int(base * score_mult)
	tween.tween_property(ui, "position", pos - Vector2(0, 20), 0.5)
	tween.parallel().tween_property(ui, "scale", Vector2(0.8, 0.8), 0.5)
	tween.tween_callback(ui.queue_free)

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

func sort_gems():
	gems.sort_custom(func(a, b):
		return a.type * 0xffff + a.rune * 0xff + (100.0 / max(a.base_score, 0.1)) < b.type * 0xffff + b.rune * 0xff + (100.0 / max(b.base_score, 0.1))
	)

func add_skill(s : Skill):
	skills.append(s)
	skills_bar_ui.add_ui(s)

func add_pattern(p : Pattern):
	patterns.append(p)
	patterns_bar_ui.add_ui(p)

func get_level_score(lv : int):
	# 300, 800, 2000, 5000, 11000, 20000, 35000, 50000
	match lv:
		1:
			return 50000000
		2:
			return 90000000
		3:
			return 150000000
		4:
			return 210000000
		5:
			return 280000000
		6:
			return 360000000
		7:
			return 450000000
		8:
			return 600000000

func begin_busy():
	control_ui.roll_button.disabled = true
	control_ui.match_button.disabled = true
	hand_ui.disabled = true

func end_busy():
	if rolls > 0:
		control_ui.roll_button.disabled = false
	control_ui.match_button.disabled = false
	hand_ui.disabled = false

func start_new_game(saving : String = ""):
	board_size = 6
	skills.clear()
	skills_bar_ui.clear()
	patterns.clear()
	patterns_bar_ui.clear()
	gems.clear()
	items.clear()
	
	modifiers["red_bouns_i"] = 0
	modifiers["orange_bouns_i"] = 0
	modifiers["green_bouns_i"] = 0
	modifiers["blue_bouns_i"] = 0
	modifiers["pink_bouns_i"] = 0
	modifiers["explode_range_i"] = 0
	modifiers["explode_power_i"] = 0
	modifiers["base_combo_i"] = 0
	modifiers["continueous_roll_and_match_i"] = 0
	modifiers["board_upper_lower_connected_i"] = 0
	
	if saving == "":
		rolls_per_level = 4
		matches_per_level = 3
		startup_draws = 5
		draws_per_roll = 1
		pins_num_per_level = 0
		activates_num_per_level = 0
		grabs_num_per_level = 0
		coins = 10
		
		for i in 1:
			var s = Skill.new()
			s.setup("Bao")
			add_skill(s)
		
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
		
		for i in 1:
			var r = Relic.new()
			r.setup("Blue Stone")
			add_relic(r)
		
		for i in 72:
			var g = Gem.new()
			g.type = Gem.Type.Red
			g.rune = Gem.Rune.Zhe
			add_gem(g)
		for i in 72:
			var g = Gem.new()
			g.type = Gem.Type.Red
			g.rune = Gem.Rune.Cha
			add_gem(g)
		for i in 72:
			var g = Gem.new()
			g.type = Gem.Type.Red
			g.rune = Gem.Rune.Kou
			add_gem(g)
		for i in 72:
			var g = Gem.new()
			g.type = Gem.Type.Orange
			g.rune = Gem.Rune.Zhe
			add_gem(g)
		for i in 72:
			var g = Gem.new()
			g.type = Gem.Type.Orange
			g.rune = Gem.Rune.Cha
			add_gem(g)
		for i in 72:
			var g = Gem.new()
			g.type = Gem.Type.Orange
			g.rune = Gem.Rune.Kou
			add_gem(g)
		for i in 72:
			var g = Gem.new()
			g.type = Gem.Type.Green
			g.rune = Gem.Rune.Zhe
			add_gem(g)
		for i in 72:
			var g = Gem.new()
			g.type = Gem.Type.Green
			g.rune = Gem.Rune.Cha
			add_gem(g)
		for i in 72:
			var g = Gem.new()
			g.type = Gem.Type.Green
			g.rune = Gem.Rune.Kou
			add_gem(g)
		for i in 72:
			var g = Gem.new()
			g.type = Gem.Type.Blue
			g.rune = Gem.Rune.Zhe
			add_gem(g)
		for i in 72:
			var g = Gem.new()
			g.type = Gem.Type.Blue
			g.rune = Gem.Rune.Cha
			add_gem(g)
		for i in 72:
			var g = Gem.new()
			g.type = Gem.Type.Blue
			g.rune = Gem.Rune.Kou
			add_gem(g)
		for i in 72:
			var g = Gem.new()
			g.type = Gem.Type.Pink
			g.rune = Gem.Rune.Zhe
			add_gem(g)
		for i in 72:
			var g = Gem.new()
			g.type = Gem.Type.Pink
			g.rune = Gem.Rune.Cha
			add_gem(g)
		for i in 72:
			var g = Gem.new()
			g.type = Gem.Type.Pink
			g.rune = Gem.Rune.Kou
			add_gem(g)
		
		for i in 1:
			var item = Item.new()
			item.setup("Dye: Red")
			add_item(item)
		for i in 1:
			var item = Item.new()
			item.setup("Dye: Orange")
			add_item(item)
		for i in 1:
			var item = Item.new()
			item.setup("Dye: Green")
			add_item(item)
		for i in 1:
			var item = Item.new()
			item.setup("Dye: Blue")
			add_item(item)
		for i in 1:
			var item = Item.new()
			item.setup("Dye: Pink")
			add_item(item)
		for i in 1:
			var item = Item.new()
			item.setup("Bomb")
			add_item(item)
		for i in 1:
			var item = Item.new()
			item.setup("Minefield")
			add_item(item)
		'''
		for i in 1:
			var item = Item.new()
			item.setup("Idol")
			add_item(item)
		'''
	
	level = 0
	history.init()
	
	Board.setup(board_size)
	game_ui.show()
	control_ui.enter()

func new_level():
	score = 0
	level += 1
	target_score = get_level_score(level) * 0
	
	stage = Stage.Preparing
	
	set_props(Props.None)
	rolls = rolls_per_level
	matches = matches_per_level
	
	hand_ui.setup()
	
	if level_clear_ui.visible:
		level_clear_ui.exit()
	if game_over_ui.visible:
		game_over_ui.exit()
	control_ui.enter()

func level_end():
	set_props(Props.None)
	Buff.clear(self, [Buff.Duration.ThisLevel])

func roll():
	if rolls > 0:
		stage = Stage.Rolling
		rolls -= 1
		score_mult = 1.0
		animation_speed = base_animation_speed
		Board.roll()
		for i in draws_per_roll:
			hand_ui.draw()
		begin_busy()
		history.rolls += 1

func play():
	if matches > 0:
		stage = Stage.Matching
		matches -= 1
		begin_busy()
		Board.matching()

func toggle_in_game_menu():
	if !in_game_menu_ui.visible:
		STooltip.close()
		in_game_menu_ui.enter()
	else:
		in_game_menu_ui.exit()

func save_to_file():
	var data = {}
	data["level"] = Game.level
	data["board_size"] = Game.board_size
	data["rolls_per_level"] = Game.rolls_per_level
	data["matches_per_level"] = Game.matches_per_level
	data["startup_draws"] = Game.startup_draws
	data["draws_per_roll"] = Game.draws_per_roll
	data["coins"] = Game.coins
	data["rolls"] = Game.rolls
	data["matches"] = Game.matches
	var gems = []
	for g in Game.gems:
		var gem = {}
		gem["type"] = g.type
		gem["rune"] = g.rune
		gem["base_score"] = g.base_score
		gem["bouns_score"] = g.bonus_score
		gem["coord"] = g.coord
		for b in g.buffs:
			var buffs = []
			
		gems.append(gem)
	data["gems"] = gems
	var unused_gems = []
	for g in Game.unused_gems:
		unused_gems.append(Game.gems.find(g))
	data["unused_gems"] = unused_gems
	var items = []
	var skills = []
	var patterns = []
	var relics = []
	var hand = []
	var cells = []
	for c in Board.cells:
		var cell = {}
		cell["gem"] = Game.gems.find(c.gem)
		cell["item"] = Game.items.find(c.item)
		cell["state"] = c.state
		cell["pinned"] = c.pinned
		cell["frozen"] = c.frozen
		cells.append(cell)
	data["cells"] = cells

func load_from_file():
	pass

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == MOUSE_BUTTON_RIGHT:
				set_props(Props.None)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.is_pressed():
			if event.keycode == KEY_ESCAPE:
				SSound.sfx_click.play()
				if options_ui.visible:
					options_ui.exit()
				elif bag_viewer_ui.visible:
					bag_viewer_ui.exit()
				elif control_ui.visible:
					toggle_in_game_menu()
	elif event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == MOUSE_BUTTON_LEFT:
				var c = board_ui.hover_coord(true)
				if Board.is_valid(c):
					if !control_ui.action_tip_text.disabled:
						if props == Props.Pin:
							if pins_num > 0 && Board.freeze(c):
								pins_num -= 1
						elif props == Props.Activate:
							if activates_num > 0:
								var i = Board.get_item_at(c)
								if i:
									Board.activate(i, 0, 0, c, Board.ActiveReason.RcAction)
									Board.set_item_at(c, null)
									Board.matching()
									activates_num -= 1
						elif props == Props.Grab:
							if grabs_num > 0:
								var g = Board.get_gem_at(c)
								if g:
									board_ui.start_drag(c)
	elif event is InputEventMouseMotion:
		if board_ui.visible:
			var c = board_ui.hover_coord(true)
			if Board.is_valid(c):
				var cc = Board.offset_to_cube(c)
				control_ui.debug_text.text = "(%d,%d) (%d,%d,%d)" % [c.x, c.y, cc.x, cc.y, cc.z]
				var g = Board.get_gem_at(c)
				if g:
					var arr = g.get_tooltip()
					var i = Board.get_item_at(c)
					if i:
						arr.append_array(i.get_tooltip())
					STooltip.show(arr, 0.5)
			else:
				control_ui.debug_text.text = ""
				STooltip.close()

func _ready() -> void:
	randomize()
	
	subviewport.size = get_viewport().size
	
	Board.rolling_finished.connect(func():
		if after_rolled_eliminate_one_rune > 0:
			after_rolled_eliminate_one_rune -= 1
			after_rolled_eliminate_processing = true
			
			var tween = get_tree().create_tween()
			var r = randi_range(1, 1 + Gem.Rune.Count)
			var coords = Board.filter(func(g : Gem, i):
				return g && g.rune == r
			)
			
			tween.tween_callback(func():
				SSound.sfx_bubble.play()
				Game.add_combo()
				for c in coords:
					Game.add_score(Board.gem_score_at(c), Board.get_pos(c))
			)
			Board.eliminate(coords, tween, Board.ActiveReason.Pattern)
			tween.tween_callback(Board.clear_consumed)
			tween.tween_interval(0.4 * Game.animation_speed)
			tween.tween_callback(Board.fill_blanks)
		elif after_rolled_roll_and_match_processing:
			after_rolled_roll_and_match_processing = false
			Board.matching()
		else:
			stage = Stage.Deploy
			save_to_file()
			end_busy()
	)
	Board.filling_finished.connect(func():
		if after_rolled_eliminate_processing:
			after_rolled_eliminate_processing = false
			Board.rolling_finished.emit()
		else:
			Board.matching()
	)
	Board.matching_finished.connect(func():
		if !after_rolled_roll_and_match_processed && modifiers["continueous_roll_and_match_i"] > 0:
			after_rolled_roll_and_match_processed = true
			after_rolled_roll_and_match_processing = true
			Board.roll()
		else:
			combos = 0
			stage = Stage.Deploy
			history.update()
			save_to_file()
			animation_speed = base_animation_speed
			
			Buff.clear(self, [Buff.Duration.ThisMatching, Buff.Duration.ThisCombo])
			for y in Board.cy:
				for x in Board.cx:
					var c = Vector2i(x, y)
					var g = Board.get_gem_at(c)
					var i = Board.get_item_at(c)
					if g:
						Buff.clear(g, [Buff.Duration.ThisMatching, Buff.Duration.ThisCombo])
					if i:
						Buff.clear(i, [Buff.Duration.ThisMatching, Buff.Duration.ThisCombo])
			
			if matches == 0 && score < target_score:
				level_end()
				game_over_ui.enter()
			elif score >= target_score:
				level_end()
				level_clear_ui.enter()
			else:
				end_busy()
	)
	board_ui.drag_dropped.connect(func(c0 : Vector2i, c1 : Vector2i):
		if Board.is_valid(c1):
			if !control_ui.action_tip_text.disabled:
				if props == Props.Grab:
					if grabs_num > 0:
						var g0 = Board.get_gem_at(c0)
						var g1 = Board.get_gem_at(c1)
						Board.set_gem_at(c0, g1)
						Board.set_gem_at(c1, g0)
						Board.matching()
						grabs_num -= 1
	)
	hand_ui.setup_finished.connect(func():
		stage = Stage.Deploy
		save_to_file()
		control_ui.roll_button.disabled = false
	)
