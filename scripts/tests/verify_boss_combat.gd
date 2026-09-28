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
	var gun_orbit := model.find_child("boss-core-gun-orbit", true, false) as Node3D

	var enemy := EnemyUtil.create_boss_core(model, Vector2.ZERO, Color.CYAN, 800, MainUtil.BOSS_CORE_RADIUS)
	enemy.age = 2.0
	enemy.core_visual = model.find_child("boss-core-visual", true, false)
	enemy.wire_sphere = model.find_child("boss-core-wire-sphere", true, false)
	enemy.energy_shell = model.find_child("boss-core-energy-shell", true, false)
	enemy.core_mark = model.find_child("boss-core-inner-mark", true, false)
	enemy.rings_cw = model.find_children("boss-core-ring-cw*", "Node3D", true, false)
	enemy.rings_ccw = model.find_children("boss-core-ring-ccw*", "Node3D", true, false)
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

	# Core stays locked while three turrets are alive, but its orbit guns fire.
	boss.update_enemy(enemy, BossUtil.CORE_GUN_FIRE_INTERVAL, Vector2.DOWN, bullets, game_state, enemies)
	assert(not enemy.damageable)
	assert(not enemy.get("core_just_unlocked", false))
	assert(bullets.count() == 4)
	var first_core_gun := gun_orbit.get_child(0) as Node3D
	var first_expected_pos: Vector2 = enemy.pos + Vector2(first_core_gun.position.x, first_core_gun.position.z) * MainUtil.BOSS_CORE_VISUAL_SCALE
	assert((bullets.bullets[0].pos as Vector2).is_equal_approx(first_expected_pos))

	# Destroying a turret unlocks the core exactly once.
	enemies.pop_back()
	boss.update_enemy(enemy, 0.016, Vector2.DOWN, bullets, game_state, enemies)
	assert(enemy.damageable)
	assert(enemy.gum_vulnerable)
	assert(enemy.get("core_just_unlocked", false))
	boss.update_enemy(enemy, 0.016, Vector2.DOWN, bullets, game_state, enemies)
	assert(not enemy.get("core_just_unlocked", false))

	# The core line shot starts at the core.
	bullets.clear()
	enemy.core_burst_active = false
	enemy.core_burst_recoil = 0.0
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

	# T1: two rapid guns fire from their muzzles, not from the turret center.
	var t1_enemy := EnemyUtil.create_boss_turret("boss_turret_t1", t1_model, Vector2.ZERO, Color.ORANGE, 240, 0.52, Vector2(3.0, 2.0))
	t1_enemy.age = 2.1
	t1_enemy.fire_offset = 0.0
	t1_enemy.rev = 1.0
	t1_enemy.body_visual = t1_model.find_child("boss-t-body-visual", false, false)
	t1_enemy.tripod_base = t1_model.find_child("boss-t-tripod-base", false, false)
	t1_enemy.slow_gun = t1_model.find_child("boss-t-slow-gun", true, false)
	t1_enemy.slow_gun_visual = t1_model.find_child("boss-t-slow-gun-cube", true, false)
	t1_enemy.rapid_guns = t1_model.find_children("boss-t1-rapid-gun*", "Node3D", true, false)
	boss.update_enemy(t1_enemy, 0.2, Vector2.DOWN * 4.0, bullets, game_state, [t1_enemy])
	_assert_spread_muzzles(bullets, t1_enemy, 2)
	bullets.clear()

	# T2: two direction guns.
	var t2_enemy := EnemyUtil.create_boss_turret("boss_turret_t2", t2_model, Vector2.ZERO, Color.ORANGE_RED, 240, 0.52, Vector2.ZERO)
	t2_enemy.age = 2.1
	t2_enemy.fire_offset = 0.0
	t2_enemy.slow_gun = t2_model.find_child("boss-t-slow-gun", true, false)
	t2_enemy.slow_gun_visual = t2_model.find_child("boss-t-slow-gun-cube", true, false)
	t2_enemy.opposing_gun = t2_model.find_child("boss-t2-opposing-gun", true, false)
	t2_enemy.direction_guns = t2_model.find_children("boss-t2-direction-gun*", "Node3D", true, false)
	boss.update_enemy(t2_enemy, 0.2, Vector2.DOWN * 4.0, bullets, game_state, [t2_enemy])
	_assert_spread_muzzles(bullets, t2_enemy, 2)
	bullets.clear()

	# T3: three emitters launch homing boss_b2 bullets.
	var t3_enemy := EnemyUtil.create_boss_turret("boss_turret_t3", t3_model, Vector2.ZERO, Color(1.0, 0.66, 0.12), 240, 0.52, Vector2.ZERO)
	t3_enemy.age = 2.1
	t3_enemy.fire_offset = 0.0
	t3_enemy.emitters = t3_model.find_children("boss-t3-emitter*", "Node3D", true, false)
	boss.update_enemy(t3_enemy, 0.2, Vector2.DOWN * 4.0, bullets, game_state, [t3_enemy])
	assert(bullets.count() == 3)
	for spawned_bullet in bullets.bullets:
		assert(not (spawned_bullet.pos as Vector2).is_equal_approx(t3_enemy.pos))
		assert(spawned_bullet.behavior == "boss_b2")
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
	print("boss combat verification passed")
	quit()


func _assert_spread_muzzles(bullets: BulletManager, turret: Dictionary, expected_count: int) -> void:
	assert(bullets.count() == expected_count)
	for index in range(expected_count):
		assert(not (bullets.bullets[index].pos as Vector2).is_equal_approx(turret.pos))
	assert(not (bullets.bullets[0].pos as Vector2).is_equal_approx(bullets.bullets[1].pos as Vector2))
