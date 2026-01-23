extends Control

@onready var sub_viewport = $SubViewport
@onready var gem_kind_sp = $SubViewport/GemKind
@onready var wild_sp = $SubViewport/Wild
@onready var special_sp = $SubViewport/Special
@onready var rune_sp = $SubViewport/Rune
@onready var display : Sprite2D = $Display
@onready var charming_fx : CPUParticles2D = $Charming
@onready var sharp_fx : CPUParticles2D = $Sharp
@onready var pieces_root = $Pieces
@export var angle : Vector2:
	set(v):
		angle = v
		display.material.set_shader_parameter("x_rot", angle.x)
		display.material.set_shader_parameter("y_rot", angle.y)

var type : int
var rune : int
var image_id : int
var gem_kind : bool = false
var charming : int = 0
var sharp : int = 0
var pieces_tweens : Array[Tween]

func reset(_type : int = 0, _rune : int = 0, _image_id : int = 0):
	type = _type
	rune = _rune
	image_id = _image_id
	gem_kind = false
	charming = 0
	sharp = 0
	wild_sp.hide()
	gem_kind_sp.show()
	update(null)

func update(g : Gem):
	if g:
		type = g.type
		rune = g.rune
		image_id = g.image_id
		gem_kind = (g.category == "Gem")
		for enchant in Buff.find_all_typed(g, Buff.Type.Enchant):
			var enchant_type = enchant.data["type"]
			if enchant_type == "w_enchant_charming":
				charming += 1
			elif enchant_type == "w_enchant_sharp":
				sharp += 1
	
	if gem_kind_sp:
		gem_kind_sp.frame = type - Gem.ColorFirst + 1
		gem_kind_sp.material.set_shader_parameter("type_color", Gem.type_color(type))
		
		if image_id > 0:
			if gem_kind:
				gem_kind_sp.frame = image_id
				special_sp.frame = 0
			else:
				gem_kind_sp.hide()
				special_sp.frame = image_id
		else:
			if type == Gem.ColorWild:
				gem_kind_sp.hide()
				wild_sp.show()
				rune_sp.modulate = Color(0.0, 0.0, 0.0, 0.66)
			else:
				gem_kind_sp.show()
				wild_sp.hide()
				rune_sp.modulate = Color(0.0, 0.0, 0.0, 0.66)
			special_sp.frame = 0
		rune_sp.frame = rune - Gem.RuneFirst + 1
		
		if charming > 0:
			charming_fx.show()
		else:
			charming_fx.hide()
		if sharp > 0:
			sharp_fx.show()
		else:
			sharp_fx.hide()

func dissolve(duration : float):
	var tween = App.game_tweens.create_tween()
	tween.tween_property(display.material, "shader_parameter/dissolve", 0.0, duration)
	tween.tween_callback(func():
		self.hide()
	)

func break_into_pieces():
	if pieces_tweens.is_empty():
		if image_id == 0:
			gem_kind_sp.hide()
			var tex = Gem.gem_frames.get_frame_texture("default", type - Gem.ColorFirst + 1)
			pieces_root.z_index = 0
			pieces_tweens = SEffect.add_break_pieces(Vector2(C.BOARD_TILE_SZ, C.BOARD_TILE_SZ) * 0.5, Vector2(C.BOARD_TILE_SZ, C.BOARD_TILE_SZ), tex, pieces_root, 0.5 * App.speed)
			for t in pieces_tweens:
				t.custom_step(0.005 * App.speed)
				t.pause()

func move_pieces():
	pieces_root.z_index = 3
	for t in pieces_tweens:
		t.play()
	pieces_tweens.clear()

func _ready() -> void:
	self.custom_minimum_size = Vector2(C.SPRITE_SZ, C.SPRITE_SZ)
	self.pivot_offset = Vector2(C.SPRITE_SZ, C.SPRITE_SZ) * 0.5
	sub_viewport.size = Vector2(C.SPRITE_SZ, C.SPRITE_SZ)
	
	update(null)

func _process(delta: float) -> void:
	gem_kind_sp.material.set_shader_parameter("offset", Vector2(0.01, 0.01) * global_position)
