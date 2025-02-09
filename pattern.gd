extends Object

class_name Pattern

var coords : Array[Vector3i]
var mult : int = 1

func search(board : Board, off : Vector2i) -> Array[Vector2i]:
	var res : Array[Vector2i] = []
	if coords.size() < 2:
		return res
	var base_c = board.offset_to_cube(off)
	var cc = board.cube_to_offset(base_c)
	var first_g = board.get_gem_at(board.cube_to_offset(base_c + coords[0]))
	if !first_g || first_g.active:
		return res
	var first_v = first_g.type
	var all_same = true
	for i in range(1, coords.size()):
		var g = board.get_gem_at(board.cube_to_offset(base_c + coords[i]))
		if !g || g.active || g.type != first_v:
			all_same = false
			break
	if all_same:
		for c in coords:
			res.append(board.cube_to_offset(base_c + c))
	return res
