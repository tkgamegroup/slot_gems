extends Control

@onready var item_list = $VBoxContainer/ScrollContainer/VBoxContainer/List
@onready var skill_list = $VBoxContainer/ScrollContainer/VBoxContainer/List2
@onready var pattern_list = $VBoxContainer/ScrollContainer/VBoxContainer/List3
@onready var relic_list = $VBoxContainer/ScrollContainer/VBoxContainer/List4
@onready var close_button = $VBoxContainer/Button

const item_ui = preload("res://ui_item.tscn")
const skill_ui = preload("res://ui_skill.tscn")
const pattern_ui = preload("res://ui_pattern.tscn")
const relic_ui = preload("res://ui_relic.tscn")

func clear():
	for n in item_list.get_children():
		n.queue_free()
		item_list.remove_child(n)
	for n in skill_list.get_children():
		n.queue_free()
		skill_list.remove_child(n)
	for n in pattern_list.get_children():
		n.queue_free()
		pattern_list.remove_child(n)
	for n in relic_list.get_children():
		n.queue_free()
		relic_list.remove_child(n)

func enter():
	clear()
	Game.blocker_ui.enter()
	self.show()
	
	var items = ["DyeRed", "DyeOrange", "DyeGreen", "DyeBlue", "DyePink", "Pin", "Flag", "Bomb", "C4", "Minefield", "ColorPalette", "Chloroplast", "Dog", "Cat", "HotDog", "Rainbow", "Idol", "Magician", "Ruby", "Citrine", "Emerald", "Sapphire", "Tourmaline", "Volcano"]
	for n in items:
		var i = Item.new()
		i.setup(n)
		var ui = item_ui.instantiate()
		ui.setup(i)
		item_list.add_child(ui)
	var skills = ["Xiao", "Roll", "Match", "Qiang", "Se", "Huan", "Chou", "Jin", "Bao", "Fang", "Fen", "Xing"]
	for n in skills:
		var s = Skill.new()
		s.setup(n)
		var ui = skill_ui.instantiate()
		ui.setup(s)
		skill_list.add_child(ui)
	var patterns = ["\\", "I", "/", "Y", "C", "O", "√", "X"]
	for n in patterns:
		var p = Pattern.new()
		p.setup(n)
		var ui = pattern_ui.instantiate()
		ui.setup(p)
		pattern_list.add_child(ui)
	var relics = ["ExplosionScience", "HighExplosives", "UniformBlasting", "SympatheticDetonation", "BlockedLever", "MobiusStrip", "Premeditation", "PentagramPower", "RedStone", "OrangeStone", "GreenStone", "BlueStone", "PinkStone"]
	for n in relics:
		var r = Relic.new()
		r.setup(n)
		var ui = relic_ui.instantiate()
		ui.setup(r)
		relic_list.add_child(ui)
	
func exit():
	Game.blocker_ui.exit()
	self.hide()

func _ready() -> void:
	close_button.pressed.connect(func():
		SSound.sfx_click.play()
		exit()
	)
