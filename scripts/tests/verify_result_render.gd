extends SceneTree

const MainUtil := preload("res://scripts/prototype/main.gd")


func _init() -> void:
	if DisplayServer.get_name() == "headless":
		print("result render verification skipped: headless display")
		quit()
		return
	var viewport := SubViewport.new()
	viewport.size = Vector2i(2560, 1440)
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(viewport)
	var main := MainUtil.new()
	viewport.add_child(main)
	await process_frame

	main._start_arcade()
	main.game_state.score = 12345.0
	main.game_state.player_lives = -1
	main.player.alive = false
	main.player.visible = false
	main._show_game_over()
	await process_frame
	await process_frame
	var game_over_image := viewport.get_texture().get_image()
	assert(game_over_image.save_png("res://.godot/game-over-preview.png") == OK)
	assert(_region_has_red(game_over_image, Rect2i(600, 600, 1360, 240)))
	assert(_region_has_gold(game_over_image, Rect2i(40, 40, 720, 120)))

	main.game_state.game_over = false
	main._set_game_over_visible(false)
	main.game_state.complete_arcade()
	main._set_arcade_clear_visible(true)
	await process_frame
	await process_frame
	var clear_image := viewport.get_texture().get_image()
	assert(clear_image.save_png("res://.godot/all-clear-preview.png") == OK)
	assert(_region_has_red(clear_image, Rect2i(600, 600, 1360, 240)))
	assert(_region_has_gold(clear_image, Rect2i(40, 40, 720, 120)))

	viewport.queue_free()
	await process_frame
	await process_frame
	print("result render verification passed")
	quit()


func _region_has_red(image: Image, region: Rect2i) -> bool:
	for y in range(region.position.y, region.end.y, 2):
		for x in range(region.position.x, region.end.x, 2):
			var color := image.get_pixel(x, y)
			if color.r > 0.65 and color.r > color.g + 0.20 and color.r > color.b + 0.20:
				return true
	return false


func _region_has_gold(image: Image, region: Rect2i) -> bool:
	for y in range(region.position.y, region.end.y, 2):
		for x in range(region.position.x, region.end.x, 2):
			var color := image.get_pixel(x, y)
			if color.r > 0.45 and color.g > 0.32 and color.r > color.b + 0.25 and color.g > color.b + 0.15:
				return true
	return false
