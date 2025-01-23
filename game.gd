extends Node

enum RightClickAction
{
	Pin,
	Activate
}

const UiCell = preload("res://ui_cell.gd")
const UiTitle = preload("res://ui_title.gd")
const UiGame = preload("res://ui_game.gd")
const UiShop = preload("res://ui_shop.gd")
const UiOptions = preload("res://ui_options.gd")
const UiInGameMenu = preload("res://ui_in_game_menu.gd")
const UiGameOver = preload("res://ui_game_over.gd")
const UiLevelClear = preload("res://ui_level_clear.gd")
const popup_txt_pb = preload("res://popup_txt.tscn")
const Sound = preload("res://sound.gd")

@onready var game_root : Node2D = $/root/Main/Game
@onready var tilemap : TileMapLayer = $/root/Main/Game/TileMapLayer
@onready var outlines_root : Node2D = $/root/Main/Game/Outlines
@onready var cells_root : Node2D = $/root/Main/Game/Cells
@onready var overlay : Node2D = $/root/Main/Game/Overlay
@onready var title_ui : UiTitle = $/root/Main/UI/Title
@onready var game_ui : UiGame = $/root/Main/UI/Game
@onready var shop_ui : UiShop = $/root/Main/UI/Shop
@onready var options_ui : UiOptions = $/root/Main/UI/Options
@onready var in_game_menu_ui : UiInGameMenu = $/root/Main/UI/InGameMenu
@onready var game_over_ui : UiGameOver = $/root/Main/UI/GameOver
@onready var level_clear_ui : UiLevelClear = $/root/Main/UI/LevelClear
@onready var ui_blocker : Control = $/root/Main/UI/Blocker
@onready var sound : Sound = $/root/Main/Sounds

var protected_controls : Array[Control] = []

var rolls : int:
	set(v):
		rolls = v
		game_ui.rolls_text.text = "%d" % rolls
var rc_action = RightClickAction.Pin
var rc_actions : int:
	set(v):
		rc_actions = v
		game_ui.rc_actions_text.text = "%d" % rc_actions

var board : Board
var patterns : Array[Pattern]
var items : Array[String]
var score : int:
	set(v):
		score = v
		game_ui.score_text.text = "Your Score: %d" % score
var target_score : int:
	set(v):
		target_score = v
		game_ui.target_score_text.text = "Target Score: %d" % target_score
var combos_tween : Tween
var combos : int = 0:
	set(v):
		combos = v
		if combos > 1:
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
				game_ui.combos_text.hide()
				combos_tween = null
			)
var rainbow_mult : float = 1.0
var level : int
var history : History = History.new()

var animation_speed = 1.0

func begin_protect_controls():
	for c in protected_controls:
		c.disabled = true

func end_protect_controls():
	for c in protected_controls:
		c.disabled = false

func set_rc_action(t : int):
	rc_action = t
	if rc_action == RightClickAction.Pin:
		game_ui.rc_action_name_text.text = "Pins"
		game_ui.rc_action_tip_text.text = "[img width=32]res://images/mouse_right_button.png[/img]to Pin"
	elif rc_action == RightClickAction.Activate:
		game_ui.rc_action_name_text.text = "Acts"
		game_ui.rc_action_tip_text.text = "[img width=32]res://images/mouse_right_button.png[/img]to Activate"

func get_cell_ui(c : Vector2i) -> UiCell:
	return cells_root.get_child(c.y * board.cx + c.x)

func add_combo():
	combos += 1
	var burning_cells = []
	for y in board.cy:
		for x in board.cx:
			var c = Vector2i(x, y)
			if board.get_gem_state_at(c) == Cell.GemState.Burning:
				burning_cells.append(c)
			var item = board.get_item_at(c)
			if item:
				if item.on_combo.is_valid():
					item.on_combo.call(self, combos)
	for c in burning_cells:
		for cc in board.offset_neighbors(c):
			if board.get_gem_state_at(cc) != Cell.GemState.Burning:
				board.set_gem_state_at(cc, Cell.GemState.Burning)
				break

