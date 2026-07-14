extends SceneTree

const BulletManagerUtil := preload("res://scripts/game/bullet_manager.gd")


func _init() -> void:
	assert(is_equal_approx(BulletManagerUtil.BULLET1_VISUAL_LENGTH, 0.552))
	assert(is_equal_approx(BulletManagerUtil.BULLET1_INNER_LENGTH, 0.48))
	var bullets := BulletManagerUtil.new()
	root.add_child(bullets)
	bullets.setup({"boss_unblockable": Color.RED, "zako3p": Color.ORANGE})
	bullets.spawn_hostile_bullet(Vector2.ZERO, 0.0, BulletManagerUtil.BULLET1_SPEED, true, "capsule")
	bullets.flush_visual_batches()
	var bullet: Dictionary = bullets.bullets[0]
	assert(bullet.node == null)
	assert(bullet.visual_key == "bullet1")
	assert(bullet.batched_visual)
	var outer_batch := bullets.get_node("BatchedBulletVisuals/bullet1_outer-batch") as MultiMeshInstance3D
	assert(outer_batch != null)
	assert(outer_batch.multimesh.instance_count == 1)
	assert(is_equal_approx(outer_batch.multimesh.mesh.get_aabb().size.z, BulletManagerUtil.BULLET1_VISUAL_LENGTH))
	var shape: Dictionary = bullets.shape_for(bullet)
	var centerline_length := (shape.b as Vector2).distance_to(shape.a as Vector2)
	assert(is_equal_approx(centerline_length, BulletManagerUtil.BULLET1_COLLISION_LENGTH))
	assert(centerline_length + float(shape.radius) * 2.0 <= BulletManagerUtil.BULLET1_VISUAL_LENGTH + 0.0001)
	assert(float(shape.radius) <= BulletManagerUtil.BULLET1_VISUAL_HALF_WIDTH)
	bullets.queue_free()
	await process_frame
	await process_frame
	print("bullet1 visual verification passed")
	quit()
