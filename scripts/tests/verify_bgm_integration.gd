extends SceneTree

const BgmPlayerUtil := preload("res://scripts/core/bgm_player.gd")


func _init() -> void:
	assert(BgmPlayerUtil.track_for_state("arcade", 0, 1) == 1)
	assert(BgmPlayerUtil.track_for_state("arcade", 0, 2) == 2)
	assert(BgmPlayerUtil.track_for_state("arcade", 0, 3) == 3)
	for difficulty in range(1, 5):
		assert(BgmPlayerUtil.track_for_state("endless", difficulty, 1) == difficulty)

	var bgm := BgmPlayerUtil.new()
	root.add_child(bgm)
	bgm.setup()
	await process_frame
	assert(bgm.player.bus == BgmPlayerUtil.TimeWarpAudioUtil.BUS_NAME)
	for track in range(1, 5):
		assert(BgmPlayerUtil.TRACKS[track].resource_path.ends_with("/original_bgm/%d.ogg" % track))
		assert(bgm._loop_streams.has(track))
		var stream := bgm._loop_streams[track] as AudioStreamOggVorbis
		assert(stream != null)
		assert(stream.loop)

	bgm.sync("arcade", 0, 1)
	assert(bgm.current_track == 1)
	assert(bgm.player.playing)
	bgm.sync("arcade", 0, 3)
	assert(bgm.current_track == 3)
	bgm.sync("endless", 4, 1)
	assert(bgm.current_track == 4)
	bgm.stop()
	assert(bgm.current_track == 0)
	assert(not bgm.player.playing)
	assert(bgm.player.stream == null)

	bgm.queue_free()
	await process_frame
	await process_frame
	print("BGM integration verification passed")
	quit()
