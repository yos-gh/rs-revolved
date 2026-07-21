class_name Spawner
extends RefCounted

const ENDLESS_BOSS_FRAMES := 3600.0
const FRAMES_PER_SECOND := 60.0
const ORIGINAL_SCREEN_W := 640.0
const ORIGINAL_SCREEN_H := 480.0
const SPAWN_AVOID_PLAYER_DISTANCE := 4.0
const SPAWN_AVOID_PLAYER_DISTANCE_ZAKOM1 := 5.0
const SPAWN_AVOIDANCE_SAMPLE_COUNT := 64
const SPAWN_AVOIDANCE_EPSILON := 0.001
const SPAWN_RULES := {
	"zakoM0": Vector2i(20, 20),
	"zakoM1": Vector2i(40, 40),
	"zako0": Vector2i(5, 4),
	"zako2": Vector2i(4, 2),
	"zako1": Vector2i(3, 2),
	"zako3": Vector2i(10, 10),
	"zako4": Vector2i(20, 15),
	"zako5": Vector2i(10, 10),
	"zako6": Vector2i(5, 4),
	"zako7": Vector2i(20, 15),
}

var spawn_delay := 0.0
var frame_accumulator := 0.0
var generator_counter := 0
var spawn_queue: Array[Dictionary] = []
var endless_boss_counter := 0.0


func reset() -> void:
	spawn_delay = 0.0
	frame_accumulator = 0.0
	generator_counter = 0
	spawn_queue.clear()
	endless_boss_counter = 0.0


func set_delay(delay: float) -> void:
	spawn_delay = delay


func update(delta: float, game_mode: String, rank: int, boss_mode: bool, should_start_boss: bool, enemies: Array[Dictionary], field_w: float, field_h: float, spawn_margin: float, player_pos := Vector2.ZERO) -> Dictionary:
	if boss_mode:
		return {}
	if game_mode == "endless":
		endless_boss_counter += delta * FRAMES_PER_SECOND
		if endless_boss_counter >= ENDLESS_BOSS_FRAMES:
			endless_boss_counter = 0.0
			spawn_queue.clear()
			return {"start_boss": true}
	elif should_start_boss:
		spawn_queue.clear()
		return {"start_boss": true}

	spawn_delay = maxf(0.0, spawn_delay - delta)
	if spawn_delay > 0.0:
		return {}

	frame_accumulator += delta * FRAMES_PER_SECOND
	while frame_accumulator >= 1.0:
		frame_accumulator -= 1.0
		generator_counter += 1
		_evaluate_original_spawn_frame(game_mode, rank, enemies, field_w, field_h, spawn_margin, player_pos)
	if not spawn_queue.is_empty():
		return spawn_queue.pop_front()
	return {}


func _evaluate_original_spawn_frame(game_mode: String, rank: int, enemies: Array[Dictionary], field_w: float, field_h: float, spawn_margin: float, player_pos := Vector2.ZERO) -> void:
	if enemies.size() + spawn_queue.size() >= _enemy_limit(game_mode, rank):
		return
	var rankbase := maxi(1, 20 - rank)
	for kind in SPAWN_RULES:
		if not _kind_unlocked(kind, rank) or not _kind_below_limit(kind, rank, enemies):
			continue
		var rule: Vector2i = SPAWN_RULES[kind]
		var divisor := rule.x * rankbase + randi_range(0, maxi(0, rule.y * rankbase - 1))
		if generator_counter % divisor != 0:
			continue
		var pos := _spawn_pos_for_kind(kind, field_w, field_h, spawn_margin)
		spawn_queue.append({
			"kind": kind,
			"pos": _avoid_player_spawn_pos(kind, pos, player_pos, field_w, field_h),
		})


func _enemy_limit(game_mode: String, rank: int) -> int:
	var rankbase := maxi(1, 20 - rank)
	if game_mode == "endless" and rank == 17:
		return int(900.0 / float(rankbase))
	if game_mode == "endless" and rank >= 18:
		return 700
	return int(300.0 / float(rankbase))


func _kind_unlocked(kind: String, rank: int) -> bool:
	if kind == "zako5":
		return rank > 5
	if kind == "zakoM1":
		return rank > 10
	return true


func _kind_below_limit(kind: String, rank: int, enemies: Array[Dictionary]) -> bool:
	if kind == "zakoM0":
		return _count_kind(enemies, kind) + _count_queued_kind(kind) < int(rank / 5.0) + 1
	if kind == "zakoM1":
		return _count_kind(enemies, kind) + _count_queued_kind(kind) < 1
	return true


func _count_kind(enemies: Array[Dictionary], kind: String) -> int:
	var count := 0
	for enemy in enemies:
		if enemy.kind == kind:
			count += 1
	return count


func _count_queued_kind(kind: String) -> int:
	var count := 0
	for request in spawn_queue:
		if request.kind == kind:
			count += 1
	return count


