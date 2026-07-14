extends SceneTree

const MainUtil := preload("res://scripts/prototype/main.gd")


func _init() -> void:
	var main := MainUtil.new()
	root.add_child(main)
	await process_frame
	main.set_process(false)

	main.debug_collisions = true
	main._spawn_enemy("zako2", Vector2.ZERO)
	main._spawn_enemy("zako7", Vector2(1.0, 0.0))
	main.object_pressure = 120
	main.game_time_scale = 0.82
	main._update_debug_profile(1.0)
	assert(main.debug_profile_text.contains("visual meshes"))
	assert(main.debug_profile_text.contains("zako"))
	assert(main._hud_text().contains("visual meshes"))

	main.queue_free()
	await process_frame
	await process_frame
	print("debug profile metrics verification passed")
	quit()
