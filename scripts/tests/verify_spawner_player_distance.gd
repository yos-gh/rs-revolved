extends SceneTree

const SpawnerUtil := preload("res://scripts/game/spawner.gd")
const PlayfieldUtil := preload("res://scripts/core/playfield.gd")


func _init() -> void:
	var spawner := SpawnerUtil.new()
	var player_pos := Vector2(1.0, -0.5)

	var close_pos := player_pos + Vector2(0.5, 0.0)
	var adjusted := spawner._avoid_player_spawn_pos("zako0", close_pos, player_pos, PlayfieldUtil.FIELD_W, PlayfieldUtil.FIELD_H)
	assert(adjusted.distance_to(player_pos) > close_pos.distance_to(player_pos))
	assert(adjusted.distance_to(player_pos) >= SpawnerUtil.SPAWN_AVOID_PLAYER_DISTANCE)

	var far_pos := player_pos + Vector2(5.0, 0.0)
	assert(spawner._avoid_player_spawn_pos("zako0", far_pos, player_pos, PlayfieldUtil.FIELD_W, PlayfieldUtil.FIELD_H) == far_pos)

	var m1_pos := player_pos + Vector2(4.5, 0.0)
	var adjusted_m1 := spawner._avoid_player_spawn_pos("zakoM1", m1_pos, player_pos, PlayfieldUtil.FIELD_W, PlayfieldUtil.FIELD_H)
	assert(adjusted_m1.distance_to(player_pos) >= SpawnerUtil.SPAWN_AVOID_PLAYER_DISTANCE_ZAKOM1)

	var same_pos := spawner._avoid_player_spawn_pos("zako0", player_pos, player_pos, PlayfieldUtil.FIELD_W, PlayfieldUtil.FIELD_H)
	assert(same_pos.distance_to(player_pos) >= SpawnerUtil.SPAWN_AVOID_PLAYER_DISTANCE)

	var edge_player := Vector2(PlayfieldUtil.FIELD_W * 0.5 - 0.35, PlayfieldUtil.FIELD_H * 0.5 - 0.35)
	var outside_candidate := edge_player + Vector2(0.1, 0.1)
	var edge_adjusted := spawner._avoid_player_spawn_pos("zako0", outside_candidate, edge_player, PlayfieldUtil.FIELD_W, PlayfieldUtil.FIELD_H)
	assert(edge_adjusted.distance_to(edge_player) >= SpawnerUtil.SPAWN_AVOID_PLAYER_DISTANCE)
	assert(spawner._is_inside_field(edge_adjusted, PlayfieldUtil.FIELD_W, PlayfieldUtil.FIELD_H))
	print("spawner player distance verification passed")
	quit()
