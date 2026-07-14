extends SceneTree

const MainUtil := preload("res://scripts/prototype/main.gd")


func _init() -> void:
	var main := MainUtil.new()
	root.add_child(main)
	await process_frame
	assert(is_equal_approx(MainUtil.ZAKO2_VISUAL_MAX_BANK, deg_to_rad(44.0)))
	assert(is_equal_approx(MainUtil.ZAKO2_VISUAL_MAX_PITCH, deg_to_rad(18.0)))
	assert(is_equal_approx(MainUtil.ZAKO2_VISUAL_FULL_BANK_TURN_RATE, 5.8))
	assert(main._normalized_turn_input(0.0, 4.0 / 60.0, 1.0 / 60.0, MainUtil.ZAKO2_VISUAL_FULL_BANK_TURN_RATE) < 0.70)
	assert(is_equal_approx(MainUtil.ZAKO4_VISUAL_MAX_BANK, MainUtil.ZAKO2_VISUAL_MAX_BANK))
	assert(is_equal_approx(MainUtil.ZAKO4_VISUAL_MAX_PITCH, MainUtil.ZAKO2_VISUAL_MAX_PITCH))
	assert(is_equal_approx(MainUtil.ZAKO4_VISUAL_SPIN_SPEED, deg_to_rad(10.0 * 60.0)))
	for moving_kind in ["zako0", "zako1", "zako2", "zako3p", "zako4", "zako5", "zako6", "zako7", "zako7p"]:
		assert(is_equal_approx(main._enemy_visual_height(moving_kind), MainUtil.MOVING_CHARACTER_VISUAL_HEIGHT))
	assert(MainUtil.MOVING_CHARACTER_VISUAL_HEIGHT > 0.70)
	assert(MainUtil.MOVING_CHARACTER_VISUAL_HEIGHT - MainUtil.TUNNEL_VISUAL_HEIGHT > 0.68)
	assert(is_equal_approx(main._enemy_visual_height("zakoM0"), MainUtil.DEFAULT_ENEMY_VISUAL_HEIGHT))
	var fan_model := main._zako2_fan_blocks_model(Color.GREEN)
	var fan_min := Vector2(INF, INF)
	var fan_max := Vector2(-INF, -INF)
	for blade_index in range(4):
		var blade := fan_model.find_child("zako2-blade-%d" % blade_index, false, false) as Node3D
		assert(blade != null)
		assert(is_equal_approx(float(blade.get_meta("blade_pitch")), MainUtil.ZAKO2_BLADE_PITCH))
		var points := main._zako2_blade_points(blade.position)
		var min_height := INF
		var max_height := -INF
		for corner_index in range(4):
			var point := points[corner_index]
			var projected := Vector2(blade.position.x + point.x, blade.position.z + point.z)
			fan_min = Vector2(minf(fan_min.x, projected.x), minf(fan_min.y, projected.y))
			fan_max = Vector2(maxf(fan_max.x, projected.x), maxf(fan_max.y, projected.y))
			min_height = minf(min_height, point.y)
			max_height = maxf(max_height, point.y)
		assert(max_height - min_height > 0.12)
	assert(fan_min.is_equal_approx(Vector2(-0.48, -0.48)))
	assert(fan_max.is_equal_approx(Vector2(0.48, 0.48)))
	var light_fan := main._zako2_fan_blocks_light_model(Color.GREEN)
	assert(_count_mesh_instances(light_fan) < _count_mesh_instances(fan_model) * 0.45)
	light_fan.free()
	fan_model.free()
	var chain_part_full := main._zako7p_mini_crystal_model(Color.ORANGE)
	var chain_part_light := main._zako7p_mini_crystal_light_model(Color.ORANGE)
	assert(_count_mesh_instances(chain_part_light) < _count_mesh_instances(chain_part_full))
	chain_part_full.free()
	chain_part_light.free()
	var split_pod_full := main._zako3_split_pod_model(Color.RED, Color.ORANGE)
	var split_pod_light := main._zako3_split_pod_light_model(Color.RED, Color.ORANGE)
	assert(_count_mesh_instances(split_pod_light) < _count_mesh_instances(split_pod_full) * 0.45)
	split_pod_full.free()
	split_pod_light.free()
	var battery_full := main._zako4_diamond_battery_model(Color.ORANGE)
	var battery_light := main._zako4_diamond_battery_light_model(Color.ORANGE)
	assert(_count_mesh_instances(battery_light) < _count_mesh_instances(battery_full) * 0.30)
	for marker_index in range(4):
		assert(battery_light.find_child("zako4-muzzle-%d" % marker_index, true, false) != null)
	battery_full.free()
	battery_light.free()
	var compensation_root := Node3D.new()
	var compensation_model := Node3D.new()
	var compensation_pivot := main._attach_motion_visual(compensation_root, compensation_model)
	main.add_child(compensation_root)
	var spin_enemy := {"node": compensation_root, "visual_model": compensation_pivot, "spin_model": compensation_model, "visual_heading": 0.0}
	main._update_enemy_motion_visual(spin_enemy, 0.0, 0.1, 0.0, 0.0, 8.0, 1.0)
	var initial_forward := compensation_model.global_basis * Vector3.FORWARD
	main._update_enemy_motion_visual(spin_enemy, 0.4, 0.1, 0.0, 0.0, 8.0, 1.0, 2.0)
	var spun_forward := compensation_model.global_basis * Vector3.FORWARD
	var initial_angle := Vector2(initial_forward.x, initial_forward.z).angle()
	var spun_angle := Vector2(spun_forward.x, spun_forward.z).angle()
	assert(is_equal_approx(absf(angle_difference(initial_angle, spun_angle)), 0.2))
	compensation_root.free()

	var tunings := [
		["zako2", MainUtil.ZAKO2_VISUAL_MAX_BANK, MainUtil.ZAKO2_VISUAL_MAX_PITCH, MainUtil.ZAKO2_VISUAL_RESPONSE, MainUtil.ZAKO2_VISUAL_FULL_BANK_TURN_RATE, 2.0, 0.0],
		["zako3p", MainUtil.ZAKO3P_VISUAL_MAX_BANK, MainUtil.ZAKO3P_VISUAL_MAX_PITCH, MainUtil.ZAKO3P_VISUAL_RESPONSE, MainUtil.ZAKO3P_VISUAL_FULL_BANK_TURN_RATE, 0.0, MainUtil.ZAKO3P_VISUAL_ROLL_SPEED],
		["zako4", MainUtil.ZAKO4_VISUAL_MAX_BANK, MainUtil.ZAKO4_VISUAL_MAX_PITCH, MainUtil.ZAKO4_VISUAL_RESPONSE, MainUtil.ZAKO4_VISUAL_FULL_BANK_TURN_RATE, 2.0, 0.0],
		["zako5", MainUtil.ZAKO5_VISUAL_MAX_BANK, MainUtil.ZAKO5_VISUAL_MAX_PITCH, MainUtil.ZAKO5_VISUAL_RESPONSE, MainUtil.ZAKO5_VISUAL_FULL_BANK_TURN_RATE, 0.0, 0.0],
		["zako6", MainUtil.ZAKO6_VISUAL_MAX_BANK, MainUtil.ZAKO6_VISUAL_MAX_PITCH, MainUtil.ZAKO6_VISUAL_RESPONSE, MainUtil.ZAKO6_VISUAL_FULL_BANK_TURN_RATE, MainUtil.ZAKO6_VISUAL_SPIN_SPEED, 0.0],
		["zako7", MainUtil.ZAKO7_VISUAL_MAX_BANK, MainUtil.ZAKO7_VISUAL_MAX_PITCH, MainUtil.ZAKO7_VISUAL_RESPONSE, MainUtil.ZAKO7_VISUAL_FULL_BANK_TURN_RATE, 0.0, 0.0],
		["zako7p", MainUtil.ZAKO7P_CHAIN_VISUAL_MAX_BANK, MainUtil.ZAKO7P_CHAIN_VISUAL_MAX_PITCH, MainUtil.ZAKO7P_VISUAL_RESPONSE, MainUtil.ZAKO7P_VISUAL_FULL_BANK_TURN_RATE, 0.0, MainUtil.ZAKO7P_CHAIN_VISUAL_ROLL_SPEED],
	]

	for tuning in tunings:
		var kind := tuning[0] as String
		main._spawn_enemy(kind, Vector2(2.0, 1.0))
		var enemy := _find_latest_enemy(main.enemies, kind)
		var visual_pivot := enemy.visual_model as Node3D
		var spin_model := enemy.spin_model as Node3D
		assert(visual_pivot != null)
		assert(spin_model != null)
		assert(spin_model.get_parent() == visual_pivot)
		var initial_spin_basis := spin_model.basis
		var heading := 0.0
		enemy.visual_heading = heading
		for step in range(30):
			heading += float(tuning[4]) / 60.0
			main._update_enemy_motion_visual(
				enemy, heading, 1.0 / 60.0,
				float(tuning[1]), float(tuning[2]), float(tuning[3]), float(tuning[4]),
				float(tuning[5]), float(tuning[6])
			)
		assert(absf(visual_pivot.rotation.z) > float(tuning[1]) * 0.80)
		assert(is_zero_approx((enemy.node as Node3D).rotation.x))
		assert(is_zero_approx((enemy.node as Node3D).rotation.z))
		if not is_zero_approx(float(tuning[5])) or not is_zero_approx(float(tuning[6])):
			assert(not spin_model.basis.is_equal_approx(initial_spin_basis))
		if kind in ["zako2", "zako3p", "zako4", "zako5", "zako6", "zako7", "zako7p"]:
			main._update_enemy_visual_batches()
			assert(String(enemy.visual_batch_kind) == kind)
			assert(_count_mesh_instances(enemy.node as Node) == 0)
			var batch := main.enemy_visual_batches[kind] as Dictionary
			var visual_entries := batch.visual_entries as Array
			var shadow_entries := batch.shadow_entries as Array
			assert((visual_entries[0].multimesh as MultiMesh).instance_count > 0)
			assert(shadow_entries.is_empty())
		else:
			main._update_enemy_shadow(enemy)
			assert(not enemy.has("shadow") or enemy.shadow == null)

	assert(MainUtil.ZAKO7P_RELEASED_VISUAL_MAX_BANK > MainUtil.ZAKO7P_CHAIN_VISUAL_MAX_BANK)
	assert(MainUtil.ZAKO7P_RELEASED_VISUAL_MAX_PITCH > MainUtil.ZAKO7P_CHAIN_VISUAL_MAX_PITCH)
	assert(MainUtil.ZAKO7P_RELEASED_VISUAL_ROLL_SPEED > MainUtil.ZAKO7P_CHAIN_VISUAL_ROLL_SPEED)
	var zako4 := _find_latest_enemy(main.enemies, "zako4")
	var muzzle_positions: Array[Vector2] = []
	for muzzle_index in range(4):
		var muzzle := main._zako4_muzzle_pose(zako4, muzzle_index)
		muzzle_positions.append(muzzle.pos)
		assert((muzzle.pos as Vector2).distance_to(zako4.pos) > 0.20)
	for muzzle_index in range(4):
		assert(muzzle_positions[muzzle_index].distance_to(muzzle_positions[(muzzle_index + 1) % 4]) > 0.25)

	main.queue_free()
	await process_frame
	await process_frame
	print("moving character visual verification passed")
	quit()


func _find_latest_enemy(enemies: Array[Dictionary], kind: String) -> Dictionary:
	for index in range(enemies.size() - 1, -1, -1):
		if enemies[index].kind == kind:
			return enemies[index]
	return {}


func _count_mesh_instances(node: Node) -> int:
	var count := 1 if node is MeshInstance3D else 0
	for child in node.get_children():
		count += _count_mesh_instances(child)
	return count
