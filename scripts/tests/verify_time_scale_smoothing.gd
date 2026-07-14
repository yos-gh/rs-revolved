extends SceneTree

const TimingUtil := preload("res://scripts/core/game_timing.gd")


func _init() -> void:
	assert(TimingUtil.compute_object_pressure(10, 15, false) == 40)
	assert(TimingUtil.compute_object_pressure(10, 15, true) == 64)
	assert(is_equal_approx(TimingUtil.compute_time_scale(TimingUtil.compute_object_pressure(0, 15, false)), 1.0))
	assert(is_equal_approx(TimingUtil.ENEMY_PRESSURE_WEIGHT, 2))

	var full_pressure := TimingUtil.BULLET_TIME_FULL_OBJECTS
	var target_slow := TimingUtil.compute_time_scale(full_pressure)
	assert(is_equal_approx(target_slow, TimingUtil.MIN_TIME_SCALE))

	var falling := TimingUtil.approach_time_scale(1.0, target_slow, 1.0 / 60.0)
	assert(falling < 1.0)
	assert(falling > target_slow)
	assert(is_equal_approx(TimingUtil.TIME_SCALE_SLOWDOWN_RATE, 1.80))

	var recovered := TimingUtil.approach_time_scale(target_slow, 1.0, 1.0 / 60.0)
	assert(recovered > target_slow)
	assert(recovered < 1.0)

	var one_second_recovery := target_slow
	for i in range(60):
		one_second_recovery = TimingUtil.approach_time_scale(one_second_recovery, 1.0, 1.0 / 60.0)
	assert(one_second_recovery > target_slow)
	assert(one_second_recovery < 1.0)

	assert(is_equal_approx(TimingUtil.bullet_time_intensity(1.0), 0.0))
	assert(is_equal_approx(TimingUtil.bullet_time_intensity(TimingUtil.MIN_TIME_SCALE), 1.0))
	assert(TimingUtil.bullet_time_intensity(0.80) > TimingUtil.bullet_time_intensity(0.92))
	quit()
