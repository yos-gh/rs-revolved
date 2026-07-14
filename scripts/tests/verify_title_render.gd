extends SceneTree

const MainUtil := preload("res://scripts/prototype/main.gd")


func _init() -> void:
	if DisplayServer.get_name() == "headless":
		print("title render verification skipped: headless display")
		quit()
		return
	var viewport := SubViewport.new()
	viewport.size = Vector2i(1280, 720)
	viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
	root.add_child(viewport)
	var main := MainUtil.new()
	viewport.add_child(main)
	await process_frame
	main.game_state.hi_score = 123456.0
	main._set_title_visible(true)
	await process_frame
	var image := viewport.get_texture().get_image()
	assert(not image.is_empty())
	assert(_region_has_bright_pixel(image, Rect2i(680, 360, 520, 260)))
	assert(_region_has_bright_pixel(image, Rect2i(790, 650, 320, 50)))
	var error := image.save_png("res://.godot/title-preview.png")
	assert(error == OK)
	viewport.queue_free()
	await process_frame
	await process_frame
	print("title render verification passed")
	quit()


func _region_has_bright_pixel(image: Image, region: Rect2i) -> bool:
	for y in range(region.position.y, region.end.y, 2):
		for x in range(region.position.x, region.end.x, 2):
			var color := image.get_pixel(x, y)
			if maxf(color.r, maxf(color.g, color.b)) > 0.5:
				return true
	return false
