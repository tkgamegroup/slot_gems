extends Node

enum Stage
{
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

const UiCell = preload("res://ui_cell.gd")
const UiTitle = preload("res://ui_title.gd")
const UiGame = preload("res://ui_game.gd")
const UiHand = preload("res://ui_hand.gd")
const UiShop = preload("res://ui_shop.gd")
const UiStatusBar = preload("res://ui_status_bar.gd")
const UiSkillsBar = preload("res://ui_skills_bar.gd")
const UiPatternsBar = preload("res://ui_patterns_bar.gd")
const UiBlocker = preload("res://ui_blocker.gd")
const UiOptions = preload("res://ui_options.gd")
const UiInGameMenu = preload("res://ui_in_game_menu.gd")
const UiGameOver = preload("res://ui_game_over.gd")
const UiLevelClear = preload("res://ui_level_clear.gd")
const UiChooseReward = preload("res://ui_choose_reward.gd")
const UiBagViewer = preload("res://ui_bag_viewer.gd")
const popup_txt_pb = preload("res://popup_txt.tscn")
const skill_pb = preload("res://ui_skill.tscn")
const pointer_cursor = preload("res://images/pointer.png")
const pin_cursor = preload("res://images/pin.png")
const activate_cursor = preload("res://images/magic_stick.png")
const grab_cursor = preload("res://images/grab.png")

@onready var background = $/root/Main/Background
@onready var bg_shader : ShaderMaterial = background.material
@onready var game_root : Node2D = $/root/Main/Game
@onready var tilemap : TileMapLayer = $/root/Main/Game/TileMapLayer
@onready var outlines_root : Node2D = $/root/Main/Game/Outlines
@onready var underlay : Node2D = $/root/Main/Game/Underlay
@onready var cells_root : Node2D = $/root/Main/Game/Cells
@onready var overlay : Node2D = $/root/Main/Game/Overlay
@onready var hover_ui : Sprite2D = $/root/Main/Game/Hover
@onready var drag_ui : AnimatedSprite2D = $/root/Main/Game/Drag
@onready var title_ui : UiTitle = $/root/Main/UI/Title
@onready var game_ui : UiGame = $/root/Main/UI/Game
@onready var hand_ui : UiHand = $/root/Main/UI/Game/Panel/HBoxContainer/Hand
@onready var shop_ui : UiShop = $/root/Main/UI/Shop
@onready var status_bar_ui : UiStatusBar = $/root/Main/UI/StatusBar
@onready var skills_bar_ui : UiSkillsBar = $/root/Main/UI/SkillsBar
@onready var patterns_bar_ui : UiPatternsBar = $/root/Main/UI/PatternsBar
@onready var blocker_ui : UiBlocker = $/root/Main/UI/Blocker
@onready var options_ui : UiOptions = $/root/Main/UI/Options
@onready var in_game_menu_ui : UiInGameMenu = $/root/Main/UI/InGameMenu
@onready var game_over_ui : UiGameOver = $/root/Main/UI/GameOver
@onready var level_clear_ui : UiLevelClear = $/root/Main/UI/LevelClear
@onready var choose_reward_ui : UiChooseReward = $/root/Main/UI/ChooseReward
@onready var bag_viewer_ui : UiBagViewer = $/root/Main/UI/BagViewer

var dragging_cell : Vector2i = Vector2i(-1, -1)

func release_dragging():
	dragging_cell = Vector2i(-1, -1)
	drag_ui.hide()

var stage : int = Stage.Deploy
var rolls : int:
	set(v):
		rolls = v
		game_ui.rolls_text.text = "%d" % rolls
var rolls_per_level : int
var props = Props.None
var pins_num : int:
	set(v):
		pins_num = v
		if pins_num > 0:
			game_ui.pin_ui.show()
			game_ui.pin_ui.num.text = "%d" % pins_num
		else:
			game_ui.pin_ui.hide()
var pins_num_per_level : int
var activates_num : int:
	set(v):
		activates_num = v
		if activates_num > 0:
			game_ui.activate_ui.show()
			game_ui.activate_ui.num.text = "%d" % activates_num
		else:
			game_ui.activate_ui.hide()
var activates_num_per_level : int
var grabs_num : int:
	set(v):
		grabs_num = v
		if grabs_num > 0:
			game_ui.grab_ui.show()
			game_ui.grab_ui.num.text = "%d" % grabs_num
		else:
			game_ui.grab_ui.hide()
var grabs_num_per_level : int
var board : Board
var board_size : int = 4
var skills : Array[Skill]
var patterns : Array[Pattern]
var gems : Array[Gem]
var unused_gems : Array[Gem] = []
var gem_bouns_scores : Array[int]
var items : Array[Item]
var unused_items : Array[Item] = []
func update_score_text():
	game_ui.score_text.text = "Score: %d/%d (x%.1f)" % [score, target_score, score_mult]
var score : int:
	set(v):
		score = v
		update_score_text()
var target_score : int:
	set(v):
		target_score = v
		update_score_text()
var combos_tween : Tween
var combos : int = 0:
	set(v):
		combos = v
		if combos > 1:
			game_ui.combos_fire.modulate.a = 1.0
			game_ui.combos_fire.show()
			game_ui.combos_fire_shader.set_shader_parameter("amount", min(1.0, combos / 10.0))
			game_ui.combos_text.modulate.a = 1.0
			game_ui.combos_text.show()
			game_ui.combos_text.text = "Combo X %d" % combos
			game_ui.combos_text.add_theme_color_override("font_color", Color.from_hsv(randf(), 0.4, 1.0))
			if combos_tween:
				combos_tween.kill()
			combos_tween = get_tree().create_tween()
			combos_tween.tween_method(func(t):
				game_ui.combos_text.get_parent().rotation_degrees = sin(t * PI * 10.0) * t * 10.0
			, 1.0, 0.0, 1.0)
			combos_tween.tween_callback(func():
				combos_tween = null
			)
var base_score_mult : float = 1.0:
	set(v):
		base_score_mult = v
		SUtils.calc_value_with_modifiers(self, "score_mult")
var score_mult : float = base_score_mult:
	set(v):
		score_mult = v
		update_score_text()
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

var animation_speed = 1.0

func set_props(t : int):
	props = t
	for n in game_ui.props_bar.get_children():
		n.select.hide()
	if props == Props.None:
		game_ui.action_tip_text.text = ""
		Input.set_custom_mouse_cursor(pointer_cursor, Input.CURSOR_ARROW, Vector2(15, 4))
	elif props == Props.Pin:
		game_ui.pin_ui.select.show()
		game_ui.action_tip_text.text = "[img width=32]res://images/mouse_left_button.png[/img]To Pin[img width=32]res://images/mouse_right_button.png[/img]Cancel"
		Input.set_custom_mouse_cursor(pin_cursor, Input.CURSOR_ARROW, Vector2(7, 30))
	elif props == Props.Activate:
		game_ui.activate_ui.select.show()
		game_ui.action_tip_text.text = "[img width=32]res://images/mouse_left_button.png[/img]To Activate[img width=32]res://images/mouse_right_button.png[/img]Cancel"
		Input.set_custom_mouse_cursor(activate_cursor, Input.CURSOR_ARROW, Vector2(5, 5))
	elif props == Props.Grab:
		game_ui.grab_ui.select.show()
		game_ui.action_tip_text.text = "[img width=32]res://images/mouse_left_button.png[/img]To Drag Around[img width=32]res://images/mouse_right_button.png[/img]Cancel"
		Input.set_custom_mouse_cursor(grab_cursor, Input.CURSOR_ARROW, Vector2(5, 20))

func get_cell_ui(c : Vector2i) -> UiCell:
	return cells_root.get_child(c.y * board.cx + c.x)

func get_gem(g : Gem = null):
	if g:
		unused_gems.erase(g)
		return g
	return SMath.pick_and_remove(unused_gems)

func release_gem(gem : Gem):
	gem.coord = Vector2i(-1, -1)
	for b in gem.buffs:
		b.die()
	gem.buffs.clear()
	unused_gems.append(gem)

func get_item(i : Item = null):
	if i:
		unused_items.erase(i)
		return i
	return SMath.pick_and_remove(unused_items)

func release_item(item : Item):
	unused_items.append(item)

func add_combo():
	combos += 1
	var burning_cells = []
	for y in board.cy:
		for x in board.cx:
			var c = Vector2i(x, y)
			if board.get_state_at(c) == Cell.State.Burning:
				burning_cells.append(c)
			var i = board.get_item_at(c)
			if i && i.on_combo.is_valid():
				i.on_combo.call(self, combos)
	for c in burning_cells:
		for cc in board.offset_neighbors(c):
			if board.get_state_at(cc) != Cell.State.Burning:
				board.set_state_at(cc, Cell.State.Burning)
				break

func float_text(txt : String, pos : Vector2):
	var ui = popup_txt_pb.instantiate()
	ui.position = pos
	ui.scale = Vector2(1.5, 1.5)
	var lb : Label = ui.get_child(0)
	lb.text = txt
	ui.z_index = 10
	overlay.add_child(ui)
	var tween = get_tree().create_tween()
	tween.tween_property(ui, "position", pos - Vector2(0, 20), 0.5)
	tween.parallel().tween_property(ui, "scale", Vector2(0.8, 0.8), 0.5)
	tween.tween_callback(func():
		ui.queue_free()
	)

func add_score(base : int, pos : Vector2):
	var mult = int(combos * score_mult)
	var ui = popup_txt_pb.instantiate()
	ui.position = pos
	ui.scale = Vector2(1.5, 1.5)
	var lb : Label = ui.get_child(0)
	lb.text = "%dx%d" % [base, int(mult * score_mult)]
	ui.z_index = 10
	overlay.add_child(ui)
	var tween = get_tree().create_tween()
	tween.tween_method(func(t):
		ui.rotation_degrees = sin(t * PI * 10.0) * t * 30.0
	, 1.0, 0.0, 1.0)
	tween.parallel().tween_property(ui, "scale", Vector2(1.0, 1.0), 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_callback(func():
		var s = base * int(mult * score_mult)
		lb.text = "%d" % s
		score += s
	)
	tween.tween_property(ui, "position", pos - Vector2(0, 20), 0.5)
	tween.parallel().tween_property(ui, "scale", Vector2(0.8, 0.8), 0.5)
	tween.tween_callback(func():
		ui.queue_free()
	)

var status_tween : Tween
func add_status(s : String, col : Color):
	game_ui.status_text.show()
	game_ui.status_text.text = s
	var parent = game_ui.status_text.get_parent()
	parent.scale = Vector2(1.3, 1.3)
	game_ui.status_text.add_theme_color_override("font_color", col)
	if status_tween:
		status_tween.kill()
	status_tween = get_tree().create_tween()
	status_tween.tween_method(func(t):
		parent.rotation_degrees = sin(t * PI * 10.0) * t * 10.0
	, 1.0, 0.0, 1.0)
	status_tween.parallel().tween_property(parent, "scale", Vector2(1.0, 1.0), 1.0)
	status_tween.tween_interval(0.5)
	status_tween.tween_callback(func():
		game_ui.status_text.hide()
		status_tween = null
	)

func sort_gems():
	gems.sort_custom(func(a, b):
		return a.type * 0xffff + a.rune * 0xff + (100.0 / max(a.base_score, 0.1)) < b.type * 0xffff + b.rune * 0xff + (100.0 / max(b.base_score, 0.1))
	)

func add_skill(s : Skill):
	var ui = skill_pb.instantiate()
	ui.setup(s)
	skills_bar_ui.list.add_child(ui)
	s.ui = ui
	skills.append(s)

func add_pattern(p : Pattern):
	patterns.append(p)
	patterns_bar_ui.add_ui(p)

func get_level_score(lv : int):
	match lv:
		1:
			return 100
		2:
			return 300
		3:
			return 600
		4:
			return 1000
		5:
			return 1500
		6:
			return 2400
		7:
			return 4000
		8:
			return 6000

func start_new_game():
	gem_bouns_scores.clear()
	for i in Gem.Type.Count:
		gem_bouns_scores.append(0)
	rolls_per_level = 4
	pins_num_per_level = 0
	activates_num_per_level = 0
	grabs_num_per_level = 0
	level = 0
	coins = 10
	history.init()
	
	skills.clear()
	skills_bar_ui.clear()
	var skill0 = Skill.new()
	skill0.add_requirement(1, 3)
	#add_skill(skill0)
	
	patterns.clear()
	patterns_bar_ui.clear()
	var patt0 = Pattern.new()
	patt0.coords.append(Vector3i(0, 0, 0))
	patt0.coords.append(Vector3i(1, 0, -1))
	patt0.coords.append(Vector3i(2, 0, -2))
	patt0.coords.append(Vector3i(3, 0, -3))
	patt0.mult = 1
	add_pattern(patt0)
	var patt1 = Pattern.new()
	patt1.coords.append(Vector3i(0, 0, 0))
	patt1.coords.append(Vector3i(0, 1, -1))
	patt1.coords.append(Vector3i(0, 2, -2))
	patt1.coords.append(Vector3i(0, 3, -3))
	patt1.mult = 1
	add_pattern(patt1)
	var patt2 = Pattern.new()
	patt2.coords.append(Vector3i(0, 0, 0))
	patt2.coords.append(Vector3i(1, -1, 0))
	patt2.coords.append(Vector3i(2, -2, 0))
	patt2.coords.append(Vector3i(3, -3, 0))
	patt2.mult = 1
	add_pattern(patt2)
	
	gems.clear()
	for j in 3:
		for i in 72:
			var g = Gem.new()
			g.type = Gem.Type.Red
			g.rune = j + 1
			gems.append(g)
	for j in 3:
		for i in 72:
			var g = Gem.new()
			g.type = Gem.Type.Orange
			g.rune = j + 1
			gems.append(g)
	for j in 3:
		for i in 72:
			var g = Gem.new()
			g.type = Gem.Type.Green
			g.rune = j + 1
			gems.append(g)
	for j in 3:
		for i in 72:
			var g = Gem.new()
			g.type = Gem.Type.Blue
			g.rune = j + 1
			gems.append(g)
	for j in 3:
		for i in 72:
			var g = Gem.new()
			g.type = Gem.Type.Pink
			g.rune = j + 1
			gems.append(g)
	
	items.clear()
	for i in 3:
		var item = Item.new()
		item.setup("Dye: Red")
		items.append(item)
	for i in 3:
		var item = Item.new()
		item.setup("Dye: Orange")
		items.append(item)
	for i in 3:
		var item = Item.new()
		item.setup("Dye: Green")
		items.append(item)
	for i in 3:
		var item = Item.new()
		item.setup("Dye: Blue")
		items.append(item)
	for i in 3:
		var item = Item.new()
		item.setup("Dye: Pink")
		items.append(item)
	for i in 100:
		var item = Item.new()
		item.setup("Bomb")
		items.append(item)
	
	status_bar_ui.appear()
	skills_bar_ui.appear()
	patterns_bar_ui.appear()
	
	board = Board.new()
	board.rolling_finished.connect(func():
		stage = Stage.Deploy
		if rolls > 0:
			game_ui.roll_button.disabled = false
		game_ui.play_button.disabled = false
		hand_ui.disabled = false
	)
	board.matching_finished.connect(func():
		stage = Stage.Deploy
		animation_speed = 1.0
		history.update()
		
		combos = 0
		if game_ui.combos_text.visible:
			if combos_tween:
				combos_tween.kill()
				combos_tween = null
			combos_tween = get_tree().create_tween()
			combos_tween.tween_property(game_ui.combos_fire, "modulate:a", 0.0, 1.0)
			combos_tween.parallel().tween_property(game_ui.combos_text, "modulate:a", 0.0, 1.0)
			combos_tween.tween_callback(func():
				game_ui.combos_fire.hide()
				game_ui.combos_text.hide()
				combos_tween = null
			)
		
		if rolls == 0 && hand_ui.is_empty() && score < target_score:
			set_props(Props.None)
			game_over_ui.enter()
		elif score >= target_score:
			set_props(Props.None)
			level_clear_ui.enter()
		else:
			if rolls > 0:
				game_ui.roll_button.disabled = false
			game_ui.play_button.disabled = false
			hand_ui.disabled = false
	)
	
	new_level()

func new_level():
	level += 1
	score = 0
	target_score = get_level_score(level)
	
	setup()

func setup():
	set_props(Props.None)
	rolls = rolls_per_level
	pins_num = pins_num_per_level
	activates_num = activates_num_per_level
	grabs_num = grabs_num_per_level
	
	SSound.sfx_board_setup.play()
	board.setup(board_size, 3)
	hand_ui.setup()
	
	var tween = get_tree().create_tween()
	tween.tween_method(func(t):
		bg_shader.set_shader_parameter("uColor", lerp(Vector3(1.0, 1.0, 0.6), Vector3(0.6, 1.0, 1.0), t))
	, 0.0, 1.0, 0.8)
	
	if level_clear_ui.visible:
		level_clear_ui.exit()
	if game_over_ui.visible:
		game_over_ui.exit()
	game_root.show()
	game_ui.enter()

func roll():
	if rolls > 0:
		stage = Stage.Rolling
		rolls -= 1
		score_mult = 1.0
		animation_speed = 1.0
		board.roll()
		game_ui.roll_button.disabled = true
		game_ui.play_button.disabled = true
		hand_ui.discard()
		hand_ui.roll()
		hand_ui.disabled = true
		history.rolls += 1

func play():
	stage = Stage.Matching
	game_ui.roll_button.disabled = true
	game_ui.play_button.disabled = true
	hand_ui.disabled = true
	board.matching()

func toggle_in_game_menu():
	if !in_game_menu_ui.visible:
		STooltip.close()
		in_game_menu_ui.enter()
	else:
		in_game_menu_ui.exit()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == MOUSE_BUTTON_RIGHT:
				set_props(Props.None)
				release_dragging()
		if event.is_released():
			if event.button_index == MOUSE_BUTTON_LEFT:
				if board:
					var c = tilemap.local_to_map(tilemap.get_local_mouse_position())
					c -= board.central_coord - Vector2i(board.cx / 2, board.cy / 2)
					if board.is_valid(c):
						if !game_ui.action_tip_text.disabled && dragging_cell.x != -1 && dragging_cell.y != -1:
							if props == Props.Grab:
								if grabs_num > 0 && (dragging_cell.x != c.x || dragging_cell.y != c.y):
									var g0 = board.get_gem_at(dragging_cell)
									var g1 = board.get_gem_at(c)
									board.set_gem_at(dragging_cell, g1)
									board.set_gem_at(c, g0)
									board.matching()
									grabs_num -= 1
					release_dragging()
	elif event is InputEventMouseMotion:
		if board && game_root.visible:
			var c = tilemap.local_to_map(tilemap.get_local_mouse_position())
			var cc = c - board.central_coord + Vector2i(board.cx / 2, board.cy / 2)
			if board.is_valid(cc):
				hover_ui.show()
				hover_ui.position = tilemap.map_to_local(c)
			else:
				hover_ui.hide()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.is_pressed():
			if event.keycode == KEY_ESCAPE:
				if options_ui.visible:
					options_ui.exit()
				elif game_ui.visible:
					toggle_in_game_menu()
	elif event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == MOUSE_BUTTON_LEFT:
				if board:
					var c = tilemap.local_to_map(tilemap.get_local_mouse_position())
					c -= board.central_coord - Vector2i(board.cx / 2, board.cy / 2)
					if board.is_valid(c):
						if !game_ui.action_tip_text.disabled:
							if props == Props.Pin:
								if pins_num > 0 && board.pin(c):
									pins_num -= 1
							elif props == Props.Activate:
								if activates_num > 0:
									var g = board.get_gem_at(c)
									if g && g.item:
										board.activate(g.item, c, Board.ActiveReason.RcAction)
										board.matching()
										activates_num -= 1
							elif props == Props.Grab:
								if grabs_num > 0:
									var g = board.get_gem_at(c)
									if g:
										dragging_cell = c
										drag_ui.frame = g.image_id
										drag_ui.position = event.position
										drag_ui.show()
	elif event is InputEventMouseMotion:
		if board && game_root.visible:
			var c = tilemap.local_to_map(tilemap.get_local_mouse_position())
			c -= board.central_coord - Vector2i(board.cx / 2, board.cy / 2)
			if board.is_valid(c):
				var cc = board.offset_to_cube(c)
				game_ui.debug_text.text = "(%d,%d) (%d,%d,%d)" % [c.x, c.y, cc.x, cc.y, cc.z]
				var g = board.get_gem_at(c)
				if g:
					var arr = g.get_tooltip()
					var i = board.get_item_at(c)
					if i:
						arr.append_array(i.get_tooltip())
					STooltip.show(arr, 0.5)
			else:
				game_ui.debug_text.text = ""
				STooltip.close()
			if drag_ui.visible:
				drag_ui.position = event.position

var noise : Noise
var noise_coord : float = 0.0

func _ready() -> void:
	noise = FastNoiseLite.new()
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	noise.fractal_type = FastNoiseLite.FRACTAL_FBM
	noise.frequency = 0.2
	noise.seed = randi()

func _process(delta: float) -> void:
	noise_coord += 1.0 * delta
	cells_root.position = Vector2(noise.get_noise_2d(17.1, noise_coord), noise.get_noise_2d(97.9, noise_coord)) * 2.0
