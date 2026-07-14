extends SceneTree

const MainUtil := preload("res://scripts/prototype/main.gd")
const BossUtil := preload("res://scripts/game/boss.gd")
const BulletManagerUtil := preload("res://scripts/game/bullet_manager.gd")
const EnemyUtil := preload("res://scripts/game/enemy.gd")
const GameStateUtil := preload("res://scripts/game/game_state.gd")


func _init() -> void:
	var main := MainUtil.new()
	var t1_model: Node3D = main._boss_t_stepped_citadel_model("boss_turret_t1", Color.ORANGE)
	var t2_model: Node3D = main._boss_t_stepped_citadel_model("boss_turret_t2", Color.ORANGE_RED)
	var t3_model: Node3D = main._boss_t_stepped_citadel_model("boss_turret_t3", Color.YELLOW)
	root.add_child(t1_model)
	root.add_child(t2_model)
	root.add_child(t3_model)

	for model in [t1_model, t2_model, t3_model]:
		assert((model as Node3D).scale.is_equal_approx(Vector3.ONE * MainUtil.BOSS_TURRET_OVERALL_SCALE))
		var body_visual := (model as Node3D).find_child("boss-t-body-visual", false, false) as Node3D
		var tripod_base := (model as Node3D).find_child("boss-t-tripod-base", false, false) as Node3D
		assert(body_visual != null)
		assert(tripod_base != null)
		assert(body_visual.scale.is_equal_approx(Vector3.ONE * MainUtil.BOSS_TURRET_VISUAL_SCALE))
		var body_faces := main._boss_t_body_faces(body_visual)
		assert(body_faces.size() >= 1)
		for face in body_faces:
			assert((face as MeshInstance3D).has_meta("base_alpha"))
			assert((face as MeshInstance3D).has_meta("hit_alpha_gain"))
		assert(body_visual.find_child("boss-t-damage-field", true, false) == null)
		var leg_panel_count := 0
		for base_mesh in tripod_base.find_children("*", "MeshInstance3D", true, false):
			if (base_mesh as MeshInstance3D).get_meta("tripod_leg_panel", false):
				leg_panel_count += 1
			assert(not (base_mesh as MeshInstance3D).has_meta("base_alpha"))
		assert(leg_panel_count == 3)
	assert(t1_model.find_child("boss-t-rapid-rail-body", true, false) != null)
	assert(t2_model.find_child("boss-t-opposing-frame-body", true, false) != null)
	assert(t3_model.find_child("boss-t-burst-triad-body", true, false) != null)
	assert(is_equal_approx(main._boss_turret_radius("boss_turret_t1"), 0.86 * MainUtil.BOSS_TURRET_VISUAL_SCALE * MainUtil.BOSS_TURRET_OVERALL_SCALE))
	assert(is_equal_approx(main._boss_turret_radius("boss_turret_t2"), 0.82 * MainUtil.BOSS_TURRET_VISUAL_SCALE * MainUtil.BOSS_TURRET_OVERALL_SCALE))
	assert(is_equal_approx(main._boss_turret_radius("boss_turret_t3"), 0.76 * MainUtil.BOSS_TURRET_VISUAL_SCALE * MainUtil.BOSS_TURRET_OVERALL_SCALE))
	assert(t1_model.find_children("boss-gun1-needle-prism", "Node3D", true, false).size() == 2)
	assert(t2_model.find_children("boss-gun2-opposing-prism", "Node3D", true, false).size() == 2)
	assert(t1_model.find_child("boss-t1-rapid-gun-left", false, false).get_parent() == t1_model)
	assert(t2_model.find_child("boss-t2-opposing-gun", false, false).get_parent() == t2_model)
	assert(t3_model.find_child("boss-t3-emitter-1", false, false).get_parent() == t3_model)
	assert(is_equal_approx((t2_model.find_child("boss-t2-opposing-gun", false, false) as Node3D).position.y, 0.30 * MainUtil.BOSS_T2_OPPOSING_GUN_HEIGHT_RATIO))
	assert(is_equal_approx(MainUtil.BOSS_T_RAPID_GUN_EDGE_WIDTH, 0.016))
	assert(is_equal_approx(MainUtil.BOSS_T_DIRECTION_GUN_EDGE_WIDTH, 0.017))

	var bullets := BulletManagerUtil.new()
	root.add_child(bullets)
	bullets.setup({"boss_unblockable": Color.RED, "zako3p": Color.ORANGE})
	var t1_body := t1_model.find_child("boss-t-body-visual", false, false) as Node3D
	var t1_faces := main._boss_t_body_faces(t1_body)
	var t1_enemy := EnemyUtil.create_boss_turret("boss_turret_t1", t1_model, Vector2.ZERO, Color.ORANGE, 240, 0.52, Vector2.RIGHT * 3.0)
	t1_enemy.age = 0.6
	t1_enemy.body_visual = t1_body
	t1_enemy.body_faces = t1_faces
	t1_enemy.tripod_base = t1_model.find_child("boss-t-tripod-base", false, false)
	var face := t1_faces[0] as MeshInstance3D
	var material := face.material_override as ShaderMaterial
	var base_alpha: float = face.get_meta("base_alpha")
	var base_emission: float = face.get_meta("base_emission")
	var boss := BossUtil.new()
	assert(is_equal_approx(boss._turret_overall_scale(t1_enemy), MainUtil.BOSS_TURRET_OVERALL_SCALE))
	boss.update_enemy(t1_enemy, 0.016, Vector2.DOWN, bullets, GameStateUtil.new(), [t1_enemy])
	t1_enemy.life -= 1
	boss.update_enemy(t1_enemy, 0.016, Vector2.DOWN, bullets, GameStateUtil.new(), [t1_enemy])
	var hit_color := material.get_shader_parameter("face_color") as Color
	assert(hit_color.a > base_alpha)
	assert(float(material.get_shader_parameter("emission_strength")) > base_emission)
	var first_flash: float = t1_enemy.turret_damage_flash
	t1_enemy.life -= 1
	boss.update_enemy(t1_enemy, 0.016, Vector2.DOWN, bullets, GameStateUtil.new(), [t1_enemy])
	assert(t1_enemy.turret_damage_flash < first_flash)
	for recovery_step in range(8):
		boss.update_enemy(t1_enemy, 0.016, Vector2.DOWN, bullets, GameStateUtil.new(), [t1_enemy])
	assert(is_zero_approx(t1_enemy.turret_damage_flash))
	var recovered_color := material.get_shader_parameter("face_color") as Color
	assert(is_equal_approx(recovered_color.a, base_alpha))
	assert(is_equal_approx(float(material.get_shader_parameter("emission_strength")), base_emission))

	bullets.queue_free()
	t1_model.queue_free()
	t2_model.queue_free()
	t3_model.queue_free()
	main.queue_free()
	await process_frame
	await process_frame
	print("boss t gun visual verification passed")
	quit()
