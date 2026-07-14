extends SceneTree

const BossUtil := preload("res://scripts/game/boss.gd")
const BulletManagerUtil := preload("res://scripts/game/bullet_manager.gd")
const EnemyUtil := preload("res://scripts/game/enemy.gd")
const GameStateUtil := preload("res://scripts/game/game_state.gd")
const MainUtil := preload("res://scripts/prototype/main.gd")


func _init() -> void:
	var main := MainUtil.new()
	var model: Node3D = main._boss_core_caged_model(Color(0.30, 0.92, 1.00))
	root.add_child(model)
	var core_visual := model.find_child("boss-core-visual", true, false) as Node3D
	var core_mark := model.find_child("boss-core-inner-mark", true, false) as Node3D
	var rings_cw := model.find_children("boss-core-ring-cw*", "Node3D", true, false)
	var rings_ccw := model.find_children("boss-core-ring-ccw*", "Node3D", true, false)
	var wire_sphere := model.find_child("boss-core-wire-sphere", true, false) as Node3D
	var energy_shell := model.find_child("boss-core-energy-shell", true, false) as MeshInstance3D
	var primary_ring := model.find_child("boss-core-ring-ccw-primary", true, false) as Node3D
	var outer_ring := model.find_child("boss-core-ring-cw-outer", true, false) as Node3D
	var gun_orbit := model.find_child("boss-core-gun-orbit", true, false) as Node3D
	assert(core_visual != null)
	assert(core_mark != null)
	assert(wire_sphere != null)
	assert(energy_shell != null)
	assert(energy_shell.mesh is SphereMesh)
	var shell_material := energy_shell.material_override as ShaderMaterial
	assert(shell_material != null)
	var shell_color := shell_material.get_shader_parameter("face_color") as Color
	assert(is_equal_approx(shell_color.a, BossUtil.CORE_SHELL_BASE_ALPHA))
	assert(is_equal_approx(shell_color.r, shell_color.g))
	assert(is_equal_approx(shell_color.g, shell_color.b))
	assert(wire_sphere.get_child_count() == 10)
	assert(model.find_child("boss-core-sphere", true, false) == null)
	assert(model.find_child("boss-core-outline", true, false) == null)
	assert(model.find_child("boss-core-inner-ring", true, false) == null)
	for wire_ring in wire_sphere.get_children():
		var wire_mesh := wire_ring as MeshInstance3D
		assert(wire_mesh != null)
		assert(wire_mesh.mesh is ArrayMesh)
		assert(wire_mesh.mesh.get_aabb().size.y <= 0.001)
		var wire_material := wire_mesh.material_override as ShaderMaterial
		assert(wire_material != null)
		var wire_color := wire_material.get_shader_parameter("line_color") as Color
		assert(wire_color.a >= 0.20)
		assert(wire_color.a <= 0.27)
		assert(wire_color.r > 0.90)
		assert(wire_color.g > 0.95)
		var wire_width := float(wire_mesh.get_meta("band_width"))
		if wire_mesh.name.begins_with("boss-core-wire-longitude"):
			assert(wire_width >= 0.044)
		else:
			assert(wire_width >= 0.034)
	var core_shadow := main._create_model_shadow(model, "BossCoreShadowTest", 0.26)
	var wire_shadow := core_shadow.find_child("boss-core-wire-sphereShadow", true, false) as Node3D
	var visual_shadow := core_shadow.find_child("boss-core-visualShadow", true, false) as Node3D
	assert(wire_shadow != null)
	assert(visual_shadow != null)
	var wire_transform := wire_sphere.transform
	wire_sphere.rotate_x(0.23)
	wire_sphere.rotate_z(-0.17)
	core_visual.visible = false
	main._sync_model_shadow(core_shadow)
	assert(wire_shadow.transform.is_equal_approx(wire_sphere.transform))
	assert(not visual_shadow.visible)
	wire_sphere.transform = wire_transform
	core_visual.visible = true
	main._sync_model_shadow(core_shadow)
	var mark_edges := core_mark.find_children("boss-core-inner-mark-edge*", "MeshInstance3D", true, false)
	assert(mark_edges.size() == 8)
	for mark_edge in mark_edges:
		var edge_mesh := (mark_edge as MeshInstance3D).mesh as BoxMesh
		assert(edge_mesh != null)
		assert(is_equal_approx(edge_mesh.size.x, 0.018))
	var mark_face := core_mark.find_child("boss-core-inner-mark-face", true, false) as MeshInstance3D
	assert(mark_face != null)
	var mark_face_material := mark_face.material_override as ShaderMaterial
	assert(mark_face_material != null)
	var mark_face_color := mark_face_material.get_shader_parameter("face_color") as Color
	assert(is_equal_approx(mark_face_color.a, 0.30))
	assert(primary_ring != null)
	assert(outer_ring != null)
	assert(rings_cw.size() == 2)
	assert(rings_ccw.size() == 1)
	assert(gun_orbit.get_child_count() == 4)
	var core_gun_base_angles: Array = []
	for gun_index in range(gun_orbit.get_child_count()):
		var core_gun := gun_orbit.get_child(gun_index) as Node3D
		assert(core_gun.has_meta("orbit_angle"))
		assert(core_gun.has_meta("orbit_tilt_x"))
		assert(core_gun.has_meta("orbit_tilt_z"))
		var orbit_angle := float(core_gun.get_meta("orbit_angle"))
		core_gun_base_angles.append(orbit_angle)
		assert(is_equal_approx(core_gun.position.length(), MainUtil.BOSS_CORE_GUN_ORBIT_RADIUS))
	assert(not is_equal_approx(absf(angle_difference(core_gun_base_angles[0], core_gun_base_angles[1])), PI * 0.5))
	assert(is_equal_approx(primary_ring.get_meta("display_radius"), 2.22))
	assert(is_equal_approx(outer_ring.get_meta("display_radius"), 3.18))
	assert(primary_ring.position.y >= 1.90)
	assert(outer_ring.position.y >= 2.80)
	assert(primary_ring.get_child_count() == 19)
	assert(outer_ring.get_child_count() == 18)
	assert(not (primary_ring.get_meta("orbit_axis") as Vector3).is_equal_approx(outer_ring.get_meta("orbit_axis") as Vector3))
	assert(not is_zero_approx(primary_ring.get_meta("precession_speed")))
	assert(not is_zero_approx(outer_ring.get_meta("precession_speed")))
	assert(is_equal_approx(float(primary_ring.get_meta("orbit_speed")), -1.35))
	assert(is_equal_approx(float(outer_ring.get_meta("orbit_speed")), 0.95))
	assert(absf(float(primary_ring.get_meta("orbit_speed"))) > absf(float(outer_ring.get_meta("orbit_speed"))))

	var enemy := EnemyUtil.create_boss_core(model, Vector2.ZERO, Color.CYAN, 800, MainUtil.BOSS_CORE_RADIUS)
	assert(is_equal_approx(enemy.radius, 0.90 * MainUtil.BOSS_CORE_VISUAL_SCALE))
	assert(is_equal_approx(BossUtil.CORE_GUN_ORBIT_RADIUS, MainUtil.BOSS_CORE_GUN_ORBIT_RADIUS * MainUtil.BOSS_CORE_VISUAL_SCALE))
	enemy.age = 2.0
	enemy.core_visual = core_visual
	enemy.wire_sphere = wire_sphere
	enemy.energy_shell = energy_shell
	enemy.core_mark = core_mark
	enemy.rings_cw = rings_cw
	enemy.rings_ccw = rings_ccw
	enemy.gun_orbit = gun_orbit
	var enemies: Array[Dictionary] = [enemy]
	for index in range(3):
		enemies.append({"kind": "boss_turret_t1", "life": 1})

	var bullets := BulletManagerUtil.new()
	root.add_child(bullets)
	bullets.setup({"boss_unblockable": Color.RED, "zako3p": Color(1.0, 0.66, 0.12)})
	var game_state := GameStateUtil.new()
	var boss := BossUtil.new()
	boss.start()
	var initial_center := boss.center
	var cw_basis: Basis = (rings_cw[0] as Node3D).basis
	var ccw_basis: Basis = (rings_ccw[0] as Node3D).basis
	var outer_basis: Basis = outer_ring.basis
	var wire_basis: Basis = wire_sphere.basis
	boss.update_enemy(enemy, BossUtil.CORE_GUN_FIRE_INTERVAL, Vector2.DOWN, bullets, game_state, enemies)
	assert(is_equal_approx(BossUtil.CORE_GUN_ORBIT_SPEED, PI))
	assert(boss.center.is_equal_approx(initial_center))
	assert(not enemy.get("core_just_unlocked", false))
	assert(not (rings_cw[0] as Node3D).basis.is_equal_approx(cw_basis))
	assert(not (rings_ccw[0] as Node3D).basis.is_equal_approx(ccw_basis))
	assert(not outer_ring.basis.is_equal_approx(outer_basis))
	assert(not wire_sphere.basis.is_equal_approx(wire_basis))
	assert(core_visual.visible)
	assert(wire_sphere.visible)
	assert(not energy_shell.visible)
	assert(not core_mark.visible)
	var locked_wire_mesh := wire_sphere.get_child(0) as MeshInstance3D
	var locked_wire_material := locked_wire_mesh.material_override as ShaderMaterial
	var locked_wire_color := locked_wire_material.get_shader_parameter("line_color") as Color
	assert(locked_wire_color.a <= BossUtil.CORE_LOCKED_WIRE_ALPHA_MAX)
	assert(bullets.count() == 4)
	var first_core_gun := gun_orbit.get_child(0) as Node3D
	var first_expected_pos: Vector2 = enemy.pos + Vector2(first_core_gun.position.x, first_core_gun.position.z) * MainUtil.BOSS_CORE_VISUAL_SCALE
	assert((bullets.bullets[0].pos as Vector2).is_equal_approx(first_expected_pos))

	enemies.pop_back()
	enemy.life -= 1
	boss.update_enemy(enemy, 0.016, Vector2.DOWN, bullets, game_state, enemies)
	assert(core_visual.visible)
	assert(energy_shell.visible)
	assert(core_mark.visible)
	assert(enemy.get("core_just_unlocked", false))
	assert(enemy.core_unlock_flash > 0.0)
	enemy.core_unlock_flash = 0.0
	var hit_shell_color := shell_material.get_shader_parameter("face_color") as Color
	assert(hit_shell_color.a > BossUtil.CORE_SHELL_BASE_ALPHA)
	assert(float(shell_material.get_shader_parameter("emission_strength")) > BossUtil.CORE_SHELL_BASE_EMISSION)
	var first_damage_flash: float = enemy.core_damage_flash
	enemy.life -= 1
	boss.update_enemy(enemy, 0.016, Vector2.DOWN, bullets, game_state, enemies)
	assert(not enemy.get("core_just_unlocked", false))
	assert(enemy.core_damage_flash < first_damage_flash)
	for rapid_hit_step in range(4):
		enemy.life -= 1
		boss.update_enemy(enemy, 0.016, Vector2.DOWN, bullets, game_state, enemies)
	assert(is_zero_approx(enemy.core_damage_flash))
	var rapid_fire_gap_color := shell_material.get_shader_parameter("face_color") as Color
	assert(is_equal_approx(rapid_fire_gap_color.a, BossUtil.CORE_SHELL_BASE_ALPHA))
	enemy.core_burst_active = false
	enemy.core_burst_recoil = 0.0
	enemy.age = 4.01
	boss.update_enemy(enemy, 0.016, Vector2.DOWN, bullets, game_state, enemies)
	assert(core_visual.scale.x < 1.0)
	assert(is_equal_approx(core_visual.scale.x, core_visual.scale.z))
	for recovery_step in range(20):
		enemy.age = 5.5
		boss.update_enemy(enemy, 0.016, Vector2.DOWN, bullets, game_state, enemies)
	assert(core_visual.scale.x > 0.99)
	bullets.clear()
	enemy.age = 2.01
	boss.update_enemy(enemy, 0.016, Vector2.DOWN * 4.0, bullets, game_state, enemies)
	assert(bullets.count() == 1)
	var boss_b1: Dictionary = bullets.bullets[0]
	var boss_b1_shape: Dictionary = bullets.shape_for(boss_b1)
	assert(boss_b1_shape.type == "capsule")
	var boss_b1_direction := Vector2.from_angle(float(boss_b1.angle))
	var boss_b1_rear := (boss_b1_shape.a as Vector2) - boss_b1_direction * float(boss_b1_shape.radius)
	assert(boss_b1_rear.is_equal_approx(enemy.pos))
	bullets.clear()

	var t1_model: Node3D = main._boss_t_stepped_citadel_model("boss_turret_t1", Color.ORANGE)
	var t2_model: Node3D = main._boss_t_stepped_citadel_model("boss_turret_t2", Color.ORANGE_RED)
	var t3_model: Node3D = main._boss_t_stepped_citadel_model("boss_turret_t3", Color(1.0, 0.66, 0.12))
	root.add_child(t1_model)
	root.add_child(t2_model)
	root.add_child(t3_model)
	assert(t1_model.find_children("boss-t1-rapid-gun*", "Node3D", true, false).size() == 2)
	assert(t1_model.find_children("boss-gun1-needle-prism", "Node3D", true, false).size() == 2)
	assert(t1_model.find_child("boss-t-slow-gun", true, false) != null)
	assert(t1_model.find_child("boss-t-slow-gun-cube", true, false) != null)
	assert(is_equal_approx(MainUtil.BOSS_T_SLOW_GUN_EDGE_WIDTH, 0.015))
	assert(is_equal_approx(MainUtil.BOSS_T_RAPID_GUN_EDGE_WIDTH, 0.016))
	assert(t2_model.find_child("boss-t2-opposing-gun", true, false) != null)
	assert(t2_model.find_children("boss-t2-direction-gun*", "Node3D", true, false).size() == 2)
	assert(t2_model.find_children("boss-gun2-opposing-prism", "Node3D", true, false).size() == 2)
	assert(t2_model.find_child("boss-t-slow-gun", true, false) != null)
	assert(t2_model.find_child("boss-t-slow-gun-cube", true, false) != null)
	assert(is_equal_approx(MainUtil.BOSS_T_DIRECTION_GUN_EDGE_WIDTH, 0.017))
	assert(t3_model.find_children("boss-t3-emitter*", "Node3D", true, false).size() == 3)
	assert(t3_model.find_child("boss-t3-emitter-0", true, false) == null)
	assert(t3_model.find_child("boss-t-slow-gun", true, false) == null)
	var t1_body := t1_model.find_child("boss-t-body-visual", false, false) as Node3D
	var t2_body := t2_model.find_child("boss-t-body-visual", false, false) as Node3D
	var t3_body := t3_model.find_child("boss-t-body-visual", false, false) as Node3D
	assert(t1_body != null)
	assert(t2_body != null)
	assert(t3_body != null)

	var t1_offset := Vector2(3.0, 2.0)
	var t1_enemy := EnemyUtil.create_boss_turret("boss_turret_t1", t1_model, Vector2.ZERO, Color.ORANGE, 240, 0.52, t1_offset)
	t1_enemy.age = 2.1
	t1_enemy.fire_offset = 0.0
	t1_enemy.rev = 1.0
	t1_enemy.body_visual = t1_body
	t1_enemy.tripod_base = t1_model.find_child("boss-t-tripod-base", false, false)
	t1_enemy.slow_gun = t1_model.find_child("boss-t-slow-gun", true, false)
	t1_enemy.slow_gun_visual = t1_model.find_child("boss-t-slow-gun-cube", true, false)
	t1_enemy.rapid_guns = t1_model.find_children("boss-t1-rapid-gun*", "Node3D", true, false)
	boss.update_enemy(t1_enemy, 0.2, Vector2.DOWN * 4.0, bullets, game_state, [t1_enemy])
	var t1_outward := Vector3(t1_offset.normalized().x, 0.0, t1_offset.normalized().y)
	var t1_body_up := (t1_model.basis * t1_body.basis * Vector3.UP).normalized()
	assert(t1_body_up.dot(t1_outward) > 0.18)
	var expected_t1_tilt: float = BossUtil.TURRET_BODY_OUTWARD_TILT + sin(float(t1_enemy.age) * BossUtil.TURRET_BODY_TILT_SWAY_SPEED + float(t1_enemy.fire_offset) * TAU) * BossUtil.TURRET_BODY_TILT_SWAY * float(t1_enemy.rev)
	assert(is_equal_approx(t1_body_up.y, cos(expected_t1_tilt)))
	assert(t1_body.scale.is_equal_approx(Vector3.ONE * MainUtil.BOSS_TURRET_VISUAL_SCALE))
	var t1_tripod_base := t1_enemy.tripod_base as Node3D
	assert(t1_tripod_base != null)
	assert(not (t1_model.basis * t1_tripod_base.basis).orthonormalized().is_equal_approx((t1_model.basis * t1_body.basis).orthonormalized()))
	assert(bullets.count() == 2)
	for rapid_gun in t1_enemy.rapid_guns:
		var rapid_node := rapid_gun as Node3D
		assert(not rapid_node.position.is_equal_approx(rapid_node.get_meta("recoil_base_position")))
	var t1_body_global_basis := (t1_model.basis * t1_body.basis).orthonormalized()
	boss.update_enemy(t1_enemy, 0.01, Vector2.RIGHT * 4.0, bullets, game_state, [t1_enemy])
	assert(not (t1_model.basis * t1_body.basis).orthonormalized().is_equal_approx(t1_body_global_basis))
	assert(t1_body.scale.is_equal_approx(Vector3.ONE * MainUtil.BOSS_TURRET_VISUAL_SCALE))
	var t1_shadow := main._create_model_shadow(t1_model, "BossTurretShadowTest", 0.28)
	main._sync_model_shadow(t1_shadow)
	var t1_body_shadow := t1_shadow.find_child("boss-t-body-visualShadow", true, false) as Node3D
	assert(t1_body_shadow != null)
	assert(t1_body_shadow.transform.is_equal_approx(t1_body.transform))
	assert(not (bullets.bullets[0].pos as Vector2).is_equal_approx(t1_enemy.pos))
	assert(not (bullets.bullets[1].pos as Vector2).is_equal_approx(t1_enemy.pos))
	assert(not (bullets.bullets[0].pos as Vector2).is_equal_approx(bullets.bullets[1].pos as Vector2))
	var slow_visual := t1_enemy.slow_gun_visual as Node3D
	boss.update_enemy(t1_enemy, BossUtil.T_SLOW_GUN_FIRE_INTERVAL, Vector2.DOWN * 4.0, bullets, game_state, [t1_enemy])
	assert(not slow_visual.position.is_equal_approx(slow_visual.get_meta("recoil_base_position")))
	bullets.clear()

	var t2_enemy := EnemyUtil.create_boss_turret("boss_turret_t2", t2_model, Vector2.ZERO, Color.ORANGE_RED, 240, 0.52, Vector2.ZERO)
	t2_enemy.age = 2.1
	t2_enemy.fire_offset = 0.0
	t2_enemy.slow_gun = t2_model.find_child("boss-t-slow-gun", true, false)
	t2_enemy.slow_gun_visual = t2_model.find_child("boss-t-slow-gun-cube", true, false)
	t2_enemy.opposing_gun = t2_model.find_child("boss-t2-opposing-gun", true, false)
	t2_enemy.direction_guns = t2_model.find_children("boss-t2-direction-gun*", "Node3D", true, false)
	boss.update_enemy(t2_enemy, 0.2, Vector2.DOWN * 4.0, bullets, game_state, [t2_enemy])
	assert(bullets.count() == 2)
	assert(not (bullets.bullets[0].pos as Vector2).is_equal_approx(t2_enemy.pos))
	assert(not (bullets.bullets[1].pos as Vector2).is_equal_approx(t2_enemy.pos))
	assert(not (bullets.bullets[0].pos as Vector2).is_equal_approx(bullets.bullets[1].pos as Vector2))
	for direction_gun in t2_enemy.direction_guns:
		var direction_node := direction_gun as Node3D
		assert(not direction_node.position.is_equal_approx(direction_node.get_meta("recoil_base_position")))
	bullets.clear()

	var t3_enemy := EnemyUtil.create_boss_turret("boss_turret_t3", t3_model, Vector2.ZERO, Color(1.0, 0.66, 0.12), 240, 0.52, Vector2.ZERO)
	t3_enemy.age = 2.1
	t3_enemy.fire_offset = 0.0
	t3_enemy.emitters = t3_model.find_children("boss-t3-emitter*", "Node3D", true, false)
	boss.update_enemy(t3_enemy, 0.2, Vector2.DOWN * 4.0, bullets, game_state, [t3_enemy])
	assert(bullets.count() == 3)
	for spawned_bullet in bullets.bullets:
		assert(not (spawned_bullet.pos as Vector2).is_equal_approx(t3_enemy.pos))
		assert(spawned_bullet.behavior == "boss_b2")
		assert(spawned_bullet.node.find_child("boss-b2-homing-wedge", true, false) != null)
	for emitter in t3_enemy.emitters:
		var emitter_node := emitter as Node3D
		assert(not emitter_node.position.is_equal_approx(emitter_node.get_meta("recoil_base_position")))
	bullets.clear()

	bullets.queue_free()
	model.queue_free()
	t1_model.queue_free()
	t2_model.queue_free()
	t3_model.queue_free()
	main.queue_free()
	await process_frame
	await process_frame
	await process_frame
	print("boss core visual verification passed")
	quit()
