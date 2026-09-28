extends SceneTree

const MainUtil := preload("res://scripts/prototype/main.gd")
const PlayfieldUtil := preload("res://scripts/core/playfield.gd")


func _init() -> void:
	var main := MainUtil.new()
	root.add_child(main)
	await process_frame
	assert(is_equal_approx(main.camera.size, PlayfieldUtil.FIELD_H))
	main.player.pos = Vector2(99.0, 99.0)
	main.player.update_motion(0.0, MainUtil.FIELD_W, MainUtil.FIELD_H, MainUtil.FIELD_EDGE_MARGIN)
	assert(is_equal_approx(main.player.pos.x, PlayfieldUtil.FIELD_W * 0.5 - MainUtil.FIELD_EDGE_MARGIN))
	assert(is_equal_approx(main.player.pos.y, PlayfieldUtil.FIELD_H * 0.5 - MainUtil.FIELD_EDGE_MARGIN))
	main.queue_free()
	await process_frame
	print("playfield scale verification passed")
	quit()
