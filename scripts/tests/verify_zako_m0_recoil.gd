extends SceneTree

const MainUtil := preload("res://scripts/prototype/main.gd")


func _init() -> void:
	var main := MainUtil.new()
	root.add_child(main)
	await process_frame
	var spawn_pos := Vector2(3.0, 2.0)
	main._spawn_enemy("zakoM0", spawn_pos)
	var enemy: Dictionary = main.enemies.back()
	var body_visual := enemy.visual_model as Node3D
	var gun0_visual := (enemy.gun0 as Node3D).find_child("zako-gun0-square-visual", false, false) as Node3D
	var gun1_visual := (enemy.gun1 as Node3D).find_child("zako-gun1-prism-sniper-visual", false, false) as Node3D
	assert(body_visual != null)
	assert(gun0_visual != null)
	assert(gun1_visual != null)
	assert(gun0_visual.scale.is_equal_approx(Vector3.ONE * 0.80))
	var gun1_face := gun1_visual.find_children("*", "MeshInstance3D", true, false)[0] as MeshInstance3D
	var gun1_material := gun1_face.material_override as ShaderMaterial
	var gun1_color: Color = gun1_material.get_shader_parameter("face_color")
	assert(gun1_color.r > gun1_color.g)
	assert(gun1_color.g > gun1_color.b)
	(enemy.node as Node3D).rotation.y = 0.73
	main._update_zako_m0_body_tilt(enemy)
	var outward_3d := Vector3(spawn_pos.normalized().x, 0.0, spawn_pos.normalized().y)
	var body_up := ((enemy.node as Node3D).basis * body_visual.basis * Vector3.UP).normalized()
	assert(body_up.dot(outward_3d) > 0.20)
	assert(is_equal_approx(body_up.y, cos(MainUtil.ZAKOM0_OUTWARD_TILT)))
	var initial_global_basis := ((enemy.node as Node3D).basis * body_visual.basis).orthonormalized()
	(enemy.node as Node3D).rotation.y = -1.10
	main._update_zako_m0_body_tilt(enemy)
	assert(((enemy.node as Node3D).basis * body_visual.basis).orthonormalized().is_equal_approx(initial_global_basis))
	(enemy.node as Node3D).rotation.y = 0.73
	main._update_zako_m0_body_tilt(enemy)
	main._update_enemy_shadow(enemy)
	assert(not enemy.has("shadow") or enemy.shadow == null)

	enemy.age = 1.021
	main._update_zako_m0_guns(enemy, 0.02)
	assert(gun0_visual.position.z > 0.0)
	assert(is_zero_approx(gun1_visual.position.z))
	assert(main.bullet_manager.count() == 1)
	var gun0_world := (enemy.node as Node3D).to_global((enemy.gun0 as Node3D).position)
	var gun0_bullet: Dictionary = main.bullet_manager.bullets[0]
	assert((gun0_bullet.pos as Vector2).is_equal_approx(Vector2(gun0_world.x, gun0_world.z)))
	main.bullet_manager.clear()
	var gun0_world_position: Vector3 = (enemy.gun0 as Node3D).position

	enemy.age = 2.201
	main._update_zako_m0_guns(enemy, 0.02)
	assert(gun1_visual.position.z > gun0_visual.position.z)
	assert(not (enemy.gun0 as Node3D).position.is_equal_approx(gun0_world_position))
	assert(main.bullet_manager.count() == 1)
	var gun1_world := (enemy.node as Node3D).to_global((enemy.gun1 as Node3D).position)
	var gun1_bullet: Dictionary = main.bullet_manager.bullets[0]
	var gun1_origin := Vector2(gun1_world.x, gun1_world.z)
	var gun1_direction := (main.player.pos - gun1_origin).normalized()
	assert((gun1_bullet.pos as Vector2).is_equal_approx(gun1_origin + gun1_direction * 0.34))
	var gun1_forward_3d: Vector3 = (enemy.gun1 as Node3D).global_basis * Vector3(0.0, 0.0, -1.0)
	var gun1_forward := Vector2(gun1_forward_3d.x, gun1_forward_3d.z).normalized()
	assert(gun1_forward.is_equal_approx(gun1_direction))
	main.bullet_manager.clear()
	for frame in range(28):
		enemy.age = 1.90 + float(frame + 1) / 60.0
		main._update_zako_m0_guns(enemy, 1.0 / 60.0)
	var rapid_bullets := main.bullet_manager.bullets.filter(func(bullet: Dictionary) -> bool:
		return is_equal_approx((bullet.vel as Vector2).length(), 7.5)
	)
	assert(rapid_bullets.size() == MainUtil.ZAKO_GUN1_BURST_SHOT_COUNT)
	main.bullet_manager.clear()

	enemy.age = 2.50
	for recovery_step in range(20):
		main._update_zako_m0_guns(enemy, 0.02)
	assert(gun0_visual.position.z < 0.01)
	assert(gun1_visual.position.z < 0.01)

	main.queue_free()
	await process_frame
	await process_frame
	print("zakoM0 recoil verification passed")
	quit()
