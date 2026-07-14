class_name Boss
extends RefCounted

const PlayfieldUtil := preload("res://scripts/core/playfield.gd")

const CORE_RING_CW_SPEED := 0.75
const CORE_RING_CCW_SPEED := -1.50
const CORE_MARK_SPEED := 0.42
const CORE_WIRE_ROTATION_SPEED := Vector3(0.46, 0.72, 0.31)
const CORE_SHELL_BASE_COLOR := Color.WHITE
const CORE_SHELL_BASE_ALPHA := 0.055
const CORE_SHELL_HIT_ALPHA := 0.30
const CORE_SHELL_BASE_EMISSION := 0.20
const CORE_SHELL_HIT_EMISSION := 2.35
const CORE_SHELL_UNLOCK_ALPHA := 0.42
const CORE_SHELL_UNLOCK_EMISSION := 3.10
const CORE_DAMAGE_FLASH_DECAY := 18.0
const CORE_DAMAGE_FLASH_INTERVAL := 0.12
const CORE_UNLOCK_FLASH_DECAY := 3.8
const CORE_LOCKED_WIRE_ALPHA_MIN := 0.105
const CORE_LOCKED_WIRE_ALPHA_MAX := 0.245
const CORE_LOCKED_WIRE_EMISSION_MIN := 0.28
const CORE_LOCKED_WIRE_EMISSION_MAX := 0.82
const TURRET_FACE_HIT_ALPHA_GAIN := 0.20
const TURRET_FACE_HIT_EMISSION := 1.45
const TURRET_DAMAGE_FLASH_DECAY := 20.0
const TURRET_DAMAGE_FLASH_INTERVAL := 0.11
const CORE_GUN_ORBIT_SPEED := PI
const CORE_GUN_FIRE_INTERVAL := 20.0 / 60.0
const CORE_VISUAL_SCALE := 1.30
const CORE_GUN_LOCAL_RADIUS := 0.96
const CORE_GUN_ORBIT_RADIUS := CORE_GUN_LOCAL_RADIUS * CORE_VISUAL_SCALE
const CORE_BURST_RECOIL_SCALE := 0.08
const CORE_BURST_RECOIL_RECOVERY := 4.5
const T_SLOW_GUN_ORBIT_RADIUS := 0.96
const T_SLOW_GUN_ORBIT_SPEED := PI
const T_SLOW_GUN_FIRE_INTERVAL := 20.0 / 60.0
const T2_OPPOSING_GUN_RADIUS := 0.62
const T3_EMITTER_RADIUS := 0.72
const T_SLOW_GUN_RECOIL_DISTANCE := 0.08
const T_FIXED_GUN_RECOIL_DISTANCE := 0.13
const T3_EMITTER_RECOIL_DISTANCE := 0.07
const T_SLOW_GUN_RECOIL_RECOVERY := 8.0
const T_FIXED_GUN_RECOIL_RECOVERY := 12.0
const T3_EMITTER_RECOIL_RECOVERY := 5.5
const ORIGINAL_SCREEN_W := 640.0
const ORIGINAL_SCREEN_H := 480.0
const SPAWN_AVOID_PLAYER_DISTANCE := 4.0
const CORE_EDGE_MARGIN_RATIO := Vector2(0.15, 0.27)
const TURRET_CORE_MIN_DISTANCE := 2.40
const TURRET_MIN_SEPARATION := 1.50
const TURRET_BODY_OUTWARD_TILT := deg_to_rad(22.0)
const TURRET_BODY_TILT_SWAY := deg_to_rad(4.5)
const TURRET_BODY_TILT_SWAY_SPEED := 1.8
const TURRET_BODY_TRACK_SPEED_T1 := 0.78
const TURRET_BODY_TRACK_SPEED_T3 := 0.58
const TURRET_BODY_T2_SPIN_SPEED := 0.20
const TURRET_BODY_T3_AIM_BLEND := 0.32
const SPAWN_RANDOM_ATTEMPTS := 32
const SPAWN_FALLBACK_GRID_STEPS := 12

var center := Vector2.ZERO


func reset() -> void:
	center = Vector2.ZERO


func start(player_pos := Vector2.ZERO, field_w := PlayfieldUtil.FIELD_W, field_h := PlayfieldUtil.FIELD_H) -> void:
	center = _random_core_spawn_pos(player_pos, field_w, field_h)


func update_enemy(enemy: Dictionary, delta: float, player_pos: Vector2, bullet_manager: BulletManager, game_state: GameState, enemies: Array[Dictionary]) -> bool:
	if enemy.kind == "boss_core":
		_update_core(enemy, delta, player_pos, bullet_manager, game_state, enemies)
		return enemy.life <= 0
	if enemy.kind.begins_with("boss_turret"):
		_update_turret(enemy, delta, player_pos, bullet_manager)
	return false


