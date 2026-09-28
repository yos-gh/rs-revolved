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
	assert(not sfx.has_event("unknown"))

	var played: Array[String] = []
	sfx.event_played.connect(func(event: String) -> void: played.append(event))
	sfx.play("shot")
	sfx.play("die")
	assert(played == ["shot", "die"])

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
	main.player.invuln_timer = 0.0
	main._kill_player()
	assert(runtime_events == ["shot", "bomb_s", "bomb_m", "bomb_s", "gum_o", "gum_c", "extend", "die"])
	runtime_events.clear()
	main._play_boss_core_destroy_sfx()
	assert(runtime_events == ["extend", "bomb_m"])
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
