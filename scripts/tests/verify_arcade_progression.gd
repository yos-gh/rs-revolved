extends SceneTree

const GameStateUtil := preload("res://scripts/game/game_state.gd")


func _init() -> void:
	var state := GameStateUtil.new()
	state.start_arcade()
	state.debug_add_score(10000000.0)
	assert(state.arcade_rank == 15)
	assert(state.pending_arcade_boss_rank == 5)

	for boss_rank in [5, 10, 15]:
		state.start_boss_mode()
		assert(state.active_arcade_boss_rank == boss_rank)
		if boss_rank == 15:
			state.complete_arcade()
			assert(state.arcade_cleared)
		else:
			state.end_boss_mode()
			assert(state.completed_arcade_boss_rank == boss_rank)
			assert(state.pending_arcade_boss_rank == boss_rank + 5)
	quit()
