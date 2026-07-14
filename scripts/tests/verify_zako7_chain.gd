extends SceneTree

const EnemyUtil := preload("res://scripts/game/enemy.gd")
const MainUtil := preload("res://scripts/prototype/main.gd")


func _init() -> void:
	var main := MainUtil.new()
	root.add_child(main)
	await process_frame
	var leader_node := Node3D.new()
	var follower_node := Node3D.new()
	main.add_child(leader_node)
	main.add_child(follower_node)
	var leader := EnemyUtil.create_zako("zako7", leader_node, Vector2.ZERO, 0.0, Color.MAGENTA, 1)
	var follower := EnemyUtil.create_zako("zako7p", follower_node, Vector2(-1.2, 0.0), 0.0, Color.ORANGE, 1)
	assert(not main._enemy_is_destroyed_on_player_contact(follower))
	leader.segment = 0
	follower.segment = 1
	follower.chain_id = 1
	main.enemies = [leader, follower]

	var far_start: Vector2 = follower.pos
	main._update_chain_segment(follower, 0.1)
	assert(is_equal_approx(follower.pos.distance_to(far_start), EnemyUtil.ZAKO7P_SPEED * 2.0 * 0.1))

	follower.pos = Vector2(-0.2, 0.0)
	follower.angle = 0.0
	var close_start: Vector2 = follower.pos
	main._update_chain_segment(follower, 0.1)
	assert(is_equal_approx(follower.pos.distance_to(close_start), EnemyUtil.ZAKO7P_SPEED * 0.5 * 0.1))

	var offscreen_follower: Dictionary = follower.duplicate()
	offscreen_follower.pos = Vector2(MainUtil.FIELD_W, MainUtil.FIELD_H)
	assert(main._enemy_stays_live(offscreen_follower))
	EnemyUtil.release_chain_part(offscreen_follower)
	assert(not main._enemy_stays_live(offscreen_follower))

	leader.pos = Vector2.ZERO
	follower.pos = Vector2(0.0, -MainUtil.ZAKO7_CHAIN_SPACING)
	leader.angle = 0.0
	follower.angle = 0.0
	main._update_chain_segment(follower, 0.01)
	var normal_turn: float = follower.angle
	follower.pos = Vector2(0.0, -MainUtil.ZAKO7_CHAIN_SPACING)
	leader.angle = PI
	follower.angle = 0.0
	main._update_chain_segment(follower, 0.01)
	assert(follower.angle > normal_turn)

	follower_node.add_child(main._zako7p_mini_crystal_model(Color.ORANGE))
	follower.shadow = null
	EnemyUtil.release_chain_part(follower)
	follower.color = Color.YELLOW
	main._replace_released_zako7p_visual(follower)
	follower.chain_released = true
	assert(main._enemy_is_destroyed_on_player_contact(follower))
	assert(follower_node.find_child("zako3p-low-wedge", true, false) != null)
	assert(follower_node.find_child("zako7p-mini-crystal", true, false) == null)
	assert(String(follower.visual_batch_kind) == "zako3p")
	assert(follower.shadow == null)
	assert(follower.damageable)
	assert(follower.gum_vulnerable)
	assert(not follower.blocks_shots)

	main.queue_free()
	await process_frame
	await process_frame
	print("zako7 chain verification passed")
	quit()
