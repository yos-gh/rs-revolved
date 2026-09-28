extends SceneTree

const BossUtil := preload("res://scripts/game/boss.gd")
const PlayfieldUtil := preload("res://scripts/core/playfield.gd")

const FIELD_W := PlayfieldUtil.FIELD_W
const FIELD_H := PlayfieldUtil.FIELD_H
const PLAYER_POS := Vector2.ZERO
const TURRET_MARGIN := Vector2(20.0 / BossUtil.ORIGINAL_SCREEN_W * FIELD_W, 20.0 / BossUtil.ORIGINAL_SCREEN_H * FIELD_H)


func _init() -> void:
	var boss := BossUtil.new()
	for sample in range(200):
		boss.start(PLAYER_POS, FIELD_W, FIELD_H)
		assert(boss.center.distance_to(PLAYER_POS) >= BossUtil.SPAWN_AVOID_PLAYER_DISTANCE)
		assert(absf(boss.center.x) <= FIELD_W * (0.5 - BossUtil.CORE_EDGE_MARGIN_RATIO.x))
		assert(absf(boss.center.y) <= FIELD_H * (0.5 - BossUtil.CORE_EDGE_MARGIN_RATIO.y))

		var turret_pos := boss.turret_spawn_pos(PLAYER_POS, FIELD_W, FIELD_H)
		assert(turret_pos.distance_to(PLAYER_POS) >= BossUtil.SPAWN_AVOID_PLAYER_DISTANCE)
		assert(turret_pos.distance_to(boss.center) >= BossUtil.TURRET_CORE_MIN_DISTANCE)
		assert(absf(turret_pos.x) <= FIELD_W * 0.5 - TURRET_MARGIN.x)
		assert(absf(turret_pos.y) <= FIELD_H * 0.5 - TURRET_MARGIN.y)

		var occupied: Array[Vector2] = [turret_pos]
		for turret_index in range(7):
			var separated_pos := boss.turret_spawn_pos(PLAYER_POS, FIELD_W, FIELD_H, occupied)
			for existing_pos in occupied:
				assert(separated_pos.distance_to(existing_pos) >= BossUtil.TURRET_MIN_SEPARATION)
			occupied.append(separated_pos)

	boss.center = Vector2(FIELD_W * 0.5, FIELD_H * 0.5)
	for sample in range(50):
		var corner_core_turret := boss.turret_spawn_pos(Vector2(-FIELD_W * 0.5, -FIELD_H * 0.5), FIELD_W, FIELD_H)
		assert(corner_core_turret.distance_to(boss.center) >= BossUtil.TURRET_CORE_MIN_DISTANCE)

	print("boss spawn position verification passed")
	quit()
