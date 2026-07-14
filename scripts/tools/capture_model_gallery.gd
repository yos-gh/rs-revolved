extends SceneTree

const MainScene := preload("res://scenes/main.tscn")

const CAPTURES := {
	4: "zakoM0-candidates.png",
	8: "zako4-candidates.png",
	9: "bullet2-low-prism.png",
	10: "zako5-candidates.png",
	11: "zakoM1-candidates.png",
	12: "zako6-candidates.png",
	13: "zako7-candidates.png",
	14: "zako7p-candidates.png",
	15: "bullet3-candidates.png",
	16: "boss-b1-candidates.png",
	17: "boss-core-ring-candidates.png",
	19: "myshot-candidates.png",
	20: "mousetarget-candidates.png",
	21: "gum-candidates.png",
	22: "mychar-candidates.png",
}


func _init() -> void:
	var output_dir := ProjectSettings.globalize_path("res://build/model-captures")
	DirAccess.make_dir_recursive_absolute(output_dir)
	var main := MainScene.instantiate()
	root.add_child(main)
	await process_frame
	await process_frame
	main._set_gallery_active(true)
	for category in CAPTURES:
		main.model_gallery._show_category(category)
		main.model_gallery.update_gallery(1.1)
		await process_frame
		await RenderingServer.frame_post_draw
		var image := root.get_viewport().get_texture().get_image()
		var output_path: String = output_dir.path_join(CAPTURES[category])
		var error := image.save_png(output_path)
		assert(error == OK)
		print("saved %s" % output_path)
	quit()
