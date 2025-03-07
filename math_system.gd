extends Node

func v3_21(v2 : Vector2, f : float) -> Vector3:
	return Vector3(v2.x, v2.y, f)

func v2_3(v3 : Vector3) -> Vector2:
	return Vector2(v3.x, v3.y)

func tangent2(v : Vector2) -> Vector2:
	return v2_3(v3_21(v, 0.0).cross(Vector3(0.0, 0.0, 1.0)))

func get_shuffled_indices(n : int):
	var ret = []
	for i in n:
		ret.append(i)
	ret.shuffle()
	return ret

func last_one(arr : Array):
	return arr[arr.size() - 1]

func pick_and_remove(arr : Array):
	var idx = randi_range(0, arr.size() - 1)
	var ret = arr[idx]
	arr.remove_at(idx)
	return ret

func pick_n(arr : Array, n : int) -> Array:
	var ret = []
	for i in n:
		ret.append(pick_and_remove(arr))
		if ret.is_empty():
			break
	return ret

func remove_if(arr : Array, cb : Callable):
	var targets = []
	for i in arr:
		if cb.call(i):
			targets.append(i)
	for t in targets:
		arr.erase(t)

func quadratic_bezier(p0: Vector2, p1: Vector2, p2: Vector2, t: float):
	var q0 = p0.lerp(p1, t)
	var q1 = p1.lerp(p2, t)
	var r = q0.lerp(q1, t)
	return r

func cubic_bezier(p0: Vector2, p1: Vector2, p2: Vector2, p3: Vector2, t: float):
	var q0 = p0.lerp(p1, t)
	var q1 = p1.lerp(p2, t)
	var q2 = p2.lerp(p3, t)

	var r0 = q0.lerp(q1, t)
	var r1 = q1.lerp(q2, t)

	var s = r0.lerp(r1, t)
	return s