func turret_spawn_pos(player_pos: Vector2, field_w: float, field_h: float, occupied_positions: Array[Vector2] = []) -> Vector2:
	var margin := Vector2(20.0 / ORIGINAL_SCREEN_W * field_w, 20.0 / ORIGINAL_SCREEN_H * field_h)
	for attempt in range(SPAWN_RANDOM_ATTEMPTS):
		var candidate := Vector2(
			randf_range(-field_w * 0.5 + margin.x, field_w * 0.5 - margin.x),
			randf_range(-field_h * 0.5 + margin.y, field_h * 0.5 - margin.y)
		)
		if _is_valid_turret_spawn(candidate, player_pos, occupied_positions):
			return candidate
	return _safest_turret_spawn_pos(player_pos, field_w, field_h, margin, occupied_positions)


func _update_core(enemy: Dictionary, delta: float, player_pos: Vector2, bullet_manager: BulletManager, game_state: GameState, enemies: Array[Dictionary]) -> void:
	game_state.boss_timer += delta
	enemy.pos = center
	var alive_turrets := _alive_turret_count(enemies)
	var was_damageable: bool = enemy.get("damageable", false)
	enemy.damageable = enemy.age > 0.5 and alive_turrets <= 2
	enemy.gum_vulnerable = enemy.damageable
	enemy.core_just_unlocked = enemy.damageable and not was_damageable
	if enemy.core_just_unlocked:
		enemy.core_unlock_flash = 1.0
	var core_visual := enemy.get("core_visual") as Node3D
	if core_visual != null:
		core_visual.visible = true
	var energy_shell := enemy.get("energy_shell") as MeshInstance3D
	if energy_shell != null:
		energy_shell.visible = enemy.damageable
	var core_mark := enemy.get("core_mark") as Node3D
	if core_mark != null:
		core_mark.visible = enemy.damageable
		core_mark.rotate_y(delta * CORE_MARK_SPEED)
	var wire_sphere := enemy.get("wire_sphere") as Node3D
	if wire_sphere != null:
		wire_sphere.visible = true
		wire_sphere.rotate_x(delta * CORE_WIRE_ROTATION_SPEED.x)
		wire_sphere.rotate_y(delta * CORE_WIRE_ROTATION_SPEED.y)
		wire_sphere.rotate_z(delta * CORE_WIRE_ROTATION_SPEED.z)
		_update_core_wire_sphere_visual(wire_sphere, enemy.damageable)
	_update_core_damage_visual(enemy, delta)
	for ring_cw in enemy.get("rings_cw", []):
		_update_core_ring(ring_cw as Node3D, delta, CORE_RING_CW_SPEED)
	for ring_ccw in enemy.get("rings_ccw", []):
		_update_core_ring(ring_ccw as Node3D, delta, CORE_RING_CCW_SPEED)
	enemy.core_gun_angle += delta * CORE_GUN_ORBIT_SPEED
	_update_core_orbit_gun_visuals(enemy)
	enemy.core_gun_fire_timer += delta
	if enemy.age > 1.0 and enemy.core_gun_fire_timer >= CORE_GUN_FIRE_INTERVAL:
		enemy.core_gun_fire_timer = fmod(enemy.core_gun_fire_timer, CORE_GUN_FIRE_INTERVAL)
		_fire_core_orbit_guns(enemy, player_pos, bullet_manager)
	var burst_time := fmod(enemy.age, 2.0)
	var burst_active: bool = enemy.age > 2.0 and burst_time < 1.33
	if burst_active and not enemy.core_burst_active:
		enemy.core_burst_recoil = 1.0
	enemy.core_burst_active = burst_active
	_update_core_burst_recoil(enemy, core_visual, delta)
	if burst_active and fmod(enemy.age, 0.05) < delta:
		var a: float = (player_pos - enemy.pos).angle()
		var bullet_center: Vector2 = enemy.pos + Vector2.from_angle(a) * BulletManager.BOSS_B1_INITIAL_LENGTH * 0.5
		bullet_manager.spawn_hostile_bullet(bullet_center, a, BulletManager.BOSS_B1_SPEED, false, "line", 4.0)


