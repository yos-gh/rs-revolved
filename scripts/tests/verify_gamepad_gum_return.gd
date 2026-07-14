extends SceneTree

const GumControllerUtil := preload("res://scripts/game/gum_controller.gd")


func _init() -> void:
	var gum := GumControllerUtil.new()
	root.add_child(gum)
	gum.setup({
		"gum": Color(0.96, 0.42, 0.78),
		"gum_low": Color(0.35, 0.42, 0.58),
		"gum_empty": Color(1.0, 0.22, 0.16),
	})

	var bounds := Rect2(-12.0, -6.75, 24.0, 13.5)
	gum.state = 2
	gum.energy = 1.0
	gum.center = Vector2.ZERO
	gum._radius = GumControllerUtil.ORBIT_TARGET_RADIUS
	gum._travel_angle = 0.0
	gum.update_controller(0.005, Vector2.ZERO, 0.0, Vector2(0.0, -6.75), [], [], Callable(), bounds)
	assert(gum.state == 2)
	assert(gum._travel_angle < 0.0)
	assert(gum.center.y < 0.0)

	gum.state = 2
	gum.energy = 1.0
	gum.center = Vector2(10.7, 0.0)
	gum._radius = GumControllerUtil.ORBIT_TARGET_RADIUS
	gum._travel_angle = 0.0
	gum.update_controller(0.1, Vector2.ZERO, 0.0, Vector2(12.0, 0.0), [], [], Callable(), bounds)
	assert(gum.state == 3)
	assert(gum.center.x > bounds.end.x)

	gum.state = 2
	gum.center = Vector2(bounds.end.x - 0.30, 0.0)
	gum._radius = GumControllerUtil.ORBIT_TARGET_RADIUS
	gum._travel_angle = PI
	gum.update_controller(0.005, Vector2.ZERO, PI, Vector2(bounds.position.x, 0.0), [], [], Callable(), bounds)
	assert(gum.state == 2)

	gum.state = 3
	gum.energy = 1.0
	gum.center = Vector2(-2.0, 1.0)
	assert(gum._try_consume_input(Vector2.ZERO, -PI * 0.5, Vector2(4.0, 0.0), true))
	assert(gum.state == 2)
	assert(is_equal_approx(gum._travel_angle, -PI * 0.5))

	gum.queue_free()
	print("gamepad Gum edge return verification passed")
	quit()
