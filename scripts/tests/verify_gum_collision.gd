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

	gum.state = 1
	var orb := gum.get_child(0)
	orb.position = Vector3.ZERO
	var bullet := {
		"hostile": true,
		"gum_blockable": true,
		"life": 1.0,
	}
	var shape := func(_bullet: Dictionary) -> Dictionary:
		return {
			"type": "circle",
			"pos": Vector2(0.40, 0.0),
			"radius": 0.09,
		}
	assert(gum._catches_bullet(0, bullet, shape))
	var break_state := {"count": 0, "color": Color.TRANSPARENT}
	gum.bullet_break_effect_requested.connect(func(_pos: Vector2, color: Color, _direction: Vector2) -> void:
		break_state.count += 1
		break_state.color = color
	)
	bullet["pos"] = Vector2(0.40, 0.0)
	bullet["vel"] = Vector2.RIGHT
	bullet["break_color"] = Color(1.0, 0.78, 0.18)
	gum.update_controller(0.016, Vector2.ZERO, 0.0, Vector2.RIGHT, [bullet], [], shape)
	assert(is_zero_approx(float(bullet.life)))
	assert(break_state.count == 1)
	assert((break_state.color as Color).is_equal_approx(Color(1.0, 0.78, 0.18)))

	var emitted_directions: Array[Vector2] = []
	gum.hit_effect_requested.connect(func(_pos: Vector2, _color: Color, direction: Vector2) -> void:
		emitted_directions.append(direction)
	)
	var hit_enemy := {
		"pos": Vector2.ZERO,
		"radius": 0.20,
		"life": 3,
		"damageable": true,
		"gum_vulnerable": true,
	}
	assert(gum._hit_enemies_at([hit_enemy], Vector2.ZERO, 0.42, 1, Vector2.DOWN))
	assert(emitted_directions.size() == 1)
	assert(emitted_directions[0].is_equal_approx(Vector2.DOWN))

	gum.queue_free()
	await process_frame
	await process_frame
	print("gum collision verification passed")
	quit()