func _update_core_damage_visual(enemy: Dictionary, delta: float) -> void:
	var current_life: int = enemy.life
	var cooldown: float = maxf(0.0, float(enemy.core_damage_flash_cooldown) - delta)
	if current_life < int(enemy.core_last_life) and cooldown <= 0.0:
		enemy.core_damage_flash = 1.0
		cooldown = CORE_DAMAGE_FLASH_INTERVAL
	enemy.core_last_life = current_life
	enemy.core_damage_flash_cooldown = cooldown
	var flash: float = enemy.core_damage_flash
	var unlock_flash: float = enemy.get("core_unlock_flash", 0.0)
	var energy_shell := enemy.get("energy_shell") as MeshInstance3D
	if energy_shell != null:
		var material := energy_shell.material_override as ShaderMaterial
		if material != null:
			var phase_color := CORE_SHELL_BASE_COLOR.lerp(Color(0.78, 1.0, 1.0), unlock_flash)
			var shell_color := phase_color
			var target_alpha := lerpf(CORE_SHELL_BASE_ALPHA, CORE_SHELL_HIT_ALPHA, flash)
			target_alpha = maxf(target_alpha, lerpf(CORE_SHELL_BASE_ALPHA, CORE_SHELL_UNLOCK_ALPHA, unlock_flash))
			shell_color.a = target_alpha
			material.set_shader_parameter("face_color", shell_color)
			var target_emission := lerpf(CORE_SHELL_BASE_EMISSION, CORE_SHELL_HIT_EMISSION, flash)
			target_emission = maxf(target_emission, lerpf(CORE_SHELL_BASE_EMISSION, CORE_SHELL_UNLOCK_EMISSION, unlock_flash))
			material.set_shader_parameter("emission_strength", target_emission)
	enemy.core_damage_flash = maxf(0.0, flash - delta * CORE_DAMAGE_FLASH_DECAY)
	enemy.core_unlock_flash = maxf(0.0, unlock_flash - delta * CORE_UNLOCK_FLASH_DECAY)


func _update_core_wire_sphere_visual(wire_sphere: Node3D, damageable: bool) -> void:
	for child in wire_sphere.get_children():
		var mesh := child as MeshInstance3D
		if mesh == null:
			continue
		var material := mesh.material_override as ShaderMaterial
		if material == null:
			continue
		var base_color: Color = mesh.get_meta("base_line_color", Color(0.86, 1.0, 1.0, 0.24))
		var base_emission: float = mesh.get_meta("base_emission", 0.62)
		if damageable:
			material.set_shader_parameter("line_color", base_color)
			material.set_shader_parameter("emission_strength", base_emission)
			continue
		var locked_color := Color(
			lerpf(0.64, 0.94, randf()),
			lerpf(0.88, 1.0, randf()),
			1.0,
			randf_range(CORE_LOCKED_WIRE_ALPHA_MIN, CORE_LOCKED_WIRE_ALPHA_MAX)
		)
		material.set_shader_parameter("line_color", locked_color)
		material.set_shader_parameter("emission_strength", randf_range(CORE_LOCKED_WIRE_EMISSION_MIN, CORE_LOCKED_WIRE_EMISSION_MAX))


func _update_core_ring(ring: Node3D, delta: float, fallback_speed: float) -> void:
	if ring == null:
		return
	var orbit_axis: Vector3 = ring.get_meta("orbit_axis", Vector3.UP)
	var orbit_speed: float = ring.get_meta("orbit_speed", fallback_speed)
	ring.rotate_object_local(orbit_axis, delta * orbit_speed)
	var precession_axis: Vector3 = ring.get_meta("precession_axis", Vector3.ZERO)
	var precession_speed: float = ring.get_meta("precession_speed", 0.0)
	if not precession_axis.is_zero_approx() and not is_zero_approx(precession_speed):
		ring.rotate(precession_axis, delta * precession_speed)


func _update_core_burst_recoil(enemy: Dictionary, core_visual: Node3D, delta: float) -> void:
	if core_visual == null:
		return
	var recoil: float = enemy.core_burst_recoil
	core_visual.scale = Vector3.ONE * (1.0 - recoil * CORE_BURST_RECOIL_SCALE)
	enemy.core_burst_recoil = maxf(0.0, recoil - delta * CORE_BURST_RECOIL_RECOVERY)


func _fire_core_orbit_guns(enemy: Dictionary, player_pos: Vector2, bullet_manager: BulletManager) -> void:
	for orbit_offset in _core_gun_offsets(enemy):
		var gun_pos: Vector2 = enemy.pos + orbit_offset
		var shot_angle := (player_pos - gun_pos).angle()
		bullet_manager.spawn_hostile_bullet(gun_pos, shot_angle, BulletManager.BULLET0_SPEED, true)


func _update_core_orbit_gun_visuals(enemy: Dictionary) -> void:
	var gun_orbit := enemy.get("gun_orbit") as Node3D
	if gun_orbit == null:
		return
	for gun in gun_orbit.get_children():
		var gun_3d := gun as Node3D
		if gun_3d == null:
			continue
		var local_pos := _core_gun_local_position(enemy, gun_3d)
		gun_3d.position = local_pos
		var facing := Vector2(local_pos.x, local_pos.z)
		if facing.length_squared() > 0.0001:
			gun_3d.rotation.y = -facing.angle() + PI * 0.5


func _core_gun_offsets(enemy: Dictionary) -> Array[Vector2]:
	var offsets: Array[Vector2] = []
	var gun_orbit := enemy.get("gun_orbit") as Node3D
	if gun_orbit != null:
		for gun in gun_orbit.get_children():
			var gun_3d := gun as Node3D
			if gun_3d != null:
				var local_pos := _core_gun_local_position(enemy, gun_3d)
				offsets.append(Vector2(local_pos.x, local_pos.z) * CORE_VISUAL_SCALE)
	if offsets.is_empty():
		for index in range(4):
			offsets.append(Vector2.from_angle(enemy.core_gun_angle + randf() * TAU) * CORE_GUN_ORBIT_RADIUS)
	return offsets


