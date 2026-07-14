extends SceneTree

const BulletManagerUtil := preload("res://scripts/game/bullet_manager.gd")


func _init() -> void:
	var manager := BulletManagerUtil.new()
	root.add_child(manager)
	manager.setup({})

	manager.spawn_hostile_bullet(Vector2.ZERO, 0.0, 0.0, true, "line", 2.0, BulletManagerUtil.ZAKO_LINE_BULLET_LENGTH)
	manager.flush_visual_batches()
	assert(manager.bullets.size() == 1)
	assert(manager.bullets[0].node == null)
	assert(manager.bullets[0].visual_key == "bullet3")
	assert(manager.bullets[0].batched_visual)
	var bullet3_batch := manager.get_node("BatchedBulletVisuals/bullet3_outer-batch") as MultiMeshInstance3D
	assert(bullet3_batch != null)
	assert(bullet3_batch.multimesh.instance_count == 1)
	assert(is_equal_approx(manager.bullets[0].visual_length, BulletManagerUtil.ZAKO_LINE_BULLET_LENGTH))
	assert(is_equal_approx(manager.bullets[0].length + manager.bullets[0].radius * 2.0, BulletManagerUtil.ZAKO_LINE_BULLET_LENGTH))
	manager.spawn_hostile_bullet(Vector2(0.3, 0.0), PI * 0.5, 0.0, true, "line", 2.0, BulletManagerUtil.ZAKO_LINE_BULLET_LENGTH)
	manager.flush_visual_batches()
	assert(bullet3_batch.multimesh.instance_count == 2)
	for angle in [0.0, PI * 0.25, PI * 0.5]:
		var root_basis := Basis(Vector3.UP, manager._visual_rotation_for_bullet(angle, ""))
		var scaled_basis := manager._basis_with_local_scale(root_basis, Vector3(1.0, 1.0, BulletManagerUtil.ZAKO_LINE_BULLET_LENGTH))
		assert(is_equal_approx(scaled_basis.x.length(), 1.0))
		assert(is_equal_approx(scaled_basis.z.length(), BulletManagerUtil.ZAKO_LINE_BULLET_LENGTH))
	assert(is_equal_approx(BulletManagerUtil.HOSTILE_BULLET_RADIUS, 0.09))
	assert(is_equal_approx(BulletManagerUtil.BULLET0_VISUAL_SCALE, 0.68))
	manager.spawn_hostile_bullet(Vector2.ZERO, 0.0)
	manager.flush_visual_batches()
	assert(manager.bullets[2].node == null)
	assert(manager.bullets[2].visual_key == "bullet0")
	assert(manager.bullets[2].batched_visual)
	var bullet0_batch := manager.get_node("BatchedBulletVisuals/bullet0_outer-batch") as MultiMeshInstance3D
	assert(bullet0_batch != null)
	assert(bullet0_batch.multimesh.instance_count == 1)

	manager.spawn_hostile_bullet(Vector2.ZERO, 0.0, 0.0, false, "line", 2.0)
	manager.flush_visual_batches()
	assert(manager.bullets.size() == 4)
	var boss_line: Node3D = manager.bullets[3].node
	assert(is_equal_approx(BulletManagerUtil.BOSS_B1_BASE_SCALE, 1.35))
	assert(is_equal_approx(BulletManagerUtil.BOSS_B1_CORE_SCALE, 1.30))
	assert(is_equal_approx(BulletManagerUtil.BOSS_B1_INITIAL_SCALE, 1.35 * 1.30))
	assert(boss_line.find_child("bullet3-low-rail", true, false) == null)
	assert(boss_line.find_child("boss-b1-line-burst", true, false) == null)
	var boss_b1_model := boss_line.find_child("boss-b1-additive-rect", true, false) as Node3D
	assert(boss_b1_model != null)
	var boss_b1_face := boss_b1_model.get_child(0) as MeshInstance3D
	assert(boss_b1_face != null)
	var boss_b1_aabb := boss_b1_face.mesh.get_aabb()
	assert(boss_b1_aabb.size.x >= 0.129)
	assert(boss_b1_aabb.size.x > BulletManagerUtil.PLAYER_SHOT_RADIUS * 1.7)
	var face_material := boss_b1_face.material_override as ShaderMaterial
	assert(face_material != null)
	var face_color: Color = face_material.get_shader_parameter("face_color")
	assert(face_color.r > 0.70 and face_color.g > 0.90 and face_color.b > 0.95)
	assert(float(face_material.get_shader_parameter("emission_strength")) >= 1.30)
	var boss_b1_edge := boss_b1_model.get_child(1) as MeshInstance3D
	assert(boss_b1_edge != null)
	var edge_mesh := boss_b1_edge.mesh as BoxMesh
	assert(edge_mesh != null)
	assert(is_equal_approx(edge_mesh.size.x, 0.009 * BulletManagerUtil.BOSS_B1_CORE_SCALE))
	var edge_material := boss_b1_edge.material_override as ShaderMaterial
	assert(edge_material != null)
	var edge_color: Color = edge_material.get_shader_parameter("line_color")
	assert(edge_color.r < face_color.r and edge_color.g < face_color.g)
	var boss_b1_glow := boss_b1_model.find_child("boss-b1-soft-glow", true, false) as MeshInstance3D
	assert(boss_b1_glow != null)
	assert(boss_b1_glow.mesh.get_aabb().size.x > boss_b1_aabb.size.x)
	assert(_count_sphere_meshes(boss_line) == 0)
	assert(is_equal_approx(manager.bullets[3].visual_length, BulletManagerUtil.BOSS_B1_INITIAL_LENGTH))
	assert(is_equal_approx(manager.bullets[3].length, BulletManagerUtil.BOSS_B1_COLLISION_LENGTH))
	assert(is_equal_approx(manager.bullets[3].radius, BulletManagerUtil.BOSS_B1_COLLISION_RADIUS))
	assert(manager.bullets[3].radius <= BulletManagerUtil.BOSS_B1_VISUAL_HALF_WIDTH)
	assert(is_equal_approx(manager.bullets[3].length + manager.bullets[3].radius * 2.0, manager.bullets[3].visual_length))
	var initial_radius: float = manager.bullets[3].radius
	var initial_length: float = manager.bullets[3].length
	manager.update_bullets(1.0, 16.0, 9.0, 2.0, false, [Vector2.ZERO, Vector2.ZERO], [])
	assert(manager.bullets[3].radius > initial_radius)
	assert(manager.bullets[3].length > initial_length)
	assert(is_equal_approx(manager.bullets[3].radius, initial_radius * 1.50))
	assert(is_equal_approx(manager.bullets[3].length, initial_length * 1.50))
	assert(is_equal_approx(manager.bullets[3].length + manager.bullets[3].radius * 2.0, manager.bullets[3].visual_length))
	assert(boss_b1_model.scale.is_equal_approx(Vector3.ONE * 1.50))

	boss_line = null
	manager.queue_free()
	await process_frame
	await process_frame
	print("bullet3 visual verification passed")
	quit()


func _count_sphere_meshes(node: Node) -> int:
	var count := 0
	var mesh_instance := node as MeshInstance3D
	if mesh_instance != null and mesh_instance.mesh is SphereMesh:
		count += 1
	for child in node.get_children():
		count += _count_sphere_meshes(child)
	return count
