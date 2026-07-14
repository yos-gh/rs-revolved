extends SceneTree

const BulletManagerUtil := preload("res://scripts/game/bullet_manager.gd")


func _init() -> void:
	var manager := BulletManagerUtil.new()
	root.add_child(manager)
	manager.setup({})

	for i in range(100):
		manager.spawn_hostile_bullet(Vector2(float(i) * 0.03, 0.0), 0.15, BulletManagerUtil.BULLET0_SPEED, true, "circle")
	for i in range(25):
		manager.spawn_hostile_bullet(Vector2(float(i) * 0.04, 0.4), 0.35, BulletManagerUtil.BULLET1_SPEED, true, "capsule")
	manager.flush_visual_batches()

	var batch_root := manager.get_node("BatchedBulletVisuals") as Node3D
	assert(batch_root != null)
	assert(manager.get_child_count() == 1)

	var bullet0_outer := manager.get_node("BatchedBulletVisuals/bullet0_outer-batch") as MultiMeshInstance3D
	var bullet0_inner := manager.get_node("BatchedBulletVisuals/bullet0_inner-batch") as MultiMeshInstance3D
	var bullet0_tail := manager.get_node("BatchedBulletVisuals/bullet0_tail_light-batch") as MultiMeshInstance3D
	var bullet1_outer := manager.get_node("BatchedBulletVisuals/bullet1_outer-batch") as MultiMeshInstance3D
	assert(bullet0_outer.multimesh.instance_count == 100)
	assert(bullet0_inner.multimesh.instance_count == 100)
	assert(bullet0_tail.multimesh.instance_count == 100)
	assert(bullet1_outer.multimesh.instance_count == 25)

	manager.clear()
	assert(bullet0_outer.multimesh.instance_count == 0)
	assert(bullet1_outer.multimesh.instance_count == 0)

	manager.queue_free()
	await process_frame
	await process_frame
	print("bullet visual batching verification passed")
	quit()
