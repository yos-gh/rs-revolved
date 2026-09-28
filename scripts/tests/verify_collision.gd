extends SceneTree

const BulletManagerUtil := preload("res://scripts/game/bullet_manager.gd")
const CollisionUtil := preload("res://scripts/core/collision.gd")


func _init() -> void:
	var manager := BulletManagerUtil.new()
	root.add_child(manager)
	manager.setup({"shot": Color(0.80, 0.95, 1.0)})
	manager.spawn_player_shot(Vector2.ZERO, 0.25)

	assert(manager.bullets.size() == 1)
	var shot: Dictionary = manager.bullets[0]
	assert(not shot.hostile)
	assert(shot.shape == "capsule")
	assert(is_equal_approx(shot.radius, BulletManagerUtil.PLAYER_SHOT_RADIUS))
	assert(is_equal_approx(shot.length, BulletManagerUtil.PLAYER_SHOT_LENGTH))
	assert(is_equal_approx(shot.vel.length(), BulletManagerUtil.SHOT_SPEED))

	var shot_shape := {
		"type": "capsule",
		"a": Vector2(-BulletManagerUtil.PLAYER_SHOT_LENGTH * 0.5, 0.0),
		"b": Vector2(BulletManagerUtil.PLAYER_SHOT_LENGTH * 0.5, 0.0),
		"radius": BulletManagerUtil.PLAYER_SHOT_RADIUS,
	}
	var fallback_enemy := {"pos": Vector2(0.60, 0.0), "radius": 0.30}
	var contact := CollisionUtil.contact_point_on_enemy(shot_shape, fallback_enemy, Vector2.RIGHT)
	assert(contact.is_equal_approx(Vector2(0.30, 0.0)))

	var shaped_enemy := {
		"pos": Vector2(0.8, 0.0),
		"radius": 1.0,
		"t_body_angle": 0.0,
		"collision_parts": [
			{"type": "capsule", "a": Vector2(-0.4, 0.0), "b": Vector2(0.4, 0.0), "radius": 0.1},
		],
	}
	assert(CollisionUtil.shape_overlaps_enemy(shot_shape, shaped_enemy))
	var shaped_contact := CollisionUtil.contact_point_on_enemy(shot_shape, shaped_enemy, Vector2.RIGHT)
	assert(shaped_contact.is_equal_approx(Vector2(0.3, 0.0)))
	shaped_enemy.t_body_angle = PI * 0.5
	assert(not CollisionUtil.shape_overlaps_enemy(shot_shape, shaped_enemy))
	assert(CollisionUtil.shape_overlaps_enemy(shot_shape, fallback_enemy))

	manager.queue_free()
	await process_frame
	await process_frame
	print("collision verification passed")
	quit()