func _core_gun_local_position(enemy: Dictionary, gun: Node3D) -> Vector3:
	var phase: float = gun.get_meta("orbit_angle", 0.0)
	var tilt_x: float = gun.get_meta("orbit_tilt_x", 0.0)
	var tilt_z: float = gun.get_meta("orbit_tilt_z", 0.0)
	var orbit_angle: float = enemy.core_gun_angle + phase
	var flat := Vector3(cos(orbit_angle) * CORE_GUN_LOCAL_RADIUS, 0.0, sin(orbit_angle) * CORE_GUN_LOCAL_RADIUS)
	return Basis.from_euler(Vector3(tilt_x, 0.0, tilt_z)) * flat


func _update_turret(enemy: Dictionary, delta: float, player_pos: Vector2, bullet_manager: BulletManager) -> void:
	enemy.pos = center + enemy.offset
	var aim_angle: float = (player_pos - (enemy.pos as Vector2)).angle()
	if enemy.kind == "boss_turret_t2":
		enemy.angle += delta * enemy.rev * 0.52
	else:
		enemy.angle = lerp_angle(enemy.angle, aim_angle, delta * 2.2)
	var node_angle: float = aim_angle if enemy.kind == "boss_turret_t2" else float(enemy.angle)
	enemy.node.rotation.y = -node_angle - PI * 0.5
	_update_turret_body_angle(enemy, delta, aim_angle)
	_update_turret_body_tilt(enemy)
	_update_turret_base_pose(enemy)
	var connection_line := enemy.get("connection_line") as Node3D
	if connection_line != null:
		_update_connection_line(connection_line, center, enemy.pos, delta)
	_update_slow_gun(enemy, delta, player_pos, bullet_manager)
	enemy.damageable = enemy.age > 0.5
	_update_turret_damage_visual(enemy, delta)
	if enemy.kind == "boss_turret_t1":
		_update_turret_t1(enemy, delta, player_pos, bullet_manager)
	elif enemy.kind == "boss_turret_t2":
		_update_turret_t2(enemy, delta, bullet_manager)
	else:
		_update_turret_t3(enemy, delta, player_pos, bullet_manager)
	_update_turret_recoil(enemy, delta)


func _update_turret_damage_visual(enemy: Dictionary, delta: float) -> void:
	var current_life: int = enemy.life
	var cooldown: float = maxf(0.0, float(enemy.turret_damage_flash_cooldown) - delta)
	if current_life < int(enemy.turret_last_life) and cooldown <= 0.0:
		enemy.turret_damage_flash = 1.0
		cooldown = TURRET_DAMAGE_FLASH_INTERVAL
	enemy.turret_last_life = current_life
	enemy.turret_damage_flash_cooldown = cooldown
	var flash: float = enemy.turret_damage_flash
	for face_node in enemy.get("body_faces", []):
		var face := face_node as MeshInstance3D
		if face == null:
			continue
		var material := face.material_override as ShaderMaterial
		if material == null:
			continue
		var base_color: Color = face.get_meta("base_color", Color.WHITE)
		var base_alpha: float = face.get_meta("base_alpha", 0.32)
		var base_emission: float = face.get_meta("base_emission", 0.58)
		var hit_alpha_gain: float = face.get_meta("hit_alpha_gain", TURRET_FACE_HIT_ALPHA_GAIN)
		var hit_emission: float = face.get_meta("hit_emission", TURRET_FACE_HIT_EMISSION)
		var hit_whiten: float = face.get_meta("hit_whiten", 0.34)
		var hit_color := base_color.lerp(Color.WHITE, hit_whiten * flash)
		hit_color.a = lerpf(base_alpha, minf(0.72, base_alpha + hit_alpha_gain), flash)
		material.set_shader_parameter("face_color", hit_color)
		material.set_shader_parameter("emission_strength", lerpf(base_emission, hit_emission, flash))
	enemy.turret_damage_flash = maxf(0.0, flash - delta * TURRET_DAMAGE_FLASH_DECAY)


func _update_turret_body_angle(enemy: Dictionary, delta: float, aim_angle: float) -> void:
	var outward_angle := _turret_outward_angle(enemy)
	if not enemy.has("t_body_angle"):
		enemy.t_body_angle = outward_angle
	if enemy.kind == "boss_turret_t2":
		enemy.t_body_angle = float(enemy.t_body_angle) + delta * float(enemy.rev) * TURRET_BODY_T2_SPIN_SPEED
	elif enemy.kind == "boss_turret_t3":
		var target := lerp_angle(outward_angle, aim_angle, TURRET_BODY_T3_AIM_BLEND)
		enemy.t_body_angle = lerp_angle(float(enemy.t_body_angle), target, delta * TURRET_BODY_TRACK_SPEED_T3)
	else:
		enemy.t_body_angle = lerp_angle(float(enemy.t_body_angle), aim_angle, delta * TURRET_BODY_TRACK_SPEED_T1)


