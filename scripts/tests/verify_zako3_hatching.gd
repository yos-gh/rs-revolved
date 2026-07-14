extends SceneTree

const MainUtil := preload("res://scripts/prototype/main.gd")


func _init() -> void:
	var main := MainUtil.new()
	root.add_child(main)
	await process_frame

	main._spawn_enemy("zako3p", Vector2(2.0, 0.0))
	var regular_spawn: Dictionary = main.enemies.back()
	assert(regular_spawn.spawn_collision_locked)
	assert(not regular_spawn.damageable)

	var before_hatching := main.enemies.size()
	main._spawn_zako3_parts(Vector2.ZERO, 0.0)
	assert(main.enemies.size() == before_hatching + 4)
	for index in range(before_hatching, main.enemies.size()):
		var part: Dictionary = main.enemies[index]
		assert(part.kind == "zako3p")
		assert(not part.spawn_collision_locked)
		assert(part.damageable)
		assert(part.gum_vulnerable)
		assert(not part.blocks_shots)
		assert(is_zero_approx(part.age))
		main._apply_spawn_effect(part.node, part.age, 2.0, 0.35)
		assert(part.node.scale.is_equal_approx(Vector3.ONE * 2.0))

	main.queue_free()
	await process_frame
	await process_frame
	print("zako3 hatching verification passed")
	quit()
