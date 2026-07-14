extends SceneTree

const BulletManagerUtil := preload("res://scripts/game/bullet_manager.gd")


func _init() -> void:
	var manager := BulletManagerUtil.new()
	root.add_child(manager)
	var shot_color := Color(0.80, 0.95, 1.0)
	manager.setup({"shot": shot_color})
	manager.spawn_player_shot(Vector2.ZERO, 0.25)

	assert(manager.bullets.size() == 1)
	var shot: Dictionary = manager.bullets[0]
	assert(not shot.hostile)
	assert(shot.shape == "capsule")
	assert(is_equal_approx(shot.radius, BulletManagerUtil.PLAYER_SHOT_RADIUS))
	assert(is_equal_approx(shot.length, BulletManagerUtil.PLAYER_SHOT_LENGTH))
	assert(is_equal_approx(shot.vel.length(), BulletManagerUtil.SHOT_SPEED))

	var shot_node: Node3D = shot.node
	var wire := shot_node.find_child("player-shot-wireframe", true, false) as Node3D
	assert(wire != null)
	assert(wire.get_child_count() == 13)
	assert(_count_cylinder_meshes(wire) == 0)
	assert(_count_box_meshes(wire) == 12)
	assert(_count_array_meshes(wire) == 1)
	assert(is_equal_approx(wire.rotation.z, deg_to_rad(28.0)))

	var face := wire.get_child(0) as MeshInstance3D
	assert(face != null)
	assert(face.mesh is ArrayMesh)
	var face_material := face.material_override as ShaderMaterial
	assert(face_material != null)
	var face_color := face_material.get_shader_parameter("face_color") as Color
	assert(face_color.a < 0.30)
	assert(float(face_material.get_shader_parameter("emission_strength")) >= 1.10)

	manager.queue_free()
	await process_frame
	await process_frame
	print("player shot visual verification passed")
	quit()


func _count_box_meshes(node: Node) -> int:
	var count := 0
	var mesh_instance := node as MeshInstance3D
	if mesh_instance != null and mesh_instance.mesh is BoxMesh:
		count += 1
	for child in node.get_children():
		count += _count_box_meshes(child)
	return count


func _count_cylinder_meshes(node: Node) -> int:
	var count := 0
	var mesh_instance := node as MeshInstance3D
	if mesh_instance != null and mesh_instance.mesh is CylinderMesh:
		count += 1
	for child in node.get_children():
		count += _count_cylinder_meshes(child)
	return count


func _count_array_meshes(node: Node) -> int:
	var count := 0
	var mesh_instance := node as MeshInstance3D
	if mesh_instance != null and mesh_instance.mesh is ArrayMesh:
		count += 1
	for child in node.get_children():
		count += _count_array_meshes(child)
	return count