func _update_turret_body_tilt(enemy: Dictionary) -> void:
	var body_visual := enemy.get("body_visual") as Node3D
	var root_node := enemy.get("node") as Node3D
	if body_visual == null or root_node == null:
		return
	var outward: Vector2 = (enemy.offset as Vector2).normalized()
	if outward.is_zero_approx():
		outward = Vector2.from_angle(float(enemy.angle))
	var outward_3d := Vector3(outward.x, 0.0, outward.y)
	var tilt_axis := Vector3.UP.cross(outward_3d).normalized()
	var body_yaw := -float(enemy.get("t_body_angle", enemy.angle)) - PI * 0.5
	var tilt_sway := sin(float(enemy.age) * TURRET_BODY_TILT_SWAY_SPEED + float(enemy.fire_offset) * TAU) * TURRET_BODY_TILT_SWAY
	var tilt_amount := TURRET_BODY_OUTWARD_TILT + tilt_sway * float(enemy.rev)
	var desired_global_basis := Basis(Quaternion(tilt_axis, tilt_amount)) * Basis(Vector3.UP, body_yaw)
	var local_basis := root_node.basis.orthonormalized().inverse() * desired_global_basis
	var visual_scale := float(body_visual.get_meta("visual_scale", body_visual.scale.x))
	body_visual.basis = local_basis.scaled(Vector3.ONE * visual_scale)


func _update_turret_base_pose(enemy: Dictionary) -> void:
	var tripod_base := enemy.get("tripod_base") as Node3D
	var root_node := enemy.get("node") as Node3D
	if tripod_base == null or root_node == null:
		return
	var base_yaw := -_turret_outward_angle(enemy) - PI * 0.5
	var desired_global_basis := Basis(Vector3.UP, base_yaw)
	tripod_base.basis = root_node.basis.orthonormalized().inverse() * desired_global_basis


func _turret_outward_angle(enemy: Dictionary) -> float:
	var outward: Vector2 = (enemy.offset as Vector2).normalized()
	if outward.is_zero_approx():
		return float(enemy.angle)
	return outward.angle()


func _update_turret_t1(enemy: Dictionary, delta: float, player_pos: Vector2, bullet_manager: BulletManager) -> void:
	if enemy.age > 1.0 and fmod(enemy.age + enemy.fire_offset, 0.067) < delta and fmod(enemy.age + enemy.fire_offset, 2.0) < 0.5:
		var visual_scale := _turret_overall_scale(enemy)
		for side in [-1.0, 1.0]:
			var muzzle_pos: Vector2 = (enemy.pos as Vector2) + _local_offset_to_world(enemy.node as Node3D, Vector2(side * 0.42, -0.16) * visual_scale)
			var shot_angle: float = (player_pos - muzzle_pos).angle()
			bullet_manager.spawn_hostile_bullet(muzzle_pos, shot_angle, BulletManager.BULLET1_SPEED, true, "capsule")
		enemy.t_fixed_gun_recoil = 1.0


func _update_turret_t2(enemy: Dictionary, delta: float, bullet_manager: BulletManager) -> void:
	var opposing_gun := enemy.get("opposing_gun") as Node3D
	if opposing_gun != null:
		opposing_gun.rotation.y = -enemy.angle - PI * 0.5 - enemy.node.rotation.y
	if enemy.age > 1.0 and fmod(enemy.age + enemy.fire_offset, 0.1) < delta and fmod(enemy.age + enemy.fire_offset, 2.0) < 1.67:
		for direction in [enemy.angle, enemy.angle + PI]:
			var muzzle_pos: Vector2 = (enemy.pos as Vector2) + Vector2.from_angle(direction) * T2_OPPOSING_GUN_RADIUS * _turret_overall_scale(enemy)
			bullet_manager.spawn_hostile_bullet(muzzle_pos, direction, BulletManager.BULLET2_SPEED, true, "capsule")
		enemy.t_fixed_gun_recoil = 1.0


func _update_turret_t3(enemy: Dictionary, delta: float, player_pos: Vector2, bullet_manager: BulletManager) -> void:
	if enemy.age > 1.0 and fmod(enemy.age + enemy.fire_offset, 1.0) < delta:
		var a: float = (player_pos - enemy.pos).angle()
		for direction in [a + PI * 0.5, a - PI * 0.5, a + PI]:
			var muzzle_pos: Vector2 = (enemy.pos as Vector2) + Vector2.from_angle(direction) * T3_EMITTER_RADIUS * _turret_overall_scale(enemy)
			bullet_manager.spawn_hostile_bullet(muzzle_pos, direction, BulletManager.BOSS_B2_SPEED, true, "boss_b2")
		enemy.t_emitter_recoil = 1.0


