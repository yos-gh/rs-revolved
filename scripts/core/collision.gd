class_name Collision
extends RefCounted


static func point_segment_distance(point: Vector2, a: Vector2, b: Vector2) -> float:
	var ab := b - a
	var length_sq := ab.length_squared()
	if length_sq <= 0.000001:
		return point.distance_to(a)
	var t := clampf((point - a).dot(ab) / length_sq, 0.0, 1.0)
	return point.distance_to(a + ab * t)


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
