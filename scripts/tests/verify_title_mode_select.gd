extends SceneTree

const MainUtil := preload("res://scripts/prototype/main.gd")


func _init() -> void:
	var menu_svg := FileAccess.get_file_as_string("res://assets/ui/original_svg/menu.svg")
	assert(not menu_svg.contains("#000000"))
	assert(not menu_svg.contains("#ffffff"))

	var main := MainUtil.new()
	root.add_child(main)
	await process_frame

	assert(main.title_menu_buttons.size() == 5)
	assert(main.title_mode_index == 0)
	assert(not main.title_void_revealed)
	assert(main.title_menu_buttons[0].icon is AtlasTexture)
	assert((main.title_menu_buttons[0].icon as AtlasTexture).atlas.get_width() == 1360)
	assert((main.title_menu_buttons[0].icon as AtlasTexture).atlas.get_height() == 412)
	assert((main.title_menu_buttons[0].icon as AtlasTexture).region == Rect2(0, 0, 1360, 56))
	assert((main.title_menu_buttons[3].icon as AtlasTexture).region == Rect2(0, 168, 1360, 56))
	assert((main.title_menu_buttons[3].icon as AtlasTexture).filter_clip)
	assert((main.title_menu_buttons[4].icon as AtlasTexture).region == Rect2(16, 336, 1328, 56))
	assert(main.title_menu_buttons[0].expand_icon)
	assert(main.title_menu_buttons[0].visible)
	assert(main.title_menu_buttons[3].visible)
	assert(not main.title_menu_buttons[4].visible)
	assert(main.title_menu_buttons[3].get_signal_connection_list("mouse_entered").is_empty())
	assert(is_equal_approx(main.title_menu_buttons[0].modulate.a, 1.0))
	assert(is_equal_approx(main.title_menu_buttons[1].modulate.a, 0.18))
	var title_logo := main.title_layer.find_child("TitleLogo", true, false) as TextureRect
	assert(title_logo != null)
	assert(title_logo.texture.get_width() == 2560)
	assert(title_logo.texture.get_height() == 256)
	assert(title_logo.texture_filter == CanvasItem.TEXTURE_FILTER_LINEAR)
	assert(is_equal_approx(main.title_band.anchor_right, main.TITLE_DIVIDER_RATIO))
	assert(not main.player.visible)
	assert(main.title_hi_score.digits == "000000000")
	assert(is_equal_approx(main.title_hi_score.anchor_left, 0.625))
	assert(is_equal_approx(main.title_hi_score.anchor_top, 0.925))
	var fullscreen_button := main.title_layer.find_child("FullscreenButton", true, false) as Button
	assert(fullscreen_button != null)
	assert(fullscreen_button.icon is ImageTexture)
	assert(InputMap.has_action("toggle_fullscreen"))
	assert(InputMap.action_get_events("toggle_fullscreen").size() > 0)
	assert(main._debug_shortcuts_enabled() == OS.is_debug_build())

	main._select_title_mode(3)
	main._move_title_selection(1)
	assert(main.title_mode_index == 4)
	assert(main.title_void_revealed)
	for index in range(4):
		assert(not main.title_menu_buttons[index].visible)
	assert(main.title_menu_buttons[4].visible)
	assert(is_equal_approx(main.title_menu_buttons[4].modulate.a, 0.34))
	main._update_title_void_noise(1.0)
	assert(main.title_menu_buttons[4].modulate.a >= 0.16)
	assert(main.title_menu_buttons[4].modulate.a <= 0.68)
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
	assert(is_equal_approx(main.title_menu_buttons[2].modulate.a, 1.0))
	assert(main.title_shade.color.b > main.title_shade.color.r)
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
