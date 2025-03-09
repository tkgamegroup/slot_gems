extends Node

const explosion_frames : SpriteFrames = preload("res://images/explosion.tres")
const big_explosion_frames : SpriteFrames = preload("res://images/big_explosion.tres")
const black_hole_rotating_frames : SpriteFrames = preload("res://images/black_hole_rotating.tres")
const white_hole_injection_frames : SpriteFrames = preload("res://images/white_hole_injection.tres")
const slash_frames : SpriteFrames = preload("res://images/slash.tres")
const fireball_image : Texture = preload("res://images/fireball.png")
const distortion = preload("res://fx_distortion.tscn")
const lightning = preload("res://fx_lightning.tscn")
const leading_line_pb = preload("res://leading_line.tscn")

func add_explosion(pos : Vector2, size : Vector2, z_index : int, duration : float):
	var sp = AnimatedSprite2D.new()
	sp.position = pos
	sp.sprite_frames = explosion_frames
	sp.speed_scale = 0.5 / duration
	sp.scale = size / 32.0
	sp.play("default")
	sp.z_index = z_index
	var tween = Game.get_tree().create_tween()
	tween.tween_interval(duration)
	tween.tween_callback(sp.queue_free)
	SSound.sfx_explode.play()
	return sp
	
func add_big_explosion(pos : Vector2, size : Vector2, z_index : int, duration : float):
	var sp = AnimatedSprite2D.new()
	sp.position = pos
	sp.sprite_frames = big_explosion_frames
	sp.speed_scale = 0.5 / duration
	sp.scale = size / 64.0
	sp.play("default")
	sp.z_index = z_index
	var tween = Game.get_tree().create_tween()
	tween.tween_interval(duration)
	tween.tween_callback(sp.queue_free)
	SSound.sfx_explode.play()
	return sp

func add_distortion(pos : Vector2, size : Vector2, z_index : int, duration : float):
	var fx = distortion.instantiate()
	fx.position = pos
	fx.scale = size * 2.0
	fx.z_index = z_index
	var mat : ShaderMaterial = fx.material
	Game.cells_root.add_child(fx)
	var tween = Game.get_tree().create_tween()
	tween.tween_method(func(t):
		mat.set_shader_parameter("radius", t)
	, 0.0, 0.5, duration)
	tween.tween_callback(fx.queue_free)
	return fx

func add_slash(p0 : Vector2, p1 : Vector2, z_index : int, duration : float):
	var pos = (p0 + p1) / 2.0
	var sp = AnimatedSprite2D.new()
	sp.position = pos
	sp.sprite_frames = slash_frames
	sp.speed_scale = 0.5 / duration
	var dist = p0.distance_to(p1)
	sp.scale = Vector2(dist, dist) / 128.0
	sp.rotation = (p1 - p0).angle()
	sp.play("default")
	sp.z_index = z_index
	var tween = Game.get_tree().create_tween()
	tween.tween_interval(duration)
	tween.tween_callback(sp.queue_free)
	return sp

func add_lighning(p0 : Vector2, p1 : Vector2, z_index : int, duration : float):
	var pos = (p0 + p1) / 2.0
	var fx = lightning.instantiate()
	fx.position = pos
	var dist = p0.distance_to(p1)
	fx.scale = Vector2(dist, dist)
	fx.rotation = (p1 - p0).angle() - PI * 0.5
	fx.z_index = z_index
	var tween = Game.get_tree().create_tween()
	tween.tween_interval(duration)
	tween.tween_callback(fx.queue_free)
	SSound.sfx_lightning_connect.play()
	return fx

func add_black_hole_rotating(pos : Vector2, size : Vector2, z_index : int, duration : float):
	var sp = AnimatedSprite2D.new()
	sp.position = pos
	sp.sprite_frames = black_hole_rotating_frames
	sp.scale = size / 64.0
	sp.play("default")
	sp.z_index = z_index
	var tween = Game.get_tree().create_tween()
	tween.tween_interval(duration - 0.5)
	tween.tween_property(sp, "scale", Vector2(0, 0), 0.5)
	tween.tween_callback(sp.queue_free)
	return sp

func add_white_hole_injection(pos : Vector2, size : Vector2, z_index : int, duration : float):
	var sp = AnimatedSprite2D.new()
	sp.position = pos
	sp.sprite_frames = white_hole_injection_frames
	sp.scale = size / 64.0
	sp.play("default")
	sp.z_index = z_index
	var tween = Game.get_tree().create_tween()
	tween.tween_interval(duration - 0.5)
	tween.tween_property(sp, "scale", Vector2(0, 0), 0.5)
	tween.tween_callback(sp.queue_free)
	return sp
