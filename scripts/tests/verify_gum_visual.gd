extends SceneTree

const GumControllerUtil := preload("res://scripts/game/gum_controller.gd")


func _init() -> void:
	var gum := GumControllerUtil.new()
	root.add_child(gum)
	gum.setup({
		"gum": Color(0.96, 0.42, 0.78),
		"gum_low": Color(0.35, 0.42, 0.58),
		"gum_empty": Color(1.0, 0.22, 0.16),
	})

	assert(gum.get_child_count() == 3)
	for orb in gum.get_children():
		assert(orb.name.begins_with("GumOrb"))
		assert(orb.find_child("gum-layer-outer", true, false) != null)
		assert(orb.find_child("gum-layer-inner", true, false) != null)
		assert(orb.find_child("gum-layer-core", true, false) != null)
		assert(orb.find_child("GumRotatingFrame", true, false) != null)
		assert(orb.find_child("gum-shell-ring-primary", true, false) != null)
		assert(orb.find_child("gum-shell-ring-secondary", true, false) != null)
		assert(orb.find_child("gum-outer-outline", true, false) != null)
		assert(_count_sphere_meshes(orb) == 3)
		assert(_count_torus_meshes(orb) == 3)
		assert(_count_box_meshes(orb) == 4)
		assert(_count_array_meshes(orb) == 0)

	var outer := gum.get_child(0).find_child("gum-layer-outer", true, false) as MeshInstance3D
	var outer_mesh := outer.mesh as SphereMesh
	assert(outer_mesh != null)
	assert(is_equal_approx(outer_mesh.radius, 0.29))
	var primary_ring := gum.get_child(0).find_child("gum-shell-ring-primary", true, false) as MeshInstance3D
	var primary_ring_mesh := primary_ring.mesh as TorusMesh
	assert(primary_ring_mesh != null)
	assert(is_equal_approx(primary_ring_mesh.outer_radius, 0.34))
	var normal_material := outer.material_override as StandardMaterial3D
	assert(normal_material != null)
	assert(normal_material.transparency == BaseMaterial3D.TRANSPARENCY_ALPHA)
	assert(normal_material.albedo_color.a < 0.30)
	assert(normal_material.emission_energy_multiplier > 1.0)
	var core := gum.get_child(0).find_child("gum-layer-core", true, false) as MeshInstance3D
	var core_mesh := core.mesh as SphereMesh
	assert(core_mesh != null)
	assert(is_equal_approx(core_mesh.radius, 0.12))
	var core_material := core.material_override as StandardMaterial3D
	assert(core_material != null)
	assert(core_material.albedo_color.a > 0.60)
	assert(core_material.emission_energy_multiplier >= 1.8)
	var rotating_frame := gum.get_child(0).find_child("GumRotatingFrame", true, false) as Node3D
	assert(rotating_frame != null)
	var rotation_before := rotating_frame.rotation
	gum._update_rotating_visuals(0.10)
	assert(not rotating_frame.rotation.is_equal_approx(rotation_before))

	gum._update_visuals(true)
	var low_material := outer.material_override as StandardMaterial3D
	assert(low_material != null)
	assert(low_material.albedo_color.b > low_material.albedo_color.r)
	assert(low_material.emission_energy_multiplier < normal_material.emission_energy_multiplier)

	gum._spawn_trail(Vector2.ZERO, false)
	var trail := root.find_child("GumTrail", true, false) as Node3D
	assert(trail != null)
	assert(trail.get_child_count() == 2)
	assert(_count_box_meshes(trail) == 0)
	assert(_count_torus_meshes(trail) == 0)
	assert(_count_array_meshes(trail) == 2)
	var trail_face := trail.get_child(0) as MeshInstance3D
	var trail_material := trail_face.material_override as StandardMaterial3D
	assert(trail_material != null)
	assert(trail_material.albedo_color.a < 0.40)
	assert(trail_material.emission_energy_multiplier <= 0.75)
	root.remove_child(trail)
	trail.free()

	gum._spawn_trail(Vector2.ZERO, true)
	var low_trail := root.find_child("GumTrail", true, false) as Node3D
	assert(low_trail != null)
	var low_trail_face := low_trail.get_child(0) as MeshInstance3D
	var low_trail_material := low_trail_face.material_override as StandardMaterial3D
	assert(low_trail_material != null)
	assert(low_trail_material.albedo_color.g > 0.20)
	assert(low_trail_material.albedo_color.b > 0.14)

	assert(is_equal_approx(GumControllerUtil.BULLET_RADIUS, 0.32))
	gum.state = 1
	var orb := gum.get_child(0)
	orb.position = Vector3.ZERO
	var bullet := {
		"hostile": true,
		"gum_blockable": true,
		"life": 1.0,
	}
	var shape := func(_bullet: Dictionary) -> Dictionary:
		return {
			"type": "circle",
			"pos": Vector2(0.40, 0.0),
			"radius": 0.09,
		}
	assert(gum._catches_bullet(0, bullet, shape))

	var emitted_directions: Array[Vector2] = []
	gum.hit_effect_requested.connect(func(_pos: Vector2, _color: Color, direction: Vector2) -> void:
		emitted_directions.append(direction)
	)
	var hit_enemy := {
		"pos": Vector2.ZERO,
		"radius": 0.20,
		"life": 3,
		"damageable": true,
		"gum_vulnerable": true,
	}
	assert(gum._hit_enemies_at([hit_enemy], Vector2.ZERO, 0.42, 1, Vector2.DOWN))
	assert(emitted_directions.size() == 1)
	assert(emitted_directions[0].is_equal_approx(Vector2.DOWN))

	gum.queue_free()
	await process_frame
	await process_frame
	print("gum visual verification passed")
	quit()


func _count_sphere_meshes(node: Node) -> int:
	var count := 0
	var mesh_instance := node as MeshInstance3D
	if mesh_instance != null and mesh_instance.mesh is SphereMesh:
		count += 1
	for child in node.get_children():
		count += _count_sphere_meshes(child)
	return count


func _count_torus_meshes(node: Node) -> int:
	var count := 0
	var mesh_instance := node as MeshInstance3D
	if mesh_instance != null and mesh_instance.mesh is TorusMesh:
		count += 1
	for child in node.get_children():
		count += _count_torus_meshes(child)
	return count


func _count_box_meshes(node: Node) -> int:
	var count := 0
	var mesh_instance := node as MeshInstance3D
	if mesh_instance != null and mesh_instance.mesh is BoxMesh:
		count += 1
	for child in node.get_children():
		count += _count_box_meshes(child)
	return count


func _count_array_meshes(node: Node) -> int:
	var count := 0
	var mesh_instance := node as MeshInstance3D
	if mesh_instance != null and mesh_instance.mesh is ArrayMesh:
		count += 1
	for child in node.get_children():
		count += _count_array_meshes(child)
	return count
