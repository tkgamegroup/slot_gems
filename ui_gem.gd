extends Control

@onready var type_sp = $SubViewport/Type
@onready var wild_sp = $SubViewport/Wild
@onready var item_sp = $SubViewport/Item
@onready var rune_sp = $SubViewport/Rune
@onready var display : Sprite2D = $Display
@onready var charming_fx : CPUParticles2D = $Charming
@onready var sharp_fx : CPUParticles2D = $Sharp
@export var angle : Vector2:
	set(v):
		angle = v
		display.material.set_shader_parameter("x_rot", angle.x)
		display.material.set_shader_parameter("y_rot", angle.y)

var type : int
var rune : int
var item : int
var charming : int = 0
var sharp : int = 0

func reset(_type : int = 0, _rune : int = 0, _item : int = 0):
	type = _type
	rune = _rune
	item = _item
	charming = 0
	sharp = 0
	wild_sp.hide()
	type_sp.show()
	update(null)

func update(g : Gem):
	if g:
		type = g.type
		rune = g.rune
		item = g.image_id
		for enchant in Buff.find_all_typed(g, Buff.Type.Enchant):
			var enchant_type = enchant.data["type"]
			if enchant_type == "w_enchant_charming":
				charming += 1
			elif enchant_type == "w_enchant_sharp":
				sharp += 1
	
	if type_sp:
		type_sp.frame = type - Gem.ColorRed + 1
		type_sp.material.set_shader_parameter("type_color", Gem.type_color(type))
		
		if item > 0:
			type_sp.hide()
			item_sp.frame = item
		else:
			if type == Gem.ColorWild:
				type_sp.hide()
				wild_sp.show()
				rune_sp.modulate = Color(0.0, 0.0, 0.0, 0.66)
			else:
				type_sp.show()
				wild_sp.hide()
				rune_sp.modulate = Color(0.0, 0.0, 0.0, 0.66)
			item_sp.frame = 0
		rune_sp.frame = rune - Gem.Runewave + 1
		
		if charming > 0:
			charming_fx.show()
		else:
			charming_fx.hide()
		if sharp > 0:
			sharp_fx.show()
		else:
			sharp_fx.hide()

func dissolve(duration : float):
	var tween = get_tree().create_tween()
	tween.tween_property(display.material, "shader_parameter/dissolve", 0.0, duration)
	tween.tween_callback(func():
		self.hide()
	)

func _ready() -> void:
	update(null)

func _process(delta: float) -> void:
	type_sp.material.set_shader_parameter("offset", Vector2(0.01, 0.01) * global_position)
