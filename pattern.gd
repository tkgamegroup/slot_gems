extends Object

class_name Pattern

var coords : Array[Vector3i]
var mult : int = 1

func search(board : Board, off : Vector2i):
	if coords.size() < 2:
		return
	var res = []
	var base_c = board.offset_to_cube(off)
	var first_v = board.get_gem_at(board.cube_to_offset(base_c + coords[0]))
	if first_v == 0:
		return res
	var all_same = true
	for i in range(1, coords.size()):
		if board.get_gem_at(board.cube_to_offset(base_c + coords[i])) != first_v:
			all_same = false
			break
	if all_same:
		for c in coords:
			res.append(board.cube_to_offset(base_c + c))
	return res
