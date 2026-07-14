extends SceneTree

const BulletManagerUtil := preload("res://scripts/game/bullet_manager.gd")


func _init() -> void:
	var manager := BulletManagerUtil.new()
	root.add_child(manager)
	var player_axis: Array[Vector2] = [Vector2(100.0, 100.0), Vector2(100.0, 100.0)]

	manager.bullets.append(_test_bullet(manager, Vector2.ZERO, BulletManagerUtil.DEFAULT_HOSTILE_BULLET_LIFETIME))
	manager.update_bullets(4.0, 16.0, 9.0, 2.0, false, player_axis, [])
	assert(manager.count() == 1)

	manager.bullets[0].pos = Vector2(20.0, 0.0)
	manager.update_bullets(0.1, 16.0, 9.0, 2.0, false, player_axis, [])
	assert(manager.count() == 0)

	manager.bullets.append(_test_bullet(manager, Vector2.ZERO, 0.5))
	manager.update_bullets(0.6, 16.0, 9.0, 2.0, false, player_axis, [])
	assert(manager.count() == 0)

	manager.queue_free()
	await process_frame
	await process_frame
	print("bullet lifetime verification passed")
	quit()


func _test_bullet(manager: BulletManager, pos: Vector2, life: float) -> Dictionary:
	var node := Node3D.new()
	manager.add_child(node)
	return {
		"node": node,
		"pos": pos,
		"vel": Vector2.ZERO,
		"angle": 0.0,
		"shape": "circle",
		"radius": BulletManagerUtil.HOSTILE_BULLET_RADIUS,
		"length": 0.0,
		"life": life,
		"hostile": true,
		"gum_blockable": true,
	}
