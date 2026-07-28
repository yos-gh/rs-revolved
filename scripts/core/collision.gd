class_name Collision
extends RefCounted


static func point_segment_distance(point: Vector2, a: Vector2, b: Vector2) -> float:
	return point.distance_to(closest_point_on_segment(point, a, b))


static func closest_point_on_segment(point: Vector2, a: Vector2, b: Vector2) -> Vector2:
	var ab := b - a
	var length_sq := ab.length_squared()
	if length_sq <= 0.000001:
		return a
	var t := clampf((point - a).dot(ab) / length_sq, 0.0, 1.0)
	return a + ab * t


static func circle_overlaps_circle(a_pos: Vector2, a_radius: float, b_pos: Vector2, b_radius: float) -> bool:
	var radius_sum := a_radius + b_radius
	return a_pos.distance_squared_to(b_pos) <= radius_sum * radius_sum


static func circle_overlaps_capsule(circle_pos: Vector2, circle_radius: float, capsule_a: Vector2, capsule_b: Vector2, capsule_radius: float) -> bool:
	return point_segment_distance(circle_pos, capsule_a, capsule_b) <= circle_radius + capsule_radius


static func capsule_overlaps_circle(capsule_a: Vector2, capsule_b: Vector2, capsule_radius: float, circle_pos: Vector2, circle_radius: float) -> bool:
	return circle_overlaps_capsule(circle_pos, circle_radius, capsule_a, capsule_b, capsule_radius)


static func capsules_overlap(a0: Vector2, a1: Vector2, ar: float, b0: Vector2, b1: Vector2, br: float) -> bool:
	return segment_segment_distance(a0, a1, b0, b1) <= ar + br


static func shape_overlaps_circle(shape: Dictionary, circle_pos: Vector2, circle_radius: float) -> bool:
	if shape.type == "capsule":
		return capsule_overlaps_circle(shape.a, shape.b, shape.radius, circle_pos, circle_radius)
	return circle_overlaps_circle(shape.pos, shape.radius, circle_pos, circle_radius)


static func shapes_for_enemy(enemy: Dictionary) -> Array[Dictionary]:
	var local_parts: Array = enemy.get("collision_parts", [])
	if local_parts.is_empty():
		var fallback: Array[Dictionary] = [{"type": "circle", "pos": enemy.pos, "radius": enemy.radius}]
		return fallback
	var world_parts: Array[Dictionary] = []
	var angle: float = enemy.get("t_body_angle", enemy.get("angle", 0.0))
	for local_part_variant in local_parts:
		var local_part := local_part_variant as Dictionary
		if local_part.type == "capsule":
			world_parts.append({
				"type": "capsule",
				"a": enemy.pos + (local_part.a as Vector2).rotated(angle),
				"b": enemy.pos + (local_part.b as Vector2).rotated(angle),
				"radius": local_part.radius,
			})
		else:
			world_parts.append({
				"type": "circle",
				"pos": enemy.pos + (local_part.get("pos", Vector2.ZERO) as Vector2).rotated(angle),
				"radius": local_part.radius,
			})
	return world_parts


static func shape_overlaps_shape(a: Dictionary, b: Dictionary) -> bool:
	if a.type == "capsule":
		if b.type == "capsule":
			return capsules_overlap(a.a, a.b, a.radius, b.a, b.b, b.radius)
		return capsule_overlaps_circle(a.a, a.b, a.radius, b.pos, b.radius)
	if b.type == "capsule":
		return circle_overlaps_capsule(a.pos, a.radius, b.a, b.b, b.radius)
	return circle_overlaps_circle(a.pos, a.radius, b.pos, b.radius)


static func shape_overlaps_enemy(shape: Dictionary, enemy: Dictionary) -> bool:
	var local_parts: Array = enemy.get("collision_parts", [])
	if local_parts.is_empty():
		return shape_overlaps_circle(shape, enemy.pos, enemy.radius)
	for enemy_shape in shapes_for_enemy(enemy):
		if shape_overlaps_shape(shape, enemy_shape):
			return true
	return false


static func circle_overlaps_enemy(circle_pos: Vector2, circle_radius: float, enemy: Dictionary) -> bool:
	var local_parts: Array = enemy.get("collision_parts", [])
	if local_parts.is_empty():
		return circle_overlaps_circle(circle_pos, circle_radius, enemy.pos, enemy.radius)
	return shape_overlaps_enemy({"type": "circle", "pos": circle_pos, "radius": circle_radius}, enemy)


static func contact_point_on_enemy(shape: Dictionary, enemy: Dictionary, travel_velocity: Vector2) -> Vector2:
	var reference := shape.pos as Vector2 if shape.type == "circle" else ((shape.a as Vector2) + (shape.b as Vector2)) * 0.5
	var local_parts: Array = enemy.get("collision_parts", [])
	if local_parts.is_empty():
		return _surface_point_toward({"type": "circle", "pos": enemy.pos, "radius": enemy.radius}, reference, travel_velocity)
	var best_point: Vector2 = enemy.pos
	var best_distance_sq := INF
	for enemy_shape in shapes_for_enemy(enemy):
		if not shape_overlaps_shape(shape, enemy_shape):
			continue
		var point := _surface_point_toward(enemy_shape, reference, travel_velocity)
		var distance_sq := point.distance_squared_to(reference)
		if distance_sq < best_distance_sq:
			best_distance_sq = distance_sq
			best_point = point
	return best_point


static func _surface_point_toward(shape: Dictionary, point: Vector2, fallback_velocity: Vector2) -> Vector2:
	var axis_point: Vector2
	if shape.type == "capsule":
		axis_point = closest_point_on_segment(point, shape.a, shape.b)
	else:
		axis_point = shape.pos
	var outward := point - axis_point
	if outward.is_zero_approx():
		outward = -fallback_velocity.normalized()
	if outward.is_zero_approx():
		outward = Vector2.RIGHT
	return axis_point + outward.normalized() * float(shape.radius)


static func segment_segment_distance(a0: Vector2, a1: Vector2, b0: Vector2, b1: Vector2) -> float:
	if segments_intersect(a0, a1, b0, b1):
		return 0.0
	return minf(
		minf(point_segment_distance(a0, b0, b1), point_segment_distance(a1, b0, b1)),
		minf(point_segment_distance(b0, a0, a1), point_segment_distance(b1, a0, a1))
	)


static func segments_intersect(a0: Vector2, a1: Vector2, b0: Vector2, b1: Vector2) -> bool:
	var da := a1 - a0
	var db := b1 - b0
	var denom := da.cross(db)
	if absf(denom) <= 0.000001:
		return false
	var rel := b0 - a0
	var t := rel.cross(db) / denom
	var u := rel.cross(da) / denom
	return t >= 0.0 and t <= 1.0 and u >= 0.0 and u <= 1.0
