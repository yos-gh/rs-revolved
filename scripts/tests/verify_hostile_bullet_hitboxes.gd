extends SceneTree

const BulletManagerUtil := preload("res://scripts/game/bullet_manager.gd")


func _init() -> void:
	assert(is_equal_approx(BulletManagerUtil.BULLET0_VISUAL_SCALE, 0.68))
	var manager := BulletManagerUtil.new()
	root.add_child(manager)
	manager.setup({
		"boss_unblockable": Color(1.0, 0.12, 0.52),
		"zako3p": Color(1.0, 0.66, 0.12),
	})

	manager.spawn_hostile_bullet(Vector2.ZERO, 0.0, BulletManagerUtil.BULLET0_SPEED, true, "circle")
	manager.flush_visual_batches()
	var bullet0: Dictionary = manager.bullets[-1]
	assert(bullet0.node == null)
	assert(bullet0.batched_visual)
	var bullet0_batch := manager.get_node("BatchedBulletVisuals/bullet0_outer-batch") as MultiMeshInstance3D
	assert(bullet0_batch != null)
	assert(bullet0_batch.multimesh.instance_count == 1)
	assert(float(bullet0.radius) <= _convex_mesh_inradius(bullet0_batch.multimesh.mesh, Vector3.ONE * BulletManagerUtil.BULLET0_VISUAL_SCALE) + 0.0001)

	manager.spawn_hostile_bullet(Vector2.ZERO, 0.0, BulletManagerUtil.BULLET1_SPEED, true, "capsule")
	manager.flush_visual_batches()
	_assert_capsule_inside_visual(manager.bullets[-1])

	manager.spawn_hostile_bullet(Vector2.ZERO, 0.0, BulletManagerUtil.BULLET2_SPEED, true, "capsule")
	manager.flush_visual_batches()
	_assert_capsule_inside_visual(manager.bullets[-1])

	manager.spawn_hostile_bullet(Vector2.ZERO, 0.0, 0.0, true, "line", 2.0, BulletManagerUtil.ZAKO_LINE_BULLET_LENGTH)
	manager.flush_visual_batches()
	_assert_capsule_inside_visual(manager.bullets[-1])

	manager.spawn_hostile_bullet(Vector2.ZERO, 0.0, BulletManagerUtil.BOSS_B1_SPEED, false, "line", 4.0)
	manager.flush_visual_batches()
	_assert_capsule_inside_visual(manager.bullets[-1])

	manager.spawn_hostile_bullet(Vector2.ZERO, 0.0, BulletManagerUtil.BOSS_B2_SPEED, true, "boss_b2")
	manager.flush_visual_batches()
	var boss_b2: Dictionary = manager.bullets[-1]
	var wedge := (boss_b2.node as Node3D).find_child("boss-b2-homing-wedge", true, false) as Node3D
	var wedge_face := wedge.get_child(0) as MeshInstance3D
	assert(float(boss_b2.radius) <= _triangle_mesh_inradius(wedge_face) + 0.0001)

	manager.queue_free()
	await process_frame
	await process_frame
	print("hostile bullet hitbox verification passed")
	quit()


func _assert_capsule_inside_visual(bullet: Dictionary) -> void:
	var radius: float = bullet.radius
	var collision_length: float = bullet.length
	var visual_length: float = bullet.visual_length
	var visual_half_width: float = bullet.visual_half_width
	assert(radius <= visual_half_width + 0.0001)
	assert(collision_length + radius * 2.0 <= visual_length + 0.0001)


func _convex_mesh_inradius(mesh: Mesh, visual_scale: Vector3) -> float:
	var vertices := mesh.surface_get_arrays(0)[Mesh.ARRAY_VERTEX] as PackedVector3Array
	var minimum := INF
	for index in range(1, vertices.size()):
		var next_index := index + 1 if index + 1 < vertices.size() else 1
		var a := Vector2(vertices[index].x * visual_scale.x, vertices[index].z * visual_scale.z)
		var b := Vector2(vertices[next_index].x * visual_scale.x, vertices[next_index].z * visual_scale.z)
		minimum = minf(minimum, _distance_to_segment(Vector2.ZERO, a, b))
	return minimum


func _triangle_mesh_inradius(mesh_instance: MeshInstance3D) -> float:
	var vertices := mesh_instance.mesh.surface_get_arrays(0)[Mesh.ARRAY_VERTEX] as PackedVector3Array
	var minimum := INF
	for index in range(3):
		var a := Vector2(vertices[index].x, vertices[index].z)
		var b := Vector2(vertices[(index + 1) % 3].x, vertices[(index + 1) % 3].z)
		minimum = minf(minimum, _distance_to_segment(Vector2.ZERO, a, b))
	return minimum


func _distance_to_segment(point: Vector2, a: Vector2, b: Vector2) -> float:
	var segment := b - a
	if segment.length_squared() <= 0.000001:
		return point.distance_to(a)
	var t := clampf((point - a).dot(segment) / segment.length_squared(), 0.0, 1.0)
	return point.distance_to(a + segment * t)
