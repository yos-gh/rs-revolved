extends SceneTree

const MainUtil := preload("res://scripts/prototype/main.gd")


func _init() -> void:
	var main := MainUtil.new()
	root.add_child(main)
	var reticle := main._mousetarget_reticle_model(Color(1.0, 0.86, 0.35))
	var aim_wrapper := Node3D.new()
	aim_wrapper.add_child(reticle)
	root.add_child(aim_wrapper)

	assert(reticle.name == "mousetarget-reticle-model")
	assert(reticle.get_child_count() == 13)
	assert(_count_box_meshes(reticle) == 19)
	assert(_count_torus_meshes(reticle) == 0)
	var sweep := reticle.find_child("mousetarget-visibility-sweep", true, false) as Node3D
	assert(sweep != null)
	assert(sweep.get_child_count() == 3)
	assert(_count_corner_markers(reticle) == 4)
	for child in reticle.get_children():
		var child_node := child as Node
		if child_node == sweep:
			continue
		if child_node is Node3D and child_node.has_meta("sx") and child_node.has_meta("sy"):
			assert(child_node.get_child_count() == 2)
			continue
		var mesh_instance := child_node as MeshInstance3D
		assert(mesh_instance != null)
		var mesh := mesh_instance.mesh as BoxMesh
		assert(mesh != null)
		assert(mesh.size.x <= 0.017)
		assert(mesh.size.z <= 0.23)

	main._apply_mousetarget_reticle_state(aim_wrapper, 1.0)
	var corner := _find_corner_marker(reticle) as Node3D
	assert(corner != null)
	assert(absf(absf(corner.position.x) - 0.22) < 0.001)
	assert(absf(absf(corner.position.z) - 0.22) < 0.001)
	var cross_left := reticle.find_child("mousetarget-crosshair-left", true, false) as MeshInstance3D
	assert(cross_left != null)
	var cross_mesh := cross_left.mesh as BoxMesh
	assert(cross_mesh != null)
	assert(cross_mesh.size.z > 0.33)

	aim_wrapper.queue_free()
	main.queue_free()
	await process_frame
	await process_frame
	print("mousetarget visual verification passed")
	quit()


func _count_box_meshes(node: Node) -> int:
	var count := 0
	var mesh_instance := node as MeshInstance3D
	if mesh_instance != null and mesh_instance.mesh is BoxMesh:
		count += 1
	for child in node.get_children():
		count += _count_box_meshes(child)
	return count


func _count_torus_meshes(node: Node) -> int:
	var count := 0
	var mesh_instance := node as MeshInstance3D
	if mesh_instance != null and mesh_instance.mesh is TorusMesh:
		count += 1
	for child in node.get_children():
		count += _count_torus_meshes(child)
	return count


func _count_corner_markers(node: Node) -> int:
	var count := 0
	if node.has_meta("sx") and node.has_meta("sy"):
		count += 1
	for child in node.get_children():
		count += _count_corner_markers(child)
	return count


func _find_corner_marker(node: Node) -> Node:
	if node.has_meta("sx") and node.has_meta("sy"):
		return node
	for child in node.get_children():
		var found := _find_corner_marker(child)
		if found != null:
			return found
	return null
