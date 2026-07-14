extends SceneTree

const MainUtil := preload("res://scripts/prototype/main.gd")


func _init() -> void:
	var main := MainUtil.new()
	root.add_child(main)
	await process_frame

	main.debug_collisions = false
	main.game_state.score = 12345.0
	main.game_state.hi_score = 67890.0
	main.game_state.player_lives = 4
	main.game_state.tension = 180.0
	main.gum_controller.energy = 0.75
	main._update_hud()
	assert(main.hud.size.is_equal_approx(main.get_viewport().get_visible_rect().size))
	assert(main.hud.score_digits.digits == "000012345")
	assert(main.hud.life_digit.digits == "4")
	assert(is_equal_approx(main.hud.gum_fill.size.x, main.hud.gum_track.size.x * 0.75))
	assert(is_equal_approx(main.hud.tension_fill.size.x, main.hud.tension_track.size.x * 0.5))
	assert(is_equal_approx(main.hud.gum_threshold.position.x, main.hud.gum_track.size.x * main.hud.GUM_MIN_RATIO))
	assert(main.hud.tension_track.position.y < main.hud.score_digits.position.y)
	assert(is_equal_approx(main.hud.gum_track.anchor_bottom, 1.0))
	assert(is_equal_approx(main.hud.life_digit.anchor_bottom, 1.0))
	assert(main.hud.gum_fill.color == main.hud.GUM_COLOR)
	assert(not main.hud.debug_label.visible)
	var compact_lines := main._hud_text().split("\n")
	assert(compact_lines.size() == 2)
	assert(not main._hud_text().contains("bullets"))
	assert(not main._hud_text().contains("WASD"))

	main.debug_collisions = true
	main._update_hud()
	assert(main.hud.debug_label.visible)
	var debug_text := main._hud_text()
	assert(debug_text.split("\n").size() == 4)
	assert(debug_text.contains("bullets"))
	assert(debug_text.contains("pressure"))
	assert(debug_text.contains("visual meshes"))

	main.gum_controller.energy = 0.1
	main._update_hud()
	assert(main.hud.gum_fill.color == main.hud.GUM_LOW_COLOR)

	main.queue_free()
	await process_frame
	await process_frame
	print("hud layout verification passed")
	quit()
