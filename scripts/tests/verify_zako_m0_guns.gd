extends SceneTree

const MainUtil := preload("res://scripts/prototype/main.gd")


func _init() -> void:
	var main := MainUtil.new()
	root.add_child(main)
	await process_frame
	main._spawn_enemy("zakoM0", Vector2(3.0, 2.0))
	var enemy: Dictionary = main.enemies.back()
	(enemy.node as Node3D).rotation.y = 0.73

	enemy.age = 1.021
	main._update_zako_m0_guns(enemy, 0.02)
	assert(main.bullet_manager.count() == 1)
	var gun0_world := (enemy.node as Node3D).to_global((enemy.gun0 as Node3D).position)
	var gun0_bullet: Dictionary = main.bullet_manager.bullets[0]
	assert((gun0_bullet.pos as Vector2).is_equal_approx(Vector2(gun0_world.x, gun0_world.z)))
	main.bullet_manager.clear()

	enemy.age = 2.201
	main._update_zako_m0_guns(enemy, 0.02)
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

	main.queue_free()
	await process_frame
	await process_frame
	print("zakoM0 gun verification passed")
	quit()
