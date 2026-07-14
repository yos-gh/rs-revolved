class_name GameState
extends RefCounted

signal score_extend_granted

const PLAYER_START_LIVES := 2
const MAX_PLAYER_LIVES := 9
const MAX_TENSION := 360.0
const ORIGINAL_UPDATE_RATE := 60.0
const ARCADE_BGM_RANK_2 := 6
const ARCADE_BGM_RANK_3 := 11
const ARCADE_PHASE_1_SCORE := 5000.0
const ARCADE_PHASE_2_SCORE := 40000.0
const ARCADE_PHASE_3_SCORE := 80000.0
const ARCADE_MAX_RANK := 15
const EXTEND_SCORE_INTERVAL := 80000.0
const ENDLESS_RANKS := {
	1: 15,
	2: 16,
	3: 17,
	4: 18,
}

var game_started := false
var game_mode := "arcade"
var endless_difficulty := 0
var score := 0.0
var hi_score := 0.0
var tension := 0.0
var player_lives := PLAYER_START_LIVES
var pending_arcade_boss_rank := 0
var active_arcade_boss_rank := 0
var completed_arcade_boss_rank := 0
var boss_mode := false
var boss_timer := 0.0
var arcade_cleared := false
var game_over := false
var arcade_rank := 0
var music_stage := 1
var next_extend_score := EXTEND_SCORE_INTERVAL


func start_arcade() -> void:
	game_started = true
	game_mode = "arcade"
	endless_difficulty = 0
	reset_for_arcade()


func start_endless(difficulty: int) -> void:
	game_started = true
	game_mode = "endless"
	endless_difficulty = clampi(difficulty, 1, 4)
	reset_for_endless()


func reset_for_arcade() -> void:
	score = 0
	tension = 0
	player_lives = PLAYER_START_LIVES
	pending_arcade_boss_rank = 0
	active_arcade_boss_rank = 0
	completed_arcade_boss_rank = 0
	boss_mode = false
	boss_timer = 0.0
	arcade_cleared = false
	game_over = false
	next_extend_score = EXTEND_SCORE_INTERVAL
	set_arcade_rank(0)


func reset_for_endless() -> void:
	score = 0
	tension = 0
	player_lives = PLAYER_START_LIVES
	pending_arcade_boss_rank = 0
	active_arcade_boss_rank = 0
	completed_arcade_boss_rank = 0
	boss_mode = false
	boss_timer = 0.0
	arcade_cleared = false
	game_over = false
	next_extend_score = EXTEND_SCORE_INTERVAL
	set_arcade_rank(ENDLESS_RANKS[endless_difficulty])


func add_enemy_score(base_score: int, increase_tension := true, minimum_score := 0.0) -> float:
	if base_score <= 0:
		return 0.0
	if increase_tension:
		tension = minf(MAX_TENSION, tension + float(base_score))
	var awarded_score := maxf(float(base_score) * tension / 10.0, maxf(0.0, minimum_score))
	score += awarded_score
	if score > hi_score:
		hi_score = score
	_grant_score_extends()
	if game_mode == "arcade":
		update_arcade_rank_from_score()
	return awarded_score


static func minimum_score_for_base(base_score: int) -> float:
	var guaranteed_tension := minf(MAX_TENSION, float(maxi(0, base_score)))
	return float(maxi(0, base_score)) * guaranteed_tension / 10.0


func update_tension(delta: float) -> void:
	var decay_per_second := (float(arcade_rank) + 1.0) / 10.0 * ORIGINAL_UPDATE_RATE
	tension = maxf(0.0, tension - decay_per_second * maxf(0.0, delta))


func reset_tension() -> void:
	tension = 0.0


func debug_add_score(amount: float) -> void:
	score = maxf(0.0, score + amount)
	if score > hi_score:
		hi_score = score
	_grant_score_extends()
	if game_mode == "arcade":
		update_arcade_rank_from_score()


func should_start_boss(enable_boss_mode: bool) -> bool:
	return enable_boss_mode and pending_arcade_boss_rank > 0 and not boss_mode


func start_boss_mode() -> void:
	boss_mode = true
	active_arcade_boss_rank = pending_arcade_boss_rank
	pending_arcade_boss_rank = 0
	boss_timer = 0.0


func end_boss_mode() -> void:
	boss_mode = false
	if game_mode == "arcade":
		completed_arcade_boss_rank = maxi(completed_arcade_boss_rank, active_arcade_boss_rank)
	active_arcade_boss_rank = 0
	_update_pending_arcade_boss()


func complete_arcade() -> void:
	boss_mode = false
	completed_arcade_boss_rank = ARCADE_MAX_RANK
	active_arcade_boss_rank = 0
	pending_arcade_boss_rank = 0
	arcade_cleared = true
	game_over = false


func enter_game_over() -> void:
	game_over = true


func grant_boss_extend() -> void:
	player_lives = mini(MAX_PLAYER_LIVES, player_lives + 1)


func arcade_score_floor_for_rank(rank: int) -> float:
	if rank <= 5:
		return maxf(0.0, float(rank) * ARCADE_PHASE_1_SCORE - 1.0)
	if rank <= 10:
		return ARCADE_PHASE_1_SCORE * 6.0 + float(rank - 6) * ARCADE_PHASE_2_SCORE - 1.0
	return ARCADE_PHASE_1_SCORE * 6.0 + ARCADE_PHASE_2_SCORE * 6.0 + float(rank - 11) * ARCADE_PHASE_3_SCORE - 1.0


func _grant_score_extends() -> void:
	if score < next_extend_score:
		return
	player_lives = mini(MAX_PLAYER_LIVES, player_lives + 1)
	next_extend_score = (floor(score / EXTEND_SCORE_INTERVAL) + 1.0) * EXTEND_SCORE_INTERVAL
	score_extend_granted.emit()


func set_arcade_rank(value: int) -> void:
	arcade_rank = value
	if arcade_rank >= ARCADE_BGM_RANK_3:
		music_stage = 3
	elif arcade_rank >= ARCADE_BGM_RANK_2:
		music_stage = 2
	else:
		music_stage = 1


func update_arcade_rank_from_score() -> void:
	var next_rank := arcade_rank
	if next_rank <= 5:
		next_rank = int(floor((score + 1.0) / ARCADE_PHASE_1_SCORE))
	if next_rank <= 10 and next_rank > 5:
		next_rank = int(floor((score + 1.0 - ARCADE_PHASE_1_SCORE * 6.0) / ARCADE_PHASE_2_SCORE)) + 6
	if next_rank <= 15 and next_rank > 10:
		next_rank = int(floor((score + 1.0 - ARCADE_PHASE_1_SCORE * 6.0 - ARCADE_PHASE_2_SCORE * 6.0) / ARCADE_PHASE_3_SCORE)) + 11
	if next_rank > ARCADE_MAX_RANK:
		next_rank = ARCADE_MAX_RANK
	set_arcade_rank(maxi(0, next_rank))
	_update_pending_arcade_boss()


func next_arcade_boss_rank() -> int:
	if pending_arcade_boss_rank > 0:
		return pending_arcade_boss_rank
	if arcade_rank < 5:
		return 5
	if arcade_rank < 10:
		return 10
	if arcade_rank < 15:
		return 15
	return 0


func _update_pending_arcade_boss() -> void:
	if boss_mode or pending_arcade_boss_rank > 0:
		return
	for boss_rank in [5, 10, 15]:
		if completed_arcade_boss_rank < boss_rank and arcade_rank >= boss_rank:
			pending_arcade_boss_rank = boss_rank
			return
