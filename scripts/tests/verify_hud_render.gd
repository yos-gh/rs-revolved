extends SceneTree

const GameHudUtil := preload("res://scripts/ui/game_hud.gd")


func _init() -> void:
	if DisplayServer.get_name() == "headless":
		print("hud render verification skipped: headless display")
		quit()
		return
	var viewport := SubViewport.new()
	viewport.size = Vector2i(1280, 720)
	viewport.transparent_bg = true
	viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
	root.add_child(viewport)
	var hud := GameHudUtil.new()
	viewport.add_child(hud)
	hud.setup()
	hud.update_values(123456, 987654, 4, 0.72, 248.0, "BOSS", 11, "ACTIVE", "GUARD", "")
	await process_frame
	await process_frame
	var image := viewport.get_texture().get_image()
	assert(not image.is_empty())
	assert(_region_has_visible_pixel(image, Rect2i(0, 0, 640, 90)))
	assert(_region_has_visible_pixel(image, Rect2i(0, 680, 640, 40)))
	assert(_region_has_visible_pixel(image, Rect2i(1160, 620, 120, 100)))
	var error := image.save_png("res://.godot/hud-preview.png")
	assert(error == OK)
	viewport.queue_free()
	await process_frame
	await process_frame
	print("hud render verification passed")
	quit()


func _region_has_visible_pixel(image: Image, region: Rect2i) -> bool:
	for y in range(region.position.y, region.end.y, 2):
		for x in range(region.position.x, region.end.x, 2):
			if image.get_pixel(x, y).a > 0.05:
				return true
	return false
