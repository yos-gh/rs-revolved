extends SceneTree

const BulletTimeGlitchUtil := preload("res://scripts/core/bullet_time_glitch.gd")
const MainUtil := preload("res://scripts/prototype/main.gd")


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var glitch := BulletTimeGlitchUtil.new()
	root.add_child(glitch)
	glitch.update_effect(1.0 / 60.0, Vector2(320.0, 240.0), 1.0)
	assert(glitch.visible)
	assert(glitch.size.x > 0.0)
	assert(glitch.size.y > 0.0)
	glitch.queue_free()
	await process_frame
	await process_frame

	var main := MainUtil.new()
	root.add_child(main)
	await process_frame
	main.game_state.game_started = true
	main.game_time_scale = 0.5
	main._update_bullet_time_glitch(1.0)
	assert(main.bullet_time_glitch.intensity > 0.0)
	assert(is_equal_approx(main.time_warp_audio.intensity, main.bullet_time_glitch.intensity))
	main.time_warp_audio.noise_player.stop()
	main.queue_free()
	await process_frame
	await process_frame
	quit()
