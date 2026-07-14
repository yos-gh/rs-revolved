extends SceneTree

const MainUtil := preload("res://scripts/prototype/main.gd")


func _init() -> void:
	if DisplayServer.get_name() == "headless":
		print("gameplay HUD render verification skipped: headless display")
		quit()
		return
	var viewport := SubViewport.new()
	viewport.size = Vector2i(1280, 720)
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(viewport)
	var main := MainUtil.new()
	viewport.add_child(main)
	await process_frame
	main._start_arcade()
	main.game_state.score = 12345.0
	main.game_state.tension = 180.0
	main.game_state.player_lives = 4
	main.gum_controller.energy = 0.75
	main._update_hud()
	await process_frame
	await process_frame
	var image := viewport.get_texture().get_image()
	assert(not image.is_empty())
	var error := image.save_png("res://.godot/gameplay-hud-preview.png")
	assert(error == OK)
	assert(_region_has_color(image, Rect2i(28, 16, 560, 8), "green"))
	assert(_region_has_color(image, Rect2i(28, 696, 860, 8), "blue"))
	assert(_region_has_color(image, Rect2i(1200, 660, 72, 48), "blue"))
	viewport.queue_free()
	await process_frame
	await process_frame
	print("gameplay HUD render verification passed")
	quit()


func _region_has_color(image: Image, region: Rect2i, channel: String) -> bool:
	for y in range(region.position.y, region.end.y):
		for x in range(region.position.x, region.end.x):
			var color := image.get_pixel(x, y)
			if channel == "green" and color.g > color.r + 0.12 and color.g > color.b + 0.12:
				return true
			if channel == "blue" and color.b > color.r + 0.12 and color.b > color.g + 0.08:
				return true
	return false
