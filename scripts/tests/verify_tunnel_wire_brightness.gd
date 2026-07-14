extends SceneTree

const MainUtil := preload("res://scripts/prototype/main.gd")


func _init() -> void:
	var main := MainUtil.new()
	var bright_blue := Color(0.28, 0.55, 1.00)
	var limited_blue: Color = main._limit_tunnel_line_luminance(bright_blue)
	var blue_luminance := _luminance(bright_blue)
	var blue_scale := MainUtil.TUNNEL_WIRE_MAX_LUMINANCE / blue_luminance

	assert(is_equal_approx(_luminance(limited_blue), MainUtil.TUNNEL_WIRE_MAX_LUMINANCE))
	assert(is_equal_approx(limited_blue.r, bright_blue.r * blue_scale))
	assert(is_equal_approx(limited_blue.g, bright_blue.g * blue_scale))
	assert(is_equal_approx(limited_blue.b, bright_blue.b * blue_scale))

	var bright_green := Color(0.24, 0.72, 0.56)
	var limited_green: Color = main._limit_tunnel_line_luminance(bright_green)
	assert(_luminance(limited_green) <= MainUtil.TUNNEL_WIRE_MAX_LUMINANCE + 0.0001)
	assert(limited_green.g < bright_green.g)
	assert(main._limit_tunnel_line_luminance(Color(0.20, 0.30, 0.25)).is_equal_approx(Color(0.20, 0.30, 0.25)))

	main.game_state.game_started = true
	main.game_state.game_mode = "arcade"
	main.game_state.music_stage = 1
	var stage_1 := main._background_profile()
	main.game_state.music_stage = 2
	var stage_2 := main._background_profile()
	main.game_state.music_stage = 3
	var stage_3 := main._background_profile()
	assert(stage_1.bg.r > stage_1.bg.b)
	assert(stage_2.bg.b > stage_2.bg.g and stage_2.bg.g > stage_2.bg.r)
	assert(stage_2.wire.g > stage_2.wire.b and stage_2.wire.b > stage_2.wire.r)
	assert(_luminance(stage_3.bg) < _luminance(stage_2.bg) * 0.40)
	assert(stage_3.bg.b > stage_3.bg.g * 3.0)
	var floor_material := main._floor_material()
	assert(floor_material.shading_mode != BaseMaterial3D.SHADING_MODE_UNSHADED)
	assert(main._background_light_energy(stage_3.bg) < main._background_light_energy(stage_1.bg))
	assert(main._background_light_energy(stage_3.bg) < main._background_light_energy(stage_2.bg))
	assert(float(stage_3.light) < float(stage_2.light))

	main.game_state.game_mode = "endless"
	main.game_state.endless_difficulty = 1
	var endless_normal := main._background_profile()
	assert(float(endless_normal.light) < float(stage_1.light))
	assert(float(endless_normal.light) > float(stage_3.light))
	for difficulty in range(1, 4):
		main.game_state.endless_difficulty = difficulty
		var endless := main._background_profile()
		assert(not endless.bg.is_equal_approx(stage_1.bg))
		assert(not endless.bg.is_equal_approx(stage_2.bg))
		assert(not endless.bg.is_equal_approx(stage_3.bg))

	main.main_light = DirectionalLight3D.new()
	main.background_light_base_energy = 2.0
	main.tunnel_time = 0.0
	main._update_background_light()
	var first_energy: float = main.main_light.light_energy
	main.tunnel_time = 0.75 / MainUtil.BACKGROUND_LIGHT_BREATH_SPEED
	main._update_background_light()
	assert(main.main_light.light_energy <= 2.0)
	assert(main.main_light.light_energy < first_energy)
	main.main_light.free()

	main.free()
	print("tunnel wire brightness verification passed")
	quit()


func _luminance(color: Color) -> float:
	return color.r * 0.2126 + color.g * 0.7152 + color.b * 0.0722
