extends SceneTree

const SpawnerUtil := preload("res://scripts/game/spawner.gd")
const PlayfieldUtil := preload("res://scripts/core/playfield.gd")


func _init() -> void:
	var spawner := SpawnerUtil.new()
	var player_pos := Vector2(1.0, -0.5)

	var close_pos := player_pos + Vector2(0.5, 0.0)
	var adjusted := spawner._avoid_player_spawn_pos("zako0", close_pos, player_pos, PlayfieldUtil.FIELD_W, PlayfieldUtil.FIELD_H)
	assert(adjusted.distance_to(player_pos) > close_pos.distance_to(player_pos))
	assert(is_equal_approx(adjusted.distance_to(player_pos), 3.0))

	var far_pos := player_pos + Vector2(5.0, 0.0)
	assert(spawner._avoid_player_spawn_pos("zako0", far_pos, player_pos, PlayfieldUtil.FIELD_W, PlayfieldUtil.FIELD_H) == far_pos)

	var m1_pos := player_pos + Vector2(4.5, 0.0)
	var adjusted_m1 := spawner._avoid_player_spawn_pos("zakoM1", m1_pos, player_pos, PlayfieldUtil.FIELD_W, PlayfieldUtil.FIELD_H)
	assert(adjusted_m1.distance_to(player_pos) > m1_pos.distance_to(player_pos))

	var same_pos := spawner._avoid_player_spawn_pos("zako0", player_pos, player_pos, PlayfieldUtil.FIELD_W, PlayfieldUtil.FIELD_H)
	assert(is_equal_approx(same_pos.distance_to(player_pos), SpawnerUtil.SPAWN_AVOID_PLAYER_PUSH))
	quit()
