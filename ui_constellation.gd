extends Control

var points : Array[Vector3i]
var lines : Array[Pair]

const dash : float = 0.2
const gap : float = 0.2

func setup(_name : String):
	var content = Painting.load_from_file(_name)
	var whites = content.colors.get(Gem.ColorWhite, [])
	for p in whites:
		points.append(p)
	for l in content.lines:
		lines.append(Pair.new(l[0], l[1]))

func _draw() -> void:
	var center = Board.offset_to_cube(Vector2i(Board.cx / 2, Board.cy / 2))
	var radius = C.SPRITE_SZ * 0.5
	for p in points:
		var pos = Board.get_pos(Board.cube_to_offset(center + p))
		var a = 0.0
		while a < TAU:
			draw_arc(pos, radius, a, a + dash, 16, Color.WHITE, 6.0)
			a += dash + gap
	for l in lines:
		var pos0 = Board.get_pos(Board.cube_to_offset(center + l.first))
		var pos1 = Board.get_pos(Board.cube_to_offset(center + l.second))
		var ra = radius / pos0.distance_to(pos1)
		draw_dashed_line(lerp(pos0, pos1, ra), lerp(pos1, pos0, ra), Color.WHITE, 6.0, 12.0)
