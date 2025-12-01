extends Control

@onready var panel : PanelContainer = $PanelContainer
@onready var item_list = $PanelContainer/VBoxContainer/ScrollContainer/VBoxContainer/List
@onready var skill_list = $PanelContainer/VBoxContainer/ScrollContainer/VBoxContainer/List2
@onready var pattern_list = $PanelContainer/VBoxContainer/ScrollContainer/VBoxContainer/List3
@onready var relic_list = $PanelContainer/VBoxContainer/ScrollContainer/VBoxContainer/List4
@onready var close_button = $PanelContainer/VBoxContainer/Button

const pattern_ui = preload("res://ui_pattern.tscn")
const relic_ui = preload("res://ui_relic.tscn")

func clear():
	for n in item_list.get_children():
		item_list.remove_child(n)
		n.queue_free()
	for n in skill_list.get_children():
		skill_list.remove_child(n)
		n.queue_free()
	for n in pattern_list.get_children():
		pattern_list.remove_child(n)
		n.queue_free()
	for n in relic_list.get_children():
		relic_list.remove_child(n)
		n.queue_free()

func enter():
	self.self_modulate.a = 0.0
	self.show()
	panel.show()
	
	var tween = App.create_tween()
	tween.tween_property(self, "self_modulate:a", 1.0, 0.3)
	
	var items = ["DyeRed", "DyeOrange", "DyeGreen", "DyeBlue", "DyeMagenta", "Pin", "Flag", "Bomb", "C4", "Minefield", "ColorPalette", "Chloroplast", "Dog", "Cat", "HotDog", "Rainbow", "Idol", "Magician", "Ruby", "Citrine", "Emerald", "Sapphire", "Tourmaline", "Volcano"]
	'''
	for n in items:
		var i = Item.new()
		i.setup(n)
		var ui = item_ui.instantiate()
		ui.setup(i)
		item_list.add_child(ui)
	'''
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

func exit():
	panel.hide()
	clear()
	
	self.self_modulate.a = 1.0
	var tween = App.create_tween()
	tween.tween_property(self, "self_modulate:a", 0.0, 0.3)
	tween.tween_callback(func():
		self.hide()
	)

func _ready() -> void:
	close_button.pressed.connect(func():
		SSound.se_click.play()
		App.screen_shake_strength = 8.0
		exit()
	)
