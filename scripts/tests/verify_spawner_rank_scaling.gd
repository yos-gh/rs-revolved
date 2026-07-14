extends SceneTree

const SpawnerUtil := preload("res://scripts/game/spawner.gd")
const PlayfieldUtil := preload("res://scripts/core/playfield.gd")


func _init() -> void:
	var spawner := SpawnerUtil.new()
	assert(spawner._enemy_limit("arcade", 0) == 15)
	assert(spawner._enemy_limit("arcade", 5) == 20)
	assert(spawner._enemy_limit("arcade", 10) == 30)
	assert(spawner._enemy_limit("arcade", 15) == 60)
	assert(not spawner._kind_unlocked("zako5", 5))
	assert(spawner._kind_unlocked("zako5", 6))
	assert(not spawner._kind_unlocked("zakoM1", 10))
	assert(spawner._kind_unlocked("zakoM1", 11))
	var rank_0_spawns := _count_spawns_for_rank(0)
	var rank_15_spawns := _count_spawns_for_rank(15)
	assert(rank_0_spawns < rank_15_spawns)
	quit()


func _count_spawns_for_rank(rank: int) -> int:
	seed(8675309)
	var spawner := SpawnerUtil.new()
	var enemies: Array[Dictionary] = []
	var count := 0
	for frame in range(3600):
		var request := spawner.update(1.0 / 60.0, "arcade", rank, false, false, enemies, PlayfieldUtil.FIELD_W, PlayfieldUtil.FIELD_H, 0.65, Vector2.ZERO)
		if not request.is_empty():
			count += 1
	return count