func _random_edge_pos(field_w: float, field_h: float, spawn_margin: float) -> Vector2:
	var edge := randi() % 4
	if edge == 0:
		return Vector2(randf_range(-field_w * 0.5, field_w * 0.5), -field_h * 0.5 - spawn_margin)
	if edge == 1:
		return Vector2(randf_range(-field_w * 0.5, field_w * 0.5), field_h * 0.5 + spawn_margin)
	if edge == 2:
		return Vector2(-field_w * 0.5 - spawn_margin, randf_range(-field_h * 0.5, field_h * 0.5))
	return Vector2(field_w * 0.5 + spawn_margin, randf_range(-field_h * 0.5, field_h * 0.5))


func _spawn_pos_for_kind(kind: String, field_w: float, field_h: float, spawn_margin: float) -> Vector2:
	if kind == "zakoM0" or kind == "zakoM1":
		return _random_original_rect_pos(field_w, field_h, 30.0, 30.0, 30.0, 30.0)
	if kind == "zako0" or kind == "zako1":
		return _random_original_rect_pos(field_w, field_h, -20.0, -20.0, -20.0, -20.0)
	if kind == "zako5" or kind == "zako6":
		return _random_original_rect_pos(field_w, field_h, 10.0, 10.0, 10.0, 10.0)
	if kind == "zako7":
		return _random_original_rect_pos(field_w, field_h, 20.0, 20.0, 20.0, 20.0)
	if kind == "zako2" or kind == "zako3" or kind == "zako4":
		return _random_original_rect_pos(field_w, field_h, 0.0, 0.0, 0.0, 0.0)
	return _random_edge_pos(field_w, field_h, spawn_margin)


func _random_original_rect_pos(field_w: float, field_h: float, left_px: float, top_px: float, right_px: float, bottom_px: float) -> Vector2:
	var x_px := randf_range(left_px, ORIGINAL_SCREEN_W - right_px)
	var y_px := randf_range(top_px, ORIGINAL_SCREEN_H - bottom_px)
	return Vector2(
		(x_px / ORIGINAL_SCREEN_W - 0.5) * field_w,
		(y_px / ORIGINAL_SCREEN_H - 0.5) * field_h
	)


func _avoid_player_spawn_pos(kind: String, pos: Vector2, player_pos: Vector2, field_w: float, field_h: float) -> Vector2:
	var avoid_distance := SPAWN_AVOID_PLAYER_DISTANCE_ZAKOM1 if kind == "zakoM1" else SPAWN_AVOID_PLAYER_DISTANCE
	var from_player := pos - player_pos
	if from_player.length() >= avoid_distance:
		return pos
	var target_distance := avoid_distance + SPAWN_AVOIDANCE_EPSILON
	var direction := from_player.normalized()
	if direction.length_squared() <= 0.0:
		direction = (_farthest_field_corner(player_pos, field_w, field_h) - player_pos).normalized()
	var projected := player_pos + direction * target_distance
	if _is_inside_field(projected, field_w, field_h):
		return projected

	var nearest_valid := Vector2.ZERO
	var nearest_distance_squared := INF
	var found_valid := false
	for sample in range(SPAWN_AVOIDANCE_SAMPLE_COUNT):
		var angle := TAU * float(sample) / float(SPAWN_AVOIDANCE_SAMPLE_COUNT)
		var candidate := player_pos + Vector2.from_angle(angle) * target_distance
		if not _is_inside_field(candidate, field_w, field_h):
			continue
		var candidate_distance_squared := candidate.distance_squared_to(pos)
		if not found_valid or candidate_distance_squared < nearest_distance_squared:
			nearest_valid = candidate
			nearest_distance_squared = candidate_distance_squared
			found_valid = true
	if found_valid:
		return nearest_valid
	return _farthest_field_corner(player_pos, field_w, field_h)


func _is_inside_field(pos: Vector2, field_w: float, field_h: float) -> bool:
	return (
		pos.x >= -field_w * 0.5
		and pos.x <= field_w * 0.5
		and pos.y >= -field_h * 0.5
		and pos.y <= field_h * 0.5
	)


func _farthest_field_corner(player_pos: Vector2, field_w: float, field_h: float) -> Vector2:
	var half_size := Vector2(field_w, field_h) * 0.5
	var corners := [
		Vector2(-half_size.x, -half_size.y),
		Vector2(half_size.x, -half_size.y),
		Vector2(-half_size.x, half_size.y),
		Vector2(half_size.x, half_size.y),
	]
	var farthest: Vector2 = corners[0]
	var farthest_distance_squared := farthest.distance_squared_to(player_pos)
	for corner in corners.slice(1):
		var distance_squared: float = corner.distance_squared_to(player_pos)
		if distance_squared > farthest_distance_squared:
			farthest = corner
			farthest_distance_squared = distance_squared
	return farthest
