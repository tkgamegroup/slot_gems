extends Node

const explosion_frames : SpriteFrames = preload("res://images/explosion.tres")
const big_explosion_frames : SpriteFrames = preload("res://images/big_explosion.tres")
const black_hole_rotating_frames : SpriteFrames = preload("res://images/black_hole_rotating.tres")
const white_hole_injection_frames : SpriteFrames = preload("res://images/white_hole_injection.tres")
const slash_frames : SpriteFrames = preload("res://images/slash.tres")
const splash_pb = preload("res://splash.tscn")
const fireball_image : Texture = preload("res://images/fireball.png")
const distortion = preload("res://fx_distortion.tscn")
const lightning = preload("res://fx_lightning.tscn")
const leading_line_pb = preload("res://leading_line.tscn")

func add_leading_line(p0 : Vector2, p1 : Vector2, duration : float = 0.3, width = 8.0):
	var l = SEffect.leading_line_pb.instantiate()
	l.setup(p0, p1, 0.3, duration, width)
	l.z_index = 3
	Board.ui.overlay.add_child(l)

func add_explosion(pos : Vector2, size : Vector2, z_index : int, duration : float):
	var sp = AnimatedSprite2D.new()
	sp.position = pos
	sp.sprite_frames = explosion_frames
	sp.speed_scale = 0.5 / duration
	sp.scale = size / 32.0
	sp.play("default")
	sp.z_index = z_index
	var tween = App.game_tweens.create_tween()
	tween.tween_interval(duration)
	tween.tween_callback(sp.queue_free)
	SSound.se_explode.play()
	App.screen_shake_strength = 18.0 * sp.scale.x
	return sp
	
func add_big_explosion(pos : Vector2, size : Vector2, z_index : int, duration : float):
	var sp = AnimatedSprite2D.new()
	sp.position = pos
	sp.sprite_frames = big_explosion_frames
	sp.speed_scale = 0.5 / duration
	sp.scale = size / 64.0
	sp.play("default")
	sp.z_index = z_index
	var tween = App.game_tweens.create_tween()
	tween.tween_interval(duration)
	tween.tween_callback(sp.queue_free)
	SSound.se_explode.play()
	return sp

func add_distortion(pos : Vector2, size : Vector2, z_index : int, duration : float):
	var fx = distortion.instantiate()
	fx.position = pos
	fx.scale = size * 2.0
	fx.z_index = z_index
	Board.ui.overlay.add_child(fx)
	var tween = App.game_tweens.create_tween()
	tween.tween_property(fx.material, "shader_parameter/radius", 0.5, duration).from(0.0).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_callback(fx.queue_free)
	return fx

func add_slash(p0 : Vector2, p1 : Vector2, z_index : int, duration : float):
	var pos = (p0 + p1) / 2.0
	var sp = AnimatedSprite2D.new()
	sp.position = pos
	sp.sprite_frames = slash_frames
	sp.speed_scale = 0.25 / duration
	sp.rotation = (p1 - p0).angle()
	sp.play("default")
	sp.z_index = z_index
	var tween = App.game_tweens.create_tween()
	tween.tween_interval(duration)
	tween.tween_callback(sp.queue_free)
	return sp

func add_splash(p0 : Vector2, p1 : Vector2, color : Color, z_index : int, duration : float):
	var sp : CPUParticles2D = splash_pb.instantiate()
	sp.position = p0
	sp.rotation = (p1 - p0).angle() - PI * 0.5
	sp.modulate = color
	sp.lifetime = duration
	sp.emitting = true
	sp.z_index = z_index
	var tween = App.game_tweens.create_tween()
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
	var tween = App.game_tweens.create_tween()
	tween.tween_interval(duration)
	tween.tween_callback(fx.queue_free)
	SSound.se_lightning_connect.play()
	return fx

func add_break_pieces(pos : Vector2, size : Vector2, texture : Texture, parent, num_extra_points : int = 8):
	var points = []
	points.append(Vector2(0, 0))
	points.append(Vector2(size.x, 0))
	points.append(Vector2(size.x, size.y))
	points.append(Vector2(0, size.y))
	for i in num_extra_points:
		points.append(Vector2(randf() * size.x, randf() * size.y))
	var indices = Geometry2D.triangulate_delaunay(points)
	for i in range(0, indices.size(), 3):
		var poly = Polygon2D.new()
		var verts = []
		var uvs = []
		var c = Vector2(0.0, 0.0)
		for j in 3:
			var v = points[indices[i + j]]
			verts.append(v - size * 0.5)
			uvs.append(v)
			c += v
		c /= 3.0
		var d = c - size * 0.5
		if abs(d.x) + abs(d.y) < 0.5:
			d = Vector2(1.0, 0.0)
		d = d.normalized()
		poly.polygon = verts
		poly.uv = uvs
		poly.texture = texture
		parent.add_child(poly)
		poly.position = pos
		var tween = App.game_tweens.create_tween()
		tween.tween_property(poly, "position", pos + d * 105.0 + Vector2(randf_range(-20.0, +20.0), 50.0), 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
		tween.parallel().tween_property(poly, "scale", Vector2(0.0, 0.0), 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		tween.tween_callback(poly.queue_free)

func add_black_hole_rotating(pos : Vector2, size : Vector2, z_index : int, duration : float):
	var sp = AnimatedSprite2D.new()
	sp.position = pos
	sp.sprite_frames = black_hole_rotating_frames
	sp.scale = size / 64.0
	sp.play("default")
	sp.z_index = z_index
	var tween = App.game_tweens.create_tween()
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
	var tween = App.game_tweens.create_tween()
	tween.tween_interval(duration - 0.5)
	tween.tween_property(sp, "scale", Vector2(0, 0), 0.5)
	tween.tween_callback(sp.queue_free)
	return sp
