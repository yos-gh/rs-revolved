extends SceneTree

const BulletManagerUtil := preload("res://scripts/game/bullet_manager.gd")


func _init() -> void:
	var manager := BulletManagerUtil.new()
	root.add_child(manager)
	manager.setup({"boss_unblockable": Color(1.0, 0.12, 0.52), "zako3p": Color(1.0, 0.66, 0.12), "shot": Color.WHITE})
	manager.spawn_hostile_bullet(Vector2.ZERO, 0.0, BulletManagerUtil.BOSS_B2_SPEED, false, "boss_b2")

	assert(manager.bullets.size() == 1)
	var bullet: Dictionary = manager.bullets[0]
	assert(bullet.behavior == "boss_b2")
	assert(bullet.shape == "circle")
	assert(bullet.gum_blockable)
	assert(bullet.shot_blockable)
	assert(is_equal_approx(bullet.radius, BulletManagerUtil.BOSS_B2_RADIUS))

	var player_axis: Array[Vector2] = [Vector2(0.0, 4.0), Vector2(0.0, 4.0)]
	manager.update_bullets(0.1, 16.0, 9.0, 2.0, false, player_axis, [])
	bullet = manager.bullets[0]
	assert(is_equal_approx(bullet.angle, BulletManagerUtil.BOSS_B2_HOMING_RATE * 0.1))
	assert(is_equal_approx(bullet.vel.length(), BulletManagerUtil.BOSS_B2_SPEED))

	manager.clear()
	manager.spawn_hostile_bullet(Vector2.ZERO, 0.0, BulletManagerUtil.BOSS_B2_SPEED, true, "boss_b2")
	manager.spawn_player_shot(Vector2.ZERO, 0.0)
	manager.update_bullets(0.001, 16.0, 9.0, 2.0, false, player_axis, [])
	assert(manager.bullets.is_empty())

	manager.queue_free()
	await process_frame
	await process_frame
	print("boss b2 homing verification passed")
	quit()
