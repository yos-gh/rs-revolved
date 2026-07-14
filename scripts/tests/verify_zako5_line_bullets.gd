extends SceneTree

const MainUtil := preload("res://scripts/prototype/main.gd")
const BulletManagerUtil := preload("res://scripts/game/bullet_manager.gd")


func _init() -> void:
	seed(97531)
	var main := MainUtil.new()
	root.add_child(main)
	await process_frame
	main.player.pos = Vector2(3.0, 2.0)
	main._spawn_enemy("zako5", Vector2(-3.0, -1.6))
	var enemy: Dictionary = main.enemies.back()
	enemy.fire_offset = 0.0
	enemy.angle = 0.0
	var last_rail_count := 0
	var aligned_spawn_checks := 0
	for frame in range(260):
		main._update_enemies(1.0 / 60.0)
		main.bullet_manager.flush_visual_batches()
		var current_rail_count := _rail_count(main.bullet_manager.bullets)
		if current_rail_count > last_rail_count:
			var newest_rail := _newest_rail(main.bullet_manager.bullets)
			assert((newest_rail.pos as Vector2).distance_to(enemy.pos) < 0.001)
			aligned_spawn_checks += 1
			last_rail_count = current_rail_count
	var rails: Array[Dictionary] = []
	for bullet in main.bullet_manager.bullets:
		if bullet.get("visual_key", "") == "bullet3":
			rails.append(bullet)
	assert(rails.size() >= 12)
	assert(aligned_spawn_checks >= 12)
	for rail in rails:
		assert(is_equal_approx(float(rail.visual_length), MainUtil.ZAKO5_LINE_BULLET_LENGTH))
		assert(is_equal_approx(float(rail.length) + float(rail.radius) * 2.0, MainUtil.ZAKO5_LINE_BULLET_LENGTH))
	assert(MainUtil.ZAKO5_LINE_BULLET_LENGTH < BulletManagerUtil.ZAKO_LINE_BULLET_LENGTH)
	main.queue_free()
	await process_frame
	await process_frame
	print("zako5 line bullet verification passed")
	quit()


func _rail_count(bullets: Array[Dictionary]) -> int:
	var count := 0
	for bullet in bullets:
		if bullet.get("visual_key", "") == "bullet3":
			count += 1
	return count


func _newest_rail(bullets: Array[Dictionary]) -> Dictionary:
	for index in range(bullets.size() - 1, -1, -1):
		var bullet := bullets[index]
		if bullet.get("visual_key", "") == "bullet3":
			return bullet
	assert(false)
	return {}
