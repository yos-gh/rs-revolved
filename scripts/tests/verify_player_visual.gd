extends SceneTree

const PlayerUtil := preload("res://scripts/game/player.gd")


func _init() -> void:
	var player := PlayerUtil.new()
	root.add_child(player)
	player.setup({
		"player": Color(0.2, 0.9, 0.78),
		"player_core": Color(1.0, 0.86, 0.35),
	})
	assert(is_equal_approx(PlayerUtil.VISUAL_MAX_BANK, deg_to_rad(40.0)))
	assert(is_equal_approx(PlayerUtil.VISUAL_MAX_PITCH, deg_to_rad(24.0)))

	var model := player.find_child("player-armored-pods", true, false) as Node3D
	assert(model != null)
	assert(player.visual_model == model)
	assert(model.get_child_count() == 82)
	assert(_count_box_meshes(model) == 75)
	assert(_count_sphere_meshes(model) == 1)
	assert(_count_array_meshes(model) == 6)
	assert(_count_translucent_faces(model) == 6)
	assert(_count_shader_edges(model) == 75)

	var yellow_edges := 0
	for child in model.get_children():
		var mesh_instance := child as MeshInstance3D
		if mesh_instance == null:
			continue
		var box := mesh_instance.mesh as BoxMesh
		if box == null:
			continue
		var mat := mesh_instance.material_override as ShaderMaterial
		if mat == null:
			continue
		var line_color := mat.get_shader_parameter("line_color") as Color
		if line_color.r > 0.90 and line_color.g > 0.70 and line_color.b < 0.50 and mesh_instance.position.z > 0.20:
			yellow_edges += 1
			assert(absf(mesh_instance.position.x) > 0.20)
	assert(yellow_edges == 2)
	assert(player.find_child("HitAxisPreview", true, false) != null)
	var hit_preview := player.find_child("HitAxisPreview", true, false) as Node3D
	player.angle = 0.0
	player._sync_visual()
	player._update_visual_motion(Vector2(0.0, 1.0), 0.8, 0.12)
	assert(absf(model.rotation.x) > 0.01 or absf(model.rotation.z) > 0.01)
	assert(is_zero_approx(player.rotation.x))
	assert(is_zero_approx(player.rotation.z))
	assert(is_zero_approx(hit_preview.rotation.x))
	assert(is_zero_approx(hit_preview.rotation.z))
	for recovery_step in range(60):
		player._update_visual_motion(Vector2.ZERO, 0.0, 0.016)
	assert(absf(model.rotation.x) < 0.001)
	assert(absf(model.rotation.z) < 0.001)

	player.queue_free()
	await process_frame
	await process_frame
	print("player visual verification passed")
	quit()


func _count_box_meshes(node: Node) -> int:
	var count := 0
	var mesh_instance := node as MeshInstance3D
	if mesh_instance != null and mesh_instance.mesh is BoxMesh:
		count += 1
	for child in node.get_children():
		count += _count_box_meshes(child)
	return count


func _count_sphere_meshes(node: Node) -> int:
	var count := 0
	var mesh_instance := node as MeshInstance3D
	if mesh_instance != null and mesh_instance.mesh is SphereMesh:
		count += 1
	for child in node.get_children():
		count += _count_sphere_meshes(child)
	return count


func _count_array_meshes(node: Node) -> int:
	var count := 0
	var mesh_instance := node as MeshInstance3D
	if mesh_instance != null and mesh_instance.mesh is ArrayMesh:
		count += 1
	for child in node.get_children():
		count += _count_array_meshes(child)
	return count


func _count_translucent_faces(node: Node) -> int:
	var count := 0
	var mesh_instance := node as MeshInstance3D
	if mesh_instance != null and mesh_instance.mesh is ArrayMesh:
		var mat := mesh_instance.material_override as ShaderMaterial
		if mat != null:
			var face_color := mat.get_shader_parameter("face_color") as Color
			if face_color.a < 0.20:
				count += 1
	for child in node.get_children():
		count += _count_translucent_faces(child)
	return count


func _count_shader_edges(node: Node) -> int:
	var count := 0
	var mesh_instance := node as MeshInstance3D
	if mesh_instance != null and mesh_instance.mesh is BoxMesh:
		var mat := mesh_instance.material_override as ShaderMaterial
		if mat != null:
			count += 1
	for child in node.get_children():
		count += _count_shader_edges(child)
	return count
