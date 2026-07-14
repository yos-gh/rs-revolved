extends SceneTree

const TimeWarpAudioUtil := preload("res://scripts/core/time_warp_audio.gd")


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var warp := TimeWarpAudioUtil.new()
	root.add_child(warp)
	warp.setup()
	await process_frame

	var bus_index := AudioServer.get_bus_index(TimeWarpAudioUtil.BUS_NAME)
	assert(bus_index >= 0)
	assert(AudioServer.get_bus_send(bus_index) == &"Master")
	assert(AudioServer.get_bus_effect_count(bus_index) == TimeWarpAudioUtil.EFFECT_COUNT)
	assert(warp.low_pass != null)
	assert(warp.delay != null)
	assert(warp.reverb != null)
	assert(warp.limiter != null)
	assert(warp.noise_playback != null)
	assert(warp.noise_player.bus == TimeWarpAudioUtil.BUS_NAME)
	assert(is_equal_approx(warp.low_pass.cutoff_hz, TimeWarpAudioUtil.NORMAL_CUTOFF_HZ))
	assert(is_equal_approx(warp.reverb.wet, 0.0))

	warp.update_effect(1.0)
	assert(is_equal_approx(warp.intensity, 1.0))
	assert(is_equal_approx(warp.low_pass.cutoff_hz, TimeWarpAudioUtil.SUBMERGED_CUTOFF_HZ))
	assert(is_equal_approx(warp.delay.tap1_level_db, TimeWarpAudioUtil.MAX_DELAY_TAP_1_DB))
	assert(is_equal_approx(warp.delay.tap2_level_db, TimeWarpAudioUtil.MAX_DELAY_TAP_2_DB))
	assert(is_equal_approx(warp.reverb.wet, TimeWarpAudioUtil.MAX_REVERB_WET))
	assert(is_equal_approx(warp.noise_player.volume_db, TimeWarpAudioUtil.MAX_NOISE_VOLUME_DB))

	warp.update_effect(0.5)
	assert(warp.low_pass.cutoff_hz > TimeWarpAudioUtil.SUBMERGED_CUTOFF_HZ)
	assert(warp.low_pass.cutoff_hz < TimeWarpAudioUtil.NORMAL_CUTOFF_HZ)
	assert(warp.reverb.wet > 0.0 and warp.reverb.wet < TimeWarpAudioUtil.MAX_REVERB_WET)

	warp.noise_player.stop()
	warp.queue_free()
	await process_frame
	await process_frame
	print("time warp audio verification passed")
	quit()
