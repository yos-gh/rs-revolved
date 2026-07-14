extends SceneTree

const MainScene := preload("res://scenes/main.tscn")


func _init() -> void:
	var output_dir := ProjectSettings.globalize_path("res://build/model-captures")
	DirAccess.make_dir_recursive_absolute(output_dir)
	var main := MainScene.instantiate()
	root.add_child(main)
	await process_frame
	await process_frame
	main._set_gallery_active(true)
	main.model_gallery._show_category(17)
	main.model_gallery.update_gallery(1.1)
	for frame in range(8):
		await process_frame
	var image := root.get_viewport().get_texture().get_image()
	var output_path := output_dir.path_join("boss-core-ring-candidates.png")
	var error := image.save_png(output_path)
	assert(error == OK)
	print("saved %s" % output_path)
	quit()
