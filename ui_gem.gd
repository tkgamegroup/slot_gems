extends Node2D

@onready var bg_sp : AnimatedSprite2D = $BG
@onready var rune_sp : AnimatedSprite2D = $Rune

const dissolve_mat : ShaderMaterial = preload("res://dissolve_mat.tres")
const wild_mat : ShaderMaterial = preload("res://wild_mat.tres")

var type : int
var rune : int

func set_image(_type : int, _rune : int):
	type = _type
	rune = _rune
	if bg_sp:
		bg_sp.frame = type
		if type == Gem.Type.Blue || type == Gem.Type.Orange || type == Gem.Type.Green:
			rune_sp.modulate = Color(0.0, 0.0, 0.0, 1.0)
		else:
			rune_sp.modulate = Color(1.0, 1.0, 1.0, 1.0)
		rune_sp.frame = rune
		
		if type == Gem.Type.Wild:
			bg_sp.material = wild_mat
		else:
			bg_sp.material = null
		rune_sp.material = null

func dissolve(duration : float):
	bg_sp.material = dissolve_mat
	rune_sp.material = dissolve_mat
	var tween = get_tree().create_tween()
	tween.tween_method(func(t):
		dissolve_mat.set_shader_parameter("dissolve", t)
	, 1.0, 0.0, duration)
	tween.tween_callback(func():
		self.hide()
	)

func _ready() -> void:
	set_image(type, rune)
