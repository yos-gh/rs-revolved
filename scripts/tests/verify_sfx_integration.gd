extends SceneTree

const SfxPlayerUtil := preload("res://scripts/core/sfx_player.gd")
const GumControllerUtil := preload("res://scripts/game/gum_controller.gd")
const GameStateUtil := preload("res://scripts/game/game_state.gd")
const MainUtil := preload("res://scripts/prototype/main.gd")


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var sfx := SfxPlayerUtil.new()
	sfx.setup()
	root.add_child(sfx)

	for event in ["shot", "bomb_s", "bomb_m", "die", "extend", "gum_o", "gum_c"]:
		assert(sfx.has_event(event))
		var player := sfx.player_for(event)
		assert(player != null)
		assert(player.stream != null)
		assert(player.max_polyphony == SfxPlayerUtil.MAX_POLYPHONY[event])
		assert(player.bus == (SfxPlayerUtil.DESTRUCTION_BUS_NAME if event in SfxPlayerUtil.DESTRUCTION_EVENTS else SfxPlayerUtil.SFX_MIX_BUS_NAME))
	var sfx_mix_bus := AudioServer.get_bus_index(SfxPlayerUtil.SFX_MIX_BUS_NAME)
	assert(sfx_mix_bus >= 0)
	assert(AudioServer.get_bus_send(sfx_mix_bus) == SfxPlayerUtil.TIME_WARP_BUS_NAME)
	assert(AudioServer.get_bus_effect_count(sfx_mix_bus) == SfxPlayerUtil.SFX_MIX_EFFECT_COUNT)
	var shared_delay := AudioServer.get_bus_effect(sfx_mix_bus, 0) as AudioEffectDelay
	var shared_reverb := AudioServer.get_bus_effect(sfx_mix_bus, 1) as AudioEffectReverb
	assert(shared_delay != null)
	assert(shared_reverb != null)
	assert(is_equal_approx(shared_delay.tap1_delay_ms, SfxPlayerUtil.SFX_DELAY_TAP_1_MS))
	assert(is_equal_approx(shared_delay.tap1_level_db, SfxPlayerUtil.SFX_DELAY_TAP_1_DB))
	assert(is_equal_approx(shared_delay.tap2_delay_ms, SfxPlayerUtil.SFX_DELAY_TAP_2_MS))
	assert(is_equal_approx(shared_delay.tap2_level_db, SfxPlayerUtil.SFX_DELAY_TAP_2_DB))
	assert(not shared_delay.feedback_active)
	assert(is_equal_approx(shared_reverb.wet, SfxPlayerUtil.SFX_REVERB_WET))
	var destruction_bus := AudioServer.get_bus_index(SfxPlayerUtil.DESTRUCTION_BUS_NAME)
	assert(destruction_bus >= 0)
	assert(AudioServer.get_bus_send(destruction_bus) == SfxPlayerUtil.SFX_MIX_BUS_NAME)
	assert(AudioServer.get_bus_effect_count(destruction_bus) == 2)
	var compressor := AudioServer.get_bus_effect(destruction_bus, 0) as AudioEffectCompressor
	var limiter := AudioServer.get_bus_effect(destruction_bus, 1) as AudioEffectHardLimiter
	assert(compressor != null)
	assert(limiter != null)
	assert(is_equal_approx(compressor.threshold, SfxPlayerUtil.DESTRUCTION_COMPRESSOR_THRESHOLD_DB))
	assert(is_equal_approx(compressor.ratio, SfxPlayerUtil.DESTRUCTION_COMPRESSOR_RATIO))
	assert(is_equal_approx(limiter.ceiling_db, SfxPlayerUtil.DESTRUCTION_LIMITER_CEILING_DB))
	assert(not sfx.has_event("unknown"))
	for event in ["shot", "bomb_s", "bomb_m", "die", "extend", "gum_o", "gum_c"]:
		var stream_path: String = sfx.player_for(event).stream.resource_path
		assert(stream_path.contains("/original_mastered/"))
		assert(stream_path.ends_with("/%s.wav" % event))

	var played: Array[String] = []
	sfx.event_played.connect(func(event: String) -> void: played.append(event))
	sfx.play("shot")
	sfx.play("die")
	assert(played == ["shot", "die"])
	var shot_db := sfx.player_for("shot").volume_db
	assert(shot_db >= linear_to_db(4.0 / SfxPlayerUtil.ORIGINAL_VOLUME_MAX))
	assert(shot_db <= linear_to_db(7.0 / SfxPlayerUtil.ORIGINAL_VOLUME_MAX))
	sfx.play("extend")
	assert(is_equal_approx(sfx.player_for("extend").volume_db, linear_to_db(64.0 / SfxPlayerUtil.ORIGINAL_VOLUME_MAX)))

	var gum_open_player := sfx.player_for("gum_o")
	var gum_close_player := sfx.player_for("gum_c")
	sfx.play("gum_o", Vector2i(64, 64))
	await process_frame
	gum_open_player.seek(0.40)
	sfx.play("gum_c", Vector2i(64, 64))
	var mirrored_position := gum_close_player.stream.get_length() - 0.40
	assert(absf(gum_close_player.get_playback_position() - mirrored_position) < 0.08)
	assert(gum_open_player.playing)
	await create_timer(SfxPlayerUtil.GUM_FADE_OUT_TIME + 0.15).timeout
	assert(not gum_open_player.playing)
	assert(gum_close_player.playing)
	gum_close_player.seek(0.70)
	sfx.play("gum_o", Vector2i(64, 64))
	assert(gum_open_player.playing)
	await create_timer(SfxPlayerUtil.GUM_FADE_OUT_TIME + 0.15).timeout
	assert(gum_open_player.playing)
	assert(not gum_close_player.playing)

	sfx.stop_all()
	sfx.play("gum_o", Vector2i(64, 64))
	await process_frame
	gum_open_player.seek(0.05)
	sfx.play("gum_c", Vector2i(64, 64))
	var minimum_segment_position := gum_close_player.stream.get_length() - SfxPlayerUtil.GUM_MIN_REVERSE_SEGMENT
	assert(absf(gum_close_player.get_playback_position() - minimum_segment_position) < 0.08)

	var gum := GumControllerUtil.new()
	root.add_child(gum)
	gum.setup({
		"gum": Color(0.96, 0.42, 0.78),
		"gum_low": Color(0.35, 0.42, 0.58),
		"gum_empty": Color(1.0, 0.22, 0.16),
	})
	var signal_counts := {"opened": 0, "launched": 0}
	gum.opened.connect(func() -> void: signal_counts.opened += 1)
	gum.launched.connect(func() -> void: signal_counts.launched += 1)
	gum._begin_opening(Vector2.ONE, 0.5)
	assert(signal_counts.opened == 1)
	assert(gum.state == 1)
	gum._begin_launch(Vector2(3.0, 1.0))
	assert(signal_counts.launched == 1)
	assert(gum.state == 2)
	gum._finish_closing()
	assert(signal_counts.launched == 1)
	assert(gum.state == 0)
	sfx.stop_all()
	sfx.queue_free()
	gum.queue_free()
	await process_frame

	var main := MainUtil.new()
	root.add_child(main)
	await process_frame
	main.set_process(false)
	main._start_arcade()
	var runtime_events: Array[String] = []
	main.sfx.event_played.connect(func(event: String) -> void: runtime_events.append(event))
	main._spawn_player_shot(Vector2.ZERO, 0.0)
	main._play_enemy_destroy_sfx({"kind": "zako0"})
	main._play_enemy_destroy_sfx({"kind": "zakoM0"})
	main._play_enemy_destroy_sfx({"kind": "zako7p"})
	main.gum_controller._begin_opening(Vector2.ZERO, 0.0)
	main.gum_controller._begin_launch(Vector2.RIGHT)
	main.gum_controller._finish_closing()
	main.game_state.debug_add_score(GameStateUtil.EXTEND_SCORE_INTERVAL)
	var score_extend_effect := main.find_child("PlayerExtendEffect", true, false) as Node3D
	assert(score_extend_effect != null)
	main.player.invuln_timer = 0.0
	main._kill_player()
	assert(runtime_events == ["shot", "bomb_s", "bomb_m", "bomb_s", "gum_o", "gum_c", "extend", "die"])
	runtime_events.clear()
	main._play_boss_core_destroy_sfx()
	assert(runtime_events == ["extend", "bomb_m"])
	var boss_extend_effect := main.get_child(main.get_child_count() - 1) as Node3D
	assert(boss_extend_effect != null)
	assert(String(boss_extend_effect.get_meta("effect_type", "")) == "player_extend")
	assert(boss_extend_effect != score_extend_effect)
	runtime_events.clear()
	main.game_state.game_mode = "endless"
	main.game_state.endless_difficulty = 4
	main._play_enemy_destroy_sfx({"kind": "zako3p"})
	main._play_enemy_destroy_sfx({"kind": "zako4"})
	assert(runtime_events == ["bomb_s", "bomb_s"])
	main.sfx.stop_all()
	main.queue_free()
	await process_frame

	print("SFX integration verification passed")
	quit()
