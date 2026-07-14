extends SceneTree

const GumControllerUtil := preload("res://scripts/game/gum_controller.gd")
const BossGumControllerUtil := preload("res://scripts/game/boss_gum_controller.gd")


func _init() -> void:
	assert(BossGumControllerUtil.count_for_mode("arcade", 5, 5) == 0)
	assert(BossGumControllerUtil.count_for_mode("arcade", 10, 10) == 1)
	assert(BossGumControllerUtil.count_for_mode("arcade", 15, 15) == 2)
	assert(BossGumControllerUtil.count_for_mode("arcade", 10, 15) == 2)
	assert(BossGumControllerUtil.count_for_mode("endless", 0, 5) == 0)
	assert(BossGumControllerUtil.count_for_mode("endless", 0, 10) == 1)
	assert(BossGumControllerUtil.count_for_mode("endless", 0, 14) == 2)
	assert(BossGumControllerUtil.count_for_mode("endless", 0, 15) == 3)
	assert(BossGumControllerUtil.count_for_mode("endless", 0, 16) == 3)
	assert(BossGumControllerUtil.count_for_mode("endless", 0, 17) == 4)
	assert(BossGumControllerUtil.count_for_mode("endless", 0, 18) == 4)

	var gum := GumControllerUtil.new()
	root.add_child(gum)
	gum.setup({
		"gum": Color(0.96, 0.42, 0.78),
		"gum_low": Color(0.35, 0.42, 0.58),
		"gum_empty": Color(1.0, 0.22, 0.16),
	})
	var attack := BossGumControllerUtil.new()
	root.add_child(attack)
	attack.setup(gum)
	assert(attack.get_child_count() == BossGumControllerUtil.MAX_ORBS)

	var player_pos := Vector2(4.0, 0.0)
	var player_axis: Array[Vector2] = [player_pos, player_pos]
	var bullets: Array[Dictionary] = []
	var bullet_shape := func(bullet: Dictionary) -> Dictionary:
		return {
			"type": "circle",
			"pos": bullet.pos,
			"radius": bullet.get("radius", 0.05),
		}

	attack.begin_boss(1, Vector2.ZERO)
	attack.update_attack(3.0, Vector2.ZERO, false, player_pos, false, player_axis, bullets, bullet_shape)
	assert(attack.active_positions().is_empty())
	attack.update_attack(0.0, Vector2.ZERO, true, player_pos, false, player_axis, bullets, bullet_shape)
	assert(attack.active_positions().size() == 1)
	attack.update_attack(0.10, Vector2.ZERO, true, player_pos, false, player_axis, bullets, bullet_shape)
	var launched_pos := attack.active_positions()[0]
	assert(launched_pos.x < 0.0)
	assert(is_equal_approx(launched_pos.length(), BossGumControllerUtil.OUTBOUND_SPEED * 0.10))

	var visual := attack.get_child(0) as Node3D
	var outer := visual.find_child("gum-layer-outer", true, false) as MeshInstance3D
	var blue_material := outer.material_override as StandardMaterial3D
	assert(blue_material.emission.b > blue_material.emission.r)
	assert(blue_material.emission_energy_multiplier > 1.0)
	var trail := attack.find_child("BossGumTrail*", true, false) as Node3D
	assert(trail != null)
	var trail_face := trail.get_child(0) as MeshInstance3D
	var trail_material := trail_face.material_override as StandardMaterial3D
	assert(trail_material.emission.b > trail_material.emission.r)
	assert(trail_material.albedo_color.a <= 0.31)

	var shot := {
		"hostile": false,
		"life": 1.0,
		"pos": launched_pos,
		"radius": 0.05,
		"vel": Vector2.RIGHT,
	}
	bullets.append(shot)
	attack.update_attack(0.0, Vector2.ZERO, true, player_pos, false, player_axis, bullets, bullet_shape)
	assert(shot.life <= 0.0)

	var orb: Dictionary = attack._orbs[0]
	orb.pos = player_pos
	assert(attack.update_attack(0.0, Vector2.ZERO, true, player_pos, true, player_axis, bullets, bullet_shape))
	assert(int(orb.state) == BossGumControllerUtil.OrbState.RETURNING)
	orb.state = BossGumControllerUtil.OrbState.ACTIVE
	orb.age = BossGumControllerUtil.ACTIVE_LIFETIME - 0.01
	orb.pos = Vector2(-2.0, 0.0)
	attack.update_attack(0.02, Vector2.ZERO, true, player_pos, false, player_axis, bullets, bullet_shape)
	assert(int(orb.state) == BossGumControllerUtil.OrbState.RETURNING)
	var depleted_material := outer.material_override as StandardMaterial3D
	assert(depleted_material.emission.r > depleted_material.emission.b)

	orb.state = BossGumControllerUtil.OrbState.RETURNING
	orb.pos = Vector2(1.0, 0.0)
	var return_shot := {
		"hostile": false,
		"life": 1.0,
		"pos": orb.pos,
		"radius": 0.05,
		"vel": Vector2.LEFT,
	}
	bullets = [return_shot]
	attack.update_attack(0.01, Vector2.ZERO, true, player_pos, true, player_axis, bullets, bullet_shape)
	assert(is_equal_approx(return_shot.life, 1.0))
	assert(int(orb.state) == BossGumControllerUtil.OrbState.RETURNING)

	orb.pos = Vector2(0.10, 0.0)
	attack.update_attack(0.01, Vector2.ZERO, true, player_pos, false, player_axis, bullets, bullet_shape)
	assert(int(orb.state) == BossGumControllerUtil.OrbState.WAITING)
	assert(is_equal_approx(float(orb.wait), BossGumControllerUtil.RELOAD_DELAY))
	assert(not visual.visible)

	attack.set_desired_count(0, Vector2.ZERO, true)
	attack.set_desired_count(4, Vector2.ZERO, true)
	attack.update_attack(0.0, Vector2.ZERO, true, player_pos, false, player_axis, bullets, bullet_shape)
	assert(attack.active_positions().size() == 4)
	attack.set_desired_count(2, Vector2.ZERO, true)
	assert(attack.active_positions().size() == 2)

	attack.queue_free()
	gum.queue_free()
	await process_frame
	await process_frame
	print("boss gum attack verification passed")
	quit()
