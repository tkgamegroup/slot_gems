extends Control

@onready var panel : PanelContainer = $PanelContainer
@onready var item_list = $PanelContainer/VBoxContainer/ScrollContainer/VBoxContainer/List
@onready var skill_list = $PanelContainer/VBoxContainer/ScrollContainer/VBoxContainer/List2
@onready var pattern_list = $PanelContainer/VBoxContainer/ScrollContainer/VBoxContainer/List3
@onready var relic_list = $PanelContainer/VBoxContainer/ScrollContainer/VBoxContainer/List4
@onready var close_button = $PanelContainer/VBoxContainer/Button

const item_ui = preload("res://ui_item.tscn")
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
	self.self_modulate.a = 0.0
	var tween = get_tree().create_tween()
	tween.tween_property(self, "self_modulate:a", 1.0, 0.3)
	
	var items = ["DyeRed", "DyeOrange", "DyeGreen", "DyeBlue", "DyePurple", "Pin", "Flag", "Bomb", "C4", "Minefield", "ColorPalette", "Chloroplast", "Dog", "Cat", "HotDog", "Rainbow", "Idol", "Magician", "Ruby", "Citrine", "Emerald", "Sapphire", "Tourmaline", "Volcano"]
	for n in items:
		var i = Item.new()
		i.setup(n)
		var ui = item_ui.instantiate()
		ui.setup(i)
		item_list.add_child(ui)
	var patterns = ["\\", "I", "/", "Y", "C", "O", "√", "X"]
	for n in patterns:
		var p = Pattern.new()
		p.setup(n)
		var ui = pattern_ui.instantiate()
		ui.setup(p, true)
		pattern_list.add_child(ui)
	var relics = ["ExplosionScience", "HighExplosives", "UniformBlasting", "SympatheticDetonation", "BlockedLever", "MobiusStrip", "Premeditation", "PentagramPower", "RedComposition", "Sunflowers", "WaterLilies", "BlueNude", "LesDemoisellesDAvignon"]
	for n in relics:
		var r = Relic.new()
		r.setup(n)
		var ui = relic_ui.instantiate()
		ui.setup(r)
		relic_list.add_child(ui)
	
	self.show()
	panel.show()

func exit():
	panel.hide()
	self.self_modulate.a = 1.0
	var tween = get_tree().create_tween()
	tween.tween_property(self, "self_modulate:a", 0.0, 0.3)
	tween.tween_callback(func():
		self.hide()
	)

func _ready() -> void:
	close_button.pressed.connect(func():
		SSound.se_click.play()
		Game.screen_shake_strength = 8.0
		exit()
	)
