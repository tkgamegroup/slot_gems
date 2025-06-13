extends Object

class_name SMath

static func v3_21(v2 : Vector2, f : float) -> Vector3:
	return Vector3(v2.x, v2.y, f)

static func v2_3(v3 : Vector3) -> Vector2:
	return Vector2(v3.x, v3.y)

static func vert(v : Vector2) -> Vector2:
	return Vector2(-v.y, v.x)

static func component_sort(v3 : Vector3i):
	var arr = []
	for idx in get_shuffled_indices(3):
		match idx:
			0: arr.append({"name":"x","value":v3.x})
			1: arr.append({"name":"y","value":v3.y})
			2: arr.append({"name":"z","value":v3.z})
	if abs(arr[0].value) < abs(arr[1].value):
		var t = arr[0]
		arr[0] = arr[1]
		arr[1] = t
	if abs(arr[1].value) < abs(arr[2].value):
		var t = arr[1]
		arr[1] = arr[2]
		arr[2] = t
	if abs(arr[0].value) < abs(arr[1].value):
		var t = arr[0]
		arr[0] = arr[1]
		arr[1] = t
	return arr

static func tangent2(v : Vector2) -> Vector2:
	return v2_3(v3_21(v, 0.0).cross(Vector3(0.0, 0.0, 1.0)))

static func get_shuffled_indices(n : int):
	var ret = []
	for i in n:
		ret.append(i)
	ret.shuffle()
	return ret

static func find_and_remove(arr : Array, what):
	for i in arr.size():
		if arr[i] == what:
			arr.remove_at(i)
			return true
	return false

static func pick_and_remove(arr : Array):
	var idx = randi_range(0, arr.size() - 1)
	var ret = arr[idx]
	arr.remove_at(idx)
	return ret

static func pick_n(arr : Array, n : int) -> Array:
	var ret = []
	for i in min(n, arr.size()):
		ret.append(pick_and_remove(arr))
		if ret.is_empty():
			break
	return ret

static func remove_if(arr : Array, cb : Callable):
	var targets = []
	for i in range(arr.size() - 1, -1, -1):
		var item = arr[i]
		if cb.call(item):
			targets.append(item)
	for t in targets:
		arr.erase(t)

static func quadratic_bezier(p0: Vector2, p1: Vector2, p2: Vector2, t: float):
	var q0 = p0.lerp(p1, t)
	var q1 = p1.lerp(p2, t)
	var r = q0.lerp(q1, t)
	return r

static func cubic_bezier(p0: Vector2, p1: Vector2, p2: Vector2, p3: Vector2, t: float):
	var q0 = p0.lerp(p1, t)
	var q1 = p1.lerp(p2, t)
	var q2 = p2.lerp(p3, t)

	var r0 = q0.lerp(q1, t)
	var r1 = q1.lerp(q2, t)

	var s = r0.lerp(r1, t)
	return s

static func weld_lines(src : Array, dist : float = 5.0):
	var ret = [src[0], src[1]]
	src.pop_front()
	src.pop_front()
	var ok = false
	while !ok:
		ok = true
		var sp = ret.front()
		var ep = ret.back()
		for i in range(src.size() - 2, -2, -2):
			if src[i + 1].distance_to(sp) < 5.0:
				ret.push_front(src[i])
				src.remove_at(i)
				src.remove_at(i)
			elif src[i].distance_to(sp) < 5.0:
				ret.push_front(src[i + 1])
				src.remove_at(i)
				src.remove_at(i)
			elif src[i].distance_to(ep) < 5.0:
				ret.append(src[i + 1])
				src.remove_at(i)
				src.remove_at(i)
			elif src[i + 1].distance_to(ep) < 5.0:
				ret.append(src[i])
				src.remove_at(i)
				src.remove_at(i)
			else:
				ok = false
	return ret