func add_score(base : int, pos : Vector2):
	var mult = int(combos * rainbow_mult)
	var txt = popup_txt_pb.instantiate()
	txt.position = pos
	txt.scale = Vector2(1.5, 1.5)
	var lb : Label = txt.get_child(0)
	lb.text = "%dx%d" % [base, mult]
	txt.z_index = 10
	overlay.add_child(txt)
	var tween = get_tree().create_tween()
	tween.tween_method(func(t):
		txt.rotation_degrees = sin(t * PI * 10.0) * t * 30.0
	, 1.0, 0.0, 1.0)
	tween.parallel().tween_property(txt, "scale", Vector2(1.0, 1.0), 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_callback(func():
		var total_score = base * mult
		lb.text = "%d" % total_score
		score += total_score
	)
	tween.tween_property(txt, "position", pos - Vector2(0, 20), 0.5)
	tween.parallel().tween_property(txt, "scale", Vector2(0.8, 0.8), 0.5)
	tween.tween_callback(func():
		txt.queue_free()
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

func start_new_game():
	score = 0
	target_score = 10000
	rolls = 40
	set_rc_action(RightClickAction.Pin)
	rc_actions = 5
	level = 1
	history.init()
	
	game_root.show()
	game_ui.enter()
	
	board = Board.new()
	board.setup(4, 3)
	board.processed_finished.connect(func():
		end_protect_controls()
		history.update_max_roll()
		animation_speed = 1.0
		if rolls == 0 && score < target_score:
			game_over_ui.enter()
		elif score >= target_score:
			level_clear_ui.enter()
	)
	
	patterns.clear()
	var patt0 = Pattern.new()
	patt0.coords.append(Vector3i(0, 0, 0))
	patt0.coords.append(Vector3i(1, 0, -1))
	patt0.coords.append(Vector3i(2, 0, -2))
	patt0.coords.append(Vector3i(3, 0, -3))
	patt0.mult = 4
	patterns.append(patt0)
	var patt1 = Pattern.new()
	patt1.coords.append(Vector3i(0, 0, 0))
	patt1.coords.append(Vector3i(0, 1, -1))
	patt1.coords.append(Vector3i(0, 2, -2))
	patt1.coords.append(Vector3i(0, 3, -3))
	patt1.mult = 4
	patterns.append(patt1)
	var patt2 = Pattern.new()
	patt2.coords.append(Vector3i(0, 0, 0))
	patt2.coords.append(Vector3i(1, -1, 0))
	patt2.coords.append(Vector3i(2, -2, 0))
	patt2.coords.append(Vector3i(3, -3, 0))
	patt2.mult = 4
	patterns.append(patt2)
	
	items.clear()
	for i in 20:
		items.append("ruby")

func roll():
	if rolls > 0:
		rolls -= 1
		begin_protect_controls()
		rainbow_mult = 1.0
		animation_speed = 1.0
		board.roll()
		history.rolls += 1

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.is_pressed():
			if event.keycode == KEY_ESCAPE:
				if options_ui.visible:
					ui_blocker.hide()
					options_ui.hide()
				elif game_ui.visible:
					if !in_game_menu_ui.visible:
						ui_blocker.show()
						in_game_menu_ui.show()
					else:
						ui_blocker.hide()
						in_game_menu_ui.hide()
	elif event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == MOUSE_BUTTON_RIGHT:
				var c = tilemap.local_to_map(tilemap.get_local_mouse_position())
				c -= board.central_coord - Vector2i(board.cx / 2, board.cy / 2)
				if c.x >= 0 && c.x < board.cx && c.y >= 0 && c.y < board.cy:
					if rc_actions > 0 && !game_ui.rc_action_tip_text.disabled:
						if rc_action == RightClickAction.Pin:
							if board.set_state_at(c, Cell.State.Pined):
								rc_actions -= 1
						elif rc_action == RightClickAction.Activate:
							var item = board.get_item_at(c)
							if item:
								begin_protect_controls()
								board.activate_item(item, Board.ActiveReason.RcAction)
								board.search_patterns()
								rc_actions -= 1
