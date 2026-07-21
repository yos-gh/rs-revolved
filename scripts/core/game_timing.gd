class_name GameTiming
extends RefCounted

const BULLET_TIME_START_OBJECTS := 75
const BULLET_TIME_FULL_OBJECTS := 170
const ENEMY_PRESSURE_WEIGHT := 2
const MIN_TIME_SCALE := 0.50
const TIME_SCALE_SLOWDOWN_RATE := 2.00
const TIME_SCALE_RECOVERY_RATE := 0.33


static func compute_object_pressure(bullet_count: int, enemy_count: int, boss_active: bool) -> int:
	var boss_bonus := 24 if boss_active else 0
	return bullet_count + enemy_count * ENEMY_PRESSURE_WEIGHT + boss_bonus


static func compute_time_scale(object_pressure: int) -> float:
	if object_pressure <= BULLET_TIME_START_OBJECTS:
		return 1.0
	var t := inverse_lerp(float(BULLET_TIME_START_OBJECTS), float(BULLET_TIME_FULL_OBJECTS), float(object_pressure))
	return lerpf(1.0, MIN_TIME_SCALE, clampf(t, 0.0, 1.0))


static func approach_time_scale(current_scale: float, target_scale: float, delta: float) -> float:
	var rate := TIME_SCALE_SLOWDOWN_RATE if target_scale < current_scale else TIME_SCALE_RECOVERY_RATE
	return move_toward(current_scale, target_scale, rate * delta)


static func bullet_time_intensity(time_scale: float) -> float:
	var t := inverse_lerp(1.0, MIN_TIME_SCALE, clampf(time_scale, MIN_TIME_SCALE, 1.0))
	return pow(clampf(t, 0.0, 1.0), 0.72)
