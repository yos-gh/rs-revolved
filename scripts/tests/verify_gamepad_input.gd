extends SceneTree

const MainUtil := preload("res://scripts/prototype/main.gd")
const PlayerUtil := preload("res://scripts/game/player.gd")


func _init() -> void:
	var main := MainUtil.new()
	main._setup_gamepad_input()

	_assert_joy_button("move_left", JOY_BUTTON_DPAD_LEFT)
	_assert_joy_button("move_right", JOY_BUTTON_DPAD_RIGHT)
	_assert_joy_button("fire", JOY_BUTTON_LEFT_SHOULDER)
	_assert_joy_button("gum", JOY_BUTTON_RIGHT_SHOULDER)
	_assert_joy_button("gamepad_accept", JOY_BUTTON_A)
	_assert_joy_button("gamepad_accept", JOY_BUTTON_START)
	_assert_joy_button("gamepad_back", JOY_BUTTON_B)
	_assert_joy_button("gamepad_back", JOY_BUTTON_BACK)
	_assert_joy_axis("move_left", JOY_AXIS_LEFT_X, -1.0)
	_assert_joy_axis("move_down", JOY_AXIS_LEFT_Y, 1.0)
	_assert_joy_axis("fire", JOY_AXIS_TRIGGER_LEFT, 1.0)
	_assert_joy_axis("gum", JOY_AXIS_TRIGGER_RIGHT, 1.0)

	var joy_event := InputEventJoypadButton.new()
	joy_event.device = 2
	joy_event.button_index = JOY_BUTTON_A
	joy_event.pressed = true
	main._input(joy_event)
	assert(main.input_mode == MainUtil.InputMode.GAMEPAD)
	assert(main.active_joypad_device == 2)

	var mouse_event := InputEventMouseButton.new()
	mouse_event.button_index = MOUSE_BUTTON_LEFT
	mouse_event.pressed = true
	main._input(mouse_event)
	assert(main.input_mode == MainUtil.InputMode.KEYBOARD_MOUSE)
	assert(main._desired_mouse_mode(false) == Input.MOUSE_MODE_VISIBLE)
	assert(main._desired_mouse_mode(true) == Input.MOUSE_MODE_CONFINED)

	main.input_mode = MainUtil.InputMode.GAMEPAD
	assert(main._desired_mouse_mode(false) == Input.MOUSE_MODE_HIDDEN)
	assert(main._desired_mouse_mode(true) == Input.MOUSE_MODE_CONFINED_HIDDEN)
	main.app_has_focus = false
	assert(main._desired_mouse_mode(false) == Input.MOUSE_MODE_VISIBLE)
	assert(main._desired_mouse_mode(true) == Input.MOUSE_MODE_VISIBLE)
	main.app_has_focus = true

	var player := PlayerUtil.new()
	player.pos = Vector2(2.0, -1.0)
	player.update_aim_direction(Vector2(0.0, -1.0))
	assert(is_equal_approx(player.angle, -PI * 0.5))
	assert(player.aim_pos.is_equal_approx(Vector2(2.0, -5.0)))
	player.update_aim_direction(Vector2.ZERO)
	assert(is_equal_approx(player.angle, -PI * 0.5))
	assert(main._gamepad_aim_point(Vector2.ZERO, Vector2.RIGHT).is_equal_approx(Vector2(12.0, 0.0)))
	assert(main._gamepad_aim_point(Vector2.ZERO, Vector2.DOWN).is_equal_approx(Vector2(0.0, 6.75)))

	main.free()
	player.free()
	print("gamepad input verification passed")
	quit()


func _assert_joy_button(action: StringName, button: JoyButton) -> void:
	for event in InputMap.action_get_events(action):
		if event is InputEventJoypadButton and event.button_index == button:
			return
	assert(false, "%s is missing joy button %d" % [action, button])


func _assert_joy_axis(action: StringName, axis: JoyAxis, axis_value: float) -> void:
	for event in InputMap.action_get_events(action):
		if event is InputEventJoypadMotion and event.axis == axis and is_equal_approx(event.axis_value, axis_value):
			return
	assert(false, "%s is missing joy axis %d/%s" % [action, axis, axis_value])
