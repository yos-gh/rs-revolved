extends SceneTree

const SpawnerUtil := preload("res://scripts/game/spawner.gd")
const PlayfieldUtil := preload("res://scripts/core/playfield.gd")

const SAMPLE_FRAMES := 120000
const FIELD_W := PlayfieldUtil.FIELD_W
const FIELD_H := PlayfieldUtil.FIELD_H
const SPAWN_MARGIN := 0.65


func _init() -> void:
	seed(24681357)
	var rank_0 := _sample_rank(0)
	var rank_6 := _sample_rank(6)
	var rank_11 := _sample_rank(11)

	assert(rank_0.get("zako5", 0) == 0)
	assert(rank_0.get("zakoM1", 0) == 0)
	assert(rank_6.get("zako5", 0) > 0)
	assert(rank_6.get("zakoM1", 0) == 0)
	assert(rank_11.get("zakoM1", 0) > 0)

	_assert_same_frame_cap_keeps_independent_checks()
	_assert_common_order(rank_0)
	_assert_common_order(rank_6)
	_assert_common_order(rank_11)
	quit()


func _sample_rank(rank: int) -> Dictionary:
	var spawner := SpawnerUtil.new()
	var counts := {}
	for kind in SpawnerUtil.SPAWN_RULES.keys():
		counts[kind] = 0
	for frame in range(SAMPLE_FRAMES):
		spawner.generator_counter += 1
		spawner._evaluate_original_spawn_frame("arcade", rank, [], FIELD_W, FIELD_H, SPAWN_MARGIN, Vector2.ZERO)
		while not spawner.spawn_queue.is_empty():
			var request: Dictionary = spawner.spawn_queue.pop_front()
			counts[request.kind] += 1
	return counts


func _assert_common_order(counts: Dictionary) -> void:
	assert(counts.zako1 > counts.zako2)
	assert(counts.zako2 > counts.zako0)
	assert(counts.zako0 >= counts.zako6 * 0.85)
	assert(counts.zako6 >= counts.zako0 * 0.85)
	assert(counts.zako0 > counts.zako3)
	assert(counts.zako3 > counts.zako4)
	assert(counts.zako3 > counts.zako7)


func _assert_same_frame_cap_keeps_independent_checks() -> void:
	var spawner := SpawnerUtil.new()
	spawner.generator_counter = 840
	var enemies: Array[Dictionary] = []
	for i in range(spawner._enemy_limit("arcade", 19) - 1):
		enemies.append({"kind": "filler"})
	for attempt in range(50):
		spawner.spawn_queue.clear()
		seed(13579 + attempt)
		spawner._evaluate_original_spawn_frame("arcade", 19, enemies, FIELD_W, FIELD_H, SPAWN_MARGIN, Vector2.ZERO)
		if spawner.spawn_queue.size() > 1:
			return
	assert(false)