func _update_slow_gun(enemy: Dictionary, delta: float, player_pos: Vector2, bullet_manager: BulletManager) -> void:
	var slow_gun := enemy.get("slow_gun") as Node3D
	if slow_gun == null:
		return
	enemy.t_slow_gun_angle += delta * T_SLOW_GUN_ORBIT_SPEED
	enemy.t_slow_gun_timer += delta
	var world_offset := Vector2.from_angle(enemy.t_slow_gun_angle) * T_SLOW_GUN_ORBIT_RADIUS * _turret_overall_scale(enemy)
	var local_offset: Vector3 = (enemy.node as Node3D).basis.inverse() * Vector3(world_offset.x, 0.0, world_offset.y)
	slow_gun.position = Vector3(local_offset.x, slow_gun.position.y, local_offset.z)
	var gun_pos: Vector2 = enemy.pos + world_offset
	var shot_angle := (player_pos - gun_pos).angle()
	slow_gun.rotation.y = -shot_angle - PI * 0.5 - enemy.node.rotation.y
	if enemy.age > 1.0 and enemy.t_slow_gun_timer >= T_SLOW_GUN_FIRE_INTERVAL:
		enemy.t_slow_gun_timer = fmod(enemy.t_slow_gun_timer, T_SLOW_GUN_FIRE_INTERVAL)
		bullet_manager.spawn_hostile_bullet(gun_pos, shot_angle, BulletManager.BULLET0_SPEED, true)
		enemy.t_slow_gun_recoil = 1.0


func _update_turret_recoil(enemy: Dictionary, delta: float) -> void:
	var slow_visual := enemy.get("slow_gun_visual") as Node3D
	if slow_visual != null:
		_apply_local_recoil(slow_visual, enemy.t_slow_gun_recoil * T_SLOW_GUN_RECOIL_DISTANCE)
	for rapid_gun in enemy.get("rapid_guns", []):
		_apply_local_recoil(rapid_gun as Node3D, enemy.t_fixed_gun_recoil * T_FIXED_GUN_RECOIL_DISTANCE)
	for direction_gun in enemy.get("direction_guns", []):
		_apply_local_recoil(direction_gun as Node3D, enemy.t_fixed_gun_recoil * T_FIXED_GUN_RECOIL_DISTANCE)
	for emitter in enemy.get("emitters", []):
		_apply_radial_recoil(emitter as Node3D, enemy.t_emitter_recoil * T3_EMITTER_RECOIL_DISTANCE)
	enemy.t_slow_gun_recoil = maxf(0.0, enemy.t_slow_gun_recoil - delta * T_SLOW_GUN_RECOIL_RECOVERY)
	enemy.t_fixed_gun_recoil = maxf(0.0, enemy.t_fixed_gun_recoil - delta * T_FIXED_GUN_RECOIL_RECOVERY)
	enemy.t_emitter_recoil = maxf(0.0, enemy.t_emitter_recoil - delta * T3_EMITTER_RECOIL_RECOVERY)


func _apply_local_recoil(node: Node3D, distance: float) -> void:
	if node == null:
		return
	var base_position: Vector3 = node.get_meta("recoil_base_position", node.position)
	node.position = base_position + node.basis * Vector3(0.0, 0.0, distance)


func _apply_radial_recoil(node: Node3D, distance: float) -> void:
	if node == null:
		return
	var base_position: Vector3 = node.get_meta("recoil_base_position", node.position)
	var radial := Vector3(base_position.x, 0.0, base_position.z).normalized()
	node.position = base_position - radial * distance


func _update_connection_line(line: Node3D, a: Vector2, b: Vector2, delta := 0.0) -> void:
	if line is MeshInstance3D:
		_update_legacy_connection_line(line as MeshInstance3D, a, b)
		return
	var seed := int(line.get_meta("connection_seed", 0))
	var point_count := _connection_ribbon_point_count(a, b)
	var motion_offsets := _connection_ribbon_motion_offsets(line, point_count, seed, delta)
	var points := _connection_ribbon_points(a, b, seed, motion_offsets)
	var main := line.find_child("BossCoreConnectionRibbonMain", false, false) as MeshInstance3D
	if main != null:
		main.mesh = _connection_ribbon_mesh(points, 0.11)
	var highlight := line.find_child("BossCoreConnectionRibbonHighlight", false, false) as MeshInstance3D
	if highlight != null:
		highlight.mesh = _connection_ribbon_mesh(_connection_offset_points(points, Vector3(0.0, 0.07, 0.05)), 0.045)


func _update_legacy_connection_line(line: MeshInstance3D, a: Vector2, b: Vector2) -> void:
	var mid := (a + b) * 0.5
	var direction := b - a
	var mesh := line.mesh as BoxMesh
	if mesh != null:
		mesh.size.z = direction.length()
	line.position = Vector3(mid.x, 0.08, mid.y)
	line.rotation.y = -direction.angle() + PI * 0.5


