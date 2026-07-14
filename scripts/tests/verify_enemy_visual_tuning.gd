extends SceneTree

const MainUtil := preload("res://scripts/prototype/main.gd")
const EnemyUtil := preload("res://scripts/game/enemy.gd")


func _init() -> void:
	assert(is_equal_approx(MainUtil.ZAKO5_VISUAL_SCALE, 0.58))
	assert(is_equal_approx(MainUtil.ZAKO7_VISUAL_SCALE, 0.68))
	assert(is_equal_approx(MainUtil.ZAKO7_CHAIN_SPACING, 0.65))
	assert(is_equal_approx(MainUtil.ZAKO1_VISUAL_SCALE, 0.85))
	assert(is_equal_approx(MainUtil.ZAKO1_VISUAL_ROLL_SPEED, 0.72))
	assert(is_equal_approx(MainUtil.ZAKO1_CROSS_SECTION_RADIUS, 0.28))
	assert(is_equal_approx(MainUtil.ZAKO0_VISUAL_MAX_BANK, deg_to_rad(60.0)))
	assert(is_equal_approx(MainUtil.ZAKO0_VISUAL_MAX_PITCH, deg_to_rad(20.0)))
	assert(is_equal_approx(MainUtil.ZAKO0_VISUAL_FULL_BANK_TURN_RATE, 0.75))
	assert(is_equal_approx(MainUtil.ZAKO3P_VISUAL_SCALE, 1.35))
	assert(is_equal_approx(MainUtil.ZAKO_BASE_OUTLINE_WIDTH, 0.012))
	assert(is_equal_approx(MainUtil.ZAKO4_OUTLINE_WIDTH, MainUtil.ZAKO_BASE_OUTLINE_WIDTH))
	assert(is_equal_approx(MainUtil.ZAKO6_OUTER_OUTLINE_WIDTH, MainUtil.ZAKO_BASE_OUTLINE_WIDTH))
	assert(is_equal_approx(MainUtil.ZAKOM1_OUTLINE_WIDTH, MainUtil.ZAKO_BASE_OUTLINE_WIDTH))
	assert(is_equal_approx(MainUtil.ZAKOM1_RIDGE_WIDTH, 0.014))
	assert(is_equal_approx(MainUtil.ZAKOM1_VISUAL_ROLL_SPEED, 0.82))
	assert(is_equal_approx(EnemyUtil.zako_radius("zako1"), 0.41))
	assert(is_equal_approx(EnemyUtil.zako_radius("zako3p"), EnemyUtil.zako_radius("zako7p")))
	assert(is_equal_approx(EnemyUtil.zako_radius("zako5"), EnemyUtil.zako_radius("zako0")))
	assert(is_equal_approx(EnemyUtil.zako_radius("zako7"), EnemyUtil.zako_radius("zako0")))
	assert(is_equal_approx(EnemyUtil.zako_radius("zako7p"), 0.28))

	var main := MainUtil.new()
	var zako0_root := Node3D.new()
	var zako0_model := main._zako0_dihedral_model(Color.RED)
	zako0_root.add_child(zako0_model)
	zako0_root.rotation.y = -0.72
	main._update_moving_visual(
		zako0_root,
		zako0_model,
		Vector2.from_angle(0.35),
		0.8,
		0.12,
		MainUtil.ZAKO0_VISUAL_MAX_BANK,
		MainUtil.ZAKO0_VISUAL_MAX_PITCH,
		MainUtil.ZAKO0_VISUAL_RESPONSE
	)
	assert(absf(zako0_model.rotation.x) > 0.001 or absf(zako0_model.rotation.z) > 0.001)
	assert(is_zero_approx(zako0_root.rotation.x))
	assert(is_zero_approx(zako0_root.rotation.z))
	var turn_input := main._normalized_turn_input(0.0, 0.075, 0.1, MainUtil.ZAKO0_VISUAL_FULL_BANK_TURN_RATE)
	assert(is_equal_approx(turn_input, 1.0))
	for step in range(30):
		main._update_moving_visual(
			zako0_root,
			zako0_model,
			Vector2.from_angle(-zako0_root.rotation.y - PI * 0.5),
			1.0,
			1.0 / 60.0,
			MainUtil.ZAKO0_VISUAL_MAX_BANK,
			MainUtil.ZAKO0_VISUAL_MAX_PITCH,
			MainUtil.ZAKO0_VISUAL_RESPONSE
		)
	assert(absf(zako0_model.rotation.z) > deg_to_rad(50.0))
	var zako1_model := main._zako1_thin_wedge_model(Color.ORANGE)
	assert(zako1_model.name == "drifter-zako1")
	assert(zako1_model.get_child_count() == 13)
	var initial_basis := zako1_model.basis
	main._update_zako1_visual_roll(zako1_model, 0.5)
	assert(not zako1_model.basis.is_equal_approx(initial_basis))
	var zakom1_model := main._zako_m1_ridged_crystal_model(Color.ORANGE)
	assert(zakom1_model.get_child_count() == 34)
	var zakom1_initial_basis := zakom1_model.basis
	main._update_zako_m1_visual_roll(zakom1_model, 0.5)
	assert(not zakom1_model.basis.is_equal_approx(zakom1_initial_basis))
	zako1_model.free()
	zakom1_model.free()
	zako0_root.free()
	main.free()

	print("enemy visual tuning verification passed")
	quit()
