extends SceneTree

const GameStateUtil := preload("res://scripts/game/game_state.gd")
const MainUtil := preload("res://scripts/prototype/main.gd")
const EnemyUtil := preload("res://scripts/game/enemy.gd")


func _init() -> void:
	var state := GameStateUtil.new()
	assert(EnemyUtil.boss_turret_score("boss_turret_t1") == 800)
	assert(EnemyUtil.boss_turret_score("boss_turret_t2") == 200)
	assert(EnemyUtil.boss_turret_score("boss_turret_t3") == 1200)
	state.start_arcade()
	state.add_enemy_score(20)
	assert(is_equal_approx(state.tension, 20.0))
	assert(is_equal_approx(state.score, 40.0))
	state.update_tension(1.0)
	assert(is_equal_approx(state.tension, 14.0))
	state.set_arcade_rank(10)
	state.tension = 100.0
	state.update_tension(1.0)
	assert(is_equal_approx(state.tension, 34.0))
	state.reset_tension()
	assert(is_zero_approx(state.tension))
	var guaranteed_t2 := GameStateUtil.minimum_score_for_base(EnemyUtil.BOSS_TURRET_T2_SCORE)
	assert(is_equal_approx(guaranteed_t2, 4000.0))
	var chain_score := state.add_enemy_score(EnemyUtil.BOSS_TURRET_T2_SCORE, false, guaranteed_t2)
	assert(is_equal_approx(chain_score, 4000.0))
	assert(is_zero_approx(state.tension))
	state.tension = 300.0
	chain_score = state.add_enemy_score(EnemyUtil.BOSS_TURRET_T2_SCORE, false, guaranteed_t2)
	assert(is_equal_approx(chain_score, 6000.0))
	assert(is_equal_approx(state.tension, 300.0))
	var manual_clear := GameStateUtil.new()
	manual_clear.start_arcade()
	manual_clear.add_enemy_score(EnemyUtil.BOSS_TURRET_T1_SCORE)
	manual_clear.add_enemy_score(EnemyUtil.BOSS_TURRET_T2_SCORE)
	var chained_clear := GameStateUtil.new()
	chained_clear.start_arcade()
	for base_score in [EnemyUtil.BOSS_TURRET_T1_SCORE, EnemyUtil.BOSS_TURRET_T2_SCORE]:
		chained_clear.add_enemy_score(base_score, false, GameStateUtil.minimum_score_for_base(base_score))
	assert(manual_clear.score > chained_clear.score)
	assert(is_equal_approx(manual_clear.tension, GameStateUtil.MAX_TENSION))
	assert(is_zero_approx(chained_clear.tension))

	state.reset_for_arcade()
	state.debug_add_score(GameStateUtil.EXTEND_SCORE_INTERVAL)
	assert(state.player_lives == GameStateUtil.PLAYER_START_LIVES + 1)
	state.debug_add_score(GameStateUtil.EXTEND_SCORE_INTERVAL * 3.0)
	assert(state.player_lives == GameStateUtil.PLAYER_START_LIVES + 2)
	for extend_index in range(20):
		state.grant_boss_extend()
	assert(state.player_lives == GameStateUtil.MAX_PLAYER_LIVES)

	state.reset_for_arcade()
	state.score = 24999.0
	state.update_arcade_rank_from_score()
	assert(state.arcade_rank == 5)
	for base_score in [EnemyUtil.BOSS_TURRET_T2_SCORE, EnemyUtil.BOSS_TURRET_T1_SCORE]:
		state.add_enemy_score(base_score)
	assert(state.arcade_rank >= GameStateUtil.ARCADE_BGM_RANK_2)
	assert(state.arcade_rank < GameStateUtil.ARCADE_BGM_RANK_3)
	assert(state.music_stage == 2)

	var main := MainUtil.new()
	root.add_child(main)
	await process_frame
	main.set_process(false)
	main.game_state.start_arcade()
	main.game_state.set_arcade_rank(9)
	main.game_state.score = 189999.0
	main.game_state.tension = 0.0
	main.game_state.next_extend_score = 240000.0
	main.game_state.update_arcade_rank_from_score()
	assert(main.game_state.arcade_rank == 10)
	for turret_data in [
		["boss_turret_t2", EnemyUtil.BOSS_TURRET_T2_SCORE],
		["boss_turret_t3", EnemyUtil.BOSS_TURRET_T3_SCORE],
		["boss_turret_t2", EnemyUtil.BOSS_TURRET_T2_SCORE],
		["boss_turret_t1", EnemyUtil.BOSS_TURRET_T1_SCORE],
	]:
		main.enemies.append({
			"kind": turret_data[0],
			"life": 1,
			"score_base": turret_data[1],
			"pos": Vector2.ZERO,
			"radius": 0.5,
			"color": Color.ORANGE,
		})
	main._award_remaining_boss_turret_scores()
	assert(is_zero_approx(main.game_state.tension))
	assert(is_equal_approx(main.game_state.score, 269999.0))
	assert(main.game_state.arcade_rank >= GameStateUtil.ARCADE_BGM_RANK_3)
	assert(main.game_state.music_stage == 3)
	assert(main.game_state.score >= main.game_state.arcade_score_floor_for_rank(11))
	assert(EnemyUtil.BOSS_TURRET_T3_SCORE == 1200)
	for enemy in main.enemies:
		assert(enemy.life == 0)

	main.queue_free()
	await process_frame
	await process_frame
	print("score progression verification passed")
	quit()