func _connection_ribbon_point_count(a: Vector2, b: Vector2) -> int:
	return clampi(8 + int(a.distance_to(b) * 0.75), 8, 14)


func _connection_ribbon_motion_offsets(line: Node3D, count: int, seed: int, delta: float) -> Array[Vector3]:
	var stored_offsets: Array = line.get_meta("connection_offsets", [])
	var stored_velocities: Array = line.get_meta("connection_velocities", [])
	var offsets: Array[Vector3] = []
	var velocities: Array[Vector3] = []
	if stored_offsets.size() == count and stored_velocities.size() == count:
		for index in range(count):
			offsets.append(stored_offsets[index] as Vector3)
			velocities.append(stored_velocities[index] as Vector3)
	if offsets.size() != count or velocities.size() != count:
		offsets = []
		velocities = []
		for index in range(count):
			var t := float(index) / float(count - 1)
			var end_fade := sin(t * PI)
			var initial := Vector3(
				sin(float(seed * 19 + index * 31)) * 0.07,
				sin(float(seed * 23 + index * 17)) * 0.10,
				cos(float(seed * 29 + index * 13)) * 0.14
			) * end_fade
			var direction := Vector3(
				sin(float(seed * 41 + index * 7)),
				cos(float(seed * 37 + index * 11)),
				sin(float(seed * 43 + index * 5))
			).normalized()
			var speed := lerpf(0.08, 0.56, 0.5 + 0.5 * sin(float(seed * 47 + index * 3)))
			offsets.append(initial)
			velocities.append(direction * speed * end_fade)
	for index in range(count):
		var t := float(index) / float(count - 1)
		var end_fade := sin(t * PI)
		var offset := offsets[index] as Vector3
		var velocity := velocities[index] as Vector3
		offset += velocity * delta
		var limit := Vector3(0.34, 0.42, 0.70) * end_fade
		if absf(offset.x) > limit.x:
			offset.x = clampf(offset.x, -limit.x, limit.x)
			velocity.x *= -1.0
		if absf(offset.y) > limit.y:
			offset.y = clampf(offset.y, -limit.y, limit.y)
			velocity.y *= -1.0
		if absf(offset.z) > limit.z:
			offset.z = clampf(offset.z, -limit.z, limit.z)
			velocity.z *= -1.0
		offsets[index] = offset
		velocities[index] = velocity
	line.set_meta("connection_offsets", offsets)
	line.set_meta("connection_velocities", velocities)
	return offsets


func _connection_ribbon_points(a: Vector2, b: Vector2, seed: int, motion_offsets: Array[Vector3] = []) -> Array[Vector3]:
	var start := Vector3(a.x, 0.10, a.y)
	var finish := Vector3(b.x, 0.16, b.y)
	var points: Array[Vector3] = []
	var distance := a.distance_to(b)
	var count := _connection_ribbon_point_count(a, b)
	var wave_cycles := lerpf(1.35, 2.35, clampf((distance - 3.0) / 5.0, 0.0, 1.0))
	var lateral_scale := lerpf(1.0, 1.55, clampf((distance - 3.0) / 5.0, 0.0, 1.0))
	for index in range(count):
		var t := float(index) / float(count - 1)
		var base := start.lerp(finish, t)
		var wave := sin(t * TAU * wave_cycles + float(seed) * 0.9)
		var jitter := sin(float(index * 37 + seed * 11)) * 0.5 + 0.5
		var end_fade := sin(t * PI)
		var motion_offset := motion_offsets[index] as Vector3 if index < motion_offsets.size() else Vector3.ZERO
		base += motion_offset * lateral_scale
		base.y += (wave * 0.46 + end_fade * 0.34) * end_fade * lateral_scale
		base.z += cos(t * TAU * (wave_cycles + 0.35)) * lerpf(0.36, 0.64, jitter) * end_fade * lateral_scale
		points.append(base)
	return points


func _connection_offset_points(points: Array[Vector3], offset: Vector3) -> Array[Vector3]:
	var offset_points: Array[Vector3] = []
	for point in points:
		offset_points.append(point + offset)
	return offset_points


func _connection_ribbon_mesh(points: Array[Vector3], width: float) -> ArrayMesh:
	var verts := PackedVector3Array()
	var indices := PackedInt32Array()
	for index in range(points.size()):
		var current := points[index]
		var previous := points[maxi(0, index - 1)]
		var next := points[mini(points.size() - 1, index + 1)]
		var tangent := (next - previous).normalized()
		var side := tangent.cross(Vector3.UP).normalized()
		if side.is_zero_approx():
			side = Vector3.RIGHT
		var twist := sin(float(index) * 1.73 + width * 19.0) * 0.35
		side = side.rotated(tangent, twist)
		var local_width := width * (0.82 + 0.24 * sin(float(index) * 1.11 + 0.4))
		verts.append(current - side * local_width * 0.5)
		verts.append(current + side * local_width * 0.5)
		if index < points.size() - 1:
			var base := index * 2
			indices.append_array([base, base + 1, base + 2, base + 1, base + 3, base + 2])
	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = verts
	arrays[Mesh.ARRAY_INDEX] = indices
	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	return mesh


