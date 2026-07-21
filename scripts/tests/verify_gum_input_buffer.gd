extends SceneTree

const GumControllerUtil := preload("res://scripts/game/gum_controller.gd")


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var gum := GumControllerUtil.new()
	root.add_child(gum)
	gum.setup({
		"gum": Color(0.96, 0.42, 0.78),
		"gum_low": Color(0.35, 0.42, 0.58),
		"gum_empty": Color(1.0, 0.22, 0.16),
	})

	gum.energy = GumControllerUtil.MIN_ENERGY - 0.01
	gum.request_input()
	gum.update_controller(1.0 / 120.0, Vector2.ZERO, 0.0, Vector2.RIGHT, [], [], Callable())
	assert(gum.state == 0)
	assert(gum._input_buffer_timer > 0.0)

	gum.energy = GumControllerUtil.MIN_ENERGY + 0.01
	gum.update_controller(1.0 / 120.0, Vector2.ZERO, 0.0, Vector2.RIGHT, [], [], Callable())
	assert(gum.state == 1)
	assert(is_equal_approx(gum._input_buffer_timer, 0.0))

	gum.reset(Vector2.ZERO)
	gum.energy = 0.0
	gum.request_input()
	gum.update_controller(GumControllerUtil.INPUT_BUFFER_TIME + 0.01, Vector2.ZERO, 0.0, Vector2.RIGHT, [], [], Callable())
	gum.energy = 1.0
	gum.update_controller(1.0 / 120.0, Vector2.ZERO, 0.0, Vector2.RIGHT, [], [], Callable())
	assert(gum.state == 0)

	gum.queue_free()
	await process_frame
	print("gum input buffer verification passed")
	quit()
