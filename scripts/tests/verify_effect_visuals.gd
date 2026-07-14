extends SceneTree

const MainUtil := preload("res://scripts/prototype/main.gd")


func _init() -> void:
	var main := MainUtil.new()
	root.add_child(main)

	main._spawn_hit_effect(Vector2.ZERO, Color(0.80, 0.95, 1.0), Vector2.RIGHT)
	var hit := main.find_child("HitEffect", true, false) as Node3D
	assert(hit != null)
	assert(hit.get_child_count() >= 4)
	assert(hit.get_child_count() <= 6)
	assert(_count_box_meshes(hit) == hit.get_child_count())
	assert(_count_torus_meshes(hit) == 0)
	assert(_count_sphere_meshes(hit) == 0)
	var hit_tail_count := 0
	var hit_tip_count := 0
	var rearward_tail_count := 0
	for child in hit.get_children():
		var plate := child as MeshInstance3D
		assert(plate != null)
		var mesh := plate.mesh as BoxMesh
		assert(mesh != null)
		assert(mesh.size.y <= 0.007)
		assert(mesh.size.x <= 0.044)
		assert(mesh.size.z >= 0.10)
		assert(mesh.size.z <= 0.43)
		var material := plate.material_override as StandardMaterial3D
		assert(material != null)
		assert(material.transparency == BaseMaterial3D.TRANSPARENCY_ALPHA)
		var hit_piece := String(plate.get_meta("hit_piece", ""))
		if hit_piece == "tail":
			hit_tail_count += 1
			assert(material.albedo_color.a >= 0.31)
			assert(material.albedo_color.a <= 0.33)
			assert(not material.emission_enabled)
			var spark_direction := plate.get_meta("spark_direction") as Vector2
			if spark_direction.dot(Vector2.LEFT) > 0.70:
				rearward_tail_count += 1
		elif hit_piece == "tip":
			hit_tip_count += 1
			assert(material.albedo_color.a >= 0.85)
			assert(material.albedo_color.r > 0.88)
			assert(material.albedo_color.g > 0.90)
			assert(material.albedo_color.b < 0.90)
			assert(material.emission_enabled)
			assert(material.emission_energy_multiplier >= 2.40)
		else:
			assert(false)
	assert(hit_tail_count == hit_tip_count)
	assert(rearward_tail_count >= 2)

	main._spawn_player_backfire(Vector2.ZERO, 0.0)
	var backfire := main.find_child("PlayerBackfire", true, false) as Node3D
	assert(backfire != null)
	assert(backfire.get_child_count() == 3)
	assert(_count_box_meshes(backfire) == 3)
	assert(_count_sphere_meshes(backfire) == 0)
	assert(backfire.position.x < -0.12)
	assert(backfire.position.x > -0.20)
	var trailing_piece_count := 0
	var wide_piece_count := 0
	var large_piece_count := 0
	for child in backfire.get_children():
		var plate := child as MeshInstance3D
		assert(plate != null)
		assert(absf(plate.position.z) <= 0.15)
		assert(is_equal_approx(plate.rotation.y, PI * 0.25))
		if plate.position.x < -0.30:
			trailing_piece_count += 1
		if absf(plate.position.z) > 0.08:
			wide_piece_count += 1
		var plate_mesh := plate.mesh as BoxMesh
		assert(plate_mesh != null)
		assert(plate_mesh.size.x >= 0.109)
		if plate_mesh.size.x > 0.25:
			large_piece_count += 1
		assert(plate_mesh.size.y <= 0.009)
		var plate_material := plate.material_override as StandardMaterial3D
		assert(plate_material != null)
		assert(plate_material.transparency == BaseMaterial3D.TRANSPARENCY_ALPHA)
		assert(plate_material.albedo_color.r > plate_material.albedo_color.g)
		assert(plate_material.albedo_color.b > plate_material.albedo_color.g)
		assert(plate_material.albedo_color.a <= 0.19)
	assert(trailing_piece_count >= 1)
	assert(wide_piece_count >= 1)
	assert(large_piece_count >= 1)

	main._spawn_player_burst(Vector2.ZERO)
	var burst := main.find_child("PlayerCrashBurst", true, false) as Node3D
	assert(burst != null)
	assert(burst.get_child_count() == 20)
	assert(_count_box_meshes(burst) == 20)
	assert(_count_sphere_meshes(burst) == 0)
	var crash_plate_count := 0
	var crash_chunk_count := 0
	for child in burst.get_children():
		var shard := child as MeshInstance3D
		assert(shard != null)
		var mesh := shard.mesh as BoxMesh
		assert(mesh != null)
		var material := shard.material_override as StandardMaterial3D
		assert(material != null)
		assert(material.transparency == BaseMaterial3D.TRANSPARENCY_ALPHA)
		var piece_type := String(shard.get_meta("crash_piece", ""))
		if piece_type == "plate":
			crash_plate_count += 1
			assert(mesh.size.x >= 0.159)
			assert(mesh.size.y <= 0.011)
			assert(absf(shard.rotation.x) > 0.001 or absf(shard.rotation.z) > 0.001)
			assert(material.albedo_color.a >= 0.67)
			assert(float(shard.get_meta("target_distance", 0.0)) >= 3.20)
		elif piece_type == "chunk":
			crash_chunk_count += 1
			assert(mesh.size.z >= 0.12)
			assert(mesh.size.y >= 0.035)
			assert(absf(shard.rotation.x) > 0.001)
			assert(material.albedo_color.a >= 0.57)
			assert(float(shard.get_meta("target_distance", 0.0)) >= 2.70)
		else:
			assert(false)
	assert(crash_plate_count == 12)
	assert(crash_chunk_count == 8)

	main._spawn_enemy_destroy_effect(Vector2.ZERO, Color(0.55, 0.95, 1.0), 0.86)
	var enemy_destroy := main.find_child("EnemyDestroyEffect", true, false) as Node3D
	assert(enemy_destroy != null)
	assert(enemy_destroy.get_child_count() >= 12)
	assert(_count_box_meshes(enemy_destroy) == enemy_destroy.get_child_count())
	assert(_count_torus_meshes(enemy_destroy) == 0)
	var far_destroy_piece_count := 0
	var enemy_plate_count := 0
	var enemy_shard_count := 0
	for child in enemy_destroy.get_children():
		var piece := child as MeshInstance3D
		assert(piece != null)
		var mesh := piece.mesh as BoxMesh
		assert(mesh != null)
		var piece_type := String(piece.get_meta("destroy_piece", ""))
		if piece_type == "plate":
			enemy_plate_count += 1
			assert(mesh.size.y <= 0.011)
			assert(is_equal_approx(mesh.size.x, mesh.size.z))
		elif piece_type == "shard":
			enemy_shard_count += 1
			assert(mesh.size.y >= 0.025)
			assert(mesh.size.z > mesh.size.x)
		else:
			assert(false)
		if float(piece.get_meta("target_distance", 0.0)) > 3.6:
			far_destroy_piece_count += 1
		var material := piece.material_override as StandardMaterial3D
		assert(material != null)
		assert(material.transparency == BaseMaterial3D.TRANSPARENCY_ALPHA)
	assert(abs(enemy_plate_count - enemy_shard_count) <= 1)
	assert(far_destroy_piece_count >= 1)

	main._spawn_enemy_destroy_effect(Vector2.ONE, Color(0.45, 0.85, 1.0), 0.52, Color.ORANGE_RED, 0.20)
	var turret_destroy := main.get_child(main.get_child_count() - 1) as Node3D
	assert(turret_destroy != null)
	assert(String(turret_destroy.get_meta("effect_type", "")) == "enemy_destroy")
	var accent_piece_count := _count_meta_nodes(turret_destroy, "destroy_palette", "accent")
	assert(accent_piece_count == 2)

	var boss_source := Node3D.new()
	boss_source.name = "BossCoreSource"
	boss_source.position = Vector3(0.0, 0.26, 0.0)
	var boss_source_model := main._boss_core_caged_model(Color(0.70, 0.95, 1.0))
	boss_source_model.scale = Vector3.ONE * MainUtil.BOSS_CORE_VISUAL_SCALE
	boss_source.add_child(boss_source_model)
	var snapshot_marker := Node3D.new()
	snapshot_marker.name = "BossSnapshotMarker"
	boss_source.add_child(snapshot_marker)
	main.add_child(boss_source)
	main._spawn_boss_destroy_effect(Vector2.ZERO, Color(0.70, 0.95, 1.0), boss_source)
	var boss_destroy := main.find_child("BossDestroyEffect", true, false) as Node3D
	assert(boss_destroy != null)
	var anticipation := boss_destroy.find_child("BossDestroyAnticipation", true, false) as Node3D
	assert(anticipation != null)
	assert(anticipation.visible)
	assert(anticipation.find_child("BossSnapshotMarker", true, false) != null)
	var anticipation_model := anticipation.find_child("boss-core-caged", true, false) as Node3D
	assert(anticipation_model != null)
	assert(is_equal_approx(anticipation_model.scale.x, MainUtil.BOSS_CORE_VISUAL_SCALE))
	assert(_count_meta_nodes(boss_destroy, "boss_destroy_piece", "anticipation") == 1)
	assert(_count_meta_nodes(boss_destroy, "boss_destroy_piece", "leak_stage") == 1)
	var leak_count := _count_meta_nodes(boss_destroy, "boss_destroy_piece", "leak")
	assert(leak_count >= 3)
	assert(leak_count <= 4)
	assert(_count_true_meta_nodes(anticipation, "boss_destroy_compression_part") == 2)
	var wire_sphere := anticipation.find_child("boss-core-wire-sphere", true, false) as Node3D
	var energy_shell := anticipation.find_child("boss-core-energy-shell", true, false) as Node3D
	var inner_mark := anticipation.find_child("boss-core-inner-mark", true, false) as Node3D
	var outer_ring := anticipation.find_child("boss-core-ring-cw-outer", true, false) as Node3D
	assert(wire_sphere != null)
	assert(energy_shell != null)
	assert(wire_sphere.has_meta("boss_destroy_compression_part"))
	assert(energy_shell.has_meta("boss_destroy_compression_part"))
	assert(inner_mark != null)
	assert(outer_ring != null)
	assert(not inner_mark.has_meta("boss_destroy_compression_part"))
	assert(not outer_ring.has_meta("boss_destroy_compression_part"))
	assert(_count_meta_nodes(boss_destroy, "boss_destroy_piece", "plate") == 30)
	assert(_count_meta_nodes(boss_destroy, "boss_destroy_piece", "chunk") == 22)
	assert(_count_meta_nodes(boss_destroy, "boss_destroy_piece", "shock_ring") == 0)
	var boss_far_piece_count := 0
	var first_burst_piece_count := 0
	var second_burst_piece_count := 0
	for child in boss_destroy.get_children():
		var piece_type := String(child.get_meta("boss_destroy_piece", ""))
		if piece_type != "plate" and piece_type != "chunk":
			continue
		assert(not child.visible)
		var burst_delay := float(child.get_meta("burst_delay", 0.0))
		if is_equal_approx(burst_delay, MainUtil.BOSS_DESTROY_ANTICIPATION_TIME):
			first_burst_piece_count += 1
		elif is_equal_approx(burst_delay, MainUtil.BOSS_DESTROY_SECOND_BURST_DELAY):
			second_burst_piece_count += 1
		else:
			assert(false)
		if float(child.get_meta("target_distance", 0.0)) >= 6.5:
			boss_far_piece_count += 1
	assert(first_burst_piece_count == 18)
	assert(second_burst_piece_count == 34)
	assert(boss_far_piece_count >= 30)
	var previous_leak_delay := -1.0
	var thick_leak_count := 0
	var thin_leak_count := 0
	var leak_angles: Array[float] = []
	var leak_sweep_speeds: Array[float] = []
	var leak_stage := boss_destroy.find_child("BossDestroyLightLeaks", true, false) as Node3D
	assert(leak_stage != null)
	for leak in leak_stage.get_children():
		var leak_delay := float(leak.get_meta("start_delay", 0.0))
		assert(leak_delay > previous_leak_delay)
		assert(is_equal_approx(float(leak.get_meta("target_distance", 0.0)), Vector2(MainUtil.FIELD_W, MainUtil.FIELD_H).length() * MainUtil.BOSS_LIGHT_LENGTH_MARGIN))
		var leak_origin := leak.get_meta("origin") as Vector2
		var leak_direction := leak.get_meta("direction") as Vector2
		assert(leak_origin.length() >= 0.18 * MainUtil.BOSS_CORE_VISUAL_SCALE)
		assert(leak_origin.length() <= 0.72 * MainUtil.BOSS_CORE_VISUAL_SCALE)
		assert(leak_origin.normalized().dot(leak_direction) > 0.99)
		leak_angles.append(float(leak.get_meta("origin_angle", 0.0)))
		var sweep_speed := float(leak.get_meta("sweep_speed", 0.0))
		assert(absf(sweep_speed) >= 0.9)
		assert(absf(sweep_speed) <= 2.4)
		leak_sweep_speeds.append(sweep_speed)
		var extension_duration := float(leak.get_meta("extension_duration", 0.0))
		assert(extension_duration >= 0.025)
		assert(extension_duration <= 0.045)
		var width_scale := float(leak.get_meta("width_scale", 0.0))
		if bool(leak.get_meta("is_thick", false)):
			thick_leak_count += 1
			assert(width_scale >= 1.80)
		else:
			thin_leak_count += 1
			assert(width_scale <= 1.12)
		assert(leak.get_child_count() == 1)
		var band := leak.get_child(0) as MeshInstance3D
		assert(band != null)
		assert(String(band.get_meta("boss_destroy_piece", "")) == "leak_band")
		assert(float(band.get_meta("outer_width", 0.0)) > float(band.get_meta("inner_width", 0.0)))
		assert(is_equal_approx(band.scale.x, 0.35))
		assert(is_equal_approx(band.scale.z, 0.01))
		var leak_mesh := band.mesh as ArrayMesh
		assert(leak_mesh != null)
		assert(leak_mesh.get_surface_count() == 1)
		var leak_arrays := leak_mesh.surface_get_arrays(0)
		assert((leak_arrays[Mesh.ARRAY_VERTEX] as PackedVector3Array).size() == 18)
		assert((leak_arrays[Mesh.ARRAY_INDEX] as PackedInt32Array).size() == 48)
		var leak_material := band.material_override as ShaderMaterial
		assert(leak_material != null)
		assert(is_equal_approx(float(leak_material.get_shader_parameter("beam_length")), float(band.get_meta("beam_length"))))
		assert(is_equal_approx(float(leak_material.get_shader_parameter("falloff_distance")), MainUtil.BOSS_LIGHT_FALLOFF_DISTANCE))
		assert(leak_material.shader.code.contains("UV.y * beam_length"))
		assert(leak_material.shader.code.contains("mix(0.96, 0.34, falloff)"))
		assert(leak_material.shader.code.contains("mix(3.80, 1.15, falloff)"))
		previous_leak_delay = leak_delay
	assert(thick_leak_count == 2)
	assert(thin_leak_count == leak_count - 2)
	for angle_index in range(leak_angles.size()):
		for other_index in range(angle_index + 1, leak_angles.size()):
			assert(absf(angle_difference(leak_angles[angle_index], leak_angles[other_index])) >= 0.55)
	var distinct_sweep_speed_found := false
	for speed_index in range(1, leak_sweep_speeds.size()):
		if not is_equal_approx(leak_sweep_speeds[speed_index], leak_sweep_speeds[0]):
			distinct_sweep_speed_found = true
	assert(distinct_sweep_speed_found)
	assert(inner_mark.scale.is_equal_approx(Vector3.ONE))
	assert(outer_ring.scale.is_equal_approx(Vector3.ONE))

	main._spawn_player_respawn_effect(Vector2.ZERO)
	var respawn := main.find_child("PlayerRespawnSquares", true, false) as Node3D
	assert(respawn != null)
	assert(respawn.get_child_count() == 4)
	assert(_count_box_meshes(respawn) == 4)
	assert(_count_sphere_meshes(respawn) == 0)
	for child in respawn.get_children():
		var plate := child as MeshInstance3D
		assert(plate != null)
		var mesh := plate.mesh as BoxMesh
		assert(mesh != null)
		assert(mesh.size.x >= 0.33)
		assert(mesh.size.y <= 0.009)
		assert(plate.position.length() > 0.9)
		var material := plate.material_override as StandardMaterial3D
		assert(material != null)
		assert(material.transparency == BaseMaterial3D.TRANSPARENCY_ALPHA)
		assert(material.albedo_color.a <= 0.25)

	main._setup_player()
	main.player.angle = 0.72
	main.player.rotation.y = -main.player.angle - PI * 0.5
	main.player.visual_model.rotation = Vector3(0.18, 0.0, -0.24)
	main._spawn_player_extend_effect(Vector2(1.2, -0.8))
	var extend := main.find_child("PlayerExtendEffect", true, false) as Node3D
	assert(extend != null)
	assert(String(extend.get_meta("effect_type", "")) == "player_extend")
	assert(is_equal_approx(extend.rotation.y, main.player.rotation.y))
	assert(is_equal_approx(extend.position.y, MainUtil.PLAYER_EXTEND_VISUAL_HEIGHT))
	assert(_count_meta_nodes(extend, "extend_piece", "plate") == 8)
	assert(_count_meta_nodes(extend, "extend_piece", "scan_ring") == 0)
	assert(_count_meta_nodes(extend, "extend_piece", "core_flash") == 1)
	assert(_count_meta_nodes(extend, "extend_piece", "wire_echo") == 1)
	assert(_count_meta_nodes(extend, "extend_piece", "wire_edge") >= 12)
	assert(_count_torus_meshes(extend) == 0)
	assert(_count_sphere_meshes(extend) == 1)
	var wire_echo := extend.find_child("PlayerExtendWireEcho", true, false) as Node3D
	assert(wire_echo != null)
	assert(wire_echo.rotation.is_equal_approx(main.player.visual_model.rotation))
	assert(extend.find_child("PlayerExtendWireEchoDelayed", true, false) == null)
	var core_flash := extend.find_child("PlayerExtendCoreFlash", true, false) as MeshInstance3D
	assert(core_flash != null)
	var core_material := core_flash.material_override as StandardMaterial3D
	assert(core_material != null)
	assert(core_material.emission_energy_multiplier >= 3.04)
	assert(core_material.no_depth_test)
	assert(core_material.render_priority == MainUtil.PLAYER_EXTEND_RENDER_PRIORITY)
	var extend_plate := extend.find_child("PlayerExtendPlate", true, false) as MeshInstance3D
	assert(extend_plate != null)
	var plate_material := extend_plate.material_override as StandardMaterial3D
	assert(plate_material != null)
	assert(plate_material.no_depth_test)
	assert(plate_material.render_priority == MainUtil.PLAYER_EXTEND_RENDER_PRIORITY)
	var wire_edge := extend.find_child("PlayerExtendWireEdge", true, false) as MeshInstance3D
	assert(wire_edge != null)
	var wire_material := wire_edge.material_override as StandardMaterial3D
	assert(wire_material != null)
	assert(wire_material.no_depth_test)
	assert(wire_material.render_priority == MainUtil.PLAYER_EXTEND_RENDER_PRIORITY)

	main.queue_free()
	await process_frame
	await process_frame
	print("effect visual verification passed")
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


func _count_sphere_meshes(node: Node) -> int:
	var count := 0
	var mesh_instance := node as MeshInstance3D
	if mesh_instance != null and mesh_instance.mesh is SphereMesh:
		count += 1
	for child in node.get_children():
		count += _count_sphere_meshes(child)
	return count


func _count_meta_nodes(node: Node, meta_key: String, meta_value: String) -> int:
	var count := 0
	if String(node.get_meta(meta_key, "")) == meta_value:
		count += 1
	for child in node.get_children():
		count += _count_meta_nodes(child, meta_key, meta_value)
	return count


func _count_true_meta_nodes(node: Node, meta_key: String) -> int:
	var count := 1 if bool(node.get_meta(meta_key, false)) else 0
	for child in node.get_children():
		count += _count_true_meta_nodes(child, meta_key)
	return count
