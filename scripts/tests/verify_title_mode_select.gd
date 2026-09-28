extends SceneTree

const MainUtil := preload("res://scripts/prototype/main.gd")


func _init() -> void:
	var main := MainUtil.new()
	root.add_child(main)
	await process_frame

	assert(main.title_menu_buttons.size() == 5)
	assert(main.title_mode_index == 0)
	assert(not main.title_void_revealed)
	assert(main.title_menu_buttons[3].visible)
	assert(not main.title_menu_buttons[4].visible)
	assert(not main.player.visible)
	assert(main.title_hi_score.digits == "000000000")
	assert(InputMap.has_action("toggle_fullscreen"))
	assert(InputMap.action_get_events("toggle_fullscreen").size() > 0)
	assert(main._debug_shortcuts_enabled() == OS.is_debug_build())
	main._block_title_accept_for_fullscreen()
	Input.action_press("fire")
	main._update_title()
	assert(not main.game_state.game_started)
	Input.action_release("fire")
	main._update_title()
	assert(not main.game_state.game_started)

	main._select_title_mode(3)
	main._move_title_selection(1)
	assert(main.title_mode_index == 4)
	assert(main.title_void_revealed)
	for index in range(4):
		assert(not main.title_menu_buttons[index].visible)
	assert(main.title_menu_buttons[4].visible)
	main.gum_controller._input_buffer_timer = 0.0
	assert(main._handle_web_pointer_state("pointerdown", 2, 3))
	assert(main.gum_controller._input_buffer_timer == main.gum_controller.INPUT_BUFFER_TIME)
	assert(not main._handle_web_pointer_state("pointermove", 0, 3))
	assert(not main._handle_web_pointer_state("pointerup", 2, 1))
	assert(not main.web_right_mouse_down)
	main._move_title_selection(-1)
	assert(main.title_mode_index == 3)
	assert(not main.title_void_revealed)
	assert(main.title_menu_buttons[3].visible)
	assert(not main.title_menu_buttons[4].visible)

	main._move_title_selection(1)
	main._start_selected_mode()
	assert(main.game_state.game_started)
	assert(main.game_state.game_mode == "endless")
	assert(main.game_state.endless_difficulty == 4)
	main._return_to_title()

	main._select_title_mode(2)
	assert(main.title_mode_index == 2)
	main._start_selected_mode()
	assert(main.game_state.game_started)
	assert(main.game_state.game_mode == "endless")
	assert(main.game_state.endless_difficulty == 2)
	main.game_state.debug_add_score(123456.0)

	main._return_to_title()
	assert(not main.game_state.game_started)
	assert(main.title_mode_index == 0)
	assert(main.title_layer.visible)
	assert(main.title_hi_score.digits == "000123456")

	main.queue_free()
	await process_frame
	await process_frame
	print("title mode select verification passed")
	quit()
