extends Node2D

@onready var bg_sp : AnimatedSprite2D = $BG
@onready var rune_sp : AnimatedSprite2D = $Rune
@onready var item_sp : AnimatedSprite2D = $Item
@onready var charming_fx : CPUParticles2D = $Charming
@onready var sharp_fx : CPUParticles2D = $Sharp

const dissolve_mat : ShaderMaterial = preload("res://materials/dissolve_mat.tres")
const wild_mat : ShaderMaterial = preload("res://materials/wild_mat.tres")
const omni_mat : ShaderMaterial = preload("res://materials/omni_mat.tres")

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
	bg_sp.material = null
	rune_sp.material = null
	item_sp.material = null
	self.show()
	update(null)

func update(g : Gem, override_item : int = -1):
	if g:
		type = g.type
		rune = g.rune
		item = override_item
		if item == -1 && g.bound_item:
			item = g.bound_item.image_id
		for enchant in Buff.find_all_typed(g, Buff.Type.Enchant):
			var type = enchant.data["type"]
			if type == "w_enchant_charming":
				charming += 1
			elif type == "w_enchant_sharp":
				sharp += 1
	
	if bg_sp:
		bg_sp.frame = type
		if type == Gem.Type.Blue || type == Gem.Type.Orange || type == Gem.Type.Green:
			rune_sp.modulate = Color(0.0, 0.0, 0.0, 1.0)
		else:
			rune_sp.modulate = Color(1.0, 1.0, 1.0, 1.0)
		rune_sp.frame = rune
		item_sp.frame = item
		
		if type == Gem.Type.Wild:
			bg_sp.material = wild_mat
		else:
			bg_sp.material = null
		if rune == Gem.Rune.Omni:
			rune_sp.material = omni_mat
		else:
			rune_sp.material = null
		
		if charming > 0:
			charming_fx.show()
		else:
			charming_fx.hide()
		if sharp > 0:
			sharp_fx.show()
		else:
			sharp_fx.hide()

func dissolve(duration : float):
	bg_sp.material = dissolve_mat
	rune_sp.material = dissolve_mat
	item_sp.material = dissolve_mat
	var tween = get_tree().create_tween()
	tween.tween_method(func(t):
		dissolve_mat.set_shader_parameter("dissolve", t)
	, 1.0, 0.0, duration)
	tween.tween_callback(func():
		self.hide()
	)

func _ready() -> void:
	update(null)
