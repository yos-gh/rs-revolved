extends SceneTree

const BossUtil := preload("res://scripts/game/boss.gd")
const PlayfieldUtil := preload("res://scripts/core/playfield.gd")

const FIELD_W := PlayfieldUtil.FIELD_W
const FIELD_H := PlayfieldUtil.FIELD_H
const PLAYER_POS := Vector2.ZERO
const TURRET_MARGIN := Vector2(20.0 / BossUtil.ORIGINAL_SCREEN_W * FIELD_W, 20.0 / BossUtil.ORIGINAL_SCREEN_H * FIELD_H)


func _init() -> void:
	var boss := BossUtil.new()
	assert(is_equal_approx(BossUtil.CORE_GUN_ORBIT_RADIUS, BossUtil.CORE_GUN_LOCAL_RADIUS * BossUtil.CORE_VISUAL_SCALE))
	var connection_points := boss._connection_ribbon_points(Vector2.ZERO, Vector2(4.0, 1.0), 2)
	assert(connection_points.size() > 8)
	var connection_mesh := boss._connection_ribbon_mesh(connection_points, 0.11)
	assert(connection_mesh.get_surface_count() == 1)
	assert(connection_mesh.get_aabb().size.x > 3.0)
	assert(connection_mesh.get_aabb().size.y > 0.35)
	assert(connection_mesh.get_aabb().size.z > 1.0)
	var far_connection_points := boss._connection_ribbon_points(Vector2.ZERO, Vector2(8.0, 2.0), 2)
	var far_connection_mesh := boss._connection_ribbon_mesh(far_connection_points, 0.11)
	assert(far_connection_points.size() > connection_points.size())
	assert(far_connection_mesh.get_aabb().size.z > connection_mesh.get_aabb().size.z)
	var connection_line := Node3D.new()
	var initial_offsets := boss._connection_ribbon_motion_offsets(connection_line, connection_points.size(), 2, 0.0)
	var moved_offsets := boss._connection_ribbon_motion_offsets(connection_line, connection_points.size(), 2, 1.0)
	var animated_connection_points := boss._connection_ribbon_points(Vector2.ZERO, Vector2(4.0, 1.0), 2, moved_offsets)
	assert(animated_connection_points[0].is_equal_approx(connection_points[0]))
	assert(animated_connection_points[animated_connection_points.size() - 1].is_equal_approx(connection_points[connection_points.size() - 1]))
	var middle_index := animated_connection_points.size() / 2
	assert(not animated_connection_points[middle_index].is_equal_approx(connection_points[middle_index]))
	var middle_delta := (moved_offsets[middle_index] as Vector3) - (initial_offsets[middle_index] as Vector3)
	var neighbor_delta := (moved_offsets[middle_index + 1] as Vector3) - (initial_offsets[middle_index + 1] as Vector3)
	assert(not middle_delta.is_equal_approx(neighbor_delta))
	assert(middle_delta.length() > 0.05)
	var orbit := Node3D.new()
	var gun := Node3D.new()
	gun.set_meta("orbit_angle", 0.0)
	gun.set_meta("orbit_tilt_x", 0.0)
	gun.set_meta("orbit_tilt_z", 0.0)
	orbit.add_child(gun)
	var core_enemy := {"gun_orbit": orbit, "core_gun_angle": 0.0}
	var firing_offsets: Array[Vector2] = boss._core_gun_offsets(core_enemy)
	assert(firing_offsets.size() == 1)
	assert(is_equal_approx(firing_offsets[0].length(), BossUtil.CORE_GUN_ORBIT_RADIUS))
	boss._update_core_orbit_gun_visuals(core_enemy)
	assert(is_equal_approx(gun.position.length(), BossUtil.CORE_GUN_LOCAL_RADIUS))
	orbit.free()
	for sample in range(200):
		boss.start(PLAYER_POS, FIELD_W, FIELD_H)
		assert(boss.center.distance_to(PLAYER_POS) >= BossUtil.SPAWN_AVOID_PLAYER_DISTANCE)
		assert(absf(boss.center.x) <= FIELD_W * (0.5 - BossUtil.CORE_EDGE_MARGIN_RATIO.x))
		assert(absf(boss.center.y) <= FIELD_H * (0.5 - BossUtil.CORE_EDGE_MARGIN_RATIO.y))

		var turret_pos := boss.turret_spawn_pos(PLAYER_POS, FIELD_W, FIELD_H)
		assert(turret_pos.distance_to(PLAYER_POS) >= BossUtil.SPAWN_AVOID_PLAYER_DISTANCE)
		assert(turret_pos.distance_to(boss.center) >= BossUtil.TURRET_CORE_MIN_DISTANCE)
		assert(absf(turret_pos.x) <= FIELD_W * 0.5 - TURRET_MARGIN.x)
		assert(absf(turret_pos.y) <= FIELD_H * 0.5 - TURRET_MARGIN.y)

		var occupied: Array[Vector2] = [turret_pos]
		for turret_index in range(7):
			var separated_pos := boss.turret_spawn_pos(PLAYER_POS, FIELD_W, FIELD_H, occupied)
			for existing_pos in occupied:
				assert(separated_pos.distance_to(existing_pos) >= BossUtil.TURRET_MIN_SEPARATION)
			occupied.append(separated_pos)

	boss.center = Vector2(FIELD_W * 0.5, FIELD_H * 0.5)
	for sample in range(50):
		var corner_core_turret := boss.turret_spawn_pos(Vector2(-FIELD_W * 0.5, -FIELD_H * 0.5), FIELD_W, FIELD_H)
		assert(corner_core_turret.distance_to(boss.center) >= BossUtil.TURRET_CORE_MIN_DISTANCE)

	print("boss spawn position verification passed")
	quit()