func _local_offset_to_world(node: Node3D, local_offset: Vector2) -> Vector2:
	var world_offset := node.basis * Vector3(local_offset.x, 0.0, local_offset.y)
	return Vector2(world_offset.x, world_offset.z)


func _turret_overall_scale(enemy: Dictionary) -> float:
	var node := enemy.get("node") as Node3D
	if node == null:
		return 1.0
	return float(node.get_meta("turret_overall_scale", node.get_meta("overall_scale", 1.0)))


func _alive_turret_count(enemies: Array[Dictionary]) -> int:
	var count := 0
	for enemy in enemies:
		if enemy.kind.begins_with("boss_turret") and enemy.life > 0:
			count += 1
	return count


func _random_core_spawn_pos(player_pos: Vector2, field_w: float, field_h: float) -> Vector2:
	var margin := Vector2(field_w * CORE_EDGE_MARGIN_RATIO.x, field_h * CORE_EDGE_MARGIN_RATIO.y)
	var min_pos := Vector2(-field_w * 0.5, -field_h * 0.5) + margin
	var max_pos := Vector2(field_w * 0.5, field_h * 0.5) - margin
	for attempt in range(SPAWN_RANDOM_ATTEMPTS):
		var candidate := Vector2(randf_range(min_pos.x, max_pos.x), randf_range(min_pos.y, max_pos.y))
		if candidate.distance_to(player_pos) >= SPAWN_AVOID_PLAYER_DISTANCE:
			return candidate
	return _farthest_field_corner(player_pos, field_w, field_h, margin)


func _is_valid_turret_spawn(candidate: Vector2, player_pos: Vector2, occupied_positions: Array[Vector2] = []) -> bool:
	if not (
		candidate.distance_to(player_pos) >= SPAWN_AVOID_PLAYER_DISTANCE
		and candidate.distance_to(center) >= TURRET_CORE_MIN_DISTANCE
	):
		return false
	for occupied in occupied_positions:
		if candidate.distance_to(occupied) < TURRET_MIN_SEPARATION:
			return false
	return true


func _safest_turret_spawn_pos(player_pos: Vector2, field_w: float, field_h: float, margin: Vector2, occupied_positions: Array[Vector2] = []) -> Vector2:
	var min_pos := Vector2(-field_w * 0.5 + margin.x, -field_h * 0.5 + margin.y)
	var max_pos := Vector2(field_w * 0.5 - margin.x, field_h * 0.5 - margin.y)
	var safest := min_pos
	var safest_score := -INF
	for y_step in range(SPAWN_FALLBACK_GRID_STEPS + 1):
		for x_step in range(SPAWN_FALLBACK_GRID_STEPS + 1):
			var candidate := Vector2(
				lerpf(min_pos.x, max_pos.x, float(x_step) / SPAWN_FALLBACK_GRID_STEPS),
				lerpf(min_pos.y, max_pos.y, float(y_step) / SPAWN_FALLBACK_GRID_STEPS)
			)
			var core_distance := candidate.distance_to(center)
			if core_distance < TURRET_CORE_MIN_DISTANCE:
				continue
			var nearest_turret_distance := INF
			for occupied in occupied_positions:
				nearest_turret_distance = minf(nearest_turret_distance, candidate.distance_to(occupied))
			if nearest_turret_distance < TURRET_MIN_SEPARATION:
				continue
			var player_distance := candidate.distance_to(player_pos)
			var score := minf(player_distance, core_distance)
			if not occupied_positions.is_empty():
				score = minf(score, nearest_turret_distance)
			if player_distance >= SPAWN_AVOID_PLAYER_DISTANCE:
				score += field_w + field_h
			if score > safest_score:
				safest = candidate
				safest_score = score
	return safest


func _farthest_field_corner(player_pos: Vector2, field_w: float, field_h: float, margin: Vector2) -> Vector2:
	var corners := [
		Vector2(-field_w * 0.5 + margin.x, -field_h * 0.5 + margin.y),
		Vector2(field_w * 0.5 - margin.x, -field_h * 0.5 + margin.y),
		Vector2(-field_w * 0.5 + margin.x, field_h * 0.5 - margin.y),
		Vector2(field_w * 0.5 - margin.x, field_h * 0.5 - margin.y),
	]
	var farthest: Vector2 = corners[0]
	for corner in corners:
		if corner.distance_squared_to(player_pos) > farthest.distance_squared_to(player_pos):
			farthest = corner
	return farthest
